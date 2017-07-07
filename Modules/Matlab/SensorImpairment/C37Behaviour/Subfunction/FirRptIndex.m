N = 164;
FSamp = 960;
F0 = 20;

k = N/(2*FSamp/F0)-.5;

for j = 1:(N+1)
    index(j) = -(ceil(k));
    k = k - (F0/FSamp);
end