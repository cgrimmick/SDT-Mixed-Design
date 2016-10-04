% Compare prob with occurance SDT Mixed design
clear all; close all


dataFiles = dir([pwd, '/*.mat']); % Define data files to be loaded; for loop if more data later
f = 1;
thisFile = dataFiles(f).name; 
    
load(thisFile);


    
OvertTrialFreq = data.OvertTrialFreq; 
pA = data.pA;
pB = data.pB;
pA(OvertTrialFreq:OvertTrialFreq:end) = [];
pB(OvertTrialFreq:OvertTrialFreq:end) = [];

probsA = rmrepeats(pA);
probsB = rmrepeats(pB);



CatShown = data.TrialType; % category of elipse shown on each trial; Cat A = 2; Cat B = 1 
%CatShown(OvertTrialFreq:OvertTrialFreq:end) = []; % Category shown for covert trials

SampHold = data.SampleHoldLength + 1;

A_obs = [];
B_obs = [];
tally = 0;

for i = 1:length(SampHold)
    
    if SampHold(i) > length(CatShown)
        curHold = length(CatShown)
    else
        curHold = SampHold(i);
    end
    
    A_obs(i) = sum(CatShown(1:curHold)==2)/curHold;
    B_obs(i) = sum(CatShown(1:curHold)==1)/curHold;
    
    CatShown(1:curHold) = [];
%     if isempty(CovCatShown)
%         break
%     end
%     
    tally = tally + curHold;
end
    




    
    