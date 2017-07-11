function  [xk, Pk, Kk]= GetModelOutput (xk_1,Pk_1,Fk,zk,Hk,Qk,Rk)

xk_1 = Fk * xk_1.';
Pk_1 = Fk * Pk_1 * Fk.' + Qk;

yk = zk.' - Hk * xk_1;
Sk = Hk * Pk_1 *  Hk.' + Rk;
Kk = Pk_1 * Hk.' / Sk;

xk = xk_1 + Kk * yk; xk = xk.'; 
xk(1)=wrapToPi(xk(1));
Pk = (eye(size(Pk_1)) - Kk*Hk) * Pk_1;


end