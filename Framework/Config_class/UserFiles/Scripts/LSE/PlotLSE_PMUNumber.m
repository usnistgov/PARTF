close all; 
clc;
%clear all

dist_plots=0;

[dfile,pathname]=uigetfile('*.mat','Select Data File');
if pathname == 0
   error(' you must select a valid data file')
else
   load([pathname dfile]);
end

IEEE_Sys = size(AppOutput{1}.LSEOutput.SystemVoltagesRef,2);
num_repetitions=length(AppOutput)/IEEE_Sys;
app_name=fieldnames(AppOutput{1});

fprintf('---------------------- %s --------------------------\n',app_name{1});


%% Data Analysis

%clearvars -except EventParams EventTime AppOutput num_repetitions dist_plots IEEE_Sys


for i=1:length(EventTime)
    time(i)=EventTime{i};
end

if(prod(time>=0))
    begin_index=1;
else
    begin_index = find(abs(time)==min(abs(time)));
end
time=time(begin_index:end);

RAMSE=zeros(1,IEEE_Sys);
Obs=zeros(1,IEEE_Sys);


for j=1:IEEE_Sys
    err_mag_total=[];
    err_phase_total=[];
    ep_ve_total=[];
    for i=num_repetitions*(j-1)+1:num_repetitions*j
        err_mag=zeros(length(time),length(AppOutput{1}.LSEOutput.Bus));
        err_phase=err_mag;
        ep_ve=err_mag;
        for k=1:length(AppOutput{i}.LSEOutput.Bus)
            n=AppOutput{i}.LSEOutput.Bus(k);
            ep_ve(:,n)=abs(AppOutput{i}.LSEOutput.SystemVoltagesRef(:,n)-AppOutput{i}.LSEOutput.Vestimate(:,n)); 
            err_mag(:,n)=abs(AppOutput{i}.LSEOutput.SystemVoltagesRef(:,n))-abs(AppOutput{i}.LSEOutput.Vestimate(:,n));
            err_phase(:,n)= angle(AppOutput{i}.LSEOutput.SystemVoltagesRef(:,n))-angle(AppOutput{i}.LSEOutput.Vestimate(:,n));
        end
        err_mag_total=[err_mag_total; err_mag];
        err_phase_total=[err_phase_total; err_phase];
        ep_ve_total = [ep_ve_total; ep_ve];
    end

RAMSE(IEEE_Sys-j+1) = sqrt(mean(mean(ep_ve_total.^2)));
Obs(IEEE_Sys-j+1)= (IEEE_Sys-sum(ep_ve(1,:)==0))/IEEE_Sys *100;

end


%% Plots

f1=figure('Name','RAMSE','NumberTitle','off','Color','w','Position',[100 700 800 400]);
plot(1:IEEE_Sys,RAMSE,'Linewidth',2)
xlabel('Number of PMUs')
ylabel('RAMSE [p.u.]')

f2=figure('Name','Observability','NumberTitle','off','Color','w','Position',[1000 700 800 400]);
plot(1:IEEE_Sys,Obs,'Linewidth',2)
xlabel('Number of PMUs')
ylabel('Buses Observed [%]')

