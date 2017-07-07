% IMPORTANT: YOU MUST INCLUDE THE MATPOWER v6.0 TO THE MATLAB PATH

clc;  clear;  close all

%% User input variables:
% APP
num_pmu=18;
IEEE_bus_selection=6;
NoiseVariance=1e-10;
% Event
Start_Time='0';
End_Time='5';
bPosSeq='FALSE';
Nominal_Frequency='60';
if(strcmp(Nominal_Frequency,'60'))
    Reporting_Rate='60';
    Fsamp='960';
else
    Reporting_Rate='50';
    Fsamp='1000';
end
% PMU Impairment
PmuImpairPluginINIFilePath='NoPmuImpairPlugin/NoPmuImpairPlugin.ini';
FilterType='Blackman';
PmuImpairParams='0 0';


%%

all_IEEE_cases={'case5' 'case9' 'case14' 'case30' 'case39' 'case57'};
nbus = [5 9 14 30 39 57];  % IEEE-5, IEEE-9, IEEE-14, IEEE-30, IEEE-57..

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
bus_obs=sort(list_buses(1:num_pmu));
fprintf('\n There are PMUs in the following buses:   [');
for i=1:num_pmu
    fprintf('% d ',bus_obs(i));
end
fprintf(']\n');
column_num=max(current_concections(bus_obs))+2;

Neigs=Connectivity-eye(size(Connectivity,2));
neighbours=zeros(num_pmu,column_num-2);
for i=1:num_pmu
    neighs=find(Neigs(bus_obs(i),:));
    neighbours(i,1:length(neighs))=neighs;
end

mag_current_matrix=[];
ang_current_matrix=[];

for i=1:num_pmu
   for j=1:column_num-2 
       if(neighbours(i,j))
            mag_current_matrix(i,j)=Iijm(bus_obs(i),neighbours(i,j));
            ang_current_matrix(i,j)=180/pi*Iija(bus_obs(i),neighbours(i,j));
       else
            mag_current_matrix(i,j)=0;
            ang_current_matrix(i,j)=0;
       end
   end
end



%% Create TST file
column_num=current_concections(bus_obs)+1;

% File creation;
file_path=['Z:\My Documents\PARTF\Tests\IEEEBusSystem_' IEEE_case '_' num2str(num_pmu) 'pmus.tst'];
fid = fopen(file_path, 'wt' );

if(fid==-1)
    usersChosenFolder = uigetdir();
    file_path=[usersChosenFolder '\IEEEBusSystem_' IEEE_case '_' num2str(num_pmu) 'pmus.tst'];
    fid = fopen(file_path, 'wt' );
end

for i=1:num_pmu
fprintf(fid,['[Bus' num2str(i) ']\n']);
fprintf(fid,['BusNumber = "' num2str(i) '"\n']);
fprintf(fid,'EvtPluginINIFilePath = "IEEEBusSystemEvtPlugin/IEEEBusSystem.ini"\n');
fprintf(fid,'EvtParams.<size(s)> = "%d %d"\n',3,column_num(i));
fprintf(fid,'EvtParams 0 = "%.16f"\n',V_Mag(bus_obs(i)));
l=1;
for j=1:column_num(i)-1
        fprintf(fid,'EvtParams %d = "%.16f"\n',j,mag_current_matrix(i,j)); l=l+1;        
end
fprintf(fid,'EvtParams %d = "%.16f"\n',l,180/pi*V_Ang(bus_obs(i))); l=l+1; 
for j=1:column_num(i)-1
    fprintf(fid,'EvtParams %d = "%.16f"\n',l,ang_current_matrix(i,j)); l=l+1;        
end
for j=1:column_num(i)
    fprintf(fid,'EvtParams %d = "%f"\n',l,NoiseVariance); l=l+1;   
end
fprintf(fid,['EvtConfig.UTC Time 0 = "\\00\\00\\00\\00\\00\\00\\00\\00\\00\\00\\00\\00\\00\\00\\00\\00"\n',...
'EvtConfig.Nominal Frequency = "', Nominal_Frequency,'"\n',...
'EvtConfig.Reporting Rate = "' Reporting_Rate,'"\n',...
'EvtConfig.Fsamp = "', Fsamp,'"\n',...
'EvtConfig.PosSeq = "', bPosSeq, '"\n',...
'Start Time = "', Start_Time, '"\n',...
'End Time = "', End_Time, '"\n',...
'PmuImpairPluginINIFilePath = "', PmuImpairPluginINIFilePath '"\n',...
'PmuImpairParams .<size(s)> = "', PmuImpairParams,'"\n',...
'PmuImpairConfig.FilterType = "', FilterType,'"\n',...
'PmuImpairConfig.bPosSeq = "', bPosSeq,'"\n',...
'NetImpPluginINIFilePath = "NetworkPluginNone/NetworkPluginNone.ini"\n',...
'NetImpParams.<size(s)> = "0 0"\n',...
'FlagImpPluginINIFilePath = "NoFlagImpairPlugin/NoFlagImpairPlugin.ini"\n',...
'FlagImpParams.<size(s)> = "0 0"\n']);
fprintf(fid,'\n');
end

%% AppConfig
fprintf(fid,'[AppData]\n');
fprintf(fid,'AppData.AppPluginIniFilePath = "LSEPlugin/LSEPlugin.ini"\n');
fprintf(fid,['AppData.Config = "<Cluster>\\0D\\0A<Name>LSEConfig</Name>\\0D\\0A<NumElts>6</NumElts>\\0D\\0A<DBL>\\0D\\0A<Name>NoiseVariance</Name>\\0D\\0A<Val>' num2str(NoiseVariance)]);
fprintf(fid,['</Val>\\0D\\0A</DBL>\\0D\\0A<U32>\\0D\\0A<Name>IEEESystem</Name>\\0D\\0A<Val>' num2str(nbus)]);
fprintf(fid,['</Val>\\0D\\0A</U32>\\0D\\0A<Array>\\0D\\0A<Name>PMULocations</Name>\\0D\\0A<Dimsize>' num2str(num_pmu) '</Dimsize>\\0D\\0A']);
for i=1:num_pmu
fprintf(fid,['<U32>\\0D\\0A<Name>Numeric</Name>\\0D\\0A<Val>' num2str(bus_obs(i)) '</Val>\\0D\\0A</U32>\\0D\\0A']);
end
fprintf(fid,'</Array>\\0D\\0A<I32>\\0D\\0A<Name>Vindex</Name>\\0D\\0A<Val>0</Val>\\0D\\0A</I32>\\0D\\0A<I32>\\0D\\0A<Name>Iindex</Name>\\0D\\0A<Val>3</Val>\\0D\\0A</I32>\\0D\\0A<String>\\0D\\0A<Name>DynamicRef</Name>\\0D\\0A<Val></Val>\\0D\\0A</String>\\0D\\0A</Cluster>\\0D\\0A"');
fprintf(fid,'\n\n');

%% OutToFileConfig

fprintf(fid,'[OutToFileConfig]\n');
fprintf(fid,'OutToFileConfig.OutputToFilePluginINIFilePath = "OutputToFileBasePlugin/OutputToFileBasePlugin.ini"\n');
fprintf(fid,'OutToFileConfig.Output File Path = "Output"\n');
fprintf(fid,'OutToFileConfig.clConfigOptions.TIME_BASE = "\\00\\00\\00\\00\\00\\0FB@"\n');
fprintf(fid,'OutToFileConfig.clConfigOptions.STN = "Bus_1"\n');
fprintf(fid,'OutToFileConfig.clConfigOptions.IDCODE = "0"\n');
fprintf(fid,'OutToFileConfig.clConfigOptions.rdoPolRect = "Rectangular"\n');
fprintf(fid,'OutToFileConfig.clConfigOptions.rdoFloatInt = "Float"\n');
fprintf(fid,'OutToFileConfig.clConfigOptions.PHUNIT = "\\00\\00\\00\\00\\00\\0FB@"\n');
fprintf(fid,'OutToFileConfig.clConfigOptions.rdoFreqDfreq = "Float"\n');
fprintf(fid,'OutToFileConfig.clConfigOptions.CHNAM.<size(s)> = "8"\n');
fprintf(fid,'OutToFileConfig.clConfigOptions.CHNAM 0 = "VA"\n');
fprintf(fid,'OutToFileConfig.clConfigOptions.CHNAM 1 = "VB"\n');
fprintf(fid,'OutToFileConfig.clConfigOptions.CHNAM 2 = "VC"\n');
fprintf(fid,'OutToFileConfig.clConfigOptions.CHNAM 3 = "V+"\n');
fprintf(fid,'OutToFileConfig.clConfigOptions.CHNAM 4 = "IA"\n');
fprintf(fid,'OutToFileConfig.clConfigOptions.CHNAM 5 = "IB"\n');
fprintf(fid,'OutToFileConfig.clConfigOptions.CHNAM 6 = "IC"\n');
fprintf(fid,'OutToFileConfig.clConfigOptions.CHNAM 7 = "I+"\n');
fprintf(fid,'OutToFileConfig.clConfigOptions.chkCfg2Prefix = "TRUE"\n');

fclose(fid);
