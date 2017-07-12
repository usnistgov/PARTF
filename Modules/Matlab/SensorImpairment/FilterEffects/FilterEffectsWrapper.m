function [ImpTimestamp,...
          ImpSynx,...
          ImpFreq,...
          ImpROCOF] = FilterEffectsWrapper(EvtTimestamp,...
		                                   EvtSynx,...
										   EvtFreq,...
										   EvtROCOF,...
										   ImpParams,...
										   EvtParams, ...
                                           FilterType,...
                                           F0, ...
                                           Fs, ...
                                           T0 ...
                                           )
                                       
% Overview:
% In order to reproduce the effects of the DFT, low-pass filtering, and
% decimation on synchrophasors, the event waveform will need to be
% reproduced and a set of synchrophasor estimates made using the techniques
% of the C37.118 annex.

FSamp = ImpParams(1,1);     % PMU internal sampling rate
Fr = ImpParams(2,1);        % Filter cutoff frequency
N = ImpParams(3,1);         % Filter order (there will be one more sample than the order number)

Nphases = length(EvtParams(1,:));

% From EvtTimestamp and T0 plus the filter group delay,
% calculate time vector, add (negative) time at the beginning for the
% filter step response
tStart = EvtTimestamp(1) - T0;
tEnd = (EvtTimestamp(end) - T0;
t = (tStart - ((N+1)/FSamp):1/FSamp:tEnd);

% create the power system event signal
Signal = genC37Signal (...
                        t, ...    
                        FSamp, ...
                        EvtParams ...
                       ); 
                                       
% DFT
DFT = zeros(Nphases,length(t));
for i = 1:length(EvtParams(1,:))
    DFT(i,:) = sqrt(2) .* Signal(i,:) .* exp(1i * (2*pi*F0) .* t);   
end

% get the filter coefficients
% get the filter coefficients
Bn = FIR(N,Fr,FSamp);
Wn = (Window(N,filterType)).';  

% get the filter coefficients
Bn = FIR(N,Fr,FSamp);               % unnormalized coefficients
Wn = (Window(N,WindowType)).';
Bn = Bn.*Wn;
Bn = Bn./sum(Bn);                   % normalized coefficients

% filter the DFT
for i = 1:Nphases
    DFT(i,:) = filter(Bn,1,real(DFT(i,:))) + 1i*filter(Bn,1,imag(DFT(i,:)));
end
% remove the filter step response at the beginning
DFT = DFT(:,((N+1)+(N/2)+1:end));

% TODO: ADD THE freq AND rocof ESTIMATES HERE

% decimate
ImpSynx = zeros(Nphases,floor(N/(FSamp/Fs)));
for j = 1:Nphases
    i = 1;
    for k = 1:FSamp/Fs:length(DFT(1,:))
        ImpSynx(j,i) = DFT(j,k);
        i = i+1;
    end
end

end %function
%---

% % This function serves as a wrapper for the three filter effect
% % functions created for the FilterEffectsPlugin in the PmuImpairModule
% 
% % dFr = 8.19;
% % iFs = 960;
% % N = 164;
% % sWindowType = 'Hamming';
% % MaxFreq = 25;
% % FreqStep = .1;
% % close all
% 
% iFs = ImpParams(1,1);
% dFr = ImpParams(2,1);
% N = ImpParams(3,1);
% sWindowType = FilterType;
% NomFreq = F0;
% 
% Bn = FIR(N,dFr,iFs);
% Wn = Window(N,sWindowType);  %Can't transpose vector in this line in Mathscript
% Wn = Wn.';
% 
% % % Plot the impulse response
% % figure();
% % n = (-N/2:1:N/2);
% % plot(n,Bn.*Wn);
% 
% % Hjw = zeros(1,MaxFreq/FreqStep);
% % fAxis = Hjw;
% % dFreq = -MaxFreq;
% % for n = (1:1:2*MaxFreq/FreqStep)
% %   Hjw(n) = SincResp(N,iFs,Wn,Bn,dFreq);
% %   fAxis(n)=dFreq;
% %   dFreq = dFreq+FreqStep;
% % end
% 
% dFreq = EvtFreq - NomFreq;
% Hjw = zeros(length(EvtFreq),1);
% for n = (1:length(Hjw))
%     Hjw(n) = SincResp(N,iFs,Wn,Bn,dFreq(n));
% end
% Hjw = Hjw/dot(Wn,Bn);   %Scales the response to 1 
% % y = 10*log(abs(Hjw));   % Magnitude Response in dB
% % 
% % figure();
% % subplot(2,1,1);
% % plot(fAxis,y);
% % 
% % % Matlab has an issue with angle wrapping when the magnitude of Hjw is
% % % small  This begins to happen after 26.5 Hz given the default settings.
% % % This should not effect the PMU impairment module. 
% % Angle = (angle(Hjw));
% % 
% % %Angle = Angle - pi * floor((angle+pi)/2*pi);
% % subplot (2,1,2);
% % plot (fAxis,Angle);
% 
% ImpTimestamp = EvtTimestamp;
% [rows,cols] = size(EvtSynx);
% ImpSynx = zeros(rows,cols);
% for n = (1:cols)
%     ImpSynx(:,n) = EvtSynx(:,n).*Hjw;
% end
% ImpFreq = EvtFreq;
% ImpROCOF = EvtROCOF;
