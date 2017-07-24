function  [xk, Pk, Kk]= GetModelOutput (xk_1,Pk_1,Fk,zk,Hk,Qk,Rk)

Pe=zk(7);
Pm=zk(3);
omega0=zk(4);
delta_t=zk(5);
D=zk(6);

zk=zk(1:2);

xk_1(1)=xk_1(1)+(xk_1(2)-omega0)*delta_t;
xk_1(2)= xk_1(2) + omega0/(2*xk_1(3))*delta_t*(Pm-Pe-D*(xk_1(2)-omega0));
xk_1(3)=xk_1(3);

xk_1 = xk_1.';
Pk_1 = Fk * Pk_1 * Fk.' + Qk;

yk = zk.' - Hk * xk_1;
Sk = Hk * Pk_1 *  Hk.' + Rk;
Kk = Pk_1 * Hk.' / Sk;

xk = xk_1 + Kk * yk; xk = xk.'; 
%xk(1)=wrapToPi(xk(1));
Pk = (eye(size(Pk_1)) - Kk*Hk) * Pk_1;


end