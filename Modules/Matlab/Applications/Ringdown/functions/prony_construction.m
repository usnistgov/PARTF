function prony_gen = prony_construction(sample_number,dft,param_matrix)

amp=param_matrix(:,1);
freq=param_matrix(:,2);
phase=param_matrix(:,3);
damp=param_matrix(:,4);

time=zeros(sample_number,1);
prony_signal=zeros(sample_number,1);

for i=1:sample_number
    time(i,1)=(i-1)*dft;
    prony_signal(i,1)= sum(amp.*exp(-damp*time(i)).*cos(2*pi*freq*time(i)+deg2rad(phase)));
end

prony_gen=[time prony_signal];

end
    