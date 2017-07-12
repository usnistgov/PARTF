function [deptime, totallost] = networkloss(tmax, lambda, p_up, q_down, service_mean, service_deviation, queuethreshold)

if (nargin==0)
  tmax=10;                   % simulation interval can we inherit this from the user input
  lambda=60;                 % arrival rate 
  p_up=.05;                  % p_up is the probability of transferring from good State to the bad
  q_down= .9;                % q_down is the probability of transferring from the bad state to good
  service_deviation = 0.1;   % service time standard deviation
  service_mean = 0.5;        % mean service time as fraction of reporting rate
  queuethreshold = 5;        % the max size of the PDC buffer
end
arrtime=-log(rand)/lambda; % Poisson arrivals
i=1;                  
  while (min(arrtime(i,:))<=tmax);
    arrtime = [arrtime; arrtime(i, :)-log(rand)/lambda];  
    i=i+1;
  end
n=length(arrtime);           % arrival times t_1,...,t_n         
servtime=service_mean*(1/lambda)+service_deviation*(1/lambda).*randn(1,n);  % service times s_1,...,s_k
cumservtime=cumsum(servtime);
arrsubtr=arrtime-[0 cumservtime(:,1:n-1)]';% t_k-(k-1)
arrmatrix=arrsubtr*ones(1,n);        
deptime=cumservtime+max(triu(arrmatrix));  % departure times u_k=k+max(t_1,..,t_k-k+1)   
systtime=deptime-arrtime';           % system times 
% Output is system size and system waiting times.
B=[ones(n,1) arrtime ; -ones(n,1) deptime']; 
Bsort=sortrows(B,2);                 % sort queue jumps in order
jumps=Bsort(:,1);
jumptimes=[0;Bsort(:,2)];
systsize=[0;cumsum(jumps)];          % size of M/G/1 queue
queuelost=(nonzeros(systsize(2:end).*(jumps>0)))<queuethreshold;
%If p_up is the probability of transferring from Good State to the bad state
%and if q_down is the probability of transferring from the bad state to the Good
%state, given the p_up and q_down values, this code will generate a packet loss
%pattern (with burst losses).
check = 1;
while check >= .1
good = 1;
networklost = [];
size = 1;
    for size= 1:1:n
        if good == 1
            networklost = [networklost; good];
            good = rand(1) > p_up;
        elseif good == 0
            networklost= [networklost; good];
            good = rand(1) > (1-q_down);
        else
            fprintf('error\n');
            break;
        end
    end
received_packs = nnz(networklost);
theo_loss_rate = 1 - q_down / (p_up+q_down);
act_loss_rate = 1 - received_packs/n;
check = abs(theo_loss_rate - act_loss_rate) / theo_loss_rate;
end
totallost=queuelost&networklost;
% figure(1)
% stairs(jumptimes,systsize);
% xmax=max(systsize)+2;
% axis([0 tmax 0 xmax]);
% xlabel('Queue operation');
% ylabel('Queue length');
% grid
% 
% figure(2)
% plot(systtime.*lambda);
% xlabel('Packet number');
% ylabel('System delay');
% 
% figure(3)
% plot(deptime), plot([1:n],(1/lambda).*[1:n],'.g');
% xlabel('Packet number');
% ylabel('Packet time');
% 
% figure(4)
% hist(((diff(arrtime)-(1/lambda))./(1/lambda)).*100);
% xlabel('Percentage variation from reporting rate');
% ylabel('Frequency');