% testing impairment function
% this script is used to test the correction of C37PmuImpair1.m function
clc;
clear;

% simulated system sampling rate
FSamp = 960;
F0 = 60;
Fs = 60;

% Filter parameters
Fr = 8.19;
N = 164;
WindowType = 'Hamming';
ImpParams = [Fr;N];

% Filter and Window Coefficients 
Bn = FIR(N,Fr,FSamp);  % sinc function coefficients
Wn = Window(N,WindowType).';  % Windowing coefficients

% Test C37Evt
T0 = 0;
F0 = 60;
EvtTime = 0:1/60:5;
Ff = 61;

bPosSeq = true;
% 6 phases positive sequences will be generated
Xm = [100,100,100,20,20,20];
Fin = [Ff,Ff,Ff,Ff,Ff,Ff];
Ps = [0,-120,120,0,-120,120];
Fh = [0,0,0,0,0,0];
Ph = [0,0,0,0,0,0];
Kh = [0,0,0,0,0,0];
Fa = [0,0,0,0,0,0];
Ka = [0,0,0,0,0,0];
Fx = [0,0,0,0,0,0];
Kx = [0,0,0,0,0,0];
Rf = [0,0,0,0,0,0];
KaS = [0,0,0,0,0,0];
KxS = [0,0,0,0,0,0];

% % Only two channels of data voltage and current
% bPosSeq = false;
% % only 2 channels, no positive sequences will be generated
% Xm = [100,20];
% Fin = [Ff,Ff];
% Ps = [0,0];
% Fh = [0,0];
% Ph = [0,0];
% Kh = [0,0];
% Fa = [0,0];
% Ka = [0,0];
% Fx = [0,0];
% Kx = [0,0];
% Rf = [0,0];
% KaS = [0,0];
% KxS = [0,0];

% bPosSeq = true;
% % weird event parameters, 8 phases (not multiple of 3) so 2 positive
% % sequences will be generated
% Xm = [100,100,100,20,20,20,1,1];
% Fin = [Ff,Ff,Ff,Ff,Ff,Ff,Ff,Ff];
% Ps = [0,-120,120,0,-120,120,0,-120];
% Fh = [0,0,0,0,0,0,0,0];
% Ph = [0,0,0,0,0,0,0,0];
% Kh = [0,0,0,0,0,0,0,0];
% Fa = [0,0,0,0,0,0,0,0];
% Ka = [0,0,0,0,0,0,0,0];
% Fx = [0,0,0,0,0,0,0,0];
% Kx = [0,0,0,0,0,0,0,0];
% Rf = [0,0,0,0,0,0,0,0];
% KaS = [0,0,0,0,0,0,0,0];
% KxS = [0,0,0,0,0,0,0,0];

EvtParams = [Xm;Fin;Ps;Fh;Ph;Kh;Fa;Ka;Fx;Kx;Rf;KaS;KxS];

% Generate the ideal synchrophasors
[EvtTimeStamp,EvtSynx,EvtFreq,EvtROCOF] = C37evt(T0,F0,EvtTime,EvtParams,bPosSeq);


%-------------------------Test C37Behaviour--------------------------------
[ImpTimestamp,...
    ImpSynx,...
    ImpFreq,...
    ImpROCOF] = C37PMUBehaviour(...
        EvtTime, ...
        EvtSynx, ...
        EvtFreq, ...
        EvtROCOF, ...
        bPosSeq, ...
        ImpParams, ...
        WindowType, ...
        F0, ...
        Fs, ...
        FSamp);


TVE = TotalVectorError(EvtSynx,ImpSynx);
figure(1)
subplot(3,1,1)
%plot(EvtFreq,TVE(1,:))
plot(TVE(4,:))
ylabel('TVE');
subplot(3,1,2) 
%plot(EvtFreq,abs(ImpSynx(:,1))-abs(EvtSynx(:,1)))
plot(abs(ImpSynx(:,4))-abs(EvtSynx(:,4)))
ylabel('ME')
subplot(3,1,3)
%plot(EvtFreq,angle(ImpSynx(:,1))-angle(EvtSynx(:,1)))
plot(angle(ImpSynx(:,4))-angle(EvtSynx(:,4)))
ylabel('PE')

figure(2)
plot(ImpFreq-EvtFreq)
%-------------------------Test C37Behaviour--------------------------------

%-------------------------- Bode Plot----------------------------
% Freq = -25:1/60:25;
% [Hjw] = FirResp ( ...
%     N,...
%     Bn,...
%     Wn,...
%     Freq,...
%     FSamp...
%     );
% figure(11)
% subplot(2,1,1)
% plot(Freq,20*log(abs(Hjw)),'-k')
% %plot(Freq,abs(Hjw),'-k')
% title('Hamming Window: Magnitude Response')
% xlabel('Frequency (Hz)')
% ylabel('Gain (dB)')
% subplot(2,1,2)
% plot(Freq,angle(Hjw),'-k')
% title('Phase Response')
% xlabel('Frequency (Hz)')
% ylabel('Phase (rad)')
%-------------------------- Bode Plot----------------------------


