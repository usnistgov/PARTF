clc;
clear;

% simulated system sampling rate
FSamp = 960;
F0 = 60;
Fs = 60;

% Filter parameters
Fr = 8.19;
N = 164;
WindowType = 'Hamming';
ImpParams = [Fr;N];

% Filter and Window Coefficients 
Bn = FIR(N,Fr,FSamp);  % sinc function coefficients
Wn = Window(N,WindowType).';  % Windowing coefficients

% Event Parameters
T0 = 0;
Vm = 100;
Im = 5;
%theta = [0,-2*pi/3,2*pi/3];

Xm = [Vm,Vm,Vm];
Fin = [60,60,60];
Ps = [0,-120,120];
Fh = [0,0,0];
Ph = [0,0,0];
Kh = [0,0,0];
Fa = [3,3,3];
Ka = [.1,.1,.1];
Fx = [0,0,0];
Kx = [0,0,0];
Rf = [0,0,0];
KaS = [0,0,0];
KxS = [0,0,0];
EvtParams = [Xm;Fin;Ps;Fh;Ph;Kh;Fa;Ka;Fx;Kx;Rf;KaS;KxS];

tStart = 0;
tEnd = 1;
EvtTime = tStart:1/Fs:tEnd;

%----------------------------EvtReports-----------------------------------
[EvtTimeStamp,EvtSynx,EvtFreq,EvtROCOF] = C37evt(T0,F0,EvtTime,EvtParams);

%--------------------------------------------------------------------------
% Set up the Error arrays
ImpSynx = EvtSynx;
ImpFreq = EvtFreq;
ImpROCOF = EvtROCOF;
% FreqErr = zeros(1,length(EvtFreq));
% ROCOFErr = zeros(1,length(EvtROCOF));

%==========================Filter Transfer function========================
% For each report, generate the Filter magnitude and phase response based
% on the reported frequency
Bn = FIR(N,Fr,FSamp);  % sinc function coefficients
Wn = Window(N,WindowType).';  % Windowing coefficients
%--------------------------------------------------------------------------
%For each report, get the transfer function and multiply the report by the magnitude response
[Hjw] = FirResp (...
    Fs, ...
    N,...
    Bn, ...
    Wn, ...
    EvtFreq-F0, ...
    EvtROCOF, ...
    FSamp ...
    );    % filter transfer function

%=========================Synchrophasor Error==============================
% Error of the transfer function without the unfiltered sum component
for i=1:length(ImpSynx(1,:))
    ImpSynx(:,i) = Hjw.*ImpSynx(:,i);
end
% %------------------------Phase Error Plots---------------------------------
% ImpPE=wrapToPi(angle(ImpSynx(:,1))-angle(EvtSynx(:,1)));
% figure(300)
% %subplot(3,1,1)
% plot(ImpPE)
% xlabel('Samples')
% title('Phase Error')
% ylabel('Phase Error (rad)')

%=======================Frequency Error ===================================
[FreqErrFilt, ROCOFErrFilt] = C37FreqFilt ( ...
    F0, ...
    Fs, ...
    EvtSynx, ...
    ImpSynx ...
    );
% Frequency Error Plots
figure(301)
plot(FreqErrFilt,'.')


