function [oXa, oXb, oXc, oF, oROCOF] = SineModel( ...
    iXa, ...    % should be column vector
    iXb, ...
    iXc, ...
    iF, ...
    iROCOF, ...
    pFsamp, ...
    pF0, ...
    pMagAmp, ...
    pMagOffset, ...
    pPhaseAmp, ...
    pPhaseOffset ...
    )
% This is a simple example of PMU data impariment functiont
% This MATLAB function, and its extended version, together with the MATLAB
% sciprt to call this function, will be used for the plug-in module of the
% PMU impairment module.
% 
% Input of this function includes configuration and parameters, and the ideal
% PMU measurements from event module: complex value of voltage and current
% phasor (1 or more channels), frequency, ROCOF.
% Timestamp is not needed. All the input vectors are assumed to be with the
% same sampling rate and no data loss. Based on this assmuption, the output
% vectors has the same timestamp as the input. Therefore, it is not used
% here.

% Output of this script includes: the impaired measurements (phasor,
% frequency, ROCOF), and timestamp.

% Impairment type: fixed sinusoidal wave
% Behavior: 
% 1) The phasor magnitude and angle will have a sinusoidal waveform of
% error. 
% 2) The amplitude, phase angle, and offset of this waveform can be
% obtained from the ideal measurements and input parameters.
% 3) The frequency and ROCOF remains unchanged.

% parameters: 
% pF0: nominal frequency (usually 60 Hz or 50 Hz)
% pMagAmp: amplitude of the sinusoidal waveform as the magnitude error
% pMagOffset: offset of the sinusoidal waveform as the magnitude error
% pPhaseAmp: amplitude of the sinusoidal waveform as the phase error
% pPhaseOffset: offset of the sinusoidal waveform as the phase error

% -------------------------------------------------------------------
% tranform inputs from complex number to magnitude and phase angle
iMagA = abs(iXa);
iMagB = abs(iXb);
iMagC = abs(iXc);
iPhaseA = angle(iXa);
iPhaseB = angle(iXb);
iPhaseC = angle(iXc);

% set the relative time vector for the input data vector
aDataNo = length(iXa);
aTimeLength = (aDataNo-1)/pFsamp;
aTime = 0:1/pFsamp:aTimeLength;  % relative time, assuming the input data starts from time 0
aTime = aTime'; % make t a colum vector

% -------------------------------------------------------------------
% magnitude error creation
% frequency of the sinusoidal waveform as the magnitude error
aMagFreq = 2*abs(iF-pF0);

% initial phase angle of the sinusoidal waveform as the magnitude error
errMagPhaseA = zeros(aDataNo, 1);
errMagPhaseB = -sign(iF-pF0)*pi/3;
errMagPhaseC = sign(iF-pF0)*pi/3;

% create the sinusoidal waveform as the magnitude error
errMagA = pMagAmp*iMagA/70.*cos(2*pi*aMagFreq.*aTime + errMagPhaseA) + pMagOffset;
errMagB = pMagAmp*iMagB/70.*cos(2*pi*aMagFreq.*aTime + errMagPhaseB) + pMagOffset;
errMagC = pMagAmp*iMagC/70.*cos(2*pi*aMagFreq.*aTime + errMagPhaseC) + pMagOffset;

% -------------------------------------------------------------------
% phase error creation
% frequency of the sinusoidal waveform as the phase error
aPhaseFreq = 2*abs(iF-pF0);

% initial phase angle of the sinusoidal waveform as the phase error
errPhasePhaseA = zeros(aDataNo, 1);
errPhasePhaseB = -sign(iF-pF0)*pi/3;
errPhasePhaseC = sign(iF-pF0)*pi/3;

% create the sinusoidal waveform as the phase error
errPhaseA = pPhaseAmp*iMagA/70.*cos(2*pi*aPhaseFreq.*aTime + errPhasePhaseA) + pPhaseOffset;
errPhaseB = pPhaseAmp*iMagB/70.*cos(2*pi*aPhaseFreq.*aTime + errPhasePhaseB) + pPhaseOffset;
errPhaseC = pPhaseAmp*iMagC/70.*cos(2*pi*aPhaseFreq.*aTime + errPhasePhaseC) + pPhaseOffset;

% -------------------------------------------------------------------
% magnitude output creation
oMagA = iMagA + errMagA;
oMagB = iMagB + errMagB;
oMagC = iMagC + errMagC;

% phase output creation
oPhaseA = iPhaseA + errPhaseA;
oPhaseB = iPhaseB + errPhaseB;
oPhaseC = iPhaseC + errPhaseC;

% tranform output from magnitude and phase into complex vector and output
oXa = oMagA.*(cos(oPhaseA)+1j*sin(oPhaseA));
oXb = oMagB.*(cos(oPhaseB)+1j*sin(oPhaseB));
oXc = oMagC.*(cos(oPhaseC)+1j*sin(oPhaseC));

oF = iF;

oROCOF = iROCOF;
