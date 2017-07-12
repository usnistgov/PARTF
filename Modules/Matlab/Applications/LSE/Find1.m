function [N]=Find1(A,b)
N=0;
for i=1:length(A)
    if b==A(i)
        N=1;
        break;
    end
end