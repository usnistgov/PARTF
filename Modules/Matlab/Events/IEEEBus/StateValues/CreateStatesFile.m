% IMPORTANT. YOU MUST INCLUDE THE MATPOWER v6.0 TO THE MATLAB PATH


% Clear memory
clear
clc

%% File creation;
fid = fopen( 'IEEEBusStates.csv', 'wt' );
all_IEEE_cases={'case5' 'case9' 'case14' 'case30' 'case39' 'case57' 'case118' 'case145' 'case300'};

for j=1:length(all_IEEE_cases)
% Get the power flow results from Matpower
mpc = loadcase(all_IEEE_cases{j});
results=runpf(mpc,mpoption('pf.tol',1e-12,'pf.nr.max_it',100));

V_Mag = results.bus(:,8);
V_Ang = results.bus(:,9);
n_bus = length(V_Mag);


fprintf(fid,'%d,',n_bus);
for i=1:n_bus
    fprintf(fid,'%.16f',V_Mag(i));
    if(i<n_bus)
        fprintf(fid,',');
    end
end
fprintf(fid,'\n');
fprintf(fid,'%d,',n_bus);
for i=1:n_bus
        fprintf(fid,'%.16f',V_Ang(i));
    if(i<n_bus)
        fprintf(fid,',');
    end
end

if(j<length(all_IEEE_cases))
        fprintf(fid,'\n');
end
end

fclose(fid);