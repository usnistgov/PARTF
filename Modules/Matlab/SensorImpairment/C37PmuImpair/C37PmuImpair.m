function [ImpTimestamp,...
          ImpSynx,...
          ImpFreq,...
          ImpROCOF] = C37PmuImpair ( ...
                        EvtTimestamp, ...
                        Signal, ...
                        bPosSeq, ...
                        ImpParams, ...
                        WindowType, ...
                        T0, ...
                        F0, ...
                        Fs, ...
                        FSamp ...
                      )  
                     
% Overview this implements a PMU model in the style of the C37.118.1 Annex
% Signal Processing model in that it uses a quadrature demodulator to
% perform the DFT yeilding an unfiltered difference and sum signal.  It
% then filters the DFT signal using parametrizable FilterTypes.  finally it
% decimates the signal down to the PMU reporting rate.

% ImpParams
Fr = ImpParams(1,1);        % Filter cutoff frequency
N = ImpParams(2,1);         % Filter order (there will be one more sample than the order number)

% Check for some common errors
if (FSamp/Fs)-floor(FSamp/Fs) ~= 0
    errMsg = sprintf('Error: Sample Rate: %d Hz must be an interger multiple of Reporting rate: %d FPS', ...
                       FSamp, Fs);
    error(errMsg)
    % error('Error: Sample Rate: %d Hz must be an interger multiple of Reporting rate: %d FPS', ...
    %                   FSamp, Fs)
else
    if length(Signal(:,1)) < 2*(N+1)
        errMsg = sprintf('Error: Event Signal length: %d must be greater than two filter windows: %d', ...
                    length(Signal(:,1)), ...
                    2 * (N+1) );
        error(errMsg)

        %error ('Error: Event Signal length: %d must be greater than two filter windows: %d', ...
        %            length(Signal(1,:)), ...
        %            2 * (N+1) )
    else
        % number of phases      
        Nphases = length(Signal(1,:));
        
        % From EvtTimestamp and T0 plus the filter group delay,
        % calculate time vector, add (negative) time at the beginning for the
        % filter step response
        
        % There will be 2 filter order periods of additional samples at the beginning and
        % at the end of the Signal.
        tStart = (EvtTimestamp - T0) - ((2*N)/FSamp);
        tEnd = tStart + (length(Signal(:,1))/FSamp);
        t = (tStart:1/FSamp:tEnd);
        t = (t(1:end-1)).';
       
        % get the filter coefficients
        Bn = FIR(N,Fr,FSamp);               % unnormalized coefficients
        Wn = Window(N,WindowType);
        Bn = Bn.*Wn;
        Bn = Bn./sum(Bn);                   % normalized coefficients
        
        % DFT
        DFT = zeros(length(t),Nphases);
        PosSeq = zeros(length(t),floor(Nphases/3)); % one PosSeq per 3 phases
        for i = 1:Nphases
            DFT(:,i) = sqrt(2) .* Signal(:,i) .* exp(-1i * (2*pi*F0) .* t);
        end      
        
        % filter the DFT
        for i = 1:Nphases
            DFT(:,i) = filter(Bn,1,real(DFT(:,i))) + 1i*filter(Bn,1,imag(DFT(:,i)));
        end
        
        
        %------------------------------------------------------------------
        % Positive Sequence
        for i = 1:floor(Nphases/3)
          phases3 = DFT(:,(((i-1)*3)+1):(((i-1)*3)+3)); 
          PosSeq(:,i) = calcPosSeq(phases3).';
        end
        
     
        % decimate  
        filterDelay = (2*N)+(N/2);  % The center of the next window after the start        
        Nsynx = floor((length(t)- (4*N))/(FSamp/Fs))+1; % number of synchrophasor reports
        
        ImpSynx = zeros(Nsynx,Nphases);
        ImpPosSeq = zeros(Nsynx,floor(Nphases/3));
        ImpFreq = zeros(Nsynx,1);
        ImpROCOF = ImpFreq;
        ImpTimestamp = ImpFreq;
        
        for j = 1:Nphases  % decimation loop per phase
            i = 1;
            for k =filterDelay+1:FSamp/Fs:(Nsynx*FSamp/Fs)+filterDelay % loop per timestamp
                ImpSynx(i,j) = DFT(k,j);
                ImpPosSeq(i,:) = PosSeq(k,:);
                % timestamp
                ImpTimestamp(i) = t(k-(N/2)) + T0;
                
                % Frequency
                if j == 1       %only get frequency once
                    % Frequency
                    argA = angle(PosSeq((k+1),1));
                    argC = angle(PosSeq((k-1),1));
                    Darg =  argA - argC;
                    if Darg < - pi;
                        argA = argA  + (2*pi);
                    else
                        if Darg > pi
                            argA = argA - (2*pi);
                        end
                    end
                    Darg = argA - argC;
                    ImpFreq(i) = F0 + (Darg /(4*pi*(1/FSamp)));
                    
                    %ROCOF
                    argB = angle(PosSeq((k),1));
                    Sarg = argA + argC;
                    
                    Darg = Sarg - (2*argB);
                    if Darg < -pi
                        argB = argB - (2*pi);
                    else
                        if Darg > pi
                            argB = argB + (2*pi);
                        end
                    end
                    Darg = Sarg - (2*argB);
                    ImpROCOF(i) = Darg /(2*pi*((1/FSamp)^2));
                    
                end %if
                i = i+1;
            end
        end
        
        if (bPosSeq)
        % insert the positive sequence behind each set of 3 phasors 
        tempZero = zeros(Nsynx,1);
            for i = 1:floor(Nphases/3)
                insPos = ((i-1)*3)+3+i;
                temp = ImpSynx(:,insPos:end);
                ImpSynx = cat(2, ImpSynx,tempZero);
                ImpSynx(:,insPos) = ImpPosSeq(:,i);
                ImpSynx(:,insPos+1:end) = temp; 
            end
        end    
    end % error check
end % error check
%hold off
ImpTimestamp = ImpTimestamp.';  % Transpose when using Matlab script node, do not transpose when using Labview MathScript
ImpFreq = ImpFreq.';	       % Transpose when using Matlab script node, do not transpose when using Labview MathScript
ImpROCOF = ImpROCOF.';	       % Transpose when using Matlab script node, do not transpose when using Labview MathScript
end %function

