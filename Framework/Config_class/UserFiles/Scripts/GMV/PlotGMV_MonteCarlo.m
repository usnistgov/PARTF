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

num_repetitions=length(AppOutput)/length(NoiseVariances);
app_name=fieldnames(AppOutput{1});

fprintf('---------------------- %s --------------------------\n',app_name{1});


%% Data Analysis

%clearvars -except EventParams EventTime AppOutput num_repetitions dist_plots IEEE_Sys

d2aem

H=mac_con(1,16);
Xd_p=mac_con(1,7);
D=mac_con(1,17);

for i=1:length(EventTime)
    time(i)=EventTime{i};
end

if(prod(time>=0))
    begin_index=1;
else
    begin_index = find(abs(time)==min(abs(time)));
end
time=time(begin_index:end);

err_H=zeros(length(NoiseVariances),num_repetitions);
err_D=zeros(length(NoiseVariances),num_repetitions);
err_Xd_p=zeros(length(NoiseVariances),num_repetitions);

for i=1:length(NoiseVariances)
    for k=1:num_repetitions
        err_H(i,k)=AppOutput{(i-1)*num_repetitions+k}.ModelValidationOutput.xk(3,end)-H; 
        err_Xd_p(i,k)=AppOutput{(i-1)*num_repetitions+k}.ModelValidationOutput.xk(4,end)-Xd_p;
        err_D(i,k)=AppOutput{(i-1)*num_repetitions+k}.ModelValidationOutput.xk(5,end)-D;
    end
end


%% Plots

threshold=H; %TVE percent
threshold_const=threshold/50*ones(1,size(err_H,2)+1);
f1=figure('Name','Inertia Constant','NumberTitle','off','Color','w','Position',[100 200 800 400]);
boxplot(err_H.'); hold on
plot(0.5:1:size(err_H,2)+0.5,threshold_const,'--k')
plot(0.5:1:size(err_H,2)+0.5,-threshold_const,'--k')
ylim([-1.4*threshold_const(1) 1.4*threshold_const(1)])
xlabel('Noise Variance Set')
ylabel('Inertia Constant Magnitude Error[p.u.]')
legend('Threshold')
%
threshold=Xd_p; %TVE percent
threshold_const=threshold/100*ones(1,size(err_H,2)+1);
f2=figure('Name','Transient Reactance','NumberTitle','off','Color','w','Position',[100 200 800 400]);
boxplot(err_Xd_p.'); hold on
plot(0.5:1:size(err_Xd_p,2)+0.5,threshold_const,'--k')
plot(0.5:1:size(err_Xd_p,2)+0.5,-threshold_const,'--k')
ylim([-1.4*threshold_const(1) 1.4*threshold_const(1)])
xlabel('Noise Variance Set')
ylabel('Magnitude Error of x´d [p.u.]')
legend('Threshold')

threshold=D; %TVE percent
threshold_const=threshold/50*ones(1,size(err_H,2)+1);
f3=figure('Name','Damping','NumberTitle','off','Color','w','Position',[100 200 800 400]);
boxplot(err_D.'); hold on
plot(0.5:1:size(err_D,2)+0.5,threshold_const,'--k')
plot(0.5:1:size(err_D,2)+0.5,-threshold_const,'--k')
ylim([-1.4*threshold_const(1) 1.4*threshold_const(1)])
xlabel('Noise Variance Set')
ylabel('Damping Magnitude Error[p.u.]')
legend('Threshold') 
% 
% %% Print in Command Window
% fprintf(['\nMonte Carlo Analysis:  ' num2str(num_repetitions) ' iterations\n\n'])
% 
% if(isequal(tve_total<threshold,ones(size(tve_total))))
%     fprintf('<a href="">                       COMPLETE                            </a>\n');
% else
%     fprintf(2,'                       FAILURE\n');
%     fprintf(2,'-----------------------------------------------------------\n');
% end
% 
% fprintf('-----------------------------------------------------------\n\n')

