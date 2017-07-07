function [ SynxErrFilt] = C37PmuFilt( ...
    N, ...          % filter order
    Bn, ...         % filter coefficients
    Wn, ...         % window coefficients
    FSamp, ...      % system sampling rate
    EvtFreq, ...    % event report frequency vector
    EvtROCOF, ...   % event reported ROCOF vector
    EvtSynx, ...    % even report phasor array
    F0 ...          % nominal frequency
    )
%C37PmuFilt creates error signals based on the unfiltered DFT output sum
% component.

%First some error checking
if (length(EvtFreq) ~= length(EvtSynx(:,1)))
    errMsg = sprintf('Frequency length %d, and Synchrophasor length %d must be the same',...
        length(EvtFreq),length(EvtSynx(1,:)));
    error(errMsg)
end

% Calculate the sumFreq magnitude and phase response
[Hjw] = FirResp ( ...
    N,...
    Bn,...
    Wn,...
    EvtFreq + F0,...
    EvtROCOF, ...      % for now, don't consider ROCOF in the unfiltered sum component
    FSamp...
    );

SynxErrFilt = zeros(size(EvtSynx));
MagErrFilt = zeros(size(EvtSynx));
AngErrFilt = zeros(size(EvtSynx));
FreqErrFilt = zeros(1,length(EvtFreq));
ROCOFErrFilt = zeros(1,length(EvtFreq));

for i = 1:length(EvtSynx(1,:))  
    SynxErrFilt(:,i) = EvtSynx(:,i).*Hjw.*(cos(2*angle(EvtSynx(:,i)))-1i*sin(2*angle(EvtSynx(:,i))));
end

% %--------------------------------------------------------------------------
% % experiment with positive sequence
% Rad120 = (2*pi)/3;
% A = exp(1i*Rad120);
% PosSeqErr =  (SynxErrFilt(:,1) + (A.*SynxErrFilt(:,2))+ (A^2*SynxErrFilt(:,3)))/3;
% figure(200)
% subplot(2,1,1)
% plot (EvtFreq,angle(PosSeqErr))
% subplot(2,1,2)
% plot (EvtFreq,angle(SynxErrFilt(:,1)))

end

