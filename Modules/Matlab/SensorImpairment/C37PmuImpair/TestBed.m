clear;
clc;

FSamp = 960;    % internal PMU sample rate
F0 = 60;        % nominal frequency
Fs = 60;        % reporting rate
T0 = 0;

% Filter parameters
N = 164;        % filter order (one less than the number of coefficients)
WindowType = 'Hamming';
Fr = 8.19;      % filter cutoff frequency

tStart = 0;
tEnd = 1000;

% Signal Parameters
Xm = [70,70,70,5,5,5];
Fin = [60,60,60,60,60,60];
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

bPosSeq = true;

signalparams = [Xm;Fin;Ps;Fh;Ph;Kh;Fa;Ka;Fx;Kx;Rf;KaS;KxS];

time = (tStart:1/Fs:tEnd);
% Generate Theoretical Synchrophasor Reports
[timestamp,synx,freq,ROCOF] = C37evt( ...
    T0, ...
    F0, ...
    time, ...
    signalparams, ...
    bPosSeq ...
);

%time
t = (tStart - ((2*N)/FSamp): 1/FSamp: tEnd + ((2*N)/FSamp));



Signal = genC37Signal (t, FSamp, signalparams);
%figure(1)
%plot(t,Signal(:,1),'.-');



% set up to test the C37PmuImpair
bPosSeq = false(1);
EvtTimestamp = t((2*N)+1);
ImpParams(1,1)=Fr;
ImpParams(2,1)=N;
T0 = 0;

[ImpTimestamp,...
ImpSynx,...
ImpFreq,...
ImpROCOF] =  C37PmuImpair( ...
               EvtTimestamp, ...
               Signal, ...
               bPosSeq, ...
               ImpParams, ...
               WindowType, ...
               T0, ...
               F0, ...
               Fs, ...
               FSamp ...
              );  

          
figure(9)
%plot(freq,wrapToPi(angle(ImpSynx(:,1))-angle(synx(:,1))))
plot(wrapToPi(angle(ImpSynx(:,1))-angle(synx(:,1))))
figure(10)
subplot(2,1,1)
plot(ImpFreq - freq)
subplot(2,1,2)
plot(ImpROCOF - ROCOF);         

figure(11)
plot(abs(ImpSynx(:,1))-abs(synx(:,1)));
grid on
set(gca, 'YTickLabel',num2str(get(gca,'YTick')','%.12f'));
% plot (ImpTimestamp,real(ImpSynx(:,1)));
% %DFT
% DFT = zeros(length(Xm),length(t));
% for i = 1:length(Xm)
%     DFT(i,:) = sqrt(2) .* Signal(i,:) .* exp(1i * (2*pi*F0) .* t);
% end
% %plot
% % figure(1)
% % subplot(2,1,1)
% % plot(abs(DFT(1,:)))
% % subplot(2,1,2)
% % plot(unwrap(angle(DFT(1,:))))
% % 
% % get the filter coefficients
% Bn = FIR(N,Fr,FSamp);               % unnormalized coefficients
% Wn = (Window(N,WindowType)).';
% Bn = Bn.*Wn;
% Bn = Bn./sum(Bn);                   % normalized coefficients
% 
% % filter the DFT
% for i = 1:length(Xm)
%     DFT(i,:) = filter(Bn,1,real(DFT(i,:))) + 1i*filter(Bn,1,imag(DFT(i,:)));
% end
% % the filter has a step response at the beginning
% DFT = DFT(:,((N+1)+(N/2)+1:end));
% %DFT = DFT(:,((N+1):end));
% 
% % figure(2)
% % subplot(2,1,1)
% % plot(abs(DFT(1,:)))
% % subplot(2,1,2)
% % plot(unwrap(angle(DFT(1,:))))
% 
% % decimate
% ImpSynx = zeros(length(Xm),floor(N/(FSamp/Fs)));
% for j = 1:length(Xm)
%     i = 1;
%     for k = 1:FSamp/Fs:length(DFT(1,:))
%         ImpSynx(j,i) = DFT(j,k);
%         i = i+1;
%     end
% end
%     
% figure(2)
% subplot(2,1,1)
% plot(abs(ImpSynx(1,:)))
% subplot(2,1,2)
% plot(unwrap(angle(ImpSynx(1,:))))