% Test_CompareBehaviorToModel
% Runs both the C37 Behaviour PMU impairment simulation and the C37 PMU
% model and allow the user to compare the differences in the impairments
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

% Event Parameters
T0 = 0;
Vm = 100;
Im = 5;

Xm = [Vm,Vm,Vm];
Fin = [60,60,60];
Ps = [0,-120,120];
Fh = [0,0,0];
Ph = [0,0,0];
Kh = [0,0,0];
Fa = [1,1,1];
Ka = [.1,.1,.1];
Fx = [0,0,0];
Kx = [0,0,0];
Rf = [0,0,0];
KaS = [0,0,0];
KxS = [0,0,0];
EvtParams = [Xm;Fin;Ps;Fh;Ph;Kh;Fa;Ka;Fx;Kx;Rf;KaS;KxS];

tStart = 0;
tEnd = 2;
EvtTime = (tStart:1/Fs:tEnd).';
%============================EvtReports===================================
[EvtTimeStamp,...
    EvtSynx,...
    EvtFreq,...
    EvtROCOF] = C37evt(T0,F0,EvtTime,EvtParams);

%====================-Input Signal (for the model)=======================
%time begins and ends 2 filter periods before/after
t = (tStart - ((2*N)/FSamp): 1/FSamp: tEnd + ((2*N)/FSamp)).';
Signal = genC37Signal (t, FSamp, EvtParams);

%--------------------Model output-----------------------------------------
TimeZero = t((2*N)+1);

[ModelTimestamp,...
ModelSynx,...
ModelFreq,...
ModelROCOF] =  C37PmuImpair( ...
               TimeZero, ...
               Signal, ...
               ImpParams, ...
               WindowType, ...
               T0, ...
               F0, ...
               Fs, ...
               FSamp ...
              ); 
 ModelPosSeq = ModelSynx(4,:);         
% %--------------------Experiment Simulated FE from Model PE---------------------      
% ImpSynx = ModelSynx;
% ImpPosSeq = ModelPosSeq;
% 
% [FreqErrFilt, ROCOFErrFilt] = C37FreqFilt ( ...
%     F0, ...
%     Fs, ...
%     EvtPosSeq, ...
%     ImpPosSeq ...
%     );    
% ImpFreq = EvtFreq+FreqErrFilt;
% 
% %-------------------------End Experiment ----------------------------------          


% %===================C37 Behaviour Output=================================
%EvtROCOF = zeros(1,length(EvtROCOF));

[ImpTimestamp,...
    ImpSynx,...
    ImpFreq,...
    ImpROCOF] = C37PMUBehaviour(...
        EvtTimeStamp, ...
        EvtSynx, ...
        EvtFreq, ...
        EvtROCOF, ...
        ImpParams, ...
        WindowType, ...
        F0, ...
        Fs, ...
        FSamp);



%===============================Plots=====================================

%------------------------Mag Error Plots----------------------------------
ImpME=abs(ImpSynx(:,1))-abs(EvtSynx(:,1));
ModelME=abs(ModelSynx(:,1))-abs(EvtSynx(:,1));
figure(1)
%subplot(2,1,1)         % combining model and simulated on one plot
% plot(EvtFreq,ImpME,'r',EvtFreq,ModelME,'b')
% title('Magnitude Error')

subplot(3,1,1)
% plot(EvtFreq,ModelME,'k')     % Changing frequency
% xlabel('Frequency (Hz)')
plot(EvtTime,ModelME,'k')       % Fixed Frequency
xlabel('Time (s)')
title('PMU Model Magnitude Error')
%ylabel('Magnitude Error (%)')
%axis([0,5,0,.1])

subplot(3,1,2)
% plot(EvtFreq,ImpME,'k') % Changing Frequency
% xlabel('Frequency (Hz)')
plot(EvtTime,ImpME,'k')       % Fixed Frequency
xlabel('Time (s)')
title('Simulated Magnitude Error')
ylabel('Magnitude Error (%)')
%axis([0,5,0,.1])
% 
subplot(3,1,3)
%plot(EvtFreq,abs(ImpSynx(:,1))-abs(ModelSynx(:,1))) %changing frequency
% xlabel('Frequency (Hz)')
plot(EvtTime,abs(ImpSynx(:,1))-abs(ModelSynx(:,1))) %fixed frequency
xlabel('Time (s)')
title('ME Difference')
%ylabel('Magnitude Error (%)')
%plot(abs(ImpSynx(:,1))-abs(ModelSynx(:,1)))
%axis([0,5,-.01,.01])
    
%-------------------------Phase Error Plots------------------------------------
ImpPE=wrapToPi(angle(ImpSynx(:,1))-angle(EvtSynx(:,1)));
ModelPE=wrapToPi(angle(ModelSynx(:,1))-angle(EvtSynx(:,1)));

figure(2)
% subplot(2,1,1)        % combining model and simulated on one plot
% plot(EvtFreq,ModelPE,'b',EvtFreq,ImpPE,'r')
% title('Phase Error');

subplot(3,1,1)
% plot(EvtFreq,ModelPE,'k')     % Changing frequency
% xlabel('Frequency (Hz)')
plot(EvtTime,ModelPE,'k')     % fixed frequency
xlabel('Time (s))')
title('PMU Model Phase A Phase Error')
ylabel('Phase Error (rad)')
%axis([0,5,-.001,.001])

subplot(3,1,2)
% plot(EvtFreq,ImpPE,'k') %Changing Frequency
% xlabel('Frequency (Hz)')
plot(EvtTime,ImpPE,'k') %Changing Frequency
xlabel('Time (s)')
title('Simulated Phase A Phase Error')
ylabel('Phase Error (rad)')
%axis([0,5,-.001,.001])

subplot(3,1,3)
% plot(EvtFreq,wrapToPi(angle(ImpSynx(:,1))-angle(ModelSynx(:,1))))
% xlabel('Frequency (Hz)')
plot(EvtTime,wrapToPi(angle(ImpSynx(:,1))-angle(ModelSynx(:,1))))
xlabel('Time (s)')
title('Phase A PE Difference')
ylabel('Phase Error (rad)')
%axis([0,5,-.01,.01])

%plot(abs(ImpSynx(:,1))-abs(ModelSynx(:,1)))
%plot(EvtFreq,wrapToPi(angle(ImpSynx(:,1))-angle(EvtSynx(:,1))))
%plot(wrapToPi(angle(ImpSynx(:,1))-angle(EvtSynx(:,1))))
%title('PE Behavior');
%subplot(3,1,2)
%plot(EvtFreq,wrapToPi(angle(ModelSynx(:,1))-angle(EvtSynx(:,1))))
%plot(wrapToPi(angle(ModelSynx(:,1))-angle(EvtSynx(:,1))))
%title('PE Model');subplot(3,1,3)
% subplot(2,1,2)
% plot(EvtFreq,wrapToPi(angle(ImpSynx(:,1))-angle(ModelSynx(:,1))))
%plot(wrapToPi(angle(ImpSynx(:,1))-angle(ModelSynx(:,1))))
%title('PE Difference')

%-----------------Compare Simulated PE to Model PE-------------------------
ImpPE=wrapToPi(angle(ImpSynx(:,4))-angle(EvtSynx(:,4)));
ModelPE=wrapToPi(angle(ModelPosSeq)-angle(EvtSynx(:,4)));
figure(200)
subplot(3,1,1)
plot(EvtTime,ModelPE)
xlabel('Time (s)')
title('Model PosSeq Phase Error')
ylabel('Phase Error(rad)')

subplot(3,1,2)
plot(EvtTime,ImpPE)
xlabel('Time (s)')
title('Simulated PosSeq Phase Error')
ylabel('Phase Error(rad)')

subplot(3,1,3)
plot(EvtTime,ModelPE-ImpPE)
xlabel('Time (s)')
title('Phase Error Difference')
ylabel('Phase(rad)')

%---------------------- Frequency Error Plots -----------------------------
ImpFE = ImpFreq - EvtFreq;
ModelFE = ModelFreq - EvtFreq;
figure(3)
subplot(3,1,1)
plot(EvtTime,ModelFE)
xlabel('Time (s)')
title ('Model Frequency Error')
ylabel('Freq Error (Hz)')

subplot(3,1,2)
plot (EvtTime,ImpFE)
xlabel('Time (s)')
title ('Simulated Frequency Error')
ylabel('Freq Error (Hz)')

subplot(3,1,3)
plot(EvtTime,ImpFE-ModelFE)
xlabel('Time (s)')
title ('FE Difference')
ylabel('Freq Error (Hz)')

% % Figure of Merit during phase moduleation:
% % Quotient of RMS values of Sumulation to Model FE
% ImpFErms = rms(ImpFE);
% ModelFErms = rms(ModelFE);
% FEQuotient= ImpFErms/ModelFErms


%---------------------- ROCOF Error Plots -----------------------------
ImpRFE = ImpROCOF - EvtROCOF;
ModelRFE = ModelROCOF - EvtROCOF;
figure(4)
subplot(3,1,1)
plot(EvtTime,ModelRFE)
xlabel('Time (s)')
title ('Model ROCOF Error')
%ylabel('ROCOF Error (Hz/s)')

subplot(3,1,2)
plot (EvtTime,ImpRFE)
xlabel('Time (s)')
title ('Simulated ROCOF Error')
ylabel('ROCOF Error (Hz/s)')

subplot(3,1,3)
plot(EvtTime,ImpRFE - ModelRFE)
xlabel('Time (s)')
title ('RFE Difference')
%ylabel('ROCOF Error (Hz/s)')


%-----------------Model Positive Sequence Plots
% figure(10)
% % subplot(2,1,1)
% % %plot(EvtFreq,abs(ModelPosSeq(:))-abs(EvtSynx(:,1)))
% % plot(abs(ModelPosSeq(:))-abs(EvtSynx(:,1)))
% % title('ME PosSeq Model');
% subplot(2,1,1)
% %plot(EvtFreq,wrapToPi(angle(ModelPosSeq(:))-angle(EvtSynx(:,1))))
% plot(EvtTime,wrapToPi(angle(ModelPosSeq(:))-angle(EvtSynx(:,1))))
% title('Model Positive Sequence Phase Error');
% subplot(2,1,2)
% % plot(EvtFreq,ModelFreq-EvtFreq)
% plot(EvtTime,ModelFreq-EvtFreq)
% title('Model Freq Error')
% 
% figure(11)
% %subplot(3,1,1)
% %plot(EvtFreq,wrapToPi(angle(ImpSynx(:,1))-angle(EvtSynx(:,1))))
% %subplot(3,1,2)
% plot(EvtFreq,ModelFreq-EvtFreq)
% title('Model Freq Error')
% %subplot(3,1,3)
% %plot(EvtFreq,wrapToPi(angle(ImpSynx(:,1))-angle(ModelSynx(:,1))))
% 
% figure(12)
% PosSeqPE = wrapToPi(angle(ModelPosSeq(:))-angle(EvtSynx(:,1)));
% dPosSeqPE = zeros(1,length(PosSeqPE)-1);
% for i=1:length(PosSeqPE)-1
%     dPosSeqPE(i) = PosSeqPE(i+1)-PosSeqPE(i);
% end
% subplot(2,1,1)
% plot(PosSeqPE)
% title('Model Positive Sequence Phase Error')
% subplot(2,1,2)
% plot(dPosSeqPE)
% title('Model Positive sequence phase error derivative')
% 
% % figure(13)
% % subplot(2,1,1)
% % plot(EvtFreq,abs(EvtSynx(:,1)))
% % title('Reference Magnitude');
% % subplot(2,1,2)
% % plot(EvtFreq,angle(EvtSynx(:,1)))
% % title('Reference Phase')
