function [a0F,a1F,ferr,theta1F,a2F,a3F] = C37PmuIterharmonicFreq57(...
    Fi,...
    theta0,...
    F0,...
    Fin,...
    PhaseID,...
    MagFreqRes...
        )

a1F = 0;
a0F = 0;
ferr = 2*(F0 - Fin);
theta1F = 0;    % since a1F = 0, so we don't care the value of this variable 

if Fi < 17.3
    k2F = 1.756e-5;
    b2F = 9.758e-4;
elseif Fi >= 17.3 && Fi < 23.7
    k2F = 1.178e-5;
    b2F = 1.076e-3;
elseif Fi >= 23.7 && Fi < 30
    k2F = 4.331e-4;
    b2F = -9.244e-3;
elseif Fi == 30
    k2F = 0;
    b2F = 2.483e-3;
elseif Fi == 90
    k2F = 0;
    b2F = 1.409e-3;
elseif Fi > 90 && Fi < 93.1
    k2F = -7.448e-4;
    b2F = 7.099e-2;
elseif Fi >= 93.1 && Fi < 96.3
    k2F = -1.488e-4;
    b2F = 1.552e-2;
elseif Fi >= 96.3 && Fi < 120
    k2F = -5.399e-5;
    b2F = 6.425e-3;        
end
a2F = k2F*Fi + b2F;

if Fi < 23.7
    k3M = 7.927e-5;
    b3M = -5.837e-4;
elseif Fi >= 23.7 && Fi < 28.5
    k3M = -1.414e-4;
    b3M = 4.624e-3;
elseif Fi >= 28.5 && Fi < 30
    k3M = 6.316e-4;
    b3M = -1.734e-2;
elseif Fi == 30 || Fi ==90
    k3M = 0;
    b3M = 0;
elseif Fi > 90 && Fi < 91.5
    k3M = -1.684e-3;
    b3M = 1.542e-1;
elseif Fi >= 91.5 && Fi < 93.1
    k3M = 1.630e-3;
    b3M = -1.490e-1;
 elseif Fi >= 93.1 && Fi < 102.7
    k3M = -1.723e-4;
    b3M = 1.874e-2; 
elseif Fi >= 102.7 && Fi < 120
    k3M = 4.444e-5;
    b3M = -3.504e-3;        
end
a3F = k3M*Fi + b3M;
