function [linkstate, unlocked_time, phase_error, stat] = timingerrorcode(timevector, p_up, q_down, bias, drift, clock_noise, stat)
if (nargin==0)
   timevector=[0:1/60:1000]';
   stat=logical([zeros(length(timevector),16)]);
   p_up=.05;                  % p_up is the probability of transferring from good State to the bad (1-reliability)
   q_down= 0.05;                % q_down is the probability of transferring from the bad state to good (redundancy)
   % Set q_down to zero if you want to simulate a device failure
   drift=-6.709e-16;
   bias=1.049e-10;
    clock_noise=2.73e-16;
elseif (nargin==3)
    drift=-6.709e-16;
    bias=1.049e-10;
    clock_noise=2.73e-16;
    stat=logical([zeros(length(timevector),16)]); 
elseif (nargin== 6)
    stat=logical([zeros(length(timevector),16)]); 
end
reportrate=mean(diff(timevector));
 %Global Average URE = ((cxT)2 +(0.980xR)2 +(0.141xA)2 +(0.141xC)2 -1.960xcxTxR)½   
 %c = speed of light
%T = total Timing error
%R = Radial orbit error
%A = Alongtrack orbit error
%C = Crosstrack orbit error
n=length(timevector);
%This code will generate a packet loss pattern (with burst losses).
check = 1;
while check >= .1
good = 1;
%  linkstate = [];
linkstate = zeros(n,1); %initialized to increase run-time speed
    for index= 1:1:n
        if good == 1
            %linkstate = [linkstate; good];
            linkstate(index) = good;
            good = rand(1) > p_up;
        elseif good == 0
            %linkstate = [linkstate; good];
            linkstate(index) = good;
            good = rand(1) > (1-q_down);      
        else
            fprintf('error\n');
            break;
        end
    end
linkstate=logical(linkstate);
link_up = nnz(linkstate);
theo_loss_rate = 1 - q_down / (p_up+q_down);
if theo_loss_rate>=1
    theo_loss_rate=1;
end
act_loss_rate = 1 - link_up/n;
check = abs(theo_loss_rate - act_loss_rate) / theo_loss_rate;
end
unlocked_time=zeros(n,1);
unlocked_code=zeros(n,1);
phase_error = clock_noise*randn(n,1);
phase_error_code= zeros(n,1);
unlocked_time(1)=reportrate.*~linkstate(1);
unlocked_code(1)=(unlocked_time(1)>=10)+(unlocked_time(1)>100)+(unlocked_time(1)>1000);
phase_error_code(1)=1+(phase_error(1)>=10e-9)+(phase_error(1)>=1e-6)+(phase_error(1)>=10e-6)+(phase_error(1)>=100e-6)+(phase_error(1)>=1e-3)+(phase_error(1)>=10e-3);
    for index= 2:1:n
        if ~linkstate(index)
            unlocked_time(index)=reportrate+unlocked_time(index-1);
            phase_error(index) = phase_error(index)+phase_error(index-1)+bias*unlocked_time(index)+ (drift/2)*(unlocked_time(index))^2;
            unlocked_code(index)=(unlocked_time(index)>=10)+(unlocked_time(index)>100)+(unlocked_time(index)>1000);
            phase_error_code(index)=1+(phase_error(index)>=100e-9)+(phase_error(index)>=1e-6)+(phase_error(index)>=10e-6)+(phase_error(index)>=100e-6)+(phase_error(index)>=1e-3)+(phase_error(index)>=10e-3);
        else
        phase_error_code(index)=1+(phase_error(index)>=100e-9)+(phase_error(index)>=1e-6)+(phase_error(index)>=10e-6)+(phase_error(index)>=100e-6)+(phase_error(index)>=1e-3)+(phase_error(index)>=10e-3);
        end
    end
%     stat(:,11:12)=dec2bin(unlocked_code,2);
%     stat(:,8:10)=dec2bin(phase_error_code,3);
    stat(:,5)=bitget(unlocked_code,1);
    stat(:,6)=bitget(unlocked_code,2);
    stat(:,7)=bitget(phase_error_code,1);
    stat(:,8)=bitget(phase_error_code,2);
    stat(:,9)=bitget(phase_error_code,3);
    stat(:,14)= ~linkstate;
%% This code uses a random walk PM (integral of white FM) instead of white PM used by default        
% dr=-6.709e-16;
% b=1.049e-10;
% sigma=2.73e-16;
% x = sigma*randn(n,1);
% indP = x>0;
% indM = x<=0;
% x(indP) = sigma;
% x(indM) = -sigma;
% z = zeros(n,1);
% for index=2:n
% z(index) = b*unlocked_time(index)+ (dr/2)*(unlocked_time(index))^2+z(index-1)+ x(index);
% end
