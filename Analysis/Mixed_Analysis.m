% SDT Mixed experiment design analysis and plotting
% Covert and Overt analyses are done separately and combined in plot.
% Separated scripts for scratch.

clear all; close all
cd('/Users/chrisgrimmick/Documents/Lab/Landy/SDT-Changing-Probabilities/Mixed-Design/Data')  
    
% Ask for options for running of script
subj = upper(input('Subject initials (ALL to run all files): ', 's'));
plot_opt = input('Plot data? y/n: ', 's');
save_opt = input('Save data to csv? y/n: ', 's');

if strcmp(subj,'ALL')
    dataFiles = dir([pwd, '/*.mat']); % Define data files to be loaded
else
    dataFiles = dir([pwd, '/*' ,subj, '.mat']);
end


 for f = 1:length(dataFiles);
 thisFile = dataFiles(f).name; 

%thisFile = 'SDTChangingProbabilitiesMixed_HHL';

load(thisFile);
fileName = thisFile(1:end-4)

    
OvertTrialFreq = data.OvertTrialFreq; 
CovTrial = [1:data.NumTrials].';
CovTrial(OvertTrialFreq:OvertTrialFreq:end) = [];
OvTrial = [OvertTrialFreq:OvertTrialFreq:data.NumTrials].';
NumCovTrials = length(CovTrial);
NumOvTrials = length(OvTrial);
trial = data.trial;

pA = data.pA; % Probability of A on each trial
pB = data.pB; % Probability of B on each trial 
Cov_pA = pA;
Cov_pA(OvertTrialFreq:OvertTrialFreq:end) = []; 
muA = data.MeanSignal; %mean of category A (2)
muB = data.MeanNoise; % mean of category B (1)
data.response(OvertTrialFreq:OvertTrialFreq:end) = [];
CovResponse = data.response;
CovCatShown = data.TrialType; % category of elipse shown on each trial; Cat A = 2; Cat B = 1 
CovCatShown(OvertTrialFreq:OvertTrialFreq:end) = []; % Category shown for covert trials
obsCriterion = data.criterion;

% Add check for criterion >90  or < -90:
% Visual check first

%  critover90 = find(obsCriterion>90);
%  obsCriterion(critover90) = obsCriterion(critover90) - 180;
% critunderneg90 = find(obsCriterion< -90);
% obsCriterion(critunderneg90) = obsCriterion(critunderneg90) + 180;
% 
%     if strcmp('HHL',fileName)
%         hhlcorr = find(obsCriterion<0);
%         obsCriterion(hhlcorr) = obsCriterion(5hhlcorr) + 180;
%     end

 critover90 = find(obsCriterion>90);
 obsCriterion(critover90) = obsCriterion(critover90) - 180;
critunderneg90 = find(obsCriterion< -90);
obsCriterion(critunderneg90) = obsCriterion(critunderneg90) + 180;

    if strcmp('HHL',fileName)
        hhlcorr = find(obsCriterion<0);
        obsCriterion(hhlcorr) = obsCriterion(hhlcorr) + 180;
    end

 
% Step Four
    
winSize = 24; % define moving window size
FalseAlarms = zeros((NumCovTrials-winSize),1); 
Hits = zeros((NumCovTrials-winSize),1);
FAR = zeros((NumCovTrials-winSize),1); 
HR = zeros((NumCovTrials-winSize),1); 
CovScore = data.CovScore;
c = zeros(936,1);
estCriterion = zeros(936,1);
hackWind = [];
hw = 1; 
    % Step 5; mixed window be 24 trials; plot estCriterion at trial 14.
    % Plot overt crit in different color every 5; full window is 30.
    
    
    
    for curWind = 1:(NumCovTrials-winSize);

        
        
        
        windEnd = curWind + (winSize-1); 
    
        Hits(curWind) = sum(CovCatShown(curWind:windEnd)==2 & CovScore(curWind:windEnd)==1); % 'Yes' response; signal present
        
        FalseAlarms(curWind) = sum(CovCatShown(curWind:windEnd)==1 & CovScore(curWind:windEnd)==0); % 'Yes' response; singal absent
        
        
        % should be divided by number of cat 2 shown
        
        CatAtrials = sum(CovCatShown(curWind:windEnd)==2); % Signal trials
        CatBtrials = sum(CovCatShown(curWind:windEnd)==1); % Noise trials
        
        
         % Make sure you aren't dividing by 0!
        if CatBtrials == 0
            CatBtrials = 1;
            hackWind(hw) = curWind;
            hw = hw + 1;
        end

        if CatAtrials == 0
            CatAtrials = 1;
            hackWind(hw) = curWind;
            hw = hw + 1;
        end
        
        windCatA(curWind) = CatAtrials;
        windCatB(curWind) = CatBtrials;
        
       
         % Calculate hit and false alarm rates
        HR(curWind) = ((Hits(curWind))./CatAtrials);  
        FAR(curWind) = ((FalseAlarms(curWind))./CatBtrials); 
        
        
        
        
%         
%         if HR(curWind)==0 && FAR(curWind)== 0
%             disp('HR and FAR zero')
%             curWind
%             FAR(curWind) = .049;
%            % FAR(curWind)
%             HR(curWind) = .949;
%            % HR(curWind)
            
             
        %end
        
        
        
    
        
        % Cheat for keeping bias from being 0 and criterion going to (-)Inf
%         if (norminv(HR(curWind))) + norminv(FAR(curWind)) == 0
%             %del(curWind) = 1;
%             disp('no bias')
%             HR(curWind)
%             FAR(curWind)
%             HR(curWind) = HR(curWind) - .05 ;
%             HR(curWind) 
%         end
      

% Make sure HR and FAR aren't 0 or 1
    if HR(curWind) == 0 
        HR(curWind) = 0.02;
        hackWind(hw) = curWind;
        hw = hw + 1;
    elseif HR(curWind) == 1 
        HR(curWind) = 0.98;
        hackWind(hw) = curWind;
        hw = hw + 1;
    elseif HR(curWind) == 1 
        HR(curWind) = 0.98;
    end
    
    if FAR(curWind) == 0 
        FAR(curWind) = 0.02;
        hackWind(hw) = curWind;
        hw = hw + 1;
    elseif FAR(curWind) == 1 
        FAR(curWind) = 0.98;
        hackWind(hw) = curWind;
        hw = hw + 1;

    elseif FAR(curWind) == 1 
        FAR(curWind) = 0.98;

    end
    

       
%         if CatBtrials == 0
%             disp(['No B Trials at window', num2str(curWind)])
%             FAR(curWind) = 0.02;
%            
%         end
%         
%          if CatAtrials == 0
%             disp(['No A Trials at window', num2str(curWind)])
%             HR(curWind) = .02;
%            
%         end
%         
%         if FAR(curWind) == 0 
%             FAR(curWind) = 0.02;
%              disp('FAR zero')
%              curWind
%         elseif FAR(curWind) == 1 
%             FAR(curWind) = 0.98;
%              disp('FAR one')
%              curWind
%         end    
        
        
       
        
        %Z_Hit = norminv(HR(curWind));
        %Z_FA = norminv(FAR(curWind));
        
       
        
       % c(curWind) = exp(.5*(Z_Hit.^2-Z_FA.^2));
         % flip hack: redefine bias in terms of rejects and misses
%         if (HR(curWind)==0.05) && (FAR(curWind) == .049)
%             CRR = .99;
%             MR = .01;
%             Z_CRR = norminv(CRR);
%             Z_MR = norminv(MR);
%             c(curWind) = exp(.5*(Z_CRR.^2-Z_MR.^2));
%             'flip'
%             curWind
%         end
        %estCriterion(curWind) = (((data.StdDevCombined^2)*log(c(curWind)))/(muB-muA)) + ((muB + muA)/2);
        
        
        % 2 STD Hack 
%         if (HR(curWind)==0.98) && (FAR(curWind) == .02) % Criterion moved far past mean of B 
%            estCriterion(curWind) = data.MeanNoise + 20;
%            disp(['past noise', num2str(curWind)])
%         elseif (HR(curWind)==0.02) && (FAR(curWind) == .02)
%             estCriterion(curWind) = data.MeanSignal - 20;
%              disp(['past signal', num2str(curWind)])
%         end
 end
        
        
%         end
    
    
    %end

Z_Hit = norminv(HR);
Z_FA = norminv(FAR);
    
c = exp(.5*(Z_Hit.^2-Z_FA.^2));
    
    
    

omBias = pA./pB;
%omBiasCov(OvertTrialFreq:OvertTrialFreq:end) = []; 
%omBiasCov(end-(winSize-1):end) = [];
omBiasOv = pA./pB;
omBiasOv = omBiasOv(OvertTrialFreq:OvertTrialFreq:end); 
wind = CovTrial(12:end-13);
%CovTrial(end-(winSize-1):end) = [];  
% Step 9 

omCriterion = (data.StdDevCombined^2)*log(omBias)/(muB-muA) + ((muB + muA)/2);

   omCriterion = (data.StdDevCombined^2)*log(omBias)/(muB-muA) + ((muB + muA)/2);

estCriterion = (data.StdDevCombined^2)*log(c)/(muB-muA) + ((muB + muA)/2);

OvOmCrit = omCriterion(OvertTrialFreq:OvertTrialFreq:end);
CovOmCrit = omCriterion;
CovOmCrit(OvertTrialFreq:OvertTrialFreq:end) = [];
CovOmCrit = CovOmCrit(12:960-13);

% Smooth Data
catResp = double(data.catResponse==2); % A - 1, B - 0
smoothCatResp = smooth(catResp, 24);
smoothProbA = smooth(pA, 30);
StdCombined = data.StdDevCombined;
neutralCriterion = .5*(muB+muA);
diffMu = muB-muA;
    % Infer pA_obs from observed criterion in the overt-criterion task
pA_obs = exp(diffMu.*(obsCriterion-neutralCriterion)./StdCombined)./(1+exp(diffMu.*(obsCriterion-neutralCriterion)./StdCombined));

smoothpA_obs = smooth(pA_obs, 6);


% Compute the slope of the line fit to the observed/estimated vs. ominiscient criterion
fitrange = -150:150;
CovCritFit = polyfit(CovOmCrit,estCriterion,1);
Cov_yfit = CovCritFit(1)*(fitrange) + CovCritFit(2);
OvCritFit = polyfit(OvOmCrit,obsCriterion,1);
Ov_yfit = OvCritFit(1)*(fitrange) + OvCritFit(2);

if strcmp(plot_opt,'y')
    
    % Plot estimated, observed, and omniscient criterion as a function of trial
    figure(1); hold on;
    plot(trial, omCriterion, '--k', 'linewidth', 3); % Omniscient criterion as a fct of trial
    plot(OvTrial, obsCriterion, 'or'); % Overt-criterion as a fct of trial
    plot(wind,estCriterion,'ob'); % Estimated criterion as a fct of trial
    legend('Omnicient criterion', 'Overt criterion', 'Covert criterion');
    xlabel('Trial number');
    ylabel('Orientation (deg)');
    hold off;
    
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
    plot3(FAR(hackWind), HR(hackWind), c(hackWind), '*r')
    xlabel('FAR');
    ylabel('HR');
    zlabel('Bias ratio (c)');
    hold off;


end

if strcmp(save_opt,'y')
    % Save data to struct and export to csv
    SDT_MixedPlot.omCrit = omCriterion;
    SDT_MixedPlot.estCrit = estCriterion;
    SDT_MixedPlot.obsCrit = obsCriterion;
    SDT_MixedPlot.trial = trial;
    SDT_MixedPlot.OvTrial = OvTrial;
    SDT_MixedPlot.wind = wind;
    SDT_MixedPlot.CovOmCrit = CovOmCrit;
    SDT_MixedPlot.OvOmCrit = OvOmCrit;

    SDT_MixedPlot.catResp = catResp;
    SDT_MixedPlot.smoothCatResp = smoothCatResp;
    SDT_MixedPlot.smoothProbA = smoothProbA;
    SDT_MixedPlot.smoothpA_obs = smoothpA_obs;
    SDT_MixedPlot.bias = c;
    SDT_MixedPlot.FAR = FAR;
    SDT_MixedPlot.HR = HR;
    SDT_MixedPlot.hackWind = hackWind;

    struct2csv(SDT_MixedPlot,[fileName,'.csv'])
end
    
    
    
end
    
    
    
    
    
    
    
    
