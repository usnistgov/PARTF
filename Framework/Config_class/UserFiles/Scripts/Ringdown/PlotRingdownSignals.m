close all; clc; clear all

[dfile,pathname]=uigetfile('*.mat','Select Data File');
if pathname == 0
   error(' you must select a valid data file')
else
   load([pathname dfile]);
end

app_name='Ringdown';

fprintf('-------------------- %s -----------------------\n',app_name);


%% Data Analysis

clearvars -except EventParams EventTime EventInput num_repetitions

for i=1:length(EventTime)
    time(i)=EventTime{i};
end

if(prod(time>=0))
    begin_index=1;
else
    begin_index = find(abs(time)==min(abs(time)));
end
time=time(begin_index:end);

data_len=length(EventInput.clEvtReportArray);

voltage=zeros(1,data_len);
current=zeros(1,data_len);
freq=zeros(1,data_len);
ROCOF=zeros(1,data_len);

for i=1:data_len
    voltage(i)=EventInput.clEvtReportArray{i}.clReportArg.Synx(1);
    current(i)=EventInput.clEvtReportArray{i}.clReportArg.Synx(4);
    freq(i)=EventInput.clEvtReportArray{i}.clReportArg.Freq;
    ROCOF(i)=EventInput.clEvtReportArray{i}.clReportArg.ROCOF;
end

f1=figure('Name','Voltage (V)','NumberTitle','off','Color','w','Position',[100 700 800 400]);
subplot(2,1,1)
plot(time,abs(voltage))
ylabel('Magnitude [Volt]')
title('Bus voltage signal')
subplot(2,1,2)
plot(time,phase(voltage))
ylabel('Phase [rad]')
xlabel('Time [s]')

f2=figure('Name','Current (I)','NumberTitle','off','Color','w','Position',[1000 700 800 400]);
subplot(2,1,1)
plot(time,abs(current))
ylabel('Magnitude [Amp]')
title('Bus current signal')
subplot(2,1,2)
plot(time,phase(current))
ylabel('Phase [rad]')
xlabel('Time [s]')

f3=figure('Name','Frequency and ROCOF','NumberTitle','off','Color','w','Position',[1000 150 800 400]);
subplot(2,1,1)
plot(time,freq)
title('Bus Frequency and ROCOF')
ylabel('Frequency [Hz]')
xlabel('Time [s]')
subplot(2,1,2)
plot(time,ROCOF)
ylabel('ROCOF [Hz/s]')
xlabel('Time [s]')


