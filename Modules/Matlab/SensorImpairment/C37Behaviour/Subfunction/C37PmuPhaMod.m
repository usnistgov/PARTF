function [MagErrPhaMod,AngErrPhaMod,FreqErrPhaMod,ROCOFErrPhaMod] = C37PmuPhaMod(...
    Fa,...
    Ka,...
    Xm,...
    theta0,...
    F0,...
    Fin,...
    PhaseID,...
    t,...
    MagFreqRes)

% magnitude error
beta1MA = [0.03064,-1.9554e-6,1.4471e-5,-3.4445e-6,2.5790e-6,-4.8199e-7];
a0MA = polyval(beta1MA,Fa);

beta1MB = [0.015333,6.5888e-5,-9.5856e-5,3.2272e-6,-3.7774e-6];
a0MB = polyval(beta1MB,Fa);

beta1MC = beta1MB;
a0MC = polyval(beta1MC,Fa);

a1MA = 6.1e-4*sin(2*pi/10.8*Fa);
a1MB = 2.6e-3*cos(2*pi/11.5*Fa)+2.7e-3;
a1MC = a1MB;

thetaM1A = 359.9639*Fa+89.7183;
thetaM1B = 356.8198*Fa+1.4156;
thetaM1C = 363.0224*Fa-181.5444;

beta2M = [3.1046e-4,-7.4844e-5,1.5616e-4,-1.9159e-4,5.3465e-5,-9.4319e-7];
a2M = polyval(beta2M,Fa);

thetaM2A = 667.8345*Fa-142.0384;
thetaM2B = 717.0557*Fa+15.1510;
thetaM2C = 722.4955*Fa-14.9631;

switch PhaseID
    case 0
        a0M = a0MA;
        a1M = a1MA;
        thetaM1 = thetaM1A;
        thetaM2 = thetaM2A;
    case -1
        a0M = a0MB;
        a1M = a1MB;
        thetaM1 = thetaM1B;
        thetaM2 = thetaM2B;
    case 1
        a0M = a0MC;
        a1M = a1MC;
        thetaM2 = thetaM1C;
        thetaM1 = thetaM2C;
end

MagErrPhaMod = Xm/70*(a0M+a1M*cos(2*pi*Fa*t+thetaM1)+a2M*cos(2*pi*2*Fa*t+thetaM2));

% phaes angle error

a0PA = 0;

if Fa > 0.1
    a0PB = 1.1e-4*cos(2*pi/11.5*Fa)-2.183e-2;
else
    a0PB = -2.163e-2;
end    

a0PC = -a0PB;

switch PhaseID
    case 0
        a0P = a0PA;
    case -1
        a0P = a0PB;
    case 1
        a0P = a0PC;
end

a1P = 11.4570*sin(2*pi*0.5*Fa);

thetaP = 3.1365*Fa-1.5636; % or -2*theta0-pi/2?
AngErrPhaMod = a0P+a1P*cos(2*pi*Fa+thetaP);

a1F = 0.2*Fa*sin(2*pi*0.5*Fa);
theta1F = 3.1359*Fa+0.0081;
if Fa <= 4.9
    a2F = 0;
else
    a2F = 1.269e-4;
end
theta2F = -1.6234;
FreqErrPhaMod = a1F*cos(2*pi*Fa*t+theta1F)+a2F*cos(2*pi*3*Fa*t+theta2F);

a0ROC = 0;
a1ROC =(1.1614*Fa^2+0.3905*Fa-0.08793)*sin(2*pi*0.5*Fa);
theta1ROC = 3.1350*Fa+1.5804;
if Fa <= 4.9
    a2ROC = 0;
else
    a2ROC = 1.1498e-2;
end
theta2ROC = -0.02496;
ROCOFErrPhaMod = a0ROC+a1ROC*cos(2*pi*Fa*t+theta1ROC)+a2ROC*cos(2*pi*3*Fa*t+theta2ROC);
