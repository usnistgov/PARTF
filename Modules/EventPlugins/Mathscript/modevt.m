function [timestamp,synx,freq,ROCOF] = modevt(...
                                                   T0,...
                                                   F0,...
                                                   time,...
                                                   signalparams)
% This is the .m file for the modulation event in the 
% event module.  Example inputs and outputs
% for the Labview code are listed below.  SignalParams
% descriptions can be found in Event Parameters.docx
% INPUTS:
% T0 = 1;             %UTC Timestamp at time 0
% F0 = 60;            %nominal frequency of the synchrophasor
% time = [-1:1/20:1,1.1:1/10:2,2.25:1/4:3.5,3.51:1/100:4];   %time array
% signalparams = [[70,20]     %Vin/Iin (rms magnitudes)
%                 [61,61]     %Fin (Event fundamental freq)
%                 [0,0]       %V_Pin/I_Pin (Event initial phase offset at time 0 for voltage and current)
%                 [1,1]       %Fx  (Event amplitude modulation frequency)
%                 [2,2]       %Fa  (Event phase (angle) modulation frequency)
%                 [0,0]       %Px  (Event amplitude modulation (AM) initial phase offset at time 0)
%                 [0,0]       %Pa  (Event phase (angle) modulation initial phase offset at time 0)
%                 [0.1,0.1]       %Kx  (Event amplitude modulation index in percent)
%                 [0.2,0.2]];     %Ka  (Event phase modulation index in percent)
% OUTPUTS:  timestamp[1]
%           synx[2]
%           freq[1]
%           ROCOF[1]

% Start of event description
% Initialize calculation variables
Mag = signalparams(1,:);        %Voltage and current magnitude
Fin = signalparams(2,:);        %Fundamental freq (should be same for voltage and current)
Pin = signalparams(3,:)/180*pi; %Initial phase offset for voltage and current
Fx = signalparams(4,:);         %AM frequency (should be same for voltage and current)
Fa = signalparams(5,:);         %PM frequency (should be same for voltage and current)
Px = signalparams(6,:)/180*pi;  %AM initial phase offset (should be same for voltage and current)
Pa = signalparams(7,:)/180*pi;  %PM initial phase offset (should be same for voltage and current)
Kx = signalparams(8,:);         %AM index (should be same for voltage and current)
Ka = signalparams(9,:);         %PM index (should be same for voltage and current)

% Precalculate the angular frequencies
W0 = 2*pi*F0;      % Nominal angular frequency
Win = 2*pi*Fin;    % Input fundamental angular frequency
Wa = 2*pi*Fa;      % PM angular frequency
Wx = 2*pi*Fx;      % AM angular frequency

% Generate outputs
timestamp = time + T0;          %Timestamps generated from UTC T0 and time array
synx = zeros(length(time),10);  %3 balanced phases and positive sequence voltage
                                %6 phases of current
                                
% Calculate three phases of voltage and place results in columns 1-3 of synx
% Voltage amplitude and AM
Vin = Mag(1)*(1+Kx(1)*cos(Wx(1)*time+Px(1)));

PS = [0, -2*pi/3, 2*pi/3];      %phase shift for 3 balanced phases
for n = 1:3
       phase = (Win(1)*time)...
              -(W0*time)...
              -(Ka(1)*cos(Wa(1)*time+Pa(1)))...
              +(Pin(1)+PS(n));
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
% Current amplitude and AM
Iin = Mag(2)*(1+Kx(2)*cos(Wx(2)*time+Px(2)));

PS = [0, -2*pi/3, 2*pi/3];      %phase shift for 3 balanced phases
for n = 1:3
       phase = (Win(2)*time)...
              -(W0*time)...
              -(Ka(2)*cos(Wa(2)*time+Pa(2)))...
              +(Pin(2)+PS(n));
       synx(:,n+4) = Iin.*exp(1i*phase);
       synx(:,n+7) = sqrt(3)*Iin.*exp(1i*phase);
end

% Calculate freq and ROCOF arrays by 1st and 2nd derivative of theta
freq = (Win(1) -(-Ka(1)*Wa(1))*sin(Wa(1)*time))/(2*pi);
ROCOF = (((Ka(1)*Wa(1)^2)*cos(Wa(1)*time)))/(2*pi);