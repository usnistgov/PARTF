clear;
clc;

FSamp = 960;
FStart = -10;
FEnd = 10;
Rf = 1;

% Filter parameters
Fr = 8.19;
N = 164;
WindowType = 'Hamming';
ImpParams = [Fr;N];

% Filter and Window Coefficients 
Bn = FIR(N,Fr,FSamp);  % sinc function coefficients
Wn = Window(N,WindowType).';  % Windowing coefficients
Bn = Bn.*Wn;
Bn = Bn./sum(Bn);                   % normalized coefficients

t = FStart/Rf:1/FSamp:FEnd/Rf;

synx = exp(-1i*2*pi*(Rf.*t).*t);

FSynx = filter(Bn,1,real(synx))+1i*filter(Bn,1,imag(synx));
FSynx = FSynx(N+(N/2)+1:length(FSynx));
synx = synx(N+1:length(synx)-(N/2));
PE = wrapToPi(angle(synx)-angle(FSynx));

for i=1:length(PE)-1
dPE(i) = PE(i+1)-PE(i);
end

% figure(100)
% subplot(3,1,1)
% plot(angle(synx))
% subplot(3,1,2)
% plot(angle(FSynx))
% subplot(3,1,3)
% plot(PE);
% 
% figure(101)
% plot(dPE);