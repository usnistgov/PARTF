function [state_var, Pk, Kk] = KFStage (voltage,current,delta_t,NoiseVariance,initial_state)

phase_steps=0;


%% INI
d2aem;

% Load Model parameters
omega0 =1;
L_line= 0;
Epp=    1.0878;
Pm=     0.78578767302243357;

% State parameters
delta=  phase(voltage(1));
omega=  1.0005;
H=      initial_state(1);
Xd_p=   initial_state(2);
D  =    initial_state(3);
xk(1)=  delta;  xk(2)=omega;      xk(3)=H;  xk(4)=Xd_p;  xk(5)=D; 
Pk = 1*eye(length(xk)); Pk(2,2)=1; Pk(2,2)=10;   Pk(3,3)=20;
Qk=     1e-15*eye(length(xk));
Rk=     NoiseVariance * eye(2);


%%  FK
state_var=zeros(length(xk),length(voltage));
std_noise=1e-3;
voltage=(abs(voltage)+std_noise*randn(size(voltage))).*...
    exp(1i*(phase(voltage)+std_noise*randn(size(voltage))));
current=(abs(current)+std_noise*randn(size(current))).*...
    exp(1i*(phase(current)+std_noise*randn(size(current))));


for i=1:length(voltage)

vk=voltage(i);
ik=current(i);
    
V=abs(vk);
theta=phase(vk)+ phase_steps*2*pi;
if abs(theta-xk(1))>6  % any value between pi and 2 pi
    theta=theta+2*pi;
    phase_steps=phase_steps+1;
end

% State parameters
delta = xk(1);
omega = xk(2);
H     = xk(3);
xdp   = xk(4);
D     = xk(5);
   
%%%%%%%%%%%%%%% PAPER 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

S=vk*conj(ik);
Pe=real(S);
Qe=imag(S);
zk=[Pe, Qe]/9;

a14= V * sin(delta - theta)/(xdp + L_line);
a15= V * cos(delta - theta)/(xdp + L_line);
H14= -(Epp*V*sin(delta-theta)/xdp^2);
H24= (V^2-Epp*V*cos(delta-theta))/xdp^2;

Hk= [a15*Epp 0  0 H14 0 ;
     -a14*Epp 0  0 H24 0 ];
 
Fk21 = -omega0*Epp*a15*delta_t/(2*H);
Fk22 = 1 - omega0*D*delta_t/(2*H);
Pe2= Epp*V * sin(delta - theta)/xdp;
Fk23 = -(Pm-Pe2-D*(omega-omega0))/(2*H^2)*omega0*delta_t;
%Fk25 = omega0*delta_t/(2*H);
Fk25 = -(omega-omega0)*omega0*delta_t/(2*H);
 
Fk= [1       2*pi*60*delta_t    0       0   0      ;
     Fk21    Fk22               Fk23    0   Fk25   ; 
     0       0                  1       0   0      ;
     0       0                  0       1   0      ;
     0       0                  0       0   1      ];


xk_1=xk;
Pk_1=Pk;
state_var(:,i)=xk;

xk_1(1)=xk_1(1)+2*pi*60*(xk_1(2)-omega0)*delta_t;
Pe2= Epp*V * sin(xk_1(1) - theta)/xk_1(4);
xk_1(2)= xk_1(2) + omega0/(2*xk_1(3))*(Pm-Pe2-xk_1(5)*(xk_1(2)-omega0))*delta_t;
xk_1(3)=xk_1(3);
xk_1(4)=xk_1(4);
xk_1(5)=xk_1(5);

xk_1 = xk_1.';
Pk_1 = Fk * Pk_1 * Fk.' + Qk;

h1= Epp*V * sin(xk_1(1) - theta)/xk_1(4);
h2= (-V^2+Epp*V * cos(xk_1(1) - theta))/xk_1(4);
yk = zk.' - [h1; h2];
Sk = Hk * Pk_1 *  Hk.' + Rk;
Kk = Pk_1 * Hk.' / Sk;

xk = xk_1 + Kk * yk; xk = xk.'; 
%xk(1)=wrapToPi(xk(1));
Pk = (eye(size(Pk_1)) - Kk*Hk) * Pk_1;

end


end

