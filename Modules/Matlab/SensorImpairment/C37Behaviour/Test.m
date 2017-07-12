% testing impairment function
% this script is used to test the correction of C37PmuImpair1.m function
clc;
clear;

EvtTime = 0:1/60:5;
Vm = 70;
Im = 5;

Fin = 59;
thetaA = 0;
yA = Vm*sqrt(2)*cos(2*pi*Fin*EvtTime+thetaA);
EvtSynx = Vm*cos(2*pi*Fin*EvtTime+thetaA)+1j*Vm*sin(2*pi*Fin*EvtTime+thetaA);
EvtFreq = Fin;
EvtROCOF = 0;

Xm = Vm;
Ps = thetaA;
Fi = 0;
Ph = 0;
Kh = 0;
Fa = 0;
Ka = 0;
Fx = 0;
Kx = 0;
Rf = 0;
KaS = 0;
KxS = 0;
EvtParams = [Xm;Fin;Ps;Fi;Ph;Kh;Fa;Ka;Fx;Kx;Rf;KaS;KxS];

Fr = 8.19;
N = 164;

ImpParams = [Fr;N];

FilterType = 'Hamming';

F0 = 60;
Fs = 60;
FSamp = 60;

T0 = 0;
EvtTimestamp = 0;

tStart = (EvtTimestamp - T0) - ((2*N)/FSamp);
tEnd = tStart + (length(EvtSynx(1,:))/FSamp);
t = (tStart:1/FSamp:tEnd);
t = t(1:end-1);
[MagFreqRes,~] = OnePointFIR(N,Fr,FSamp,FilterType,Fin,F0);
theta0 = wrapToPi(Ps*pi/180);   % transfer to rad and wrap to range -pi to pi
[MagErrRag,AngErrRag,FreqErrRag,ROCOFErrRag] = C37PmuRag(Xm,Fin,F0,theta0,MagFreqRes,t);

MagErr = MagErrRag;
PhaErr = AngErrRag;
FreqErr = FreqErrRag;

figure(1);
hold on;
% plot(t,yA);
yimp = (abs(EvtSynx)+MagErr)*sqrt(2).*cos(2*pi*FreqErr*t + angle(EvtSynx)+PhaErr*pi/180);
plot(t,MagErr);
grid on;
xlabel('Time (s)');
ylabel('Magnitude (V)');
legend('Orignin Signal','Impaired Signal');

