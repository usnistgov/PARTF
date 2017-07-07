function [TVE] = TotalVectorError(Ref,Imp)

% This function outputs the Total Vector Error (as a percent) given
% in accordance with equation 9 of the draft standard.
% INPUTS: rows = timestamped report, cols = different input phases
% Ref = [2] (from event module)           
% Imp = [2] (from impairment module)
% Diff = Imp - Ref;
% TVE = sqrt(((real(Diff)).^2 ...
%                     +(imag(Diff)).^2) ...
%                      ./((real(Ref)).^2 ...
%                     +(imag(Ref)).^2));

TVE = sqrt( ...
    (real(Imp)-real(Ref)).^2 ...
    + (imag(Imp)-imag(Ref)).^2 ...
    ./ (real(Ref).^2 + imag(Ref).^2) ...
    );


%TVE = TVE*100;
TVE = TVE.';

% subplot(3,1,1)
% plot(TVE(1,:));
% subplot(3,1,2)
% plot(abs(Imp(:,1))-abs(Ref(:,1)))
% subplot(3,1,3)
% plot((angle(Imp(:,1))-angle(Ref(:,1)))*180/pi)
end