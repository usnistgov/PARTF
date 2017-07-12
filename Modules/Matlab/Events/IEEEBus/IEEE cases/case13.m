function mpc = case13

dtest_13_nofault

bus_names = bus(:,1);
mpc.bus = [(1:length(bus_names))'  bus(:,2:end)];

mpc.branch=branch;

for i=1:length(bus_names)
    mpc.branch(mpc.branch==bus_names(i))=i;
end
mpc.branch(:,9)=mpc.branch(:,6);
mpc.branch(mpc.branch(:,6)==1,9)=0;

mpc.bus_voltages=[];
mpc.baseMVA = 100;
mpc.gen = 0;
mpc.gencost = 0;

end