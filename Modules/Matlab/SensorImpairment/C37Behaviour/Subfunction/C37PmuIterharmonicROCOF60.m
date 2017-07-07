function [a0R,a1R,thetaR] = C37PmuIterharmonicROCOF60(...
    Fi,...
    theta0,...
    PhaseID...
        )
%         phase A
if Fi < 23.7
    k1 = 0.0517;
    b1 = -0.2275;
elseif Fi >= 23.7 && Fi < 26.9
    k1 = -0.3000;
    b1 = 8.0855;
elseif Fi >= 26.9 && Fi < 30
    k1 = 0.5400;
    b1 = -14.4841;
elseif Fi == 30 || Fi == 90
    k1 = 0;
    b1 = 0;
elseif Fi > 90 && Fi < 90.7
    k1 = -0.9164;
    b1 = 83.5386;
elseif Fi >= 90.7 && Fi < 91.5
    k1 = 0.1321;
    b1 = -11.5679;
elseif Fi >= 91.5 && Fi < 93.1
    k1 = 1.1610;
    b1 = -105.7068;
elseif Fi >= 93.1 && Fi < 102.7
    k1 = -0.1857;
    b1 = 19.4629; 
elseif Fi >= 102.7 && Fi < 120
    k1 = 0.0858;
    b1 = -8.3161;        
end

if Fi == 10 || 23.7 || 26.7
    thetaR = pi/2;
elseif Fi < 30
    thetaR = -pi/2;
elseif Fi == 30
    thetaR = pi;
elseif Fi == 90 || 90.1 || 90.3 || 90.7 || 102.7
    thetaR = pi/2;
else
    thetaR = -pi/2;
end

a0R = 0;
a1R = k1*Fi+b1;
