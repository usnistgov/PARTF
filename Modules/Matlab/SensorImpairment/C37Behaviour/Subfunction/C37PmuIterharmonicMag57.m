function [a0M,a1M,ferr,theta1M,a2M,theta2M,a3M,theta3M] = C37PmuIterharmonicMag57(...
    Xm,...
    Fi,...
    theta0,...
    F0,...
    Fin,...
    PhaseID,...
    MagFreqRes...
        )

a1M = 0.03163*Xm/70*sin(2*pi/11.6*(Fin-56.7));
a0M = Xm*(MagFreqRes-1);
ferr = 2*(F0 - Fin);
theta1M = -2*theta0;

if Fi < 17.3
    k2M = -2.737e-4;
    b2M = 1.033e-2;
elseif Fi >= 17.3 && Fi < 23.7
    k2M = -7.307e-5;
    b2M = 6.855e-3;
elseif Fi >= 23.7 && Fi < 30
    k2M = 1.603e-3;
    b2M = -3.414e-2;
elseif Fi == 30
    k2M = 0;
    switch PhaseID
        case 0
            b2M = 1.896e-2;
        case 1
            b2M = 1.3072e-2;
        case -1
            b2M = 1.3072e-2;
    end
elseif Fi == 90
    k2M = 0;
    b2M = 1.691e-2;
elseif Fi > 90 && Fi < 93.1
    k2M = -2.710e-3;
    b2M = 2.588e-1;
elseif Fi >= 93.1 && Fi < 96.3
    k2M = -4.562e-4;
    b2M = 4.905e-2;
elseif Fi >= 96.3 && Fi < 120
    k2M = 8.286e-5;
    b2M = -2.882e-3;        
end
a2M = k2M*Fi + b2M;

if Fi == 10 || 23.7 || 96.3
    theta2MA = pi;
else
    theta2MA = 0;
end

% theta2MB

% theta2M

 if Fi < 23.7
    k3M = 1.779e-4;
    b3M = -4.745e-4;
elseif Fi >= 23.7 && Fi < 28.5
    k3M = -4.296e-4;
    b3M = 1.376e-2;
elseif Fi >= 28.5 && Fi < 30
    k3M = 1.601e-3;
    b3M = -4.391e-2;
elseif Fi == 30 || Fi ==90
    k3M = 0;
    b3M = 0;
elseif Fi > 90 && Fi < 91.5
    k3M = -1.239e-3;
    b3M = 1.135e-1;
elseif Fi >= 91.5 && Fi < 93.1
    k3M = 1.102e-3;
    b3M = -1.008e-1;
 elseif Fi >= 93.1 && Fi < 102.7
    k3M = 1.281e-4;
    b3M = 1.373e-2; 
elseif Fi >= 102.7 && Fi < 120
    k3M = 1.804e-5;
    b3M = -1.257e-3;        
end
a3M = k3M*Fi + b3M;

if Fi == 23.7 || 26.9 || 93.1 || 96.3 || 115.5
    theta3MA = 0;
else
    theta3MA = pi;
end

% theta3MB

% theta3M