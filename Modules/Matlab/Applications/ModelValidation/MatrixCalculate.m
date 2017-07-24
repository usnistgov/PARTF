% Fuction to get the transition and observability matrices

function [Fk,zk,Hk,Qk,Rk,phase_steps] = MatrixCalculate (vk,ik,xk,NoiseStd,params,phase_steps)

V=abs(vk);
theta=phase(vk)+ phase_steps*2*pi;
if abs(theta-xk(1))>6
    theta=theta+2*pi;
    phase_steps=phase_steps+1;
end

% Load Model parameters
delta_t = params(1);
omega0 = params(2);
D  = 0;
Xd_p=params(8);
L_line=0;

% State parameters
delta = xk(1);
omega = xk(2);
H     = xk(3);
%Pm    = xk(8);

% Matrix coefficients
a14= V * sin(delta - theta)/(Xd_p + L_line);
a15= V * cos(delta - theta)/(Xd_p + L_line);

% Matrix Calculate
Pm=0.78578767302243357;
S=vk*conj(ik);
Pe=real(S);
Qe=imag(S);
zk=[V, theta, Pm, omega0, delta_t, D, Pe];

Qk=1e-5*eye(length(xk));

Rk= NoiseStd^2 * eye(length(zk(1:2)));

%E=Pe*Xd_p/(V*sin(delta-theta));

Hk= [0 0  0;
     1 0  0];
 
Fk21 = 0;
Fk22 = 1 - omega0*D*delta_t/(2*H);
Fk23 = -(Pm-Pe-D*(omega-omega0)/(2*H^2)*omega0*delta_t);

 
Fk= [1       delta_t    0;
     Fk21    Fk22       Fk23; 
     0       0          1];

end