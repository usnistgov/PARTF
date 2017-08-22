function [timestamp,synx,freq,ROCOF] = IEEEevt( ...
    T0, ...
    F0, ...
    time, ...
    signalparams, ...
    bPosSeq)

% This is the .m file for the Ringdown theoretical signal event for the event
% module.

    Xm = signalparams(1,:);%signalparams(3*bus-2,2:end);     % phase amplitudes
    Ps = signalparams(2,:);%signalparams(3*bus-1,2:end);     % phase angles
    Noise = signalparams(3,:);%signalparams(3*bus,2:end);     % Noise
    [Xm,Ps,Noise]= conv3phase(Xm,Ps,Noise);    
    
    Fin = F0*ones(size(Xm));    % frequency (must be the same for all 6 channels or an error will be thrown  
    Fa = zeros(size(Xm));     % phase (angle) moduation frequency
    Ka = zeros(size(Xm));     % phase (angle) moduation index
    Fx = zeros(size(Xm));     % amplitude moduation frequency
    Kx = zeros(size(Xm));     % amplitude moduation index
    Rf = zeros(size(Xm));     % ROCOF
    KaS = zeros(size(Xm));   % magnitude step index
    KxS = zeros(size(Xm));   % phase (angle) step index
    

    
% Phase in radians
Ph = Ps*pi/180;
    
% precalculate the angular frequencies
W0 = 2*pi*F0;     % Nominal angular frequency
Win = 2*pi*Fin;    % Input fundamental angular frequency
Wa = 2*pi*Fa;      % PM angular frequency
Wx = 2*pi*Fx;      % AM angular frequency

% Amplitude, AM and magnitude step
for i = 1:length(Xm)
    Ain(i,:) = Xm(i) *(1+(Kx(i)*cos((Wx(i)*time)+Ph(i))));
    % Amplitude Step: applied after time passes 0
    Ain(i,time >= 0) = Ain(i,time >= 0) * (1 + KxS(i));
    Ain(i,:)= Ain(i,:)+Noise(i)*randn(1,length(time));
end

% Phase
for i = 1:length(Ps)
    Theta(i,:) = (W0*time) ...                   % Nominal
                 - ( ...                 
                    (Win(i)*time) ...               % Fundamental
                    + Ph(i) ...    
                    + (Ka(i).*cos((Wa(i)*time - pi))) ...  % Phase modulation
                    + (Rf(i) * pi * time.^2) ...        % frequency ramp
                  );
    Theta(i,:)= Theta(i,:)+Noise(i)*randn(1,length(time)); %Random noise
end
 
% Phase Step
for i = 1:length(KaS)
    Theta(i,time >= 0) = Theta(i,time >= 0) - (KaS(i) * pi/180);
end

% Synchrophasors
synx = (Ain.*exp(-1i.*Theta)).';

if bPosSeq
    %for each group of 3 phases, create a positive sequence
    phases = synx;
    for i = 1:floor(length(Xm)/3)    % How many groups of 3 are there?
        group = phases(:,((i-1)*3)+1:((i-1)*3)+3);
        posSeq = calcPosSeq(group).';
        index = ((i-1)*3)+(2+i);
        synx = [synx(:,1:index),posSeq,synx(:,index+1:end)];
    end
end

%Frequency, ROCOF
for i = 1:length(Win)
freq = (Win(i) ...                              % Fundamental 
     - (Ka(i)*(Wa(i)))*sin(Wa(i).*time-pi) ...      % Phase modulation
     + (Rf(i)*2*pi.*time) ...                   % Frequency Ramp
     )/(2*pi);                                  % Hz/Radians
 
 ROCOF = ( ...
            (Ka(i)*Wa(i)^2)*cos(Wa(i).*time) ...    % Phase modulaton
            + (Rf(i)*(2*pi)) ...                    % Frequency Ramp
         )/(2*pi);                                  % Hz / Radians
end

%freq = freq.';		% Do not transpose for Matlab Script Node, transpose for Mathscript
%ROCOF = ROCOF.';	% Do not transpose for Matlab Script Node, transpose for Mathscript

%Timestamp
timestamp = time + T0;

end
