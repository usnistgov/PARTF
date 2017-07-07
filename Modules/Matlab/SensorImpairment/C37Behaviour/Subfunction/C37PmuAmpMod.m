function [MagErrAmpMod,AngErrAmpMod,FreqErrAmpMod,ROCOFErrAmpMod] = C37PmuAmpMod(...
    Fx,...
    Kx,...
    Xm,...
    theta0,...
    F0,...
    Fin,...
    PhaseID,...
    t,...
    MagFreqRes)

% magnitude error
a0M = 0.03095;
a1M = -3.6565e-4*Fx^2-1.6740e-4*Fx+0.0030;
thetaM1 = 359.3836*Fx+1.0012;
MagErrAmpMod = a0M+a1M*cos(2*pi*Fx*t+thetaM1);

% phaes angle error

a0PA = 0;
a0PB = 1.1e-4*cos(2*pi/11.6*Fx)-0.022053;
a0PC = -1.1e-4*cos(2*pi/11.6*Fx)+0.022053;

a1PA = 5e-4*sin(2*pi/10.8*Fx);
a1PB = -2.2e-3*cos(2*pi/11.5*Fx)+2.2e-3;
a1PC = a1PB;

thetaPA = 360.1530*Fx-90.5325;
thetaPB = 350.0892*Fx+40.6422;
thetaPC = 370.1062*Fx+138.6776;

switch PhaseID
    case 0
        a0P = a0PA;
        a1P = a1PA;
        thetaP = thetaPA;
    case -1
        a0P = a0PB;
        a1P = a1PB;
        thetaP = thetaPB;
    case 1
        a0P = a0PC;
        a1P = a1PC;
        thetaP = thetaPC;
end

AngErrAmpMod = a0P+a1P*cos(2*pi*Fx+thetaP);

FreqErrAmpMod = 0;

ROCOFErrAmpMod = 0;
