clear all

times=2;
RAMSE_times=[]; 
Obs_times=[];

for p=1:times
    clearvars -except RAMSE_times Obs_times times p
    PlotLSE_PMUNumber
    RAMSE_times(p,:)=RAMSE;
    Obs_times(p,:)=Obs;
end
close all


%% Plots

f1=figure('Name','RAMSE','NumberTitle','off','Color','w','Position',[100 700 800 400]);
plot(1:IEEE_Sys,RAMSE_times,'Linewidth',2)
xlim([1 IEEE_Sys])
xlabel('Number of PMUs')
ylabel('RAMSE [p.u.]')
legend('Descending order','Using current channels')

f2=figure('Name','Observability','NumberTitle','off','Color','w','Position',[1000 700 800 400]);
plot(1:IEEE_Sys,Obs_times,'Linewidth',2)
xlim([1 IEEE_Sys])
xlabel('Number of PMUs')
ylabel('Buses Observed [%]')
legend('Descending order','Using current channels')
