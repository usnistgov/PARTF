function [a0M,a1M,thetaM] = C37PmuIterharmonicMag60(...
    Fi,...
    theta0,...
    PhaseID...
        )
%         phase A
if Fi < 23.7
    k1A = 1.774e-4;
    b1A = 4.820e-3;
elseif Fi >= 23.7 && Fi < 26.9
    k1A = -1.305e-3;
    b1A = 3.969e-2;
elseif Fi >= 26.9 && Fi <= 30
    k1A = 4.645e-3;
    b1A = -1.202e-1;
elseif Fi >= 90 && Fi < 93.1
    k1A = -3.9378e-3;
    b1A = 3.713e-1;
elseif Fi >= 93.1 && Fi < 96.3
    k1A = 5.373e-4;
    b1A = -4.529e-2;
elseif Fi >= 96.3 && Fi < 120
    k1A = -2.952e-5;
    b1A = 9.266e-3;        
end
%         phase B and C
if Fi < 23.7
    k1B = -2.745e-4;
    b1B = 1.056e-2;
elseif Fi >= 23.7 && Fi < 29.9
    k1B = 1.383e-3;
    b1B = -2.871e-2;
elseif Fi >= 29.9 && Fi <= 30
    k1B = -9.673e-2;
    b1B = 2.905;
elseif Fi >= 90 && Fi < 90.1
    k1B = 5.453e-2;
    b1B = -4.9;
elseif Fi >= 90.1 && Fi < 96.3
    k1B = -1.516e-3;
    b1B = 1.499e-1;
elseif Fi >= 96.3 && Fi < 120
    k1B = 1.339e-4;
    b1B = -8.351e-3;        
end

if Fi == 10 || 23.7 || 96.3
    thetaMA = pi;
else
    thetaMA = 0;
end

if Fi < 17.3
    k2B = -0.37642;
    b2B = 5.38157;
elseif Fi >= 17.3 && Fi < 23.7
    k2B = 0.493953;
    b2B = -9.67594;
elseif Fi >= 23.7 && Fi < 26.9
    k2B = -1.32504;
    b2B = 33.43431;
elseif Fi >= 26.9 && Fi < 30
    k2B = 0.12759;
    b2B = -5.60464;
elseif Fi == 30 || Fi == 90
    k2B = 0;
    b2B = -pi;
elseif Fi >= 90.1 && Fi < 93.1
    k2B = -0.14373;
    b2B = 15.17251;
elseif Fi >= 93.1 && Fi < 96.3
    k2B = -0.87181;
    b2B = 82.94253;
elseif Fi >= 96.3 && Fi < 102.7
    k2B = 0.431519;
    b2B = -42.5685;  
elseif Fi >= 102.7 && Fi < 120
    k2B = -0.05031;
    b2B = 6.915536;
end

%         when to consider it as phase A
switch PhaseID
    case 0
        k1M = k1A;
        b1M = b1A;
        thetaM = thetaMA;
    case -1
        k1M = k1B;
        b1M = b1B;
        thetaM = k2B*Fi + b2B;
    case 1
        k1M = k1B;
        b1M = b1B;
        thetaM = -k2B*Fi - b2B;
end
a1M = k1M*Fi+b1M;
a0M = 0.309475*cos(theta0);