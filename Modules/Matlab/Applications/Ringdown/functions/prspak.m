% prspak : A function to conduct Prony analysis.
%  The following problem is solved:
%
%  Consider a sampled signal y(0:N-1) with sample period T.  Prony 
%  analysis is used to fit the function yhat to y using Prony analysis,
%  where
%            QCON
%    yhat(k)=sum AMPOPT(i)*exp(kT*DAMP(i))*cos(FRQRPS(i)*kT+PHIOPT(i))
%            i=1
%  for k=0,1,...,N-1.
% ==========================================================================================
%  INPUT VARIABLES:
%       NNFIT   : Number of data points for fitting.  Must > 3.
% 
%       KNWCON  : If = 0, perform full calculation
%                 If = 1, only calculate residues using the provided
%                 modes.
%                 If = 2, calculate additional poles from data and
%                 calculate residues for both the known poles and the
%                 newly identified poles.
%       LPOCON  : Order of linear prediction. If 0, autocalculated to 
%                 be 11*NNFIT/24.
%       LPMCON  : Linear prediction method. Default is 3.
%                 = 1 Correlation
%                 = 2 Pre-windowed
%                 = 3 Covariance
%                 = 4 Post-windowed.
% 
%       FBCON   : Forward/Backward linear prediction.  Default is 1.
%                 = 1 Forward
%                 = 2 Forward-Backward
%                 = 3 Backward.
%       LPACON  : Linear prediction algorithm. Default is 1.
%                 = 1 SVD with possible rank reduction 
%                 = 2 QR reduction via LAPACK
%                 = 3 Total least squares via SVD
%       PIRCON  : Rank of pseudo-inverse, must be <= LPOCON.
%                 Default is LPOCON.
% 
%    NOTE:  Currently, PIRCON is automatically calculated in 
%           LAPACK routines.
%       QCON    : Number of desired modes.  Default is DMODES, i.e., the 
%                 maximum number possible.
%  In the above input variables, defaults are activated by making the
%  variable zero.
%       KNWMOD  : If KNWCON=1 or KNWCON=2, this is the number of known modes.
%                 If KNWCON is any other number, this is ignored.
%       SIGCON  : Number of signals to be analyzed
%       XSIG    : Data sequence (0...NNFIT-1,1...SIGCON).
%   
%       TSTEP   : Sample period (REAL*8).
%       TRIMRE  : Identified modes with a residue relative magnitude 
%                 greater than TRIMRE are removed from the model.
%       FTRIMH  : Identified modes with an imaginary part greater
%                 than FTRIMH are removed after identifying
%                 residues.
%       FTRIML  : Identified modes with an imaginary part less
%                 than FTRIML are removed after identifying
%                 residues.
%       DAMP    : Provided only if KNWCON<>0.  Vector of the real part of 
%                 continuous-time poles.  (1...KNWMOD) terms.
%       FRQRPS  : Provided only if KNWCON<>0.  Vector of the imaginary part of 
%                 continuous-time poles.  (1...KNWMOD) terms.
% ==========================================================================================
%  OUTPUT VARIABLES:
%       DAMP    : Vector of Identified real part of continueous-time poles.
%                 (1...QCON) terms, QCON may be different from that
%                 in calling due to auto calculations.
%       FRQRPS  : Identified imaginary part of continueous-time poles.
%       AMPOPT  : Matrix of residue amplitudes.  (1...QCON) by (1...SIGCON).
%       PHIOPT  : Matrix of residue angles in radians.  (1...QCON) by (1...SIGCON).
%       DMODES  : Total number of modes identified in the Linear Prediction.
%                 This is also the order of the Vandermonde solution and is
%                 usually around LPOCON/2.
%       WRNFLG  : Vector (1...NFLG) of return warning flags.  
%                 Currently, NFLG=6.  If WRNFLG(I)=1, then the warning 
%                 is activated.
%                 Element 1 : Numerical solution on the linear prediction
%                             SVD may be in error.  
%                 Element 2 : Numerical solution on the linear prediction
%                             QR may be in error.  
%                 Element 3 : Numerical solution on the linear prediction
%                             Total Least Squrares SVD may be in error.
%                 Element 4 : Numerical solution on the root finder may
%                             be in error.
%                 Element 5 : Possible errors in the residue solution due
%                             to large elements in the Vandermonde matrix.
%                 Element 6 : Numerical solution on the vandermonde problem
%                             may be in error.
%       MRETR   : Integer flag for fatal solution.  If not equal to zero,
%                 no solution is calculated.
%                 = 0   no flags.  Solution calculated.
%                 = 100 NNFIT < 3, i.e., too small.
%                 = 110 XSIG is a null signal.
%                 = 102 QCON < 1, i.e., too small.
%                 = 103 LPOCON < 1, i.e., too small.
%                 = 104 TSTEP too small.
%                 = 105 QCON too small.  Try increasing QCON or set
%                   QCON < KNWMOD
% ===============================================================================================
%  INTERNAL VARIABLES:
%       DMATSV  : Vector of singular values
%                 [1,...,LPOCON]
%       A       : Linear prediction polynomial coefficients
%                 [1,...,LPOCON]
%                 A(0)=1.0
%       DMODES  : Total number of modes (usually around LPOCON/2)
%                 [1,...,DMODES]
%       MAG     : Vector of magnitude of the roots of A(z)
%                 [1,...,DMODES]
%       PHA     : Vector of phase of the roots of A(z)
%                 [1,...,DMODES]
%       MAGOPT  : Vector of magnitude of retained roots of A(z).
%                 [1,...,QCON]
%       PHAOPT  : Vector of phase of retained roots of A(z).
%                 [1,...,QCON]
% ==================================================================================================
% **************************************************************************
%
% The following represents the MATLAB translation of the original FORTRAN
% code for the PRSPAK function
% Author of the MATLAB code: Laurentiu Dan Marinovici
% Date: August - September 2013
%
% **************************************************************************

function [damp, frqrps, ampopt, phiopt, dmodes, mretr_key,...
    lpocon, lpmcon, lpacon, fbcon, pircon, knwcon, knwmod, qcon, trimre, ftrimh, ftriml] =... 
    prspak(xsig, sigcon, tstep, nnfit, lpocon, lpmcon, lpacon, fbcon, pircon,...
    knwcon, knwmod, qcon, trimre, ftrimh, ftriml, damp, frqrps)

    
    % global variables
    global wrnflg mretr
    global ntaille nsize nwork nsigs nflgs inpmax mincon
    
    % set some mathematical constants
    % pi already known in MATLAB
    % tolerance for what 0 means
    eps1 = 1e-8;
    % still don't know what this one represents
    p = 0.1;
    
    % setting the flags and the error messages
    % it is different than the original file; it is based on a message dictionary
    % class
    % create the dictionary
    %[mretr, wrnflg] = create_dict;
    % initialize the returned variables
    %wrnflg_vect = zeros(size(wrnflg.num_key, 1), 1);
    mretr_key = 0;
    
    nsigs_act = size(xsig, 2);
    % intialize internal variables
    mag = zeros(nsize, 1);
    pha = zeros(nsize, 1);
    magopt = zeros(nsize, 1);
    phaopt = zeros(nsize, 1);
    amp = zeros(nsize, nsigs_act);
    phi = zeros(nsize, nsigs_act);
    ampopt = zeros(nsize, nsigs_act);
    phiopt = zeros(nsize, nsigs_act);
    
    xsig2 = zeros(size(xsig));
    
    % check values for knwcon and knwmod and take action accordingly
    % convert known modes to Z-domain by getting their corresponding
    % magnitude and phase
    % counting the number of poles
    if (knwcon <= 0 | knwcon > 2) | (knwcon ~= 0 & knwmod < 1),
        knwcon = 0;
    end
    knwpol = 0;
    if knwcon == 0,
        knwmod = 0;
    else,
        mag = exp(-tstep .* damp);
        pha = tstep .* frqrps;
        knwpol = knwmod;
        % Checking the imaginary part of the known poles; if they are above the
        % 0 limit it means we have a pair of known complex conjugate poles, and
        % thus we add an extra pole if we have complex conjugate poles; that is
        % the vertical component is greater than the tolerance eps1
        knwpol_imag = abs(mag .* sin(pha));
        knwpol = fix(knwpol + length(knwpol_imag(knwpol_imag > eps1)));
    end
    
    % Check and set bounds for other control variables, such as the codes
    % for the linear prediction, model, algorithm, backward/forward, or the
    % upper and lower limits for residues and modes magnitude.
    % If lpmcon is outside the correct values, it is set-up to 3 by
    % default, that is, the default linear prediction method is through
    % correlation.
    if lpmcon < 1 | lpmcon > 4,
        lpmcon = 3; 
    end
    % If fbcon is outside the correct values, it is set-up by default to 1,
    % that is forward linear prediction.
    if fbcon < 1 | fbcon > 3,
        fbcon = 1;
    end
    % Linear prediction algorithm is set-up by default to SVD with possible rank
    % reduction.
    if lpacon < 1 | lpacon > 3,
        lpacon = 1;
    end
    % Upper limit for the residue magnitude
    if trimre < 0,
        trimre = 1e-26;
    end
    % Lower limit for the modes' imaginary part
    if ftriml < 0,
        ftriml = 0;
    end
    % Find number of data points in longest column and total number of data
    % points. Subtract knwpol from the number of points in each data column
    % if knwcon = 2.
    % knwpol points are lost in the filtering process.
    nnfit(nnfit > ntaille) = ntaille;
    if knwcon == 2,
        nnfit(:) = nnfit(:) - knwpol;
    end
    if any(nnfit < 3),
        mretr_key = 100;%mretr.get_key(100); % exit with error code 100
        return
    end
    nnfitm = fix(sum(nnfit)); % the total number data points
    if lpmcon == 1,
        n1 = fix(3 * nnfitm / 2 + 2);
    else,
        n1 = fix(nnfitm + 2);
    end
    if fbcon == 2,
        n1 = fix(2 * n1);
    end
    
    if n1 > ntaille,
        if lpmcon == 1,
            nnfit(:) = fix(2 * (ntaille - 2) / (3 * sigcon));
        elseif lpmcon ~= 1,
            nnfit(:) = fix((ntaille - 2) / sigcon);
        end
        if knwcon == 2,
            nnfit(:) = fix(nnfit(:) - knwpol);
        end
        if fbcon == 2,
            nnfit(:) = fix(nnfit(:) ./ 2);
        end
    end
    
    lpomax = fix(max(nnfit(:) / 2));
    mnnfit = fix(max(nnfit));
    if lpomax + knwpol > nsize - 1,
        lpomax = fix(nsize - knwpol - 1);
    end
    if lpocon < 1 | lpocon >= lpomax,
        lpocon = fix(11 * lpomax / 12); % the default value
    end
    if lpocon < 1,
        %mretr_key = mretr.get_key(103); % exit with error message 103
    end
    if tstep < 1e-12,
        %mretr_key = mretr.get_key(104); % exit with error message 104
    end
    if pircon < 1 | pircon > lpocon,
        pircon = lpocon;
    end
    dmodes = knwmod;
    
    % if knwcon = 2 (that is, calculate additional poles from data and then
    % the residues for both the known poles and the newly identified ones
    if knwcon == 2,
        % for the already known modes
        workrv = mag.*cos(pha);
        workrv2 = mag.*sin(pha);
        % just a simple initialization for re_modes and im_modes; they
        % might be changed subsequently
        re_modes = workrv; % the real parts of the known modes
        im_modes = workrv2; % the imaginary parts of the known modes
        % if there are any complex conjugate modes, we need to add the
        % extra one, having the opposite sign for the imaginary part
        cur_ind = 1;
        for ind = 1:length(workrv2),
            if abs(workrv2(ind)) > eps1,
                re_modes(cur_ind:(cur_ind + 1), 1) = [workrv(ind); workrv(ind)];
                im_modes(cur_ind:(cur_ind + 1), 1) = [workrv2(ind); - workrv2(ind)];
                cur_ind = cur_ind + 2;
            else,
                re_modes(cur_ind, 1) = [workrv(ind)];
                im_modes(cur_ind, 1) = [workrv2(ind)];
                cur_ind = cur_ind + 1;
            end
        end
        % the modes written in complex form are:
        complex_modes = complex(re_modes, im_modes);
        % the polynomial having the complex modes as roots; this is the
        % same as the filter's numerator; the denominator for the filter is
        % going to be 1
        poly_modes = poly(complex_modes);
        for ind = 1 : sigcon,
            xsig2_temp = filter(poly_modes, 1, xsig(1:(nnfit(ind) + knwpol), ind));
            xsig2_temp = circshift(xsig2_temp, -knwpol);
            xsig2_temp = xsig2_temp(1:(size(xsig2_temp, 1) - knwpol));
            %xsig2(:, ind) = filter(poly_modes, 1, xsig(1:(nnfit(ind) + knwpol), ind));
            %xsig2(:, ind) = circshift(xsig2(:, ind), -knwpol);
            xsig2(1:length(xsig2_temp), ind) = xsig2_temp;
        end
        %xsig2 = xsig2(1:(size(xsig2, 1) - knwpol), :);
    end
    
    % test for null signal
    if knwcon ~= 2,
        % nnfit
        workr = sum(xsig.^2, 1)./nnfit;
    else,
        % nnfit
        workr = sum(xsig2.^2, 1)./nnfit;
    end
    if any(workr < 1e-12),
        %mretr_key = mretr.get_key(110);
    end
    
    % if KNWCON = 1, only calculate residues with the provided modes
    if knwcon == 1,
        qcon = knwmod;
        [phi,amp,magopt,phaopt,ampopt,phiopt]=get_residues(qcon,dmodes,mretr,xsig,sigcon,nnfit,pha,mag,wrnflg);        
    else,        
        % form least squares Toeplitz system for denominator coefficients
        if knwcon ~= 2,
            [mat, A, n1] = settp(xsig, sigcon, nnfit, lpocon, fbcon, lpmcon);
        else,
            [mat, A, n1] = settp(xsig2, sigcon, nnfit, lpocon, fbcon, lpmcon);
        end

        % Singular Value Decomposition - for the first 2 methods: SVD with
        % possible rank reduction (lpacon = 1), and QR reduction (lpacon = 2)
        [matU, dmatsv, matV] = svd(mat, 0); % get the singular value decomposition, economy size
        dmatsv = diag(dmatsv); % just grab the singular values
        workr = max(size(mat)) * eps;%2.9104e-11; %* eps(max(dmatsv)); % tolerance for singular values
        r = sum(dmatsv > workr); % number of singular values greater then tolerance
        % Least square solution - SVD based algorithm
        if lpacon == 1,
                % solution to mat * x - A = 0; the singular values of mat
                % smaller than max(size(mat)) * eps(largest singular value of
                % mat) are treated as 0 inside the pinv function
                x = pinv(mat)*A;
                A(1:length(x)) = x; % output
                [matU, matSV, matV] = svd(mat);
                pircon = rank(pinv(mat));
                mat = matV; % mat overwritten with its right singular vectors
        end
        % Least square solution - QR based algortithm
        % no QR reduction, though; gotta work on it some more
        if lpacon == 2,
                [matQ, matR, matP] = qr(mat); % QR decomposition with pivoting
                x = linsolve(mat, A);
                A(1:length(x)) = x; % output
                % ================= !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ===========
                % output
                % mat is supposed to be overwritten by its complete orthogonal
                % factorization, but I haven't been able to see how to do the
                % complete orthogonal factorization
                mat = mat * matP ;
                pircon = 1;
                while pircon <= min(size(matR)) & cond(matR(1:pircon, 1:pircon)) < 1/workr,
                    pircon = pircon + 1;
                end
                pircon = pircon - 1;
                matR = [matR(1:pircon, 1:pircon), zeros(pircon, size(matR, 2) - pircon);...
                    zeros(size(matR, 1) - pircon, pircon), zeros(size(matR, 1) - pircon, size(matR, 2) - pircon)];
        end

        % Total least square solution
        if lpacon == 3,
                % augment the A matrix in A*x = b with the elements of b, that
                % is [A, b]*[x', -1]' = 0
                mat(:, end + 1) = A;
                % the singular value decomposition
                % according to the FORTRAN code, need to get all right singular
                % vectors
                [matU, dmatsv, matV] = svd(mat);
                dmatsv = diag(dmatsv);
                % according to the FORTRAN code, in this case, only the
                % transpose of the full right singular vectors are returned;
                % the left singular vectors are not referenced
                v = matV';
                if abs(v(size(mat, 2), size(mat, 2))) < eps1,
                    v(size(mat, 2), size(mat, 2)) = eps1;
                    %wrnflg_vect = (wrnflg.num_key == wrnflg.get_key(3));
                end
                A(1:lpocon) = - v(size(mat, 2), 1:lpocon) / v(size(mat, 2), size(mat, 2));
        end

        % set nnfit back to original value for residue calculation
        nnfit = nnfit + knwpol;

        workr = 10^(30/mnnfit);
        % root denominator polynomial
        % for FORTRAN code the coefficients of the polynomial are supposed to
        % be given in order of increasing power; but for MATLAB roots function,
        % it is actually the opposite

        % the modes, aka roots of the denominator
            new_modes = roots([1; A(1:lpocon)]);
            zeror = real(new_modes);
            zeroi = imag(new_modes);

        % a working vector to hold the value of p = 1% of the absolute value of the
        % known modes in S-plane; this is where p is used
        workrv(1:knwmod) = p .* sqrt(log(mag(1:knwmod)).^2 + pha(1:knwmod).^2);
        % sift out the complex modes in the lower part of the complex plan, that
        % is the ones with negative imaginary part
        zeror_temp = zeror(zeroi >= 0);
        zeroi_temp = zeroi(zeroi >= 0);
        % new modes in a temporary vector, before we test if they are
        % overly large or not
        zero_mag_temp = sqrt(zeror_temp.^2 + zeroi_temp.^2);
        % keep only the zeros with magnitudes below the threshold workr
        zero_pha_temp = abs(atan2(zeroi_temp(zero_mag_temp <= workr), zeror_temp(zero_mag_temp <= workr)));
        zero_pha_temp(zero_pha_temp < eps1) = 0;
        zero_mag_temp = zero_mag_temp(zero_mag_temp <= workr);
        % compare every of the left new modes with the known modes, in case
        % there were any; sift out those new modes that are within 1% of a
        % known mode in the s-plane
        if knwcon == 2,
            for ind = 1:knwmod,
                workr2 = sqrt(log(zero_mag_temp / mag(ind)).^2 + (zero_pha_temp - pha(ind)).^2);
                % only keep the modes greater than 1% of the known mode tested
                zero_mag_temp = zero_mag_temp(workr2 > workrv(ind));
                zero_pha_temp = zero_pha_temp(workr2 > workrv(ind));
            end
        end
        % the number of modes left; at this point, dmodes equals the number of
        % known modes
        mag((dmodes + 1):(dmodes + length(zero_mag_temp))) = zero_mag_temp';
        pha((dmodes + 1):(dmodes + length(zero_mag_temp))) = zero_pha_temp';
        dmodes = dmodes + length(zero_mag_temp); % because we are eliminating modes, and mag and pha need to be trimmed down from nsize
        % redefining mag and pha such that they get the right dimensions,
        % and we eliminate the zeros
        mag = mag(1:dmodes);
        pha = pha(1:dmodes);

        if qcon < knwmod | qcon > dmodes,
            qcon = dmodes;
        end

        if ftrimh < 0,
            ftrimh = 2 * pi / (3 * tstep);
        end
        
        % get the residues by calling the nested fucntion get_residues
        [phi,amp,magopt,phaopt,ampopt,phiopt]=get_residues(qcon,dmodes,mretr,xsig,sigcon,nnfit,pha,mag,wrnflg);
    end
    
    % force all mode amplitudes positive and trim modes between [ftriml,
    % ftrimh] in rad/sec
    ztrimh = ftrimh * tstep;
    if ztrimh <= 0,
        ztrimh = 2 * pi;
    end
    ztriml = ftriml * tstep;
    ampref = 0;

    % Force all mode amplitude to be positive
    phiopt(ampopt < 0) = phiopt(ampopt < 0) + pi;
    ampopt(ampopt < 0) = - ampopt(ampopt < 0);
    
    % Recalculating ampref as the maximum value in ampopt, after all values
    % have been transormed into positive values
    ampref = max(max(ampopt));

    % If some of the modes violate the phase constraints/limits, then they are
    % eliminated (in FORTRAN code this was done my moving the following rows
    % up; in MATLAB, we are just going to keep the values that satisfy the constraints)
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    % Since all the selections are based on phaopt, and the operatins are
    % done in a vector manner, phaopt should be the last one to be updated,
    % after all operations based on its original values are performed.
    % Otherwise trouble may arise.
    magopt = magopt(phaopt >= ztriml & phaopt <= ztrimh);
    ampopt = ampopt((phaopt >= ztriml & phaopt <= ztrimh), :);
    phiopt = phiopt((phaopt >= ztriml & phaopt <= ztrimh), :);
    phaopt = phaopt(phaopt >= ztriml & phaopt <= ztrimh);
    % the number of modes that we are left with is given by
    qcon = length(magopt);
    if qcon <= 0,
        mretr_key = 102;%mretr.get_key(102);
        return
    end

    % Trim weak modes; a weak mode is considered to be one for which
    % ampopt/ampref <= trimre for all signlas in xsig; if at least for one
    % signal that value is geater than trimre than that mode is kept
    if ampref <= 0,
        ampref = 1;
    end
    % any(ampopt/ampref > trimre, 2) gives the rows which have at least one 1,
    % meaning that mode is strong and worth keeping
    magopt = magopt(any(ampopt/ampref > trimre, 2));
    phaopt = phaopt(any(ampopt/ampref > trimre, 2));
    phiopt = phiopt(any(ampopt/ampref > trimre, 2), :);
    ampopt = ampopt(any(ampopt/ampref > trimre, 2), :);
    % the number of modes that we are left with is given by
    qcon = length(magopt);

    if qcon <= 0,
        mretr_key = 103;  
        return
    end

    % Convert z-domain modes to s-domain
    damp = -log(magopt)/tstep;
    frqrps = phaopt/tstep;
    
end