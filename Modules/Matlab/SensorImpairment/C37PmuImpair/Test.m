function [ImpTimestamp,...
          ImpSynx,...
          ImpFreq,...
          ImpROCOF] = Test ( ...
                        EvtTimestamp, ...
                        Signal, ...
                        ImpParams, ...
                        WindowType, ...
                        T0, ...
                        F0, ...
                        Fs, ...
                        FSamp ...
                      )  

                  
if (FSamp/Fs)-floor(FSamp/Fs) ~= 0
    error('Error: Sample Rate must be an integer multiple of the reporting rate')
else                  
                  
% ImpParams
Fr = ImpParams(1,1);        % Filter cutoff frequency
N = ImpParams(2,1);         % Filter order (there will be one more sample than the order number)

Nphases = length(Signal(:,1));                 

% From EvtTimestamp and T0 plus the filter group delay,
% calculate time vector, add (negative) time at the beginning for the
% filter step response
filterDelay = ((N+1)+(N/2)+1);  % The center of the next window after the start
tStart = (EvtTimestamp - T0)-(filterDelay/FSamp); % ensure the signal has N+1 extra samples at the beginning
tEnd = tStart + ((length(Signal(1,:))-1)/FSamp);
t = (tStart:1/FSamp:tEnd);
%
% 
% DFT
DFT = zeros(Nphases,length(t));
for i = 1:Nphases
    DFT(i,:) = sqrt(2) .* Signal(i,:) .* exp(-1i * (2*pi*F0) .* t);   
end

% % get the filter coefficients
Bn = FIR(N,Fr,FSamp);               % unnormalized coefficients
Wn = (PMU_Window(N,WindowType));
Wn = Wn.';

% switch WindowType
%     case 'Blackman'
%         Wn = win_blackman(N+1);
% % %         M = round(N/2);
% % %         w = zeros(N,1);
% % %         for n = 0:M-1
% % %             w(n+1) = 0.42-0.5*cos(2*pi*n/(N-1)) + 0.08*cos(4*pi*n/(N-1));
% % %         end
% % %         for n = 1:M-1
% % %             w(M+n) = w(M-n);
% % %         end% Wn = (Window(N,WindowType)).';
%     otherwise
%         error('Unknown window type')
% end
% Bn = Bn.*Wn;
% Bn = Bn./sum(Bn);                   % normalized coefficients

% Nsynx = floor((length(t))/(FSamp/Fs));
% ImpSynx = zeros(Nphases,Nsynx);
% ImpFreq = zeros(1,Nsynx);
% ImpROCOF = ImpFreq;
% ImpTimestamp = zeros(1,Nsynx);

ImpSynx = zeros(2,2);
ImpFreq = zeros(1,2);
ImpROCOF = ImpFreq;
ImpTimestamp = zeros(1,2);

end % function