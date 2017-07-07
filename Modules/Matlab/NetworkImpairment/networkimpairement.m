function [deptime_adj, totallost] = networkimpairement(timevector, lambda, service_mean, service_deviation, p_up, q_down, queuethreshold)
if (nargin==0)
  tmax=10;                   % simulation interval can we inherit this from the user input
  lambda=60;                 % arrival rate 
  p_up=.05;                  % p_up is the probability of transferring from good State to the bad
  q_down= .9;                % q_down is the probability of transferring from the bad state to good
  service_deviation = 0.1;   % service time standard deviation
  service_mean = 0.5;        % mean service time as fraction of reporting rate
  queuethreshold = 5;        % the max size of the PDC buffer
  arrtime=-log(rand)/lambda; % Poisson arrivals
  i=1;                  
  while (min(arrtime(i,:))<=tmax);
    arrtime = [arrtime; arrtime(i, :)-log(rand)/lambda];  
    i=i+1;
  end
end
lambda=round(1/mean(diff(timevector)));
n=length(timevector); 
arrtime=-log(rand)/lambda;
    for i=1:n-1;
    arrtime = [arrtime; arrtime(i, :)-log(rand)/lambda];  
    end 
servtime=service_mean*(1/lambda)+service_deviation*(1/lambda).*randn(1,n);  % service times s_1,...,s_k
    if min(servtime)<0;
%        errMsg = sprintf('For the Network Impairment, the minimun service time is %f.  It must be positive.  Adjust the Service Deviation. <PRI>3 <SEV>ABORT');
        error(['For the Network Impairment, the minimun service time is negative (',num2str(min(servtime)), ...
              ') Increase the service deviation for a positive minimum service time']);
    end
cumservtime=cumsum(servtime);
arrsubtr=arrtime-[0 cumservtime(:,1:n-1)]';% t_k-(k-1)
arrmatrix=arrsubtr*ones(1,n);        
deptime=cumservtime+max(triu(arrmatrix));  % departure times u_k=k+max(t_1,..,t_k-k+1)   
systtime=deptime-arrtime';           % system times 
% Output is system size and system waiting times.
deptime=deptime';
B=[ones(n,1) arrtime ; -ones(n,1) deptime]; 
Bsort=sortrows(B,2);                 % sort queue jumps in order
jumps=Bsort(:,1);
jumptimes=[0;Bsort(:,2)];
systsize=[0;cumsum(jumps)];          % size of M/G/1 queue
queuelost=(nonzeros(systsize(2:end).*(jumps>0)))<queuethreshold;
%This code will generate a packet loss pattern (with burst losses).
check = 1;
run_index=1;
while check >= .1 && run_index<20;
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
            error('Memory error in Network Impairement Script <SEV>Abort')
            break;
        end
    end
received_packs = nnz(networklost);
theo_loss_rate = 1 - q_down / (p_up+q_down);
act_loss_rate = 1 - received_packs/n;
check = abs(theo_loss_rate - act_loss_rate) / theo_loss_rate;
run_index=run_index+1;
    if run_index>=100;
    error(['The loss probability requested (1 - Q Down)/(P Up + Q Down) = ',num2str(theo_loss_rate), ...
    ') can not be attained. Typically, this happens when there are too few samples in the data set or the P Up is too low. The probability ',num2str(act_loss_rate)...
    ' may work instead. <PRI>3 <SEV>ABORT']);
    end
end
totallost=queuelost&networklost;
deptime_adj=deptime+timevector(1);