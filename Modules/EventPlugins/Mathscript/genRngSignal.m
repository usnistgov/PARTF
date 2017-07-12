function [Signal] = genRngSignal( ...
    time, ...
    FSamp, ...
    signalparams ...
    )

% This is the .m file for the Ringdown theoretical signal event for the event
% module.

if(mod(FSamp,50))
    F0=60;
else
    F0=50;
end

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

aux_phasor=(p_power-1i*q_power)./(sqrt(3)*Av*exp(1i*Pi*(1+Noise(1)*randn(length(time),1)).*time'));
current=(abs(aux_phasor)+Noise(1)*randn(length(time),1))...
    .*exp(1i*(Pi+Noise(1)*randn(length(time),1)).*time');
voltage=(Av+Noise(1)*randn(length(time),1))...
    .*exp(-1i*(angle(aux_phasor)+Noise(1)*randn(length(time),1)));

cSignal=[voltage voltage*exp(-2*pi/3*1i) voltage*exp(2*pi/3*1i) current current*exp(-2*pi/3*1i) current*exp(2*pi/3*1i)].*(exp(2*pi*F0*time'*1i)*ones(1,6));

Signal = sqrt(2) * real(cSignal);

end  %function

