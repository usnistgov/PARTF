function [MagErrInt,AngErrInt,FreqErrInt,ROCOFErrInt] = C37PmuInterharmonic(...
    Xm, ...
    Fi,...
    theta0,...
    F0,...
    Fin,...
    PhaseID,...
    t,...
    MagFreqRes,...
    Kh ...
    )

MagErrInt = 0;
AngErrInt = 0;
FreqErrInt = 0;
ROCOFErrInt = 0;

if Kh > 0 
    if (Fi >= 10 && Fi <=30) || (Fi >= 90 && Fi < 120)
        if Fin == F0
            [a0M,a1M,thetaM] = C37PmuIterharmonicMag60(Fi,theta0,PhaseID);
            MagErrInt = Xm/70*(a1M*cos(2*pi*Fi*t+thetaM)+a0M);
            
            [a0A,a1A,thetaA] = C37PmuIterharmonicAng60(Fi,theta0,PhaseID);
            AngErrInt = a1A*sin(2*pi*Fi*t+thetaA)+a0A;
            
            [a0F,a1F,thetaF] = C37PmuIterharmonicFreq60(Fi,theta0,PhaseID);
            FreqErrInt = a1F*sin(2*pi*Fi*t+thetaF)+a0F;
            
            [a0R,a1R,thetaR] = C37PmuIterharmonicROCOF60(Fi,theta0,PhaseID);
            ROCOFErrInt = a1R*sin(2*pi*Fi*t+thetaR)+a0R;
            
        elseif Fin == 57
            [a0M,a1M,ferr,theta1M,a2M,theta2M,a3M,theta3M] = ...
                C37PmuIterharmonicMag57(Xm,Fi,theta0,F0,Fin,PhaseID,MagFreqRes);
            
            MagErrInt = Xm/70*(a1M*cos(2*pi*ferr*t+theta1M) + ...
                a2M*cos(2*pi*(Fin-Fi)*t+theta2M) + ...
                a3M*cos(2*pi*(Fin+Fi)*t+theta3M) + ...
                a0M);
            
            [a0A,a1A,ferr,theta1A,a2A,theta2A,a3A,theta3A] = C37PmuIterharmonicAng57(Fi,theta0,F0,Fin,PhaseID,MagFreqRes);
            AngErrInt = a1A*cos(2*pi*ferr*t+theta1A) + ...
                a2A*cos(2*pi*(Fin-Fi)*t+theta2A) + ...
                a3A*cos(2*pi*(Fin+Fi)*t+theta3A) + ...
                a0A;
            
            [a0F,a1F,ferr,theta1F,a2F,theta2F,a3F,theta3F] = C37PmuIterharmonicFreq57(Fi,theta0,F0,Fin,PhaseID,MagFreqRes);
            FreqErrInt = a1F*cos(2*pi*ferr*t+theta1F) + ...
                a2F*cos(2*pi*(Fin-Fi)*t+theta2F) + ...
                a3F*cos(2*pi*(Fin+Fi)*t+theta3F) + ...
                a0F;
            
            [a0R,a1R,ferr,theta1R,a2R,theta2R,a3R,theta3R] = C37PmuIterharmonicROCOF57(Fi,theta0,F0,Fin,PhaseID,MagFreqRes);
            ROCOFErrInt = a1R*cos(2*pi*ferr*t+theta1R) + ...
                a2R*cos(2*pi*(Fin-Fi)*t+theta2R) + ...
                a3R*cos(2*pi*(Fin+Fi)*t+theta3R) + ...
                a0R;
            
        elseif Fin == 63
            [a0M,a1M,ferr,theta1M,a2M,theta2M,a3M,theta3M] = ...
                C37PmuIterharmonicMag57(Fi,theta0,F0,Fin,PhaseID,MagFreqRes);
            
            MagErrInt = Xm/70*(a1M*cos(2*pi*ferr*t+theta1M) + ...
                a2M*cos(2*pi*(Fin-Fi)*t+theta2M) + ...
                a3M*cos(2*pi*(Fin+Fi)*t+theta3M) + ...
                a0M);
            
            [a0A,a1A,ferr,theta1A,a2A,theta2A,a3A,theta3A] = C37PmuIterharmonicAng57(Fi,theta0,F0,Fin,PhaseID,MagFreqRes);
            AngErrInt = a1A*cos(2*pi*ferr*t+theta1A) + ...
                a2A*cos(2*pi*(Fin-Fi)*t+theta2A) + ...
                a3A*cos(2*pi*(Fin+Fi)*t+theta3A) + ...
                a0A;
            
            [a0F,a1F,ferr,theta1F,a2F,theta2F,a3F,theta3F] = C37PmuIterharmonicFreq57(Fi,theta0,F0,Fin,PhaseID,MagFreqRes);
            FreqErrInt = a1F*cos(2*pi*ferr*t+theta1F) + ...
                a2F*cos(2*pi*(Fin-Fi)*t+theta2F) + ...
                a3F*cos(2*pi*(Fin+Fi)*t+theta3F) + ...
                a0F;
            
            [a0R,a1R,ferr,theta1R,a2R,theta2R,a3R,theta3R] = C37PmuIterharmonicROCOF57(Fi,theta0,F0,Fin,PhaseID,MagFreqRes);
            ROCOFErrInt = a1R*cos(2*pi*ferr*t+theta1R) + ...
                a2R*cos(2*pi*(Fin-Fi)*t+theta2R) + ...
                a3R*cos(2*pi*(Fin+Fi)*t+theta3R) + ...
                a0R;
        end
    end
end    