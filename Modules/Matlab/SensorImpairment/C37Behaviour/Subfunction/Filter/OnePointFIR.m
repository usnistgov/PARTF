function [MagFreqRes,AngFreqRes] = OnePointFIR ( ...
    N, ...
    dFr, ...
    iFs, ...
    sWindowType, ...
    Freq, ...
    F0...
    )
% dFr = 8.19;
% iFs = 960;
% N = 164;
% sWindowType = 'Hamming';
% MaxFreq = 25;
% FreqStep = .1;
% close all

Bn = FIR(N,dFr,iFs);
Wn = Window(N,sWindowType).';

% Plot the impulse response
% figure();
% n = (-N/2:1:N/2);
% plot(n,Bn.*Wn);

dFreq = Freq - F0;
omega = 2*pi*dFreq/(iFs);
n = -N/2;
Hjw = 0;
for k = (1:1:N+1)
    Hjw = Hjw + (Wn(k)*Bn(k)*exp(-1i*omega*n));
    n=n+1;
end
Hjw = Hjw/dot(Wn,Bn);   %Scales the response to 1 
MagFreqRes = abs(Hjw);
AngFreqRes = angle(Hjw);
