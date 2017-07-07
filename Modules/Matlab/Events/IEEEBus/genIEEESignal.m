function [Signal] = genIEEESignal( ...
    t, ...
    FSamp, ...
    signalparams, ...
    bus)

% This is the .m file for the MultiBus theoretical signal event for the event
% module.

if(mod(FSamp,50))
    F0=60;
else
    F0=50;
end

    Xm = signalparams(1,:)*sqrt(2);     % phase amplitudes
    Ps = signalparams(2,:);     % phase angles
    Noise = signalparams(3,:);     % Noise
    [Xm,Ps,Noise]= conv3phase(Xm,Ps,Noise);       
    Fin = F0*ones(size(Xm));    % frequency (must be the same for all 6 channels or an error will be thrown  
    Fa = zeros(size(Xm));     % phase (angle) moduation frequency
    Ka = zeros(size(Xm));     % phase (angle) moduation index
    Fx = zeros(size(Xm));     % amplitude moduation frequency
    Kx = zeros(size(Xm));     % amplitude moduation index
    Rf = zeros(size(Xm));     % ROCOF
    KaS = zeros(size(Xm));   % magnitude step index
    KxS = zeros(size(Xm));   % phase (angle) step index    
    Fh = zeros(size(Xm));     % Frequency of the interfering signal
    Ph = zeros(size(Xm));     % Phase of the interfering signal
    Kh = zeros(size(Xm));     % index of the interfering signal       
                                    
% Phases in radians
Ps = Ps*pi/180;
Ph = Ph*pi/180;
    
% calculate the angular frequencies
Wf = 2*pi*Fin;  % fundamental frequency
Wa = 2*pi*Fa;   % phase (angle) modulation frequency
Wx = 2*pi*Fx;   % amplitude modulation frequency
%Wh = 2*pi*Fh;

% Amplitude, AM and magnitude step
Ain = zeros(length(t),length(Xm));
for i = 1:length(Xm)
    Ain(:,i) = Xm(i) *(1+Kx(i)*cos((Wx(i)*t)+Ps(i)));
    % Amplitude Step: applied after time passes 0
    Ain(t >= 0,i) = Ain(t >= 0,i) * (1 + KxS(i));
    Ain(:,i)= Ain(:,i)+Noise(i)*randn(length(t),1);
end

% Phase
Theta = zeros(length(t),length(Ps));
for i = 1:length(Ps)
    Theta(:,i) = (Wf(i)*t) ...                         % Fundamental
                 + Ps(i) ...               % phase shift
                 - ( ...                 
                    -(Ka(i)*cos((Wa(i)*t)-pi)) ...     % Phase modulation
                    - (Rf(i) * pi * t.^2) ...       % frequency ramp
                  );
    Theta(:,i)= Theta(:,i)+Noise(i)*randn(length(t),1); %Random noise
end

% Phase Step
for i = 1:length(KaS)
    Theta(t >= 0,i) = Theta(t >= 0,i) + (KaS(i) * pi/180);
end

% Complex signals
cSignal = (Ain.*exp(-1i.*Theta));

% Add a single harmonic
if (Fh > FSamp/2)
    error('Interfering signal frequency is above PMU Nyquist frequency.  Can not generate');
end % if

% for i = 1:length(Wh)
%     ThetaH(:,i) = Wh(i)*t + Ph(i);
%     cSignal(:,i) = cSignal(:,i) + ((Kh(i) * (sqrt(2)*Xm(i))) * (cos(ThetaH(:,i)) + 1i*sin(ThetaH(:,i))));
% end

Signal = real(cSignal);

end  %function