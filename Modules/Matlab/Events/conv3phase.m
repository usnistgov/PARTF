function [Xm,Ps,Noise]= conv3phase(Xm,Ps,Noise)

Xm_aux=[];
Ps_aux=[];
Noise_aux=[];

for i=1:length(Xm)
    Xm_aux= [Xm_aux Xm(i)*ones(1,3)]; 
    Ps_aux= [Ps_aux Ps(i) Ps(i)-120 Ps(i)+120];
    if(nargin==3)
        Noise_aux=[Noise_aux Noise(i)*ones(1,3)];
    end
end

Xm=Xm_aux;
Ps=Ps_aux;
Noise=Noise_aux;

end