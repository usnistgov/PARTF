function [FreqErrFilt, ROCOFErrFilt] = C37FreqFilt ( ...
    Fs, ...
    EvtPosSeq, ...
    ImpPosSeq ...
    )
ROCOFErrFilt = zeros(length(EvtPosSeq),1);
FreqErrFilt = ROCOFErrFilt;

% Calculate positive sequence of the impaired Synchrophasors
% Rad120 = (2*pi)/3;
% A = exp(1i*Rad120);
% ImpPosSeq =  (ImpSynx(:,1) + (A.*ImpSynx(:,2))+ (A^2*ImpSynx(:,3)))/3;
% ImpPosSeqPE = wrapToPi(angle(ImpPosSeq(:,1))-angle(EvtSynx(:,1)));
ImpPosSeqPE = wrapToPi(angle(ImpPosSeq)-angle(EvtPosSeq));


%-----------------------Cubic Spline Interpolation-------------------------
% This will use a spline order of 5 (knots) and will try to use a rolling
% window to reduce the number of recalculations that need to be performed.

%FreqErrFilt = FreqSpline(ImpPosSeqPE,F0,Fs); % Comment to run the experiment below

%-----------------------Experiment Linear Interpolation--------------------
% works for Steady State and Ramp but not for phase modulation

% calculate all but the first and last values 
for i=2:length(ImpPosSeqPE)-1
    FreqErrFilt(i) = (ImpPosSeqPE(i+1)-ImpPosSeqPE(i-1));
end

% linear extrapolation of first and last values
FreqErrFilt(1)=(2*FreqErrFilt(2))-FreqErrFilt(3); 
n = length(FreqErrFilt-1);
FreqErrFilt(n)= (2*FreqErrFilt(n))-FreqErrFilt(n-1);
FreqErrFilt = FreqErrFilt*(Fs/(4*pi));

for i=2:length(ROCOFErrFilt)-1
    ROCOFErrFilt(i) = FreqErrFilt(i+1)-FreqErrFilt(i-1);
end

% linear extrapolation of first and last values
ROCOFErrFilt(1)=(2*ROCOFErrFilt(2))-ROCOFErrFilt(3);
ROCOFErrFilt(end)=(2*ROCOFErrFilt(end-1))-ROCOFErrFilt(end-2);
ROCOFErrFilt = ROCOFErrFilt*(Fs/2);
end
