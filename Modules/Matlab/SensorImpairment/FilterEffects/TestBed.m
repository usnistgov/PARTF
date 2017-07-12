


FSamp = 960;    % internal PMU sample rate
F0 = 60;        % nominal frequency
Fs = 60;        % reporting rate

N = 164;        % filter order (one less than the number of coefficients)
WindowType = 'Hamming';
Fr = 8.19;      % filter cutoff frequency

%time
t = (0-((N+1)/FSamp):1/FSamp:1);

% Signal Parameters
Xm = [X,X,X,X,X,X];
Fin = [61,60,60,60,60,60];
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

signalparams = [Xm;Fin;Ps;Fh;Ph;Kh;Fa;Ka;Fx;Kx;Rf;KaS;KxS];

Signal = genC37Signal (t, FSamp, signalparams);
% plot(Signal(1,:));

%DFT
DFT = zeros(length(Xm),length(t));
for i = 1:length(Xm)
    DFT(i,:) = sqrt(2) .* Signal(i,:) .* exp(1i * (2*pi*F0) .* t);
end
%plot
% figure(1)
% subplot(2,1,1)
% plot(abs(DFT(1,:)))
% subplot(2,1,2)
% plot(unwrap(angle(DFT(1,:))))
% 
% get the filter coefficients
Bn = FIR(N,Fr,FSamp);               % unnormalized coefficients
Wn = (Window(N,WindowType)).';
Bn = Bn.*Wn;
Bn = Bn./sum(Bn);                   % normalized coefficients

% filter the DFT
for i = 1:length(Xm)
    DFT(i,:) = filter(Bn,1,real(DFT(i,:))) + 1i*filter(Bn,1,imag(DFT(i,:)));
end
% the filter has a step response at the beginning
DFT = DFT(:,((N+1)+(N/2)+1:end));
%DFT = DFT(:,((N+1):end));

% figure(2)
% subplot(2,1,1)
% plot(abs(DFT(1,:)))
% subplot(2,1,2)
% plot(unwrap(angle(DFT(1,:))))

% decimate
ImpSynx = zeros(length(Xm),floor(N/(FSamp/Fs)));
for j = 1:length(Xm)
    i = 1;
    for k = 1:FSamp/Fs:length(DFT(1,:))
        ImpSynx(j,i) = DFT(j,k);
        i = i+1;
    end
end
    
figure(2)
subplot(2,1,1)
plot(abs(ImpSynx(1,:)))
subplot(2,1,2)
plot(unwrap(angle(ImpSynx(1,:))))