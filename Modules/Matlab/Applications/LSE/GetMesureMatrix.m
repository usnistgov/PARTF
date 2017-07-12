function [Iij_num_vec, Iji_num_vec, H, Bus, Iji_index, SystemVoltages,linedata] = GetMesureMatrix(lsecon,PMUnumber)

BusNumber=lsecon.IEEESystem;
% Get Network parameters
switch BusNumber
    case 5
        mpc = case5;
    case 9
        mpc = case9;
    case 13
        mpc = case13;
    case 14
        mpc = case14;
    case 30
        mpc = case30;
    case 39
        mpc = case39;
    case 57
        mpc = case57;
    otherwise
        error('The IEEE System is not in memory')        
end

linedata=mpc.branch;
Tap_BusNo=linedata(:,1);
Z_BusNo=linedata(:,2);
R=linedata(:,3);
X=linedata(:,4);
Line_B= linedata(:,5);
Tap_ratio=linedata(:,9);
SystemVoltages=mpc.bus_voltages;

pmu_num=PMUnumber;
BranchNum=length(R);
ingroupBus=lsecon.PMULocations(1:pmu_num);

% Error message
if(pmu_num>BusNumber)
    error('The number of PMUs selected exceed the number of nodes')
end

% Creates the Bus and Branch variables. It contains the buses and branches 
% included in the "PMU neighborhood". we need to find out the tie line and 
%boundary bus for the targeted group
if length(ingroupBus)~=BusNumber  
    Bus=ingroupBus;  
    Temp=size(ingroupBus);
    N2=Temp(2)+1;  
    N=1;     
    Branch=0;
    for k=1:BranchNum
        i=Tap_BusNo(k);
        j=Z_BusNo(k);
        n=Find1(ingroupBus,i); % Check whether From bus is in the group
        m=Find1(ingroupBus,j); % Check whether To bus is in the group
        if n==1 && m==1  
            Branch(N)=k;
            N=N+1;
        elseif n==0 && m==1 
            Branch(N)=k;
            Temp=Find1(Bus,i); 
            if Temp==0
                Bus(N2)=i;
                N2=N2+1;
            end
            N=N+1;
        elseif n==1 && m==0 
            Branch(N)=k;
            Temp=Find1(Bus,j);
            if Temp==0
                Bus(N2)=j;
                N2=N2+1;
            end
            N=N+1;
        end
    end
else 
    Bus=ingroupBus;
    Branch=1:BranchNum;
end

Num1=size(Branch);
Num2=size(Bus);

% Create the Iij_num_vec and Iji_num_vec. These vectors contains the number
% of Iij and Iji currents for each PMU created.
Iij_num=0;
Iij_num_vec=[];
for i=1:pmu_num
    Iij_num_vec= [Iij_num_vec sum(Tap_BusNo(Branch) == ingroupBus(i))];
end
Iij_num=sum(Iij_num_vec);
Iji_num=0;
Iji_num_vec=[];
for i=1:pmu_num
    Iji_num_vec= [Iji_num_vec sum(Z_BusNo(Branch) == ingroupBus(i))];
end
Iji_num=sum(Iji_num_vec);

% Calculate the Measurement matrix
H31=zeros(Iij_num,Num2(2));  % H3 is for calculating Iij real part
H32=zeros(Iij_num,Num2(2));
H41=zeros(Iij_num,Num2(2));  % H4 is for calculating Iij Imaginary part
H42=zeros(Iij_num,Num2(2));
H51=zeros(Iji_num,Num2(2));  % H5 is for calculating Iji real part
H52=zeros(Iji_num,Num2(2));
H61=zeros(Iji_num,Num2(2));  % H6 is for calculating Iji Imaginary part
H62=zeros(Iji_num,Num2(2));

% Stage 1 - Iij currents involved
l=1;
for k=1:Num1(2)
    if(sum(ingroupBus == Tap_BusNo(Branch(k))));
    n=Branch(k);
    i=Tap_BusNo(n);
    j=Z_BusNo(n);
    I=1; % Find out the ingroup Number for the From Bus
    while Bus(I)~=i
        I=I+1;
    end
    J=1; % Find out the ingroup Number for the To Bus
    while Bus(J)~=j
        J=J+1;
    end
    Temp=R(n)^2+X(n)^2;
    if Tap_ratio(n)==0  % This branch is a transmission line
        H31(l,I)=R(n)/Temp;
        H31(l,J)=-R(n)/Temp;
        H32(l,I)=X(n)/Temp-Line_B(n)/2;
        H32(l,J)=-X(n)/Temp;
        H41(l,I)=-X(n)/Temp+Line_B(n)/2;                                              
        H41(l,J)=X(n)/Temp;
        H42(l,I)=R(n)/Temp;
        H42(l,J)=-R(n)/Temp;
    elseif Tap_ratio(n)~=0 % This branch is a transformer
        H31(l,I)=R(n)/(Tap_ratio(n)^2*Temp);
        H31(l,J)=-R(n)/(Tap_ratio(n)*Temp);
        H32(l,I)=X(n)/(Tap_ratio(n)^2*Temp);
        H32(l,J)=-X(n)/(Tap_ratio(n)*Temp);
        H41(l,I)=-X(n)/(Tap_ratio(n)^2*Temp);
        H41(l,J)=X(n)/(Tap_ratio(n)*Temp);
        H42(l,I)=R(n)/(Tap_ratio(n)^2*Temp);
        H42(l,J)=-R(n)/(Tap_ratio(n)*Temp);
    end
    l=l+1;
    end
end

% Stage 2 - Iji currents involved
l=1;
for k=1:Num1(2)
    if(sum(ingroupBus == Z_BusNo(Branch(k))));
    n=Branch(k);
    i=Tap_BusNo(n);
    j=Z_BusNo(n);
    I=1; % Find out the ingroup Number for the From Bus
    while Bus(I)~=i
        I=I+1;
    end
    J=1; % Find out the ingroup Number for the To Bus
    while Bus(J)~=j
        J=J+1;
    end
    Temp=R(n)^2+X(n)^2;
    if Tap_ratio(n)==0  % This branch is a transmission line
        H51(l,I)=-R(n)/Temp;
        H51(l,J)=R(n)/Temp;
        H52(l,I)=-X(n)/Temp;
        H52(l,J)=X(n)/Temp-Line_B(n)/2;
        H61(l,I)=X(n)/Temp;
        H61(l,J)=-X(n)/Temp+Line_B(n)/2;
        H62(l,I)=-R(n)/Temp;
        H62(l,J)=R(n)/Temp;
    elseif Tap_ratio(n)~=0 % This branch is a transformer
        H51(l,I)=-R(n)/(Tap_ratio(n)*Temp);
        H51(l,J)=R(n)/Temp;
        H52(l,I)=-X(n)/(Tap_ratio(n)*Temp);
        H52(l,J)=X(n)/Temp;
        H61(l,I)=X(n)/(Tap_ratio(n)*Temp);
        H61(l,J)=-X(n)/Temp;
        H62(l,I)=-R(n)/(Tap_ratio(n)*Temp);
        H62(l,J)=R(n)/Temp;
    end
    l=l+1;
    end
end

% Stage 3 - Voltages involved
H1=zeros(2*pmu_num,2*Num2(2));
for k=1:pmu_num
    index_aux=find(Bus==ingroupBus(k));
    H1(k,index_aux)=1;
end
for k=1:pmu_num
    index_aux=find(Bus==ingroupBus(k));
    H1(k+pmu_num,index_aux+Num2(2))=1;
end

% Measurement matrix
H=[H1;H31,H32;H41,H42;H51,H52;H61,H62];


% For this model is important to order the measurement matrix input. The
% Iij currents will be in order because the PMULocations vector goes from 
% lowest to highest. But the Iji is another issue. For that reason the 
% Iji_index will give us the right order. To_bus and Im_bus are auxiliar 
% variables.

To_bus=[]; l=1;
Z_BusNo_p=Z_BusNo(Branch,1);
for i=1:length(Branch)
    for j=1:pmu_num
        if(Z_BusNo_p(i,1)==lsecon.PMULocations(j))
           To_bus(l)=Z_BusNo_p(i,1); l=l+1;
        end
    end
end
Im_bus=[];
for i=1:pmu_num
    Im_bus=[Im_bus; lsecon.PMULocations(i)*ones(Iji_num_vec(i),1)];
end
Iji_index=[]; 
for i=1:length(To_bus)
    for j=1:size(Im_bus,1)
        if(To_bus(i)==Im_bus(j))
            Iji_index(i)=j;
            Im_bus(j)=0;
            break;
        end
    end
end

end