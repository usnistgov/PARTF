function [a0P,a1P,thetaP] = C37PmuIterharmonicAng60(...
    Fi,...
    theta0,...
    PhaseID...
        )
%         phase A
if Fi < 17.3
    k1A = -6.7e-4;
    b1A = 0.013931;
elseif Fi >= 17.3 && Fi < 23.7
    k1A = -1.7e-4;
    b1A = 5.254e-3;
elseif Fi >= 23.7 && Fi < 26.9
    k1A = 1.814e-3;
    b1A = -4.177e-2;
elseif Fi >= 26.9 && Fi < 29.9
    k1A = 5.99e-4;
    b1A = -9.26e-3;
elseif Fi == 30
    k1A = 0;
    b1A = 0;
elseif Fi == 90
    k1A = 0;
    b1A = 0.8857;
elseif Fi > 90 && Fi < 96.3
    k1A = -1.2e-3;
    b1A = -1.18288e-1;
elseif Fi >= 96.3 && Fi < 120
    k1A = 1.59e-4;
    b1A = -1.227e-2;        
end
%         phase B and C
if Fi < 23.7
    k1B = 3.41e-5;
    b1B = 5.443e-3;
elseif Fi >= 23.7 && Fi < 26.9
    k1B = -4.6e-4;
    b1B = 1.7037e-2;
elseif Fi >= 26.9 && Fi <= 30
    k1B = 2.566e-3;
    b1B = -6.38e-2;
elseif Fi >= 90 && Fi < 93.1
    k1B = -2.54e-3;
    b1B = 2.41046e-1;
elseif Fi >= 93.1 && Fi < 120
    k1B = 1.66e-5;
    b1B = 3.228e-3;        
end

if Fi == 10 || 23.7 || 96.3
    theta2PA = pi/2;
else
    theta2PA = -pi/2;
end

if Fi < 17.3
    k2B = 0.32930;
    b2B = -2.96747;
elseif Fi >= 17.3 && Fi < 23.7
    k2B = -0.54059;
    b2B = 12.08162;
elseif Fi >= 23.7 && Fi < 26.9
    k2B = 1.17368;
    b2B = -28.54640;
elseif Fi >= 26.9 && Fi < 30
    k2B = -0.20185;
    b2B = 8.40331;
elseif Fi == 30
    k2B = 0;
    b2B = pi;
elseif Fi == 90
    k2B = 0;
    b2B = 0;
elseif Fi >= 90.1 && Fi < 93.1
    k2B = 0.09116;
    b2B = -7.82278;
elseif Fi >= 93.1 && Fi < 96.3
    k2B = -1.16423;
    b2B = 109.08085;
elseif Fi >= 96.3 && Fi < 102.7
    k2B = 0.47308;
    b2B = -48.59210;  
elseif Fi >= 102.7 && Fi < 120
    k2B = -0.01923;
    b2B = 1.96807;
end

switch PhaseID
    case 0
        k1P = k1A;
        b1P = b1A;
        thetaP = theta2PA;
        a0P = 0;
    case -1
        k1P = k1B;
        b1P = b1B;
        thetaP = k2B*Fi + b2B;
        a0P = -0.2194;
    case 1
        k1P = k1B;
        b1P = b1B;
        thetaP = pi - k2B*Fi - b2B;
        a0P = 0.2194;
end
a1P = k1P*Fi+b1P;
