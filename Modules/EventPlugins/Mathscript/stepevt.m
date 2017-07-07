function [timestamp,synx,freq,ROCOF] = stepevt(...
                                                   T0,...
                                                   F0,...
                                                   time,...
                                                   signalparams)
% This is the .m file for the step event in the 
% event module.  Example inputs and outputs
% for the Labview code are listed below.  SignalParams
% descriptions can be found in Event Parameters.docx

%INPUTS:
% T0 = 1;             %UTC Timestamp at time 0
% F0 = 60;            %nominal frequency of the synchrophasor
% time = [-1:1/20:1,1.1:1/10:2,2.25:1/4:3.5,3.51:1/100:4];   %time array
% signalparams = [[70,20]     %Vin/Iin (rms magnitudes)
%                 [61,61]     %Fin (Event fundamental freq)
%                 [0.1,0.1]   %Kx  (Event step magnitude index as a percent of nominal magnitude)
%                 [0.2,0.2]   %Ka  (Event step angle index in degrees)
%                 [0,0]];     %V_Pin/I_Pin (Event initial phase offset at time 0 for voltage and current)
% OUTPUTS:  timestamp[1]
%           synx[2]
%           freq[1]
%           ROCOF[1]

% Start of event description
% Initialize calculation variables
Mag = signalparams(1,:);        %Voltage and current magnitude
Fin = signalparams(2,:);        %Fundamental freq (should be same for voltage and current)
Kx = signalparams(3,:);         %Event step magnitude index as a percent (should be same for voltage and current)
Ka = signalparams(4,:)/180*pi;  %Event step angle index converted to radians(should be same for voltage and current)
Pin = signalparams(5,:)/180*pi; %Initial phase offset for voltage and current

% Precalculate the angular frequencies
W0 = 2*pi*F0;      % Nominal angular frequency
Win = 2*pi*Fin;    % Input fundamental angular frequency

% Generate outputs
timestamp = time + T0;          %Timestamps generated from UTC T0 and time array
synx = zeros(length(time),10);  %3 balanced phases and positive sequence voltage
                                %6 phases of current
                                
% Calculate three phases of voltage and place results in columns 1-3 of synx
% Voltage amplitude with step event at time = 0
Vin = zeros(size(time));
for k = 1:length(time)
    if time(k) < 0
        Vin(k) = Mag(1);
    else
        Vin(k) = Mag(1)*(1+Kx(1));
    end
end

PS = [0, -2*pi/3, 2*pi/3];      %phase shift for 3 balanced phases
for n = 1:3
       phase = (Win(1)*time)...
              -(W0*time)...
              +(Pin(1)+PS(n));
          
       % Apply phase step at time = 0
       for k = 1:length(time)
            if time(k) < 0
                phase(k) = phase(k);
            else
                phase(k) = phase(k)+Ka(1);
            end
       end
       synx(:,n) = Vin.*exp(1i*phase);
end

% Calculate the positive sequence from definition using three phase
% voltages from above
alpha = exp(2/3*pi*1i);
A = [[1,  1,        1]
     [1,  alpha^2,  alpha]
     [1,  alpha,    alpha^2]];
Vabc = (synx(:,1:3)).';     %transpose 3 voltage phases for array multiplication
V012 = A^(-1)*Vabc;         %calculate zero, positive, and negative sequences
synx(:,4) = V012(2,:);      %isolate positive sequence (V1) in 4th column of synx

% Calculate six phases of current (wye = cols 5-7, delta = cols 8-10)
% Current amplitude with step event at time = 0
Iin = zeros(size(time));
for k = 1:length(time)
    if time(k) < 0
        Iin(k) = Mag(2);
    else
        Iin(k) = Mag(2)*(1+Kx(2));
    end
end

PS = [0, -2*pi/3, 2*pi/3];      %phase shift for 3 balanced phases
for n = 1:3
       phase = (Win(2)*time)...
              -(W0*time)...
              +(Pin(2)+PS(n));
       % Apply phase step at time = 0
       for k = 1:length(time)
            if time(k) < 0
                phase(k) = phase(k);
            else
                phase(k) = phase(k)+Ka(2);
            end
       end
       synx(:,n+4) = Iin.*exp(1i*phase);
       synx(:,n+7) = sqrt(3)*Iin.*exp(1i*phase);
end

% Calculate freq and ROCOF arrays by 1st and 2nd derivatives of phase
freq = zeros(size(time));
ROCOF = zeros(size(time));
for t = 1:length(time)
    freq(t) = Fin(1);
    ROCOF(t) = 0;
end