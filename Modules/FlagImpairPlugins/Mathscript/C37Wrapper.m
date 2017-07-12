function [stat] = C37Wrapper(Time,Params)
%C37WRAPPER Summary of this function goes here
%   Detailed explanation goes here
timevector = Time;
p_up = Params(1,1);
q_down = Params(2,1);
bias = Params(3,1);
drift = Params(4,1);
clock_noise = Params(5,1);
stat=logical([zeros(length(timevector),16)]);

[linkstate, unlocked_time, phase_error, stat] = timingerrorcode(timevector, p_up, q_down, bias, drift, clock_noise, stat);
end

