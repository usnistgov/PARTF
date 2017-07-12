close all
clear all
timevector=[0:1/60:10]';
lambda=0;
service_mean=0.5;
service_deviation=0.1;
p_up=0.03;
q_down=.95;
queuethreshold=5;
PMUID=1;
[deptime, totallost] = networkimpairement(timevector, lambda, service_mean, service_deviation, p_up, q_down, queuethreshold);
 figure(1)
plot(deptime-timevector);
title('Total delay introduced by the network.');
figure(2)
stairs(deptime, 'LineWidth',3); hold on; stairs(timevector)
title('Impaired time vector and original timevector');
figure(3)
lostpackets=nonzeros(timevector.*not(totallost));
scatter(lostpackets,PMUID.*ones(length(lostpackets),1),'square','MarkerEdgeColor','red',...
              'MarkerFaceColor','red',...
              'LineWidth',.1)
          title('Red squares show measurements marked as lost');