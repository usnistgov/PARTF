function [a0R,a1R,ferr,theta1R,a2R,theta2R,a3R,theta3R] = C37PmuIterharmonicROCOF57(...
    Fi,...
    theta0,...
    F0,...
    Fin,...
    PhaseID,...
    MagFreqRes...
        )

a1R = 0;
a0R = 0;
ferr = 2*(F0 - Fin);
theta1R = 0;

if Fi < 17.3
    k2F = -2.654e-3;
    b2F = 3.614e-1;
elseif Fi >= 17.3 && Fi < 23.7
    k2F = -5.352e-3;
    b2F = 4.080e-1;
elseif Fi >= 23.7 && Fi < 30
    k2F = 6.551e-2;
    b2F = -1.325;
elseif Fi == 30
    k2F = 0;
    b2F = 1.195e-1;
elseif Fi == 90
    k2F = 0;
    b2F = 2.847;
elseif Fi > 90 && Fi < 93.1
    k2F = -1.438e-1;
    b2F = 1.376e1;
elseif Fi >= 93.1 && Fi < 96.3
    k2F = -2.615e-2;
    b2F = 2.809;
elseif Fi >= 96.3 && Fi < 120
    k2F = -1.250e-2;
    b2F = 1.516;        
end
a2R = k2F*Fi + b2F;

if Fi == 10 || 23.7 || 30 || 96.3 || 115.5
    theta2RA = -pi/2;
else
    theta2RA = pi/2;
end

if Fi < 23.7
    k3M = 3.945e-2;
    b3M = -3.155e-1;
elseif Fi >= 23.7 && Fi < 28.5
    k3M = -6.497e-2;
    b3M = 2.156;
elseif Fi >= 28.5 && Fi < 30
    k3M = 3.298e-1;
    b3M = -9.062;
elseif Fi == 30 || Fi ==90
    k3M = 0;
    b3M = 0;
elseif Fi > 90 && Fi < 91.5
    k3M = -1.328;
    b3M = 1.217e2;
elseif Fi >= 91.5 && Fi < 93.1
    k3M = 1.303;
    b3M = -1.192e2;
 elseif Fi >= 93.1 && Fi < 102.7
    k3M = -1.343e-1;
    b3M = 1.467e1; 
elseif Fi >= 102.7 && Fi < 120
    k3M = 4.158e-2;
    b3M = -3.390;        
end
a3R = k3M*Fi + b3M;

if Fi == 23.7 || 26.9 || 93.1 || 96.3 || 115.5
    theta3RA = 0;
else
    theta3RA = pi;
end

if Fi <= 60
    theta3R = theta3RA - pi/2 + pi/2;
else
    theta3R = theta3RA + pi/2 + pi/2;
end
