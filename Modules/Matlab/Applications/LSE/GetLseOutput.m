function [Vestimate, I_array1] = GetLseOutput(measure_matrix,lsecon,network_data)

% Auxiliar variables
H=network_data.H;
Bus=network_data.Bus;
Iij_vec=network_data.Iij_num_vec;
Iji_vec=network_data.Iji_num_vec;
Iji_index=network_data.Iji_index;
pmu_num=network_data.PMUnumber;
Num2=size(H,2)/2;
I_index=lsecon.I_index; % this value depends on the PosSeq chek box

% Create an array with all the current measurements.
% The order depends on the PMU locations vector
h=1;
I_array=[];
for i=1:pmu_num
   for j=0:(Iji_vec(i)+Iij_vec(i))-1   
        I_array(h)=measure_matrix(i,1+I_index+I_index*j);  
        h=h+1;
   end
end

% Create the I_array1 variable. It contains all the Iji measurements form
% all PMUs created.  
h=1;
I_array1=[]; I_array2=[];
for i=1:pmu_num
    I_array1=[I_array1 I_array(h:h+Iji_vec(i)-1)];
    h=h+Iji_vec(i)+Iij_vec(i);
end

% Sort the array using the branch number index. This stage is very
% important because of the LSE estimation process. 
I_array1=I_array1(Iji_index);

% Create the I_array2 variable. It contains all the Iij measurements form
% all PMUs created.
h=Iji_vec(1)+1;
for i=1:pmu_num
    I_array2=[I_array2 I_array(h:h+Iij_vec(i)-1)];
    if(i<pmu_num)
        h=h+Iij_vec(i)+Iji_vec(i+1);
    end
end

% Extract from these arrays the real and imaginary values.
mIjiR=zeros(1,sum(Iji_vec)); mIjiI=zeros(1,sum(Iji_vec));
for i=1:sum(Iji_vec)
    mIjiR(i)=real(I_array1(i));
    mIjiI(i)=imag(I_array1(i));
end
mIijR=zeros(1,sum(Iij_vec)); mIijI=zeros(1,sum(Iij_vec)); 
for i=1:sum(Iij_vec)
    mIijR(i)=real(I_array2(i));
    mIijI(i)=imag(I_array2(i));
end
mVR=zeros(1,pmu_num); mVI=zeros(1,pmu_num); 
for i=1:pmu_num
    mVR(i)=real(measure_matrix(i,1));
    mVI(i)=imag(measure_matrix(i,1));
end

% Measurement vector
z=[mVR';mVI';mIijR';mIijI';mIjiR';mIjiI'];

N=size(H);
Rr=eye(N(1))*lsecon.NoiseVariance;
W=inv(Rr);
Q=inv(H'*W*H)*H';

%Estimate
x=Q*W*z;

% Output signals
Vestimate=zeros(1,lsecon.IEEESystem);
for k=1:Num2
    n=Bus(k);
    Vestimate(n)=x(k)+1i*x(k+Num2);
end


end