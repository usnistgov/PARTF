% Simple example to load in a MAT file and perform a command-line Prony evaluation of it
% Basically to show how Prony could be called from a Monte-Carlo-type environment (assuming you know where to run it)
%
% Created February 9, 2017 by Frank Tuffner (PNNL)

%Prepare workspace
close all;
clear all;
clc;

%Load in the data file
load SampleData;

%File is built on the assumption that this MAT file contains:
%ChannelNames - row matrix of the signal names (text)
%DataValues - Column matrix of the data, with column 1 being time
%tstep - (not used)

%Time interval to analyze
TStart=35.7;
TEnd=43;

%Channels to use for Prony analysis
ChansToUse=[2 3];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Routine - avoid edits for base functionality
%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Generic/Initial information
NumChans=length(ChansToUse);

%% Subset the channels to the desired ranges -- very simple, assumes you know the times are in the set

%Find the start time
TStartIdx=find(DataValues(:,1)>=TStart,1);
TEndIdx=find(DataValues(:,1)>=TEnd,1);

%Calculate the length 
TAnalysisLength=TEndIdx-TStartIdx+1;

%Subset the data to feed into the Prony routine
DataToAnalyze=DataValues(:,ChansToUse);

%% Set up some Prony variables
%See the top of prgv2_5.m for explanations of these

%Control vector - basically set everything to auto
ContVect=[-1 0 -1 -1 -1 3 1 1 2 -1 -1 -1];

%Known impulse matrix - empty (no known)
ImpulseVect=[];

%Known poles to find - empty (no known)
PolsToFind=[];

%Compute the step time of the data
TStepVal=median(diff(DataValues(:,1)));

%Set up the offset/length of analysis vector
%For simplicity, we're using the same length/offset for all variables (this doesn't have to be the case)
HVect=repmat([TStartIdx TAnalysisLength],NumChans,1).';

%% Perform the Prony analysis

%Prony analysis - call the exposed function
[IDedModel,OutControls,MessWarns,MessFatal]=cmd_line_ringdown(DataToAnalyze,TStepVal,HVect,ImpulseVect,PolsToFind,ContVect);

%IDedModel = 
%OutControls = Updated version of the ContVect, with actual parameters used
%MessWarns = Warning messages
%MessFatal = Error messages

%Determine some sizes for a reshape
[XSize,YSize]=size(IDedModel);

%Put output into easier to read form
%(dampf, frqrps, amp, phase, resr, resi, releng, afpe)
DataOutput=reshape(IDedModel,XSize,8,YSize/8);

%% Reformat output data into parameters of interest

%Get information
NumModes=size(DataOutput,1);
NumChans=size(DataOutput,3);

%Get Frequencies
ModalFreq=reshape(DataOutput(:,2,:),NumModes,NumChans)/(2*pi);

%Get sigma (damping)
ModalSigma=reshape(DataOutput(:,1,:),NumModes,NumChans)/(2*pi);

%Get damping ratio
ModalDR=ModalSigma./(sqrt(ModalSigma.^2 + ModalFreq.^2));

%%%%%%%%% Could get other parameters above too -- needed??? %%%%%%%%%%%%%%%%%%%%%%