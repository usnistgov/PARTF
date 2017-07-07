function [FreqImp] = FreqSpline(ImpPosSeqPE,FSamp,Fs)
%FreqSpline performs a 5-knot spline interpolation using a rolling window

% Take the first 6 phase errors and perform a poly fit
x = 0:1/Fs:5/Fs;
y = ImpPosSeqPE(1:6);
p = polyfit(x,y,4);

% now extrapolate 3 samples in front  
x1 = -3/Fs:1/Fs:-1/Fs;
ystart = polyval(p,x1);

% Take the last 6 phase errors and perform a poly fit
y = ImpPosSeqPE(end-5:end);
p = polyfit(x,y,4);
x1 = 6/Fs:1/Fs:9/Fs;
yend = polyval(p,x1);

% From the first 2 extrapolated samples, estimate the first derivative

YP1 = (ystart(3)-ystart(1))*Fs/2;
ystart = reshape(ystart,1,[]); yend = reshape(yend,1,[]);
y = [ystart(2:end),ImpPosSeqPE,yend(1:end-1)];
YP2 = (y(6)-y(4))*Fs/2;

% Later,when we optimize the spline algorithm we will not need an X
X = 0:1/Fs:4/Fs;

FreqImp=zeros(1,length(ImpPosSeqPE));
%========================================================================
% 5-Knot spline loop
for i = 3:length(y)-3
    Y = y(i-2:i+2);
    Z = CSplineA(X,Y,YP1,YP2);   % spline coefficients y''(x)
    [~,YP1]=CSplintA(X,Y,Z,X(2));
    YP2 = (y(i+3)-y(i+1))*Fs/2;
    [~,FreqImp(i-2)]=CSplintA(X,Y,Z,X(3)); %Comment to run the experiment below
%     %-------------- experiment (yields the same results) ---------------
%     x = X(3)-1/FSamp;
%     [y1,~]=CSplintA(X,Y,Z,x);   % data point 1/FSamp before the center
%     x = X(3)+1/FSamp;
%     [y2,~]=CSplintA(X,Y,Z,x); % data point at 1/FSamp after center
%     FreqImp(i-2)=(y2-y1)/(2/FSamp);
%     %------------------- end experiment --------------------------------
end
%=========================================================================
FreqImp = FreqImp/(2*pi);

end

