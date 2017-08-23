function [Hjw] = SincResp ( ...
    N, ...
    iFs, ...
    Wn, ...
    Bn, ...
    dFreq ...
    )
Hjw = 0;
omega = 2*pi*dFreq/(iFs);
n = -N/2;
for k = (1:1:N+1)
    Hjw = Hjw + (Wn(k)*Bn(k)*exp(-1i*omega*n));
    n=n+1;
end;
