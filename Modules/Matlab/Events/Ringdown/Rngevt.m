% Inputs:
% T0:           Initial time (offset)
% F0:           Nominal frequency
% time:         Array of times from the Start Time until the End Time with
%               regular intervals defined by 			the reporting rate.  
% signalparams:	Matrix of doubles containing the Event Parameters 
%               specified in the front panel.
% bPosSeq:      Boolean control which determines if the function adds 
%               the positive sequence to the output data.


function [timestamp,synx,freq,ROCOF] = Rngevt( ...
    T0, ...
    F0, ...
    time, ...
    signalparams, ...
    bPosSeq ...
)

% This is the .m file for the Ringdown theoretical signal event for the event
% module.

nyquist_ena=1;
if(find(time==0))
    zero_ind=find(time==0);
else
    zero_ind=1;
end
dft=time(zero_ind+1)-time(zero_ind);
nyquist_freq=1/(2*dft);
p_power=zeros(length(time),1);
q_power=zeros(length(time),1);

% Signal params.
Fp = signalparams(1,:)';     % Frequencies of the active power signal
    
    if(nyquist_ena)
        modes_under_nf = find(Fp<=nyquist_freq);
    else
        modes_under_nf=1:size(signalparams,2);
    end
    
Fp = signalparams(1,modes_under_nf)';     % Frequencies of the active power signal
Ap = signalparams(2,modes_under_nf)';     % Amplitudes of the active power signal
Dp = signalparams(3,modes_under_nf)';     % Dampings of the active power signal
Pp = signalparams(4,modes_under_nf)';     % Phases of the active power signal
Fq = signalparams(5,modes_under_nf)';     % Frequencies of the reactive power signal
Aq = signalparams(6,modes_under_nf)';     % Amplitudes of the active power signal    
Dq = signalparams(7,modes_under_nf)';     % Frequencies of the active power signal
Pq = signalparams(8,modes_under_nf)';     % Phases of the active power signal
Av = signalparams(9,1);      % Amplitude of the voltage signal
Pi = signalparams(10,1);     % Rate of change of phase of the current signal  
Noise = signalparams(11,:);     % Noise

p_power(zero_ind:end) = prony_reconstruction(Ap, Pp, Fp, Dp, dft, length(time(zero_ind:end)));
q_power(zero_ind:end) = prony_reconstruction(Aq, Pq, Fq, Dq, dft, length(time(zero_ind:end)));

if(zero_ind > 1)
p_power(1:zero_ind-1)= p_power(zero_ind);
q_power(1:zero_ind-1)= q_power(zero_ind);
end

% Phases in radians

Pp = Pp*pi/180;
Pq = Pq*pi/180;
Pi = Pi*pi/180;

% Calculate voltage and current
%The voltage amplitude is constant and the current phase is a linear function
aux_phasor=(p_power-1i*q_power)./(sqrt(3)*Av*exp(1i*Pi*time'));
current=(abs(aux_phasor)+Noise(1)*randn(length(time),1))...
    .*exp(1i*(Pi.*time'+Noise(1)*randn(length(time),1)));
voltage=(Av+Noise(1)*randn(length(time),1))...
    .*exp(-1i*(angle(aux_phasor)+Noise(1)*randn(length(time),1)));     
synx=[voltage voltage*exp(-2*pi/3*1i) voltage*exp(2*pi/3*1i) current current*exp(-2*pi/3*1i) current*exp(2*pi/3*1i)];

if bPosSeq
    %for each group of 3 phases, create a positive sequence
    phases = synx;
    for i = 1:2    % In this app we set the number of channels to one voltage and one current
        group = phases(:,((i-1)*3)+1:((i-1)*3)+3);
        posSeq = calcPosSeq(group).';
        index = ((i-1)*3)+(2+i);
        synx = [synx(:,1:index),posSeq,synx(:,index+1:end)];
    end
end

% Calculate frequency and ROCOF

% initialize zero values
freq=zeros(size(time));
ROCOF=zeros(size(time));
Q=zeros(size(time)); P=Q; P_p=Q; Q_p=Q; Q_pp=Q; P_pp=Q; H1=Q; H2=Q; H3=Q; H1_p=Q; H2_p=Q; H3_p=Q; 

for i=zero_ind:length(time)
    
    fact1=2*pi*Fq*time(i)+Pq;
    fact2=2*pi*Fp*time(i)+Pp;
    
    Q(i)=sum(Aq.*exp(-Dq*time(i)).*cos(fact1));      %reactive power
    P(i)=sum(Ap.*exp(-Dp*time(i)).*cos(fact2));      %and active power expressions
    
    fact3=(-Dq.*exp(-Dq*time(i)).*cos(fact1)-2*pi.*Fq.*exp(-Dq*time(i)).*sin(fact1));
    fact4=(-Dp.*exp(-Dp*time(i)).*cos(fact2)-2*pi.*Fp.*exp(-Dp*time(i)).*sin(fact2));
    
    %first derivate
    Q_p(i)=sum(Aq.*fact3);    
    P_p(i)=sum(Ap.*fact4);
    
    %second derivate
    Q_pp(i)=sum(Aq.*(-Dq.*fact3-2*pi*Fq.*(-Dq.*exp(-Dq*time(i)).*sin(fact1)+2*pi*Fq.*exp(-Dq*time(i)).*cos(fact1))));                                  
    P_pp(i)=sum(Ap.*(-Dp.*fact3-2*pi*Fp.*(-Dp.*exp(-Dp*time(i)).*sin(fact2)+2*pi*Fp.*exp(-Dp*time(i)).*cos(fact2))));
     
    
    H1(i)=1/((Q(i)/P(i))^2+1);
    H3(i)=(Q_p(i)*P(i) - Q(i)*P_p(i));
    H2(i)=H3(i)/P(i)^2;
    
    freq(i)= (H1(i)*H2(i)+Pi)/(2*pi) + F0; % Frequency
    
    H1_p(i)= -(Q(i)/P(i)+1)^(-2)*H2(i);
    H3_p(i)= Q_pp(i)*P(i) - Q(i)*P_pp(i);
    H2_p(i)= H3_p(i)*P(i)^(-2) - 2*H3(i)*P(i)^(-3)*P_p(i);
    
    ROCOF(i)= (H1_p(i)*H2(i) + H1(i)*H2_p(i))/(2*pi);   % Rate of change of frequency
    
end

if(zero_ind > 1)
freq(1:zero_ind-1)= F0;
ROCOF(1:zero_ind-1)= 0;
end
    
%Timestamp
timestamp = time + T0;

end

