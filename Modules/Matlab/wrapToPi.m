function [y] = wrapToPi(x)
y = zeros(1,length(x));
for i = 1 : length(x)
    tmp = mod(x(i)/pi,2.0);
    if tmp > 1, tmp = tmp - 2.0;end;
    y(i) = pi*tmp;
end