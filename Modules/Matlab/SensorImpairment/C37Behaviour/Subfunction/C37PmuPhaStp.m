function [MagErrPhaStp,AngErrPhaStp,FreqErrPhaStp,ROCOFErrPhaStp] = C37PmuPhaStp(...
    KaS,...
    Xm,...
    N,...
    theta0,...
    FSamp,...
    Fin,...
    PhaseID,...
    t,...
    MagFreqRes)



MagErrPhaStp = 0; AngErrPhaStp = 0; FreqErrPhaStp = 0; ROCOFErrPhaStp = 0;

if KaS > 0
% the step occurs at t = 0 it only affects samples within the filter window
    if abs(t) < (N/2)/FSamp 

%         % magnitude error
%         MagErrPhaStp = a0M+a1M*cos(2*pi*Fx*t+thetaM1);
%         
%         % phaes angle error
%         if t < N/FSamp
%             y = 0;
%             for i = 1:250
%                 y = y + 1/(2*i)*sin(2*pi*2*i/16*t);
%             end
%             AngPhaStp = KaS*(2/pi*MagFreqRes*y+0.5)+theta0;
%             AngErrPhaStp = AngPhaStp - (KaS+theta0);
%         else
%             a1P = 0.02589*sin(2*pi/11.6*(Fin-56.7));
%             a2P = 0;
%             thetaP = -2*theta0-pi/2;
%             AngErrPhaStp = a1P*cos(2*pi*ferr*t+thetaP)+a2P;    % degree
%         end
%         
        % Frequency error
        dFr = 13;
        iFs = 960;
        N = 96;
        sWindowType = 'Hamming';
        
        Bn = FIR(N,dFr,iFs);
        Wn = Window(N,sWindowType).';
        
        if t < N/FSamp
            FreqErrPhaStp = Bn.*Wn/1.1-0.00225;
        else
            FreqErrPhaStp = 0;
        end
        
        % ROCOF error
        if t < N/FSamp
%             k = t/FSamp;
%             dy(k) = 0.54*(cos(c*n)/n-sin(c*n)/(c*n^2)) - 0.46*(cos(c*n)/n-sin(c*n)/(c*n^2))*cos(2*pi*n/N+pi)+0.46*sin(c*n)/(c*n)*(2*pi/N)*sin(2*pi*n/N+pi);
%             ROCOFErrPhaStp = 600/1.1*dy(k);
        else
            ROCOFErrPhaStp = 0;
        end
    end
end

