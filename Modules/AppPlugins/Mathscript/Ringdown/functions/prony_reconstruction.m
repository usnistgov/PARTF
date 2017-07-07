function prony_estimate = prony_reconstruction(amp, phase, freq, damp, delta_t, n_leng)

%fprintf('\n%1.11f\n\n',out(2,1))
time=0:delta_t:delta_t*(n_leng-1);
prony_estimate=zeros(length(time),1);

for i=1:length(time)
    prony_estimate(i) = sum(amp.*exp(-damp*time(i)).*cos(2*pi*freq*time(i)+pi/180*(phase)));
end

end