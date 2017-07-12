function [data_values, data_len, dft, amp, damp, freq, phase, damp_ratio,...
    prony_estimate, final_time, wrnerr]=GetRngOutput(data_in,xcon,wcon)

tic
time= data_in(:,1);
dft=data_in(2,1)-data_in(1,1);

if(find(time==0))
    begin_ind=find(time==0); begin_ind=begin_ind(1)+wcon.StOffset-1; 
else
    begin_ind=wcon.StOffset;
end
 
end_ind=wcon.Length;

data_len=end_ind-begin_ind+1;

data_values=data_in(begin_ind:end_ind,2); 
shift=0;
nnfit=length(data_values);

prony_conf=[xcon.Addmod xcon.Scalmod xcon.Lpocon xcon.Pircon xcon.Dmodes xcon.Lpmcon xcon.Lpacon xcon.Fbcon xcon.Ordcon xcon.Trimre xcon.Ftrimh xcon.Ftriml];
[identmodel,xcon_out,wrnerr,mret]=prgv2_6(data_values,dft,[shift;nnfit],[],[],prony_conf);

[freq, index_vec]=sort(identmodel(:,2)/(2*pi)); freq=real(freq).';
damp=identmodel(index_vec,1).';
amp=identmodel(index_vec,3).';
phase=(identmodel(index_vec,4)).'*180/pi;

damp_ratio=damp./(sqrt(damp.^2 + freq.^2)); damp_ratio=damp_ratio.';
prony_estimate=prony_reconstruction(amp,phase, freq, damp,dft, nnfit);
prony_estimate=[prony_estimate(1)*ones(begin_ind-1,1) ; prony_estimate].';
data_values=data_values.';

final_time=toc;

end