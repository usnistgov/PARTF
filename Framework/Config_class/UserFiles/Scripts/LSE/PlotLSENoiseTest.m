close all; 
clc;
clear all

dist_plots=0;

[dfile,pathname]=uigetfile('*.mat','Select Data File');
if pathname == 0
   error(' you must select a valid data file')
else
   load([pathname dfile]);
end

num_repetitions=length(AppOutput);
app_name=fieldnames(AppOutput{1});

fprintf('---------------------- %s --------------------------\n',app_name{1});


%% Data Analysis

clearvars -except EventParams EventTime AppOutput num_repetitions dist_plots
effectiveness=100;

for i=1:length(EventTime)
    time(i)=EventTime{i};
end

if(prod(time>=0))
    begin_index=1;
else
    begin_index = find(abs(time)==min(abs(time)));
end
time=time(begin_index:end);

tse=[];
err_phase=[];
err_mag=zeros(length(time),length(AppOutput{1}.LSEOutput.Bus));
err_mag_total=[];
err_phase_total=[];
tve_total=[];

for i=1:num_repetitions
tve=[];
for k=1:length(AppOutput{i}.LSEOutput.Bus)
    n=AppOutput{i}.LSEOutput.Bus(k);
    tve(:,n)=100*abs(AppOutput{i}.LSEOutput.SystemVoltagesRef(:,n)-AppOutput{i}.LSEOutput.Vestimate(:,n))./abs(AppOutput{i}.LSEOutput.SystemVoltagesRef(:,n)); 
    err_mag(:,n)=abs(AppOutput{i}.LSEOutput.SystemVoltagesRef(:,n))-abs(AppOutput{i}.LSEOutput.Vestimate(:,n));
    err_phase(:,n)= angle(AppOutput{i}.LSEOutput.SystemVoltagesRef(:,n))-angle(AppOutput{i}.LSEOutput.Vestimate(:,n));
end
err_mag_total=[err_mag_total; err_mag];
err_phase_total=[err_phase_total; err_phase];
tve_total = [tve_total; tve];

for k=1:size(tve,1)
    tse_aux(k)=norm(tve(k,:));
end
    tse=[tse tse_aux];
end

%% Plots

threshold=0.05; %TVE percent
threshold_const=threshold/100*ones(1,size(err_mag_total,2)+1);
f1=figure('Name','Magnitude','NumberTitle','off','Color','w','Position',[100 700 800 400]);
boxplot(err_mag_total); hold on
plot(0.5:1:size(err_mag_total,2)+0.5,threshold_const,'--k')
plot(0.5:1:size(err_mag_total,2)+0.5,-threshold_const,'--k')
ylim([-1.4*threshold_const(1) 1.4*threshold_const(1)])
xlabel('Bus Number')
ylabel('Magnitude Error [p.u.]')
legend('Threshold')

f2=figure('Name','Angle','NumberTitle','off','Color','w','Position',[1000 700 800 400]);
boxplot(err_phase_total); hold on
plot(0.5:1:size(err_mag_total,2)+0.5,threshold_const,'--k')
plot(0.5:1:size(err_mag_total,2)+0.5,-threshold_const,'--k')
ylim([-1.1*threshold_const(1) 1.1*threshold_const(1)])
xlabel('Bus Number')
ylabel('Phase Error [rad]')
legend('Threshold')

f3=figure('Name','TVE','NumberTitle','off','Color','w','Position',[450 100 1050 500]);
boxplot(tve_total); hold on
plot(0.5:1:size(err_mag_total,2)+0.5,100*threshold_const,'--k')
ylim([0 160*threshold_const(1)])
xlabel('Bus Number')
ylabel('TVE [%]')
legend('Threshold')

if(dist_plots)
    
    figure
    h1 = histogram(tve_total(:,1),'Normalization','pdf');
    hold on
    bus_tve=5;
    pd = fitdist(tve_total(:,bus_tve),'rayleigh');
    y = pdf(pd,linspace(min(tve_total(:,bus_tve)),max(tve_total(:,bus_tve)),100));
    plot(linspace(min(tve_total(:,bus_tve)),max(tve_total(:,bus_tve)),100),y)
    legend('TVE norm. histogram',['Rayleigh (B= ' num2str(pd.B)])
    ylabel('PDF')
    xlabel('TVE')

    figure
    err_mag=reshape(err_mag_total,size(err_mag_total,1)*size(err_mag_total,2),1);
    err_mag(err_mag==0)=[];
    h2 = histogram(err_mag,'Normalization','pdf');    hold on
    [mu,s] = normfit(err_mag);
    plot(linspace(min(err_mag),max(err_mag),100),normpdf(linspace(min(err_mag),max(err_mag),100),mu,s))
    legend('Mag. norm. histogram',['Gaussian (mu= ' num2str(mu) ', sigma=' num2str(s)])
    ylabel('PDF')
    xlabel('Phasor Magnitude')

    figure
    err_phase=reshape(err_phase_total,size(err_phase_total,1)*size(err_phase_total,2),1);
    err_phase(err_phase==0)=[];
    h2 = histogram(err_phase,'Normalization','pdf'); hold on
    [mu,s] = normfit(err_phase);
    plot(linspace(min(err_phase),max(err_phase),100),normpdf(linspace(min(err_phase),max(err_phase),100),mu,s))
    legend('Phase norm. histogram',['Gaussian (mu= ' num2str(mu) ', sigma=' num2str(s)])
    ylabel('PDF')
    xlabel('Phasor Phase')
end

% for i=0:num_repetitions-1
%     fprintf('%.26f\n',std(tse(241*i+1:241*i+241)))
% end
%figure
%plot(time,tse)

%% Print in Command Window
fprintf(['\nMonte Carlo Analysis:  ' num2str(num_repetitions) ' iterations\n\n'])

if(isequal(tve_total<threshold,ones(size(tve_total))))
    fprintf('<a href="">                       COMPLETE                            </a>\n');
else
    fprintf(2,'                       FAILURE\n');
    fprintf(2,'-----------------------------------------------------------\n');
end

fprintf('-----------------------------------------------------------\n\n')