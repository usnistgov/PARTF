    % the nested funtion that gets the residues
    function [phi,amp,magopt,phaopt,ampopt,phiopt]=get_residues(qcon,dmodes,mretr,xsig,sigcon,nnfit,pha,mag,wrnflg)
        % ==============================================================
        % technically, this part of the code calculates DMODES choose QCON,
        % but I still need to figure out their algorithm, and to see when
        % it might turn out that the error 105 is activated
        icount = 1;
        iq = qcon;
        if iq > dmodes/2,
            iq = dmodes - qcon;
        end
        % 
        for test_i = 0:(iq - 1),
            icount = fix(icount * (dmodes - test_i) / (test_i + 1));
            if icount < 1,
                %mretr_key = mretr.get_key(105);
                return
            end
        end
        % ==============================================================
        % setting the initial binary array indicating the position of the desired
        % modes; later, different combinations will be used
        ic(1:qcon) = 1;
        ic((qcon + 1):dmodes) = 0;
        % gotta find a name for this one
        dminerr = 0;
        y = xsig.^2;
        for sig = 1:sigcon,
            dminerr = dminerr + sum(y(1:nnfit(sig), sig));
        end
        
        for ind = 1:icount,
            % select the desired modes out the total possible modes, and
            % also change the desired modes from polar coordinates to cartesian
            % coordinates
            dmodes_x = mag(ic == 1).*cos(pha(ic == 1));
            dmodes_y = mag(ic == 1).*sin(pha(ic == 1));
            % complex_tol - selects which modes are considered to be real,
            % and which are going to be considered complex
            complex_tol = 1e-12;
            dmodes_y(dmodes_y < complex_tol) = 0;
            vdm_degree = length(dmodes_x); % the degree of the "Van Der Monde" complex system; it will change once we switch
                                           % to the real Van Der Monde
                                           % matrix similar to the FORTRAN
                                           % code
            derr = 0;
            ic_opt = ic;
            icount_opt = icount;
            for sig = 1:sigcon,
                % construct the "Van Der Monde" matrix
                vdm_mat = ones(nnfit(sig), vdm_degree); % complex Van Der Monde matrix
                vdm_mat_r = ones(nnfit(sig), 2*vdm_degree); % real Van Der Monde matrix, initialized with a number of columns twice as the complex one,
                                                            % assuming all modes are complex. Will extract only the needed elements at the end.
                for j_ind = 1:nnfit(sig),
                    vdm_mat(j_ind, :) = complex(dmodes_x, dmodes_y).^(j_ind - 1);
                end
                
                % the following code was introduced in an attempt to
                % duplicate the way they construct the Van Der Monde matrix
                % in initial code, until I realized that the problem was
                % the fact that I forgot to square when I was calculating
                % derr
                cur_ind = 1;
                for m_ind = 1 : size(vdm_mat, 2),
                    if isreal(vdm_mat(2, m_ind)), % on second row of vdm_mat, we have the modes at power 1, which we test to see whether they are real or not
                        vdm_mat_r(:, cur_ind) = vdm_mat(:, m_ind);
                        if any(abs(vdm_mat_r(:, cur_ind)) > 1e+30),
                            %wrnflg_vect = (wrnflg.num_key == wrnflg.get_key(6));
                        end
                        cur_ind = cur_ind + 1;
                    else,
                        vdm_mat_r(:, [cur_ind, cur_ind + 1]) = [real(vdm_mat(:, m_ind)), imag(vdm_mat(:, m_ind))];
                        if any(any(abs(vdm_mat_r(:, [cur_ind, cur_ind + 1])) > 1e+30)),
                            %wrnflg_vect = (wrnflg.num_key == wrnflg.get_key(6));
                        end
                        cur_ind = cur_ind + 2;
                    end
                end
                vdm_mat_r = vdm_mat_r(:, 1:(cur_ind - 1));
                    if size(vdm_mat_r, 1) >= size(vdm_mat_r, 2),
                        % Using QR factorization
                        [Q_vdm, R_vdm] = qr(vdm_mat_r);
                        Q1_vdm = Q_vdm(:, 1:size(vdm_mat_r, 2));
                        Q2_vdm = Q_vdm(:, (size(vdm_mat_r, 2) + 1):end);
                        R1_vdm = R_vdm(1:size(vdm_mat_r, 2), :);
                        R2_vdm = R_vdm((size(vdm_mat_r, 2) + 1):end, :);
                        D_sol = (R1_vdm \ Q1_vdm') * xsig(1:nnfit(sig), sig);
                        RS_sol = Q2_vdm' * xsig(1:nnfit(sig), sig);
                        derr = derr +  sum(abs(RS_sol).^2);
                    else, % system is underdetermined, so no residues
                        % Using QR factorization of the transpose, to get
                        % LQ factorization of initial matrix
                        [QT_vdm, RT_vdm] = qr(vdm_mat_r');
                        QT1_vdm = QT_vdm(:, 1:size(vdm_mat_r', 2));
                        QT2_vdm = QT_vdm(:, (size(vdm_mat_r', 2) + 1):end);
                        RT1_vdm = RT_vdm(1:size(vdm_mat_r', 2), :);
                        RT2_vdm = RT_vdm((size(vdm_mat_r', 2) + 1):end, :);
                        D_sol = (QT1_vdm / RT1_vdm') * xsig(1:nnfit(sig), sig);
                    end
                    %
                    % From the complex amplitudes in D_sol, compute the power
                    % and the initial phase
                    % the index in the solution D_sol is different from the
                    % index in the actual amp and phi matrices
                    sol_ind = 1;
                    for m_ind = 1 : dmodes,
                        if ic(m_ind) == 1,
                            if (abs(mag(m_ind) * sin(pha(m_ind))) < complex_tol), % for the real axis roots
                                phi(m_ind, sig) = 0;
                                amp(m_ind, sig) = D_sol(sol_ind);
                                sol_ind = sol_ind + 1;
                            else, % for the imaginary roots
                                amp(m_ind, sig) = sqrt(D_sol(sol_ind)^2 + D_sol(sol_ind + 1)^2);
                                phi(m_ind, sig) = atan2(-D_sol(sol_ind + 1), D_sol(sol_ind));
                                sol_ind = sol_ind + 2;
                            end
                        end
                    end
                    % 
                    % ===========================================================
            end
            if derr < dminerr,
                dminerr = derr;
                magopt = mag(ic == 1);
                phaopt = pha(ic == 1);
                ampopt = amp(ic == 1, :);
                phiopt = phi(ic == 1, :);
                ic_opt = ic;
                icount_opt = icount;
            end
            ic = combin(dmodes, qcon, ic);
        end
    end