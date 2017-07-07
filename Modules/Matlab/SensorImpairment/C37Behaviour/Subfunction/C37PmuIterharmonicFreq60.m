function [a0F,a1F,thetaF] = C37PmuIterharmonicFreq60(...
    Fi,...
    theta0,...
    PhaseID...
        )
%         phase A
if Fi < 23.7
    k1 = -9.40e-5;
    b1 = 2.253e-3;
elseif Fi >= 23.7 && Fi < 26.9
    k1 = 7.95e-4;
    b1 = -1.8749e-2;
elseif Fi >= 26.9 && Fi < 28.5
    k1 = -1.3e-4;
    b1 = 6.133e-3;
elseif Fi >= 28.5 && Fi <= 30
    k1 = 1.6e-4;
    b1 = -2.172e-3;
elseif Fi >= 90 && Fi < 93.1
    k1 = 7.78e-4;
    b1 = -6.8144e-2;
elseif Fi >= 93.1 && Fi < 96.3
    k1 = -1.18e-3;
    b1 = 1.14347e-2;
elseif Fi >= 96.3 && Fi < 102.7
    k1 = -3.86e-5;
    b1 = 4.268e-3; 
elseif Fi >= 102.7 && Fi < 120
    k1 = 1.42e-4;
    b1 = -1.4317e-2;        
end

if Fi == 10 || 23.7 || 30
    thetaF = pi;
elseif Fi > 60
    thetaF = pi;
else
    thetaF = 0;
end

a0F = 0;
a1F = k1*Fi+b1;
