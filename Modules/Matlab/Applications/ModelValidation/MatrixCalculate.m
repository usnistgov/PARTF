% Fuction to get the transition and observability matrices

function [Fk,zk,Hk,Qk,Rk] = MatrixCalculate (vk,ik,xk,NoiseStd,params)

V=abs(vk);
theta=angle(vk);

% Load Model parameters
delta_t = params(1);
omega0 = params(2);
if(params(3))      Td_p = params(3); else     Td_p = inf; end
if(params(4))      Td_pp = params(4); else    Td_pp = inf; end
if(params(5))      Tq_p = params(5); else     Tq_p = inf; end
if(params(6))      Tq_pp = params(6); else    Tq_pp = inf; end
Ld = params(7);
Ld_p = params(8);
Ld_pp = params(9);
Lq = params(10);
Lq_p = params(11);
Lq_pp = params(12);
L_line = params(13);
Sd = params(14);
Sq = params(15); 
D  = params(16);

% State parameters
delta = xk(1);
omega = xk(2);
Eq_pp = xk(3);
Ed_pp = xk(4);
Eq_p  = xk(5);
Ed_p  = xk(6);
H     = xk(7);
%Pm    = xk(8);

E_pp = abs(Ed_pp + 1i*Eq_pp);

% Matrix coefficients
a1 = omega0 * V * sin(delta - theta) * delta_t / (2*H * (Ld_p + L_line));
a2 = (Ld_p - Ld_pp) * delta_t / Td_pp;
a3 = (Lq_p - Lq_pp) * delta_t / Tq_pp;
a4 = Sd * (Ld-Ld_pp)/(Ld_p-Ld_pp);
a5 = Sq * (Lq-Lq_p)/(Lq_p-Lq_pp);
a6 = Eq_pp/(sqrt(Eq_pp^2+Ed_pp^2));
a7 = Ed_pp/(sqrt(Eq_pp^2+Ed_pp^2));
a8 = E_pp * cos(delta)/(Ld_p + L_line);
a9 = E_pp * sin(delta)/(Ld_p + L_line);
a10= sin(delta)/(Ld_p + L_line) * a6;
a11= sin(delta)/(Ld_p + L_line) * a7;
a12= -cos(delta)/(Ld_p + L_line) * a6;
a13= -cos(delta)/(Ld_p + L_line) * a7;
a14= V * sin(delta - theta)/(Ld_p + L_line);
a15= V * cos(delta - theta)/(Ld_p + L_line);

% Matrix Calculate

S=vk*conj(ik);
zk=[real(S), imag(S)];

Qk=1e-5*eye(length(xk));

Rk= NoiseStd^2 * eye(length(zk));

Hk= [a15*E_pp 0  a14*a6  a14*a7 0 0 0 ;
     a14*E_pp 0 -a15*a6 -a15*a7 0 0 0 ];

Pm=[0.8068 0.7778]; Pm=Pm(1);
 
Fk21 = -omega0*E_pp*a15*delta_t/(2*H);
Fk22 = 1 - omega0*D*delta_t/(2*H);
Fk27 = -omega0*delta_t/(2*H^2)*(Pm - E_pp*V*sin(delta-theta)/(Ld_p+L_line)-D * (omega-omega0));
Fk33 = 1 - a2*a10 - Sd * delta_t / Td_pp;
Fk35 = delta_t/Td_pp;
Fk44 = 1 - a3*a13 - Sq * delta_t / Tq_pp;
Fk46 = delta_t/Tq_pp;
Fk53 = a4 * delta_t / Td_p;
Fk55 = 1 - a4 * delta_t / Td_p;
Fk64 = a5 * delta_t / Tq_p;
Fk66 = 1 - a5 * delta_t / Tq_p;

 
Fk= [1       delta_t        0           0         0         0          0    ;
     Fk21      Fk22   -a1*a6      -a1*a7         0         0          Fk27  ; 
-a2*a8            0     Fk33     -a2*a11      Fk35         0          0     ;
-a3*a9            0  -a3*a12        Fk44         0      Fk46          0     ;
     0            0     Fk53           0      Fk55         0          0     ;
     0            0        0        Fk64         0      Fk66          0     ;
     0            0        0           0         0         0          1     ;
];

end