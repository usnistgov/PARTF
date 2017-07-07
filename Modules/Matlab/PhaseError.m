function [PhaseErr] = PhaseError(Ref,Imp)

% This function returns the magnitude error (as a percent) between an
% impaired set of synchrophasors and a reference set.
% INPUTS: rows = timestamped report, cols = different input phases
% Ref = [2] (from event module)           
% Imp = [2] (from impairment module)
% Ref = [[1+2i,3+4i]
%        [5+6i,7+8i]
%        [9,1+2i]];
% Imp = [[9,1+2i]
%        [3+4i,5+6i]
%        [7+8i,9]];
Diff = (angle(Imp))-(angle(Ref));
PhaseErr = (Diff)*180/pi;
PhaseErr = PhaseErr.';

% Error check for out of bounds results
[rows,cols] = size(PhaseErr);
for n = 1:cols
    for m = 1:rows
        if PhaseErr(m,n) > 180
            PhaseErr(m,n) = PhaseErr(m,n) - 360;
        else if PhaseErr(m,n) < -180
                PhaseErr(m,n) = PhaseErr(m,n)+360;
            else
                PhaseErr(m,n) = PhaseErr(m,n);
            end
        end
    end
end
end
