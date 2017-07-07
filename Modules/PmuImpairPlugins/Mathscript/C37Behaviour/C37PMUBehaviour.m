function [ImpTimestamp,...
          ImpSynx,...
          ImpFreq,...
          ImpROCOF] = C37PMUBehaviour(...
                                       EvtTimestamp, ...
                                       EvtSynx, ...
                                       EvtFreq, ...
                                       EvtROCOF, ...
                                       bPosSeq, ...
                                       ImpParams, ...
                                       WindowType, ...
                                       F0, ...
                                       Fs, ...
                                       FSamp)
% % create the impair module based on the research of PMU impariment from the
% % data tested on C37.118 algorithm with 60 Hz nominal frequency, 60 Hz
% % reporting rate, and M class.
%
% See the paper titled: PMU Errors Due To Filter Response in
% framework/documentation

% ImpParams
Fr = ImpParams(1,1);        % Filter cutoff frequency
N = ImpParams(2,1);         % Filter order (there will be one more sample than the order number)


if (FSamp/Fs)-floor(FSamp/Fs) ~= 0
    errMsg = sprintf('Error: Sample Rate: %d Hz must be an interger multiple of Reporting rate: %d FPS', ...
                       FSamp, Fs);
    error(errMsg);
end

%--------------------------------------------------------------------------
% Set up the Error arrays

% pull the positive sequence out of the event synchrophasors (if they are
% there)
if bPosSeq
    numPosSeq = floor(size(EvtSynx,2)/4);
    EvtPosSeq = zeros(size(EvtSynx,1),numPosSeq);
    for i = 1:numPosSeq
        iPosSeq = ((i-1)*4)+(5-i);
        EvtPosSeq(:,i) = EvtSynx(:,iPosSeq);
        EvtSynx = [EvtSynx(:,1:iPosSeq-1),EvtSynx(:,iPosSeq+1:end)];
    end
else  % if the posseq is not already in the EvtSynx (there may not be 3 phases)
    %EvtPosSeq = calcPosSeq(EvtSynx(:,1:3));
    EvtPosSeq = EvtSynx(:,1);
end
    
% pre configure the impaired phases
ImpSynx = EvtSynx;
ImpFreq = EvtFreq;
ImpROCOF = EvtROCOF;

%==========================Filter Transfer function========================
% For each report, generate the Filter magnitude and phase response based
% on the reported frequency
Bn = FIR(N,Fr,FSamp);  % sinc function coefficients
Wn = Window(N,WindowType);  % Windowing coefficients
%--------------------------------------------------------------------------
%For each report, get the transfer function and multiply the report by the magnitude response
[Hjw] = FirResp (...
    N,...
    Bn, ...
    Wn, ...
    EvtFreq-F0, ...
    EvtROCOF, ...
    FSamp ...
    );    % filter transfer function


%=========================Transfer Function Error==============================
% Error of the transfer function without the unfiltered sum component
for i=1:length(ImpSynx(1,:))
    ImpSynx(:,i) = Hjw.*ImpSynx(:,i);
end

%=========================Aliased unfiltered component==============================
% (not applied to the Positive Sequence)
% For each report, generate the aliesed unfiltered portion of the sum component that
% is  aliased at 2 times the difference between the frequency and the nominal 
% frequency, including when the difference is 0, in which case it will show up as DC.   
[SynxErrFilt] = C37PmuFilt( ...
    N, ...          % filter order
    Bn, ...         % filter coefficients
    Wn, ...         % window coefficients
    FSamp, ...      % system sampling rate
    EvtFreq, ...    % event report frequency vector
    EvtROCOF, ...   % event report ROCOF vector
    EvtSynx, ...    % even report phasor array
    F0 ...          % nominal frequency
    );
ImpSynx = ImpSynx + SynxErrFilt;
%ImpSynx = SynxErrFilt;
%ImpSynx = ImpSynx;
%=============================Impaired Positive Sequence===================
% Impaired Positive Sequence
if bPosSeq
    phases = ImpSynx;
    ImpPosSeq = zeros(size(ImpSynx,1),numPosSeq);
    for i = 1:floor(size(ImpSynx,2)/3)    % How many groups of 3 are there?
        group = phases(:,((i-1)*3)+1:((i-1)*3)+3);
        ImpPosSeq(:,i) = calcPosSeq(group).';
        index = ((i-1)*3)+(2+i);
        ImpSynx = [ImpSynx(:,1:index),ImpPosSeq(:,i),ImpSynx(:,index+1:end)];
    end
else  % if the PosSeq is not included in the ImpSynx
    %ImpPosSeq = calcPosSeq(ImpSynx(:,1:3));
    ImpPosSeq = ImpSynx(:,1);
end   

%=========================Frequency and ROCOF Errors=======================
[FreqErrFilt, ROCOFErrFilt] = C37FreqFilt (...
    Fs, ...
    EvtPosSeq(:,1), ...
    ImpPosSeq(:,1) ...
    );

%this is ridiculous, but adding the vectors works fine under Matlab, but
%creates a two dimentional array when called by LabVIEW Mathscript.
% For that reason the below does a piecewice addition.

%ImpFreq = ImpFreq + FreqErrFilt;  %works for Matlab, not for Mathscript
for i = 1:length(ImpFreq)
    ImpFreq(i)=ImpFreq(i)+FreqErrFilt(i);
end

%ImpROCOF = ImpROCOF + ROCOFErrFilt; %works for Matlab, not for Mathscript
for i = 1:length(ImpROCOF)
    ImpROCOF(i)=ImpROCOF(i)+ROCOFErrFilt(i);
end


%--------------------------------------------------------------------------
ImpTimestamp = EvtTimestamp;

% % % From EvtTimestamp and T0 plus the filter group delay,
% % % calculate time vector, add (negative) time at the beginning for the
% % % filter step response
% % 
% % % There will be 2 filter order periods of additional samples at the beginning and
% % % at the end of the Signal.
% % tStart = (EvtTimestamp(1) - T0) - ((2*N)/FSamp);
% % tEnd = tStart + (length(EvtSynx(1,:))/FSamp);
% % t = (tStart:1/FSamp:tEnd);
% % t = t(1:end-1);
% 
% % Filter magnitude-frequency response at one frequency point
% %[MagFreqRes,AngFreqRes] = OnePointFIR(N,Fr,FSamp,FilterType,Fin,F0);
% 
% % % when to consider which phase the input signal belongs to
% % theta0 = wrapToPi(Ps*pi/180);   % transfer to rad and wrap to range -pi to pi
% % % PhaseID = 0;    % initialize the phase 0: phase A, -1: phase B, 1: phase C
% % if  theta0> -pi/3 && theta0 <= pi/3
% %     PhaseID = 0;
% % elseif theta0 > -pi && theta0 <= -pi/3
% %     PhaseID = -1;
% % else
% %     PhaseID = 1;
% % end
% % 
% % % Harmonics
% % [MagErrHam,AngErrHam,FreqErrHam,ROCOFErrHam] = C37PmuHarmonic(Xm,Fin,F0,theta0,Fi,Ph,Kh);
% % 
% % % % Interharmonic
% % % [MagErrInt,AngErrInt,FreqErrInt,ROCOFErrInt] = C37PmuInterharmonic(Xm,Fi,theta0,F0,Fin,PhaseID,t,MagFreqRes,Kh);
% % MagErrInt=0;AngErrInt=0;FreqErrInt=0;ROCOFErrInt=0;
% % 
% % % Frequency Ramp
% % [MagErrRmp,AngErrRmp,FreqErrRmp,ROCOFErrRmp] = C37PmuFreqRamp(Rf,Xm,theta0,F0,Fin,PhaseID,t,MagFreqRes);
% % 
% % % Phase modulation
% % [MagErrPhaMod,AngErrPhaMod,FreqErrPhaMod,ROCOFErrPhaMod] = C37PmuPhaMod(Fa,Ka,Xm,theta0,F0,Fin,PhaseID,t,MagFreqRes);
% %     
% % % Amplitude Modulation
% % [MagErrAmpMod,AngErrAmpMod,FreqErrAmpMod,ROCOFErrAmpMod] = C37PmuAmpMod(Fx,Kx,Xm,theta0,F0,Fin,PhaseID,t,MagFreqRes);
% % 
% % % Step change in Phase
% % [MagErrPhaStp,AngErrPhaStp,FreqErrPhaStp,ROCOFErrPhaStp] = C37PmuPhaStp(KaS,Xm,N,theta0,FSamp,Fin,PhaseID,t,MagFreqRes);
% % 
% % % Step change in Magnitude
% % [MagErrMagStp,AngErrMagStp,FreqErrMagStp,ROCOFErrMagStp] = C37PmuMagStp(KxS,Xm,N,theta0,FSamp,Fin,PhaseID,t,MagFreqRes);
% % 
% % MagErr = MagErrRag + MagErrHam + MagErrInt + MagErrRmp + MagErrPhaMod + MagErrAmpMod + MagErrPhaStp + MagErrMagStp;
% % PhaErr = AngErrRag + AngErrHam + AngErrInt + AngErrRmp + AngErrPhaMod + AngErrAmpMod + AngErrPhaStp + AngErrMagStp;
% % FreqErr = FreqErrRag + FreqErrHam + FreqErrInt + FreqErrRmp + FreqErrPhaMod + FreqErrAmpMod + FreqErrPhaStp + FreqErrMagStp;
% % ROCOFErr = ROCOFErrRag + ROCOFErrHam + ROCOFErrInt + ROCOFErrRmp + ROCOFErrPhaMod + ROCOFErrAmpMod + ROCOFErrPhaStp + ROCOFErrMagStp;
% 
end
% 
