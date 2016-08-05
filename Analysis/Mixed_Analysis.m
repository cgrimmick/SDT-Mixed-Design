% SDT Mixed experiment design analysis and plotting
% Covert and Overt analyses are done separately and combined in plot.
% Separated scripts for scratch.
%

clear all; close all


dataFiles = dir([pwd, '/*.mat']); % Define data files to be loaded; for loop if more data later
f = 1;
thisFile = dataFiles(f).name; 
    
load(thisFile);


    
OvertTrialFreq = data.OvertTrialFreq; 
CovTrial = [1:data.NumTrials].';
CovTrial(OvertTrialFreq:OvertTrialFreq:end) = [];
OvTrial = [OvertTrialFreq:OvertTrialFreq:data.NumTrials].';
NumCovTrials = length(CovTrial);
NumOvTrials = length(OvTrial);
trial = data.trial;

pA = data.pA; % Probability of A on each trial
pB = data.pB; % Probability of B on each trial 
muA = data.MeanSignal; %mean of category A (2)
muB = data.MeanNoise; % mean of category B (1)
CovCatShown = data.TrialType; % category of elipse shown on each trial; Cat A = 2; Cat B = 1 
CovCatShown(OvertTrialFreq:OvertTrialFreq:end) = []; % Category shown for covert trials
obsCriterion = data.criterion;



% Step Four
    
winSize = 24; % define moving window size
FalseAlarms = zeros((NumCovTrials-winSize),1); 
Hits = zeros((NumCovTrials-winSize),1);
FAR = zeros((NumCovTrials-winSize),1); 
HR = zeros((NumCovTrials-winSize),1); 
CovScore = data.CovScore;
c = zeros(936,1);
estCriterion = zeros(936,1);
 
    % Step 5; mixed window be 24 trials; plot estCriterion at trial 14.
    % Plot overt crit in different color every 5; full window is 30.
    
    
    
    for curWind = 1:(NumCovTrials-winSize);

        
        
        
        windEnd = curWind + (winSize-1); 
    
        Hits(curWind) = sum(CovCatShown(curWind:windEnd)==1 & CovScore(curWind:windEnd)==1); % 'Yes' response; signal present
    
        FalseAlarms(curWind) = sum(CovCatShown(curWind:windEnd)==2 & CovScore(curWind:windEnd)==0); % 'Yes' response; singal absent
    
        % should be divided by number of cat 2 shown
        
        CatAtrials = sum(CovCatShown(curWind:windEnd)==1); % Signal trials
        CatBtrials = sum(CovCatShown(curWind:windEnd)==2); % Noise trials
        
        windCatA(curWind) = CatAtrials;
        windCatB(curWind) = CatBtrials;
        
       
        % Calculate hit rate
        HR(curWind) = ((Hits(curWind))./CatAtrials);    
        FAR(curWind) = ((FalseAlarms(curWind))./CatBtrials); 
          
        % Cheat for keeping bias from being 0 and criterion going to (-)Inf
%         if (norminv(HR(curWind))) + norminv(FAR(curWind)) == 0
%             %del(curWind) = 1;
%             disp('no bias')
%             HR(curWind)
%             FAR(curWind)
%             HR(curWind) = HR(curWind) - .05 ;
%             HR(curWind) 
%         end
        
        if HR(curWind) == 0 
            HR(curWind) = 0.01;
        elseif HR(curWind) == 1 
            HR(curWind) = 0.99;
        end
        
        
        % Calculate false alarm rate
        
        if CatBtrials == 0
            disp(['No B Trials at window', num2str(curWind)])
            FAR(curWind) = 0.05;
        end
        
         if CatAtrials == 0
            disp(['No A Trials at window', num2str(curWind)])
            HR(curWind) = .01;
        end
        
        if FAR(curWind) == 0 
            FAR(curWind) = 0.05;
        
        elseif FAR(curWind) == 1 
            FAR(curWind) = 0.95;
        end   
        
%         Z_Hit = norminv(HR(curWind);
%         Z_FA = norminv(FAR);
%     
%         c(curWind) = exp(.5*(Z_FA.^2-Z_Hit.^2));
        
%         c(curWind) = -(norminv(HR(curWind)) + norminv(FAR(curWind)))/2;
%         estCriterion(curWind) = (((data.StdDevCombined^2)*log(c(curWind)))/(muB-muA)) + ((muB + muA)/2);
%         
%         
%         
%         if (HR(curWind)==0.95) && (FAR(curWind) == .05) % Criterion moved far past mean of B 
%            estCriterion(curWind) = data.MeanNoise + 20;
%            disp('past noise')
%         elseif (HR(curWind)==0.05) && (FAR(curWind) == .05) 
%             estCriterion(curWind) = data.MeanSignal - 20;
%             disp('to past signal')
%         end
        
        
        
    end
    
    
%end

    Z_Hit = norminv(HR);
    Z_FA = norminv(FAR);
    
    c = exp(.5*(Z_FA.^2-Z_Hit.^2));
    % Plotting criterion in middle of window?    
    
   % c = -(norminv(HR) + norminv(FAR))/2; % Observed Bias
    
    omBias = pA./pB;
    %omBiasCov(OvertTrialFreq:OvertTrialFreq:end) = []; 
    %omBiasCov(end-(winSize-1):end) = [];
    omBiasOv = pA./pB;
    omBiasOv = omBiasOv(OvertTrialFreq:OvertTrialFreq:end); 
    wind = CovTrial(12:end-13);
    %CovTrial(end-(winSize-1):end) = [];  
    % Step 9 
    
    omCriterion = (((data.StdDevCombined^2)*log(omBias))/(muB-muA)) + ((muB + muA)/2);
     
    estCriterion = (((data.StdDevCombined^2)*log(c))/(muB-muA)) + ((muB + muA)/2);
    
    OvOmCrit = omCriterion(OvertTrialFreq:OvertTrialFreq:end);
    
    CovOmCrit = omCriterion;
    CovOmCrit(OvertTrialFreq:OvertTrialFreq:end) = [];
    CovOmCrit(end-(winSize-1):end) = [];
    
    % Plot
    
    figure(1)
    plot(trial,omCriterion,'k--',wind,estCriterion,'bo',OvTrial,obsCriterion,'ro')
    
    
    figure(2)
    
    fitrange = [-150:150];
    
    CovCritFit = polyfit(CovOmCrit,estCriterion,1);
    Cov_yfit = CovCritFit(1)*(fitrange) + CovCritFit(2);
    OvCritFit = polyfit(OvOmCrit,obsCriterion,1);
    Ov_yfit = OvCritFit(1)*(fitrange) + OvCritFit(2);
    
     plot(fitrange,Cov_yfit,'b--',CovOmCrit,estCriterion,'bo'...
     ,fitrange,Ov_yfit,'r--', OvOmCrit,obsCriterion,'ro')
       
 
 
    SDT_MixedPlot.omCrit = omCriterion;
    SDT_MixedPlot.estCrit = estCriterion;
    SDT_MixedPlot.obsCrit = obsCriterion;
    SDT_MixedPlot.trial = trial;
    SDT_MixedPlot.OvTrial = OvTrial;
    SDT_MixedPlot.wind = wind;
    SDT_MixedPlot.CovOmCrit = CovOmCrit;
    SDT_MixedPlot.OvOmCrit = OvOmCrit;
    
    
    
    
    
    
    
    
    
    