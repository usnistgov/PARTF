clc
close all
clearvars -except freq1 freq2 

file_path='Z:\My Documents\Projects\PARTF\trunk\Framework\Applications\AppPlugins\Mathscript\Ringdown\pmu_imp.csv';

aux=csvread(file_path); aux=[(0:1/60:(length(aux)-1)/60)' aux']; aux(1,3)=1; aux(2,3)=301;
%%

w_size=0;
index_max=5;
%i_end=ceil(size(aux,1)/w_size);
xcon=[-1;0;-1;-1;-1;3;1;1;1;-1;-1;-1;1;w_size;1;1];
begin_ind=aux(1,3);
end_ind=aux(2,3);
data_len=end_ind-begin_ind+1;
if(xcon(14)<=0||xcon(14)>data_len)
xcon(14)=data_len;
end

prony_out=[]; prony_in=[]; prony_out2=[];
abs_error=[]; abs_error2=[];

for i=1:ceil(data_len/xcon(14))
[amp, damp, freq, phase, xcon, data_values, delta_t]=prony_module(xcon,file_path);
    
%outdat=csvread(file_path);

n_leng=length(data_values);
% if(xcon(13)<size(outdat,1))
%     time=outdat(1:xcon(14),1);
% %    prony_input_signal=outdat(xcon(13)-xcon(14):xcon(13)-1,2);
% else
%     time=outdat(1:length(xcon(13)-xcon(14):size(outdat,1)),1);
% %    prony_input_signal=outdat(xcon(13)-xcon(14):size(outdat,1),2);
% end

prony_estimate=prony_reconstruction(amp, phase, freq, damp, delta_t, n_leng);


% Saving most important nodes
amp_energy_limit=0.002;
[amp_modes ind]=sort(amp,1,'descend');
index=ind(1:index_max);
amp_modes=amp(index);
freq_modes=freq(index);
damp_modes=damp(index);
phase_modes=phase(index);
%phase_modes=phase(find(amp/max(amp)>amp_energy_limit));


prony_estimate2=prony_reconstruction(amp_modes, phase_modes, freq_modes, damp_modes, delta_t, n_leng);


error_signal=data_values-prony_estimate;
abs_error_signal=abs(error_signal);
prony_out=[prony_out; prony_estimate];
prony_out2=[prony_out2; prony_estimate2];
prony_in=[prony_in; data_values];
abs_error=[abs_error; abs_error_signal];
abs_error2=[abs_error2; abs(data_values-prony_estimate2)];


end


prony_set=[freq_modes amp_modes damp_modes phase_modes];


%%

figure
%plot(outdat(:,2)); hold all
plot(prony_in); hold all
plot(prony_out)
plot(prony_out2)
legend('input','prony estimate 1','prony estimate 2')

figure
plot(abs_error); hold all
plot(abs_error2);
legend('prony estimate 1','prony estimate 2')


%csvwrite('Z:\My Documents\Projects\PARTF\trunk\Framework\Applications\AppPlugins\Mathscript\Ringdown\input_variables\synt_i.csv',[aux(1:length(prony_out2),1) prony_out2]);









