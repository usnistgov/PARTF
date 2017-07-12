function [MagErrHam,AngErrHam,FreqErrHam,ROCOFErrHam] = C37PmuHarmonic(...
    Xm,...
    Fin,...
    F0,...
    theta0,...
    Fi,...
    Ph, ...
    Kh ...
    )
HarmMag = [0.03537, 0.03296, 0.03022, 0.02934, 0.03019, 0.0316, 0.03226];
HarmAng = [0.028394, 0.023691, 0.024181, 0.024455, 0.025959, 0.026307, 0.025877];
HarmFreq = [-0.00137, 0, 0.00137, 0.00082, 0, -0.00082, 0.00055];

if Kh == 0
    MagErrHam = 0;
    AngErrHam = 0;
    FreqErrHam = 0;
    ROCOFErrHam = 0;
else if Fin ~= F0
    error('attention: input frequency is unqual to the nominal frequency');
    else
        if Fi >= 2*F0 && Fi <= 8*F0
            if floor(Fi/F0) == ceil(Fi/F0)
                HarmOrder = floor(Fi/F0)-1;
                MagErrHam = Xm/70*HarmMag(HarmOrder)*cos(theta0);
                AngErrHam = HarmAng(HarmOrder)*sin(theta0);
                FreqErrHam = HarmFreq(HarmOrder);
                ROCOFErrHam = 0;
            end
        end
    end
end