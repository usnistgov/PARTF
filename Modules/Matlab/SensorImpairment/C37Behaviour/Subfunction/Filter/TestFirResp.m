clc;
clear;

N = 164;
Fr = 8.19;
WindowType = 'Hamming';
FSamp = 960;

Bn = FIR(N,Fr,FSamp);  % sinc function coefficients
Wn = Window(N,WindowType).';  % Windowing coefficients

% figure(1)
% subplot(3,1,1)
% plot(Bn)
% subplot(3,1,2)
% plot(Wn)
% subplot(3,1,3)
% plot (Bn.*Wn)

Freq = -5:1/4:125;
ROCOF = zeros(1,length(Freq));

[MagFreqRes, AngFreqRes] = FirResp ( ...
    N,...
    Bn,...
    Wn,...
    Freq,...
    ROCOF, ...
    FSamp...
    );

figure(2)
plot(Freq,20*log(MagFreqRes))

% Wc = 2*pi*Fr;
% W = 2*pi*Freq;
% 
% for i=1:length(W)
%     Hjw(i) = 1 /(1+1i*(W(i)/Wc));
%     Av(i) = 20*log(abs(Hjw(i)));
% end
% 
% plot(Freq,Av)