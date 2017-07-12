close all
clear all

outdat=csvread('Z:\My Documents\Projects\PARTF\trunk\Framework\Applications\AppPlugins\Mathscript\Ringdown\input_variables\data2.csv');
xcon=csvread('Z:\My Documents\Projects\PARTF\trunk\Framework\Applications\AppPlugins\Mathscript\Ringdown\input_variables\xcon.csv');

tic

shift=0;
ini_index=xcon(13);
end_index=xcon(13)+xcon(14)-1;
time_comp= (xcon(15)-1)*xcon(14)/60;
if(end_index<length(outdat(:,1)))
outdat1(:,1)=outdat(ini_index:end_index,1);
outdat2(:,1)=outdat(ini_index:end_index,2);
outdat=[outdat1 outdat2];
else
outdat1(:,1)=outdat(ini_index:length(outdat(:,1)),1);
outdat2(:,1)=outdat(ini_index:length(outdat(:,1)),2);
outdat=[outdat1 outdat2];
end

nnfit=size(outdat,1);
data_values=outdat(:,2);
dft=outdat(2,1);
[identmodel,xcon_out,wrnerr,mret]=prgv2_6(data_values,dft,[shift;nnfit],[],[],xcon);

[freq_vect, index_vec]=sort(identmodel(:,2)/(2*pi));
damp_vect=identmodel(index_vec,1);
amp_vect=identmodel(index_vec,3);
phase_vec=rad2deg(identmodel(index_vec,4));

damp_ratio=damp_vect./(sqrt(damp_vect.^2 + freq_vect.^2));
xcon(13)=end_index+1;
xcon(15)=xcon(15)+1;

final_time=toc;

pe=prony_reconstruction(identmodel(:,3),identmodel(:,4),identmodel(:,2),identmodel(:,1),outdat(:,1)-time_comp);
plot(outdat(:,2)); hold all
plot(pe)
legend('input','prony estimate')