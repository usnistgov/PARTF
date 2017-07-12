function [a0P,a1P,ferr,theta1P,a2P,theta2P,a3P,theta3P] = C37PmuIterharmonicAng57(...
    Fi,...
    theta0,...
    F0,...
    Fin,...
    PhaseID,...
    MagFreqRes...
        )

a1P = 0.02589*sin(2*pi/11.6*(Fin-56.7));
a0P = 0;
ferr = 2*(F0 - Fin);
theta1P = -2*theta0-pi/2;

if Fi < 17.3
    k2P = -2.241e-4;
    b2P = 8.453e-3;
elseif Fi >= 17.3 && Fi < 23.7
    k2P = -5.977e-5;
    b2P = 5.611e-3;
elseif Fi >= 23.7 && Fi < 30
    k2P = 1.312e-3;
    b2P = -2.795e-2;
elseif Fi == 30
    k2P = 0;
    switch PhaseID
        case 0
            b2P = 1.552e-2;
        case 1
            b2P = 1.070e-2;
        case -1
            b2P = 1.070e-2;
    end
elseif Fi == 90
    k2P = 0;
    b2P = 1.385e-2;
elseif Fi > 90 && Fi < 93.1
    k2P = -2.218e-3;
    b2P = 2.119e-1;
elseif Fi >= 93.1 && Fi < 96.3
    k2P = -3.732e-4;
    b2P = 4.013e-2;
elseif Fi >= 96.3 && Fi < 120
    k2P = 3.769e-5;
    b2P = -2.344e-3;        
end
a2P = k2P*Fi + b2P;

if Fi == 10 || 23.7 || 96.3
    theta2PA = pi/2;
else
    theta2PA = -pi/2;
end

% theta2PB

% theta2P

 if Fi < 23.7
    k3M = 1.456e-4;
    b3M = -3.886e-4;
elseif Fi >= 23.7 && Fi < 28.5
    k3M = -3.519e-4;
    b3M = 1.127e-2;
elseif Fi >= 28.5 && Fi < 30
    k3M = 1.312e-3;
    b3M = -3.598e-2;
elseif Fi == 30 || Fi ==90
    k3M = 0;
    b3M = 0;
elseif Fi > 90 && Fi < 91.5
    k3M = -1.015e-3;
    b3M = 9.300e-2;
elseif Fi >= 91.5 && Fi < 93.1
    k3M = 9.034e-4;
    b3M = -8.260e-2;
 elseif Fi >= 93.1 && Fi < 102.7
    k3M = 1.049e-4;
    b3M = 1.124e-2; 
elseif Fi >= 102.7 && Fi < 120
    k3M = 1.477e-5;
    b3M = -1.030e-3;        
end
a3P = k3M*Fi + b3M;

if Fi == 23.7 || 26.9 || 93.1 || 96.3 || 115.5
    theta3PA = pi/2;
else
    theta3PA = -pi/2;
end

% theta3PB

% theta3P