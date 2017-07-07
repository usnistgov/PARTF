clc;
clear;

FSamp = 960;

% Filter parameters
Fr = 8.19;
N = 164;
WindowType = 'Hamming';

% Filter and Window Coefficients 
Bn = FIR(N,Fr,FSamp);  % sinc function coefficients
Wn = Window(N,WindowType);  % Windowing coefficients

StartFreq = 0;
EndFreq = 150;

figure(10)
plot(Bn.*Wn);    %plot the windowed coefficients
%-------------------------- Bode Plot----------------------------

Freq = StartFreq:1/60:EndFreq;
ROCOF = ones(1,length(Freq));
[Hjw] = FirResp ( ...
    N,...
    Bn,...
    Wn,...
    Freq,...
    ROCOF, ...
    FSamp...
    );
    
    

figure(11)
%subplot(2,1,1)
plot(Freq,20*log10(abs(Hjw)),'-k')
xlim([StartFreq,EndFreq]);
%plot(Freq,abs(Hjw),'-k')
title('Hamming Window: Magnitude Response')
xlabel('Frequency (Hz)')
ylabel('Gain (dB)')
%subplot(2,1,2)
%plot(Freq,angle(Hjw),'-k')
%title('Phase Response')
%xlabel('Frequency (Hz)')
%ylabel('Phase (rad)')