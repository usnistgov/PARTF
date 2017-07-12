% Test C37Evt
T0 = 0;
F0 = 60;
EvtTime = 0:1/60:10;
bPosSeq = 1.0;

% weird event parameters, 8 phases (not multiple of 3) so 2 positive
% sequences will be generated
Xm = [100,100,100,20,20,20,1,1];
Fin = [60,60,60,60,60,60,60,60];
Ps = [0,-120,120,0,-120,120,0,-120];
Fh = [0,0,0,0,0,0,0,0];
Ph = [0,0,0,0,0,0,0,0];
Kh = [0,0,0,0,0,0,0,0];
Fa = [0,0,0,0,0,0,0,0];
Ka = [0,0,0,0,0,0,0,0];
Fx = [0,0,0,0,0,0,0,0];
Kx = [0,0,0,0,0,0,0,0];
Rf = [0,0,0,0,0,0,0,0];
KaS = [0,0,0,0,0,0,0,0];
KxS = [0,0,0,0,0,0,0,0];
EvtParams = [Xm;Fin;Ps;Fh;Ph;Kh;Fa;Ka;Fx;Kx;Rf;KaS;KxS];

% Generate the ideal synchrophasors
[EvtTimeStamp,EvtSynx,EvtFreq,EvtROCOF] = C37evt(T0,F0,EvtTime,EvtParams,bPosSeq);
