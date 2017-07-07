function [MagErr] = MagError(Ref,Imp)

% This function returns the magnitude error (as a percent) between an
% impaired set of synchrophasors and a reference set.
% INPUTS: rows = timestamped report, cols = different input phases
% Ref = [2] (from event module)           
% Imp = [2] (from impairment module)
Diff = (abs(Imp))-(abs(Ref));
MagErr = Diff./(abs(Ref))*100;
MagErr = MagErr.';
end