% SDT Mixed experiment design analysis and plotting
    % Covert and Overt analyses are done separately and combined in plot.
    % Separated scripts for scratch.

clear all; close all; clc;

dataFiles = dir([pwd, '/*.mat']); % Define data files to be loaded; for loop if more data later
f = 1;
thisFile = dataFiles(f).name;    
load(thisFile);

% Define task type (covert OR overt)
OvertTrialFreq = data.OvertTrialFreq; 
CovTrial = [1:data.NumTrials]';
CovTrial(OvertTrialFreq:OvertTrialFreq:end) = [];
OvTrial = [OvertTrialFreq:OvertTrialFreq:data.NumTrials]';
NumCovTrials = length(CovTrial);
NumOvTrials = length(OvTrial);
trial = data.trial;

% Define experimental session parameters
pA = data.pA; % Probability of A on each trial
pB = data.pB; % Probability of B on each trial 
muA = data.MeanSignal; %mean of category A (2)
muB = data.MeanNoise; % mean of category B (1)
CovCatShown = data.TrialType; % category of elipse shown on each trial; Cat A = 2; Cat B = 1 
CovCatShown(OvertTrialFreq:OvertTrialFreq:end) = []; % Category shown for covert trials
obsCriterion = data.criterion;

% Define moving window    
winSize = 24; % define moving window size
FalseAlarms = zeros((NumCovTrials-winSize),1); 
Hits = zeros((NumCovTrials-winSize),1);
FAR = zeros((NumCovTrials-winSize),1); 
HR = zeros((NumCovTrials-winSize),1); 
CovScore = data.CovScore;
c = zeros(NumCovTrials-winSize,1);
estCriterion = zeros(NumCovTrials-winSize,1);
 
% Calculate hit and FA rates for a given window
    % Covert window is 24 trials, full window is 30 trials
    % Plot estCriterion starting at trial 14
    % Plot overt crit in different color every 5  
for curWind = 1:(NumCovTrials-winSize)

    windEnd = curWind + (winSize-1); 

    Hits(curWind) = sum(CovCatShown(curWind:windEnd)==1 & CovScore(curWind:windEnd)==1); % 'Yes' response; signal present

    FalseAlarms(curWind) = sum(CovCatShown(curWind:windEnd)==2 & CovScore(curWind:windEnd)==0); % 'Yes' response; singal absent

    % should be divided by number of cat 2 shown

    CatBtrials = sum(CovCatShown(curWind:windEnd)==1); % Signal trials
    CatAtrials = sum(CovCatShown(curWind:windEnd)==2); % Noise trials
    
    % Make sure you aren't dividing by 0!
    if CatBtrials == 0
        CatBtrials = 1;
    end
    
    if CatAtrials == 0
        CatAtrials = 1;
    end

    windCatA(curWind) = CatBtrials;
    windCatB(curWind) = CatAtrials;

    % Calculate hit and false alarm rates 
    HR(curWind) = Hits(curWind)./CatBtrials;    
    FAR(curWind) = FalseAlarms(curWind)./CatAtrials; 

    % Make sure HR and FAR aren't 0 or 1
    if HR(curWind) == 0 
        HR(curWind) = 0.02;
    elseif HR(curWind) == 1 
        HR(curWind) = 0.98;
    end
    
    if FAR(curWind) == 0 
        FAR(curWind) = 0.02;
    elseif FAR(curWind) == 1 
        FAR(curWind) = 0.98;
    end
end

% Normalize
Z_Hit = norminv(HR);
Z_FA = norminv(FAR);

% Compute bias
c = exp(.5*(Z_FA.^2-Z_Hit.^2));
omBias = pA./pB;
omBiasOv = omBias(OvertTrialFreq:OvertTrialFreq:end); 
wind = CovTrial(12:end-13);
  
% Compute criterion
omCriterion = (data.StdDevCombined^2)*log(omBias)/(muB-muA) + ((muB + muA)/2);
estCriterion = (data.StdDevCombined^2)*log(c)/(muB-muA) + ((muB + muA)/2);

OvOmCrit = omCriterion(OvertTrialFreq:OvertTrialFreq:end);
CovOmCrit = omCriterion;
CovOmCrit(OvertTrialFreq:OvertTrialFreq:end) = [];
CovOmCrit = CovOmCrit(12:960-13);

% Plot estimated, observed, and omniscient criterion as a function of trial
figure(1); hold on;
plot(trial, omCriterion, '--k', 'linewidth', 3); % Omniscient criterion as a fct of trial
plot(OvTrial, obsCriterion, 'or'); % Overt-criterion as a fct of trial
plot(wind,estCriterion,'ob'); % Estimated criterion as a fct of trial
legend('Omnicient criterion', 'Overt criterion', 'Covert criterion')
xlabel('Trial number');
ylabel('Orientation (deg)');
hold off;

% Compute the slope of the line fit to the observed/estimated vs. ominiscient criterion
fitrange = -150:150;
CovCritFit = polyfit(CovOmCrit,estCriterion,1);
Cov_yfit = CovCritFit(1)*(fitrange) + CovCritFit(2);
OvCritFit = polyfit(OvOmCrit,obsCriterion,1);
Ov_yfit = OvCritFit(1)*(fitrange) + OvCritFit(2);

% Plot observed/estimated vs. omnicient
figure(2); hold on;
plot(CovOmCrit, estCriterion, 'ob');
plot(OvOmCrit, obsCriterion, 'or');
plot(fitrange, Cov_yfit, '-b', 'linewidth', 3);
plot(fitrange, Ov_yfit, '-r', 'linewidth', 3);
legend('Covert criterion', 'Overt criterion', 'Covert fit', 'Overt fit');
plot(fitrange, fitrange, '--k', 'linewidth', .5);
xlabel('Omniscient criterion (deg)');
ylabel('Measured criterion (deg)');
hold off;

% Plot a moving-average of choice as a function of trial
catResp = double(data.catResponse==2); % A - 1, B - 0
smoothCatResp = smooth(catResp, 24);
smoothProbA = smooth(pA, 30);
StdCombined = data.StdDevCombined;
neutralCriterion = .5*(muB+muA);
diffMu = muB-muA;
% Infer pA_obs from observed criterion in the overt-criterion task
pA_obs = exp(diffMu.*(obsCriterion-neutralCriterion)./StdCombined)./(1+exp(diffMu.*(obsCriterion-neutralCriterion)./StdCombined));

figure(3); hold on;
plot(CovTrial, smoothCatResp, '-b', 'linewidth', 3);
plot(trial, smoothProbA, '-k', 'linewidth', 3);
plot(OvTrial, smooth(pA_obs, 6), '-r', 'linewidth', 3);
scatter(CovTrial, catResp, 'ob');
axis([0 numel(trial) 0 1]);
xlabel('Trial number');
ylabel('P(A)');
hold off;

% Plot surface for HR, FAR, and bias ratio
figure(4); hold on;
plot3(FAR, HR, c, 'og');
plot3(FAR, HR, ones(size(c)), '.k');
xlabel('FAR');
ylabel('HR');
zlabel('Bias ratio (c)');
hold off;

SDT_MixedPlot.omCrit = omCriterion;
SDT_MixedPlot.estCrit = estCriterion;
SDT_MixedPlot.obsCrit = obsCriterion;
SDT_MixedPlot.trial = trial;
SDT_MixedPlot.OvTrial = OvTrial;
SDT_MixedPlot.wind = wind;
SDT_MixedPlot.CovOmCrit = CovOmCrit;
SDT_MixedPlot.OvOmCrit = OvOmCrit;
    
    
    
    
    
    
    
    
    
    