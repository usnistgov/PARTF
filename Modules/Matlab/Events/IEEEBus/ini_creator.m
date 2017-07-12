% IMPORTANT. YOU MUST INCLUDE THE MATPOWER v6.0 TO THE MATLAB PATH
% Program for Newton-Raphson Load Flow Analysis..

clc; 
clear
close all

% User input variables:
num_pmu= 1;
IEEE_bus_selection=1;

all_IEEE_cases={'case5' 'case9' 'case14' 'case30' 'case39' 'case57' 'case118' 'case145' 'case300'};
nbus = [5 9 14 30 39 57 118 145];  % IEEE-5, IEEE-9, IEEE-14, IEEE-30, IEEE-57..

nbus = nbus(IEEE_bus_selection);
IEEE_case=all_IEEE_cases{IEEE_bus_selection};

%--------------------------------------------------------------------------
if(num_pmu>nbus)
    error('The number of PMUs selected exceed the number of nodes')
end
%--------------------------------------------------------------------------

mpc = loadcase(IEEE_case);
results=runpf(mpc,mpoption('pf.tol',1e-12,'pf.nr.max_it',100));

V_Mag = results.bus(:,8);
V_Ang = results.bus(:,9);
V_Ang=V_Ang/180*pi;
Pij=results.branch(:,14)/100;
Qij=results.branch(:,15)/100;
Pji=results.branch(:,16)/100;
Qji=results.branch(:,17)/100;
Tap_BusNo=results.branch(:,1);
Z_BusNo=results.branch(:,2);

Temp=size(Pij);
BranchNum=Temp(1);
Temp=size(V_Mag);
BusNumber=Temp(1);

% Calculate the accurate voltage phasor
for i=1:BusNumber
    V(i)=V_Mag(i)*cos(V_Ang(i))+1i*V_Mag(i)*sin(V_Ang(i));
end
% Calculate the accurate current phasor
for k=1:BranchNum
    i=Tap_BusNo(k);
    j=Z_BusNo(k);
    Iij(k)=conj((Pij(k)+1i*Qij(k))/V(i));
    Iji(k)=conj((Pji(k)+1i*Qji(k))/V(j));
end

Iijm=zeros(BranchNum,BranchNum); Iija=zeros(BranchNum,BranchNum);
for i=1:BranchNum
    Iijm(Tap_BusNo(i),Z_BusNo(i))=abs(Iij(i));
    Iijm(Z_BusNo(i),Tap_BusNo(i))=abs(Iji(i));
end
for i=1:BranchNum
    Iija(Tap_BusNo(i),Z_BusNo(i))=angle(Iij(i));
    Iija(Z_BusNo(i),Tap_BusNo(i))=angle(Iji(i));
end

Connectivity = eye(nbus); 
for k=1:BranchNum
Connectivity(Tap_BusNo(k),Z_BusNo(k))=1;
Connectivity(Z_BusNo(k),Tap_BusNo(k))=1;
end
current_concections=sum(Connectivity,2)-1;
[temp, list_buses]=sort(current_concections,'descend');

% Some values and index for the file
bus_obs=list_buses(1:num_pmu);
fprintf('\n There are PMUs in the following buses:   [');
for i=1:num_pmu
    fprintf('% d ',list_buses(i));
end
fprintf(']\n');
column_num=max(current_concections(bus_obs))+2;

Neigs=Connectivity-eye(size(Connectivity,2));
neighbours=zeros(num_pmu,column_num-2);
for i=1:num_pmu
    neighs=find(Neigs(list_buses(i),:));
    neighbours(i,1:length(neighs))=neighs;
end

mag_current_matrix=[];
ang_current_matrix=[];

for i=1:num_pmu
   for j=1:column_num-2 
       if(neighbours(i,j))
            mag_current_matrix(i,j)=Iijm(list_buses(i),neighbours(i,j));
            ang_current_matrix(i,j)=180/pi*Iija(list_buses(i),neighbours(i,j));
       else
            mag_current_matrix(i,j)=0;
            ang_current_matrix(i,j)=0;
       end
   end
end

%% Create INI file
% File creation;

% fid = fopen( 'IEEEBusSystem.ini', 'wt' );
% fprintf(fid,'[Path to Class]IEEEBusSystemPlugin\\IEEEBusSystemEventPlugin.lvclass"\n');
% fprintf(fid,'Path = "..\\..\\EventPlugins\\IEEEBusSystemEvtPlugin\\IEEEBusSystemEvtPlugin.lvclass"\n\n');
% 
% fprintf(fid,'[EvtType]\n');
% fprintf(fid,'EvtType = "IEEEBusSystem"\n\n');
% 
% fprintf(fid,'[MultiBus]\n');
% fprintf(fid,'MultiBus=%d\n\n',num_pmu);
% 
% fprintf(fid,'[InitParams]\n');
% fprintf(fid,'RowHdrs.<size(s)> = "%d"\n',3*num_pmu);
% for i=0:num_pmu-1
%     fprintf(fid,'RowHdrs %d = "Mag"\n',3*i);
%     fprintf(fid,'RowHdrs %d = "Ang"\n',3*i+1);
%     fprintf(fid,'RowHdrs %d = "Std Noise"\n',3*i+2);
% end
% fprintf(fid,'ColHdrs.<size(s)> = "%d"\n',column_num);
% fprintf(fid,'ColHdrs 0 = "IEEE node"\n');
% fprintf(fid,'ColHdrs 1 = "V Bus"\n');
% for i=1:max(current_concections(bus_obs))
%     fprintf(fid,'ColHdrs %d = "I%d"\n',i+1,i);
% end
% fprintf(fid,'DefaultParams.<size(s)> = "%d %d"\n',3*num_pmu,column_num);
% 
% l=0;
% for i=0:num_pmu-1
%     fprintf(fid,'DefaultParams %d = "%d"\n',l,list_buses(i+1)); l=l+1;
%     fprintf(fid,'DefaultParams %d = "%.16f"\n',l,V_Mag(list_buses(i+1))); l=l+1;
%     for j=1:column_num-2
%         fprintf(fid,'DefaultParams %d = "%.16f"\n',l,mag_current_matrix(i+1,j));
%         l=l+1;
%     end
%     fprintf(fid,'DefaultParams %d = "%d"\n',l,list_buses(i+1)); l=l+1;
%     fprintf(fid,'DefaultParams %d = "%.16f"\n',l,180/pi*V_Ang(list_buses(i+1))); l=l+1;
%     for j=1:column_num-2
%         fprintf(fid,'DefaultParams %d = "%.16f"\n',l,ang_current_matrix(i+1,j));
%         l=l+1;
%     end
%     fprintf(fid,'DefaultParams %d = "%d"\n',l,list_buses(i+1)); l=l+1;
%     for j=1:column_num-1
%         fprintf(fid,'DefaultParams %d = "%1.0E"\n',l,1e-8);
%         l=l+1;
%     end
% end
% 
% fprintf(fid,'\n\n');
% 
% fprintf(fid,'[Script]\n');
% fprintf(fid,'Script.<size(s)> = "2"\n');
% fprintf(fid,'Script 0 = "GetEvtReports"\n');
% fprintf(fid,'Script 1 = "GetEvtSignal"\n');
% fclose(fid);


%% Create INI file
column_num=max(current_concections(bus_obs))+1;

% File creation;
fid = fopen( '..\..\..\EventPlugins\IEEEBusSystemEvtPlugin\IEEEBusSystem.ini', 'wt' );
fprintf(fid,'[Path to Class]IEEEBusSystemPlugin\\IEEEBusSystemEventPlugin.lvclass"\n');
fprintf(fid,'Path = "..\\..\\EventPlugins\\IEEEBusSystemEvtPlugin\\IEEEBusSystemEvtPlugin.lvclass"\n\n');

fprintf(fid,'[EvtType]\n');
fprintf(fid,'EvtType = "IEEEBusSystem"\n\n');

fprintf(fid,'[MultiBus]\n');
fprintf(fid,'MultiBus=%d\n\n',num_pmu);

fprintf(fid,'[InitParams]\n');
fprintf(fid,'RowHdrs.<size(s)> = "%d"\n',3*num_pmu);
for i=0:num_pmu-1
    fprintf(fid,'RowHdrs %d = "Mag"\n',3*i);
    fprintf(fid,'RowHdrs %d = "Ang"\n',3*i+1);
    fprintf(fid,'RowHdrs %d = "Std Noise"\n',3*i+2);
end
fprintf(fid,'ColHdrs.<size(s)> = "%d"\n',column_num);
fprintf(fid,'ColHdrs 0 = "V Bus"\n');
for i=1:max(current_concections(bus_obs))
    fprintf(fid,'ColHdrs %d = "I%d"\n',i,i);
end
fprintf(fid,'DefaultParams.<size(s)> = "%d %d"\n',3*num_pmu,column_num);

l=0;
for i=0:num_pmu-1  
    fprintf(fid,'DefaultParams %d = "%.16f"\n',l,V_Mag(list_buses(i+1))); l=l+1;
    for j=1:column_num-1
        fprintf(fid,'DefaultParams %d = "%.16f"\n',l,mag_current_matrix(i+1,j));
        l=l+1;
    end
    fprintf(fid,'DefaultParams %d = "%.16f"\n',l,180/pi*V_Ang(list_buses(i+1))); l=l+1;
    for j=1:column_num-1
        fprintf(fid,'DefaultParams %d = "%.16f"\n',l,ang_current_matrix(i+1,j));
        l=l+1;
    end
    for j=1:column_num
        fprintf(fid,'DefaultParams %d = "%1.0E"\n',l,1e-8);
        l=l+1;
    end
end

fprintf(fid,'\n\n');

fprintf(fid,'[Script]\n');
fprintf(fid,'Script.<size(s)> = "2"\n');
fprintf(fid,'Script 0 = "GetEvtReports"\n');
fprintf(fid,'Script 1 = "GetEvtSignal"\n');
fclose(fid);
