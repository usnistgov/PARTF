clc; clear all
close all
%%

real_data=load('Z:\My Documents\Projects\PARTF\trunk\Framework\Applications\AppPlugins\Mathscript\Ringdown\RingdownPMUData.mat');
synthetic_data=csvread('Z:\My Documents\Projects\PARTF\trunk\Framework\Applications\AppPlugins\Mathscript\Ringdown\input_variables\synt_ring.csv');

Data=real_data.RingdownPMUData(1:end-1,:);
clear real_data

time=Data(:,1);
freq=Data(:,2);
V_amp=Data(:,3);
V_phase=deg2rad(Data(:,4));
I_amp=Data(:,5);
I_phase=deg2rad(Data(:,6));
P=Data(:,7);
Q=Data(:,8);


S=sqrt(3)*V_amp.*exp(1i*V_phase).*I_amp.*exp(-1i*I_phase);
p=real(S);
q=imag(S);

%%

plot(time,P,'Linewidth',2); hold all;
plot(time,p,'Linewidth',2);
legend('PMU','Matlab')
title('Active Power')
ylabel('Amplitude')
xlabel('Time [s]')

figure
subplot(2,1,1)
plot(time,V_amp,'Linewidth',2)
title('Voltage')
ylabel('Amplitude')
subplot(2,1,2)
plot(time,V_phase,'Linewidth',2)
ylabel('Phase')
xlabel('Time [s]')

figure
subplot(2,1,1)
plot(time,I_amp,'Linewidth',2)
title('Current')
ylabel('Amplitude')
subplot(2,1,2)
plot(time,I_phase,'Linewidth',2)
ylabel('Phase')
xlabel('Time [s]')

figure
plot(time(3292:3292+399),P(3292:3292+399),'Linewidth',2); hold all
plot(time(3292:3292+399),synthetic_data(:,2),'Linewidth',2)
legend('measurements','MATLAB (prony)')
title('Active Power - Ringdown event')
ylabel('Amplitude')
xlabel('Time [s]')

figure
plot(time(3292:3292+399),Q(3292:3292+399),'Linewidth',2); hold all
%plot(synthetic_data(:,2),'Linewidth',2)
%legend('measurements','MATLAB (prony)')
title('Reactive Power - Ringdown event')
ylabel('Amplitude')
xlabel('Time [s]')
