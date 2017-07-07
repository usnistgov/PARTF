function [ImpTimestamp,...
          ImpSynx,...
          ImpFreq,...
          ImpROCOF] = SineModelWrapper(EvtTimestamp,...
                                       EvtSynx,...
                                       EvtFreq,...
                                       EvtROCOF,...
                                       ImpParams)

% This function serves as a wrapper for the SineModel impairment function.
% create the input vector of 3 phases in complex vector
iXa = EvtSynx(:,1);
iXb = EvtSynx(:,2);
iXc = EvtSynx(:,3);

% create the input vector of frequency
Fin = ImpParams(2,1);
iF = Fin*ones(size(EvtTimestamp))'; %transpose into column vector

% create the input vector of ROCOF
iROCOF = EvtROCOF';


pFsamp = ImpParams(4,1);    % parameter: sampling rate
pF0 = ImpParams(3,1);       % parameter: nominal frequency

Mag = ImpParams(1,1);

% parameter: amplitude of sinusoidal waveform as magnitude error
pMagAmp = abs(0.03163*Mag/70*sin(2*pi/11.6*(Fin-56.7)));

% parameter: offset of sinusoidal waveform as magnitude error          
pMagOffset = -1e-3;                                             

% parameter: amplitude of sinusoidal waveform as phase error
pPhaseAmp = abs(0.0259*Mag/70*sin(2*pi/11.6*(Fin-56.7)))*pi/180;  

% parameter: offset of sinusoidal waveform as phase error
pPhaseOffset = 0*pi/180;                                        

% call the data impair function (all vectors should be column vectors)
[oXa, oXb, oXc, oF, oROCOF] = SineModel(...
                                        iXa,...
                                        iXb,...
                                        iXc,...
                                        iF,...
                                        iROCOF,...
                                        pFsamp,...
                                        pF0,...
                                        pMagAmp,...
                                        pMagOffset,...
                                        pPhaseAmp,...
                                        pPhaseOffset);
ImpTimestamp = EvtTimestamp;
ImpSynx = [oXa, oXb, oXc];
ImpFreq = oF;
ImpROCOF = oROCOF;