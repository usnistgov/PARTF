function [X_real,X_imag,posSeq]= conv3phase2(Xm,setPosSeq)

Xm_aux=[];
posSeq=[];

for i=1:length(Xm)
    Xm_aux= [Xm_aux Xm(i) Xm(i)*exp(-2/3*pi*1i) Xm(i)*exp(2/3*pi*1i)]; 
end

if(setPosSeq)
posSeq  = [real(calcPosSeq(Xm_aux)) imag(calcPosSeq(Xm_aux))];
end
X_real=real(Xm_aux);
X_imag=imag(Xm_aux);


end