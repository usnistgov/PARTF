function [amp, damp, freq, phase, xcon, data_values, dft]=prony_module(xcon,path)

outdat=csvread(path); outdat=[(0:1/60:(length(outdat)-1)/60)' outdat']; outdat(1,3)=1; outdat(2,3)=301;

begin_ind=outdat(1,3);
end_ind=outdat(2,3);
if(xcon(14)<=0||xcon(14)>outdat(2,3)-outdat(1,3))
xcon(14)=outdat(2,3)-outdat(1,3)+1;
end

if(xcon(16)<=0);  xcon(16)=1; end
dft=outdat(xcon(16)+1,1);

%signal_slot_num=sum(outdat(:,3)~=0)/2;
%out_data=[]; out_time=[];

prony_data=outdat(begin_ind:end_ind,2);

shift=0;
ini_index=xcon(13);
end_index=xcon(13)+xcon(14)-1;
%time_comp= (xcon(15)-1)*xcon(14)/60;
if(end_index<length(outdat(:,1)))
prony_data=prony_data(ini_index:end_index);
else
prony_data=prony_data(ini_index:length(outdat(:,1)));
end

prony_sub=downsample(prony_data,xcon(16)); prony_data=prony_sub;

nnfit=length(prony_data);
data_values=prony_data;

[identmodel,xcon_out,wrnerr,mret]=prgv2_6(data_values,dft,[shift;nnfit],[],[],xcon);

[freq, index_vec]=sort(identmodel(:,2)/(2*pi));
damp=identmodel(index_vec,1);
amp=identmodel(index_vec,3);
phase=(identmodel(index_vec,4))*180/pi;

damp_ratio=damp./(sqrt(damp.^2 + freq.^2));
xcon(1:12)=xcon_out;
xcon(13)=end_index+1;
xcon(15)=xcon(15)+1;

end