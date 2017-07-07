function [MagErrMagStp,AngErrMagStp,FreqErrMagStp,ROCOFErrMagStp] = C37PmuMagStp(...
    KxS,...
    Xm,...
    N,...
    theta0,...
    FSamp,...
    Fin,...
    PhaseID,...
    t,...
    MagFreqRes)


MagErrMagStp=0;AngErrMagStp=0;FreqErrMagStp=0;ROCOFErrMagStp=0;

if KxS > 0

    
% the step occurs at t = 0 it only affects samples within the filter window
    if abs(t) < (N/2)/FSamp 
        % magnitude error
        if t < N/FSamp
            y = 0;
            for i = 1:250
                y = y + 1/(2*i)*sin(2*pi*2*i/16*t);
            end
            MagMagStp = KxS*Xm*(2/pi*MagFreqRes*y+0.5)+Xm;
            MagErrMagStp = MagMagStp - KxS;
        else
            a1P = 0.03163*Xm/70*sin(2*pi/11.6*(Fin-56.7));
            a2P = Xm*(MagFreqRes-1);
            thetaP = -2*theta0;
            %MagErrMagStp = a1P*cos(2*pi*ferr*t+thetaP)+a2P;    % degree
            MagErrMagStp = a1P*cos(2*pi*Fin*t+thetaP)+a2P;    % degree
        end
    
        % phaes angle error
        dFr = 13.3;
        iFs = 960;
        N = 104;
        sWindowType = 'Hamming';
        
        Bn = FIR(N,dFr,iFs);
        Wn = Window(N,sWindowType).';
        
        if t < N/FSamp
            AngErrMagStp = 0.27*Bn.*Wn;
        else
            AngErrMagStp = 0;
        end
    end
end    
