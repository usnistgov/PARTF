close all
clear all
%% Default parameters
timevector=[0:1/60:1000]'; % time vector - I set a long time period to see long term drift behavior
stat=logical([zeros(length(timevector),16)]); % stat message formatted as per IEEE Std. C37.118.2-2011
p_up=.05;                  % p_up is the probability of transferring from locked to the unlocked state (1-reliability of the gps system) [http://www.gps.gov/technical/ps/2008-SPS-performance-standard.pdf]
q_down= 0.5;               % q_down is the probability of transferring from unlocked to locked state (redundancy of satellite coverage* recovery probability of the GPS receiver)
                           % Set q_down to zero if you want to simulate a device failure
%Clock parameters drawn from [http://tf.nist.gov/general/tn1337/Tn264.pdf]
bias=1.049e-10;            % frequency bias in the local clock
drift=-6.709e-16;          % frequency drift rate for the local clock
clock_noise=2.73e-16;      % inherent white phase noise in the timing components
%% Main function
[linkstate, unlocked_time, phase_error, stat] = timingerrorcode(timevector, p_up, q_down, bias, drift, clock_noise, stat);
%% Pretty pictures
figure(1)
stairs(timevector,linkstate, 'LineWidth',3);
ylabel('1/0');
xlabel('Simulation time (Secs.)');
title('GPS lock status - 1 when locked and 0 when lost');
figure(2)
plot(timevector, phase_error);
title('Clock error estimate used to set PMU time quality codes');
ylabel('Secs.');
xlabel('Simulation time (Secs.)');
figure(3)
plot(timevector, unlocked_time)
title('Time elapsed since GPS lock loss - used to set Unlocked time codes');
ylabel('Secs.');
xlabel('Simulation time (Secs.)');