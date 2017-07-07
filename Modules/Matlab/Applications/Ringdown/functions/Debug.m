clc; clear
close all

data_in=csvread('Z:\data_in.csv');
RingdownInput=csvread('Z:\RindownInput.csv');

tic

xcon.Addmod = RingdownInput(1);          xcon.Scalmod =RingdownInput(2);        
xcon.Lpocon   = RingdownInput(3);          xcon.Pircon     =RingdownInput(4);             
xcon.Dmodes  = RingdownInput(5);          xcon.Lpmcon  =RingdownInput(6); 
xcon.Lpacon    = RingdownInput(7);          xcon.Fbcon     =RingdownInput(8);     
xcon.Ordcon    = RingdownInput(9);          xcon.Trimre    =RingdownInput(10);          
xcon.Ftrimh      = RingdownInput(11);        xcon.Ftriml     =RingdownInput(12); 

wcon.StOffset=RingdownInput(13);           
wcon.Length=RingdownInput(14);  


[data_values, data_len, dft, ...
  amp, damp, freq, phase, damp_ratio,...
  prony_estimate, final_time, wrnerr]=GetRngOutput(data_in,xcon,wcon);

toc
