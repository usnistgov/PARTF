close all; clc; clear all

[dfile,pathname]=uigetfile('*.mat','Select Data File');
if pathname == 0
   error(' you must select a valid data file')
else
   load([pathname dfile]);
end

num_repetitions=length(AppOutput);
app_name=fieldnames(AppOutput{1});

fprintf('-------------------- %s -----------------------\n',app_name{1});


%% Data Analysis

clearvars -except EventParams EventTime AppOutput num_repetitions
%----------  Paramas and Metrics ------------
num_modes=4;
freq_std=0.025;
damp_std=0.25;
phi=-pi:0.02:pi;
neg_thres=1e-3;
error_thres=0.2;
err_delay=0.14;

assert(num_modes<= ...
        length(AppOutput{1}.RingdownOutput.RingdownParameters.Damping),...
    'The number of modes to visualize excedees the number of modes of the data');
    
for i=1:length(EventTime)
    time(i)=EventTime{i};
end

if(prod(time>=0))
    begin_index=1;
else
    begin_index = find(abs(time)==min(abs(time)));
end
time=time(begin_index:end);

f1=figure('Name','Time Domain Results','NumberTitle','off','Color','w','Position',[100 300 900 600]);
subplot(2,1,1)
plot(time,AppOutput{1}.RingdownOutput.InputSignal,'b','LineWidth',2)
hold all
title('Prony Estimate')
ylabel('Active Power Magnitude [W]')

for i=1:num_repetitions
    subplot(2,1,1)
    plot(time,AppOutput{i}.RingdownOutput.PronyEstimate(begin_index:end))
    subplot(2,1,2)
    error_sig=abs(AppOutput{i}.RingdownOutput.PronyEstimate(begin_index:end)...
        -AppOutput{i}.RingdownOutput.InputSignal);    
    error_cond(i,:)=error_sig>error_thres;
    plot(time,error_sig)    
    hold all
end
h1=plot(time(1:5:end),error_thres*ones(size(time(1:5:end))),'k--');
legend(h1,'Thereshold')
ylabel('Error signal [W]')
xlabel('Time [s]')

f2 = figure('Name','Frequency Domain Results','NumberTitle','off','Color','w','Position',[1100 300 600 500]);
TH=zeros(num_repetitions*num_modes,1);
R=TH;

for i=1:num_repetitions
    [AppOutput{i}.RingdownOutput.RingdownParameters.Amplitude,index] = ...
        sort(AppOutput{i}.RingdownOutput.RingdownParameters.Amplitude,'descend');
    
    AppOutput{i}.RingdownOutput.RingdownParameters.Phase=AppOutput{i}.RingdownOutput.RingdownParameters.Phase(index);
    AppOutput{i}.RingdownOutput.RingdownParameters.Frequency=AppOutput{i}.RingdownOutput.RingdownParameters.Frequency(index);
    AppOutput{i}.RingdownOutput.RingdownParameters.Damping=AppOutput{i}.RingdownOutput.RingdownParameters.Damping(index);
    
    [TH_it,R_it] =cart2pol(-AppOutput{i}.RingdownOutput.RingdownParameters.Damping(1:num_modes).',...
            AppOutput{i}.RingdownOutput.RingdownParameters.Frequency(1:num_modes).');
    
    TH(1+(i-1)*num_modes:i*num_modes)=TH_it;
    R(1+(i-1)*num_modes:i*num_modes)=R_it;
    
end

[X,Y] = pol2cart(TH,R);
X=[X,Y];

opts = statset('Display','off');
[idx,C] = kmeans(X,num_modes,'Distance','cityblock',...
     'Replicates',5,'Options',opts);

[~,index] = sort(EventParams.dblEventParams(2,:),'descend');
    
 x0=-EventParams.dblEventParams(3,index(1:num_modes));
 y0= EventParams.dblEventParams(1,index(1:num_modes));
 plot(x0,y0,'kx','MarkerSize',10)
 
for i=1:num_modes
    x(i,:)=x0(i)+3*damp_std*cos(phi);
    x(i,(x(i,:)>neg_thres))=neg_thres;
    y(i,:)=y0(i)+3*freq_std*sin(phi);
    h2=plot(x(i,:),y(i,:),'k--');
    hold on;
end

for i=1:num_modes
    plot(X(idx==i,1),X(idx==i,2),'.','MarkerSize',15)
    [in(:,i),on(:,i)] = inpolygon(X(:,1),X(:,2),x(i,:),y(i,:));
    hold all
end

modes_ok=sum(sum(in))+sum(sum(on));

legend(h2,'Thereshold')
grid on
title('S plane')
xlabel('Damping')
ylabel('Frequency [Hz]')


% Print in Command Window
fprintf(['\nMonte Carlo Analysis:  ' num2str(num_repetitions) ' iterations\n\n'])
fprintf(['Number of modes inside the thereshold:  ' num2str(modes_ok) '\n'])
fprintf(['Number of total simulated modes:  ' num2str(num_repetitions*num_modes) '\n'])
effectiveness=modes_ok/(num_repetitions*num_modes)*100;
fprintf(['Effectiveness:   ' num2str(effectiveness) '%%\n\n'])

delay_error_cond=ceil(err_delay/(time(2)-time(1)));
if(effectiveness>99.7 && ~sum(sum(error_cond(:,delay_error_cond:end))))
    fprintf('<a href="">                       COMPLETE                            </a>\n');
else
    fprintf(2,'                       FAILURE\n');
    fprintf(2,'-----------------------------------------------------------\n');
end

fprintf('-----------------------------------------------------------\n\n')



