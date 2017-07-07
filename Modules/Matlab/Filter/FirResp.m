function [Hjw] = FirResp ( ...
    N,...
    Bn,...
    Wn,...
    Freq,...
    ROCOF,...
    FSamp...
    )
Hjw = zeros(length(Freq),1); 



% ====================This does not make it more accurate==================
% % The filter holds multiple reports worth of waveform samples so create an
% % index offset to the ideal frequency and ROCOF to be used to determine the
% % transfer function
% k = N/(2*FSamp/Fs)-.5;
% for i = 1:N+1
%     offset(i) = -ceil(k);
%     k = k - (Fs/FSamp);
% end
% ====================This does not make it more accurate==================

for i = 1:length(Hjw)
    n = -N/2;
    for k = (1:1:N+1)
       
% ====================This does not make it more accurate==================

%         j = i - offset(k);
%         if j < 1 
%             j = 1;
%         elseif j > length(Freq) 
%             j = i;
%         end
% ====================This does not make it more accurate==================
        j = i;
       
        
        omega(k) = 2*pi*(Freq(j)-(ROCOF(j)*n/(2*FSamp)))/FSamp;
        Hjw(i) = Hjw(i) + (Wn(k)*Bn(k)*exp(-1i*omega(k)*n));
        n=n+1;
    end
    Hjw(i) = Hjw(i)/dot(Wn,Bn);   %Scales the response to 1
end
% figure(100) 
% plot (Freq,abs(Hjw))
end