%% Covert- and overt-criterion learning with changing category probabilities
    % In this experiment there are 2 blocks, 1 category training and 1
    % experimental, consisting of 200 and 1200 trials respectively. Trials
    % consist mostly of covert condition, with an overt condition every 5
    % trials.

clear all; clc; close all;
%%
% Feedback sounds

fs_correct = 12000;
fs_incorrect = 12000;
T = .2;
t_correct = 0:(1/fs_correct):T;
t_incorrect = 0:(1/fs_incorrect):T;
f_correct = 600;
f_incorrect = 500;
a = .5;
beep_correct = a*sin(2*pi*f_correct*t_correct);
beep_incorrect = a*sin(2*pi*f_incorrect*t_incorrect);

% Define experimental variables
data.NumBlocks = 1;
data.NumTrials = 15;
trainingData.NumTrials = 2; 
data.trial = [];
trainingData.trial = [];
data.StdDev = 10;
OvertTrialFreq = 5;
i = 1; % Previously block order
data.PracticeTrials = 5;
P = [.2, .35, .5, .65, .8];
ChangeRange = [80:120];

% Create line image
LineWidth = 14; % in pixels
LineHeight = 150; % in pixels
Body = zeros(LineHeight,10);
Side = zeros(LineHeight,2);
TopBottom = zeros(2,LineWidth);
Body1 = Body+255;
Body2 = Body+255;
Body3 = Body;
Side1 = Side+128;
Side2 = Side+128;
Side3 = Side+128;
TopBottom1 = TopBottom+128;
TopBottom2 = TopBottom+128;
TopBottom3 = TopBottom+128;
L1 = [Side1 Body1 Side1];
L1 = [TopBottom1;L1;TopBottom1];
L2 = [Side2 Body2 Side2];
L2 = [TopBottom2;L2;TopBottom2];
L3 = [Side3 Body3 Side3];
L3 = [TopBottom3;L3;TopBottom3];
Line(:,:,1) = L1; Line(:,:,2) = L2; Line(:,:,3) = L3;

% Set stimulus (vertical ellipse) size in degrees of visual angle
StimHeight = 4;
StimWidth = 1;
ViewingDist = 21.5; % Viewing distance in inches
StimHeightInch = 2*ViewingDist*tan(pi/360*StimHeight); % Stimulus height in inches
StimWidthInch = 2*ViewingDist*tan(pi/360*StimWidth); % Stimulus width in inches
ScreenHeightInch = 9.5;
ScreenWidthInch = 13;
ScreenHeightPix = 768;
ScreenWidthPix = 1024;

% Set-up datafile
initials=input('Enter initials: ','s');
datafile = strcat('SDTChangingProbabilitiesMixed', '_', initials);

 %Load prelimnary data and calculate the distribution standard deviation
cd('/e/4.1/p3/norton/ChangingCategoryProbabilities/CalibrationData');
%cd('/Users/chrisgrimmick/Documents/Lab/MATLAB/Elyse'); % for Macbook compatibility 

PrelimData = strcat('Calibration_ChangingProb', '_', initials);
load(PrelimData);
data.EllipseNoise = PreData.EllipseNoise;
data.StdDevCombined = sqrt(2*(data.StdDev.^2+data.EllipseNoise.^2));


cd('/e/4.1/p3/norton/ChangingCategoryProbabilities/ExperimentalTasks');
%cd('/Users/chrisgrimmick/Documents/Lab/MATLAB/Elyse');
% Set-up and open screen
grey = 128; % Background color
whichScreen = max(Screen('Screens'));
[win, winrect] = Screen('OpenWindow', whichScreen, grey); % Open window
%[win, winrect] = Screen('OpenWindow', whichScreen, grey, [0 0 640 480]); % Smaller window for test
[screenWidth, screenHeight] = Screen('WindowSize', win);
load('GammaTableEHN'); % Saved from monitor
%calibration
Screen('LoadNormalizedGammaTable', win, gammaTable2*[1 1 1]);
HideCursor;


% Open off screen window
winOff=Screen('OpenOffScreenWindow',win,grey);
Texture1 = Screen('MakeTexture',win,Line);

%%
% Create a temporary file to save the data in on every trial
Temp = strcat('Temp', '_', initials, '.mat');
if exist(Temp, 'file') == 2
    load(Temp);
    data.RndNumSeed(end+1) = sum(100*clock);
    rand('seed',data.RndNumSeed(end)); 
    randn('seed',data.RndNumSeed(end)); % Seeds the random number generators with the clock time
    % so different random sequences are used during each session.
    
    if max(trainingData.trial) < trainingData.NumTrials;
        RunTraining = 1;
        StartTrainingTrial = max(trainingData.trial) + 1;
    elseif isempty(data.trial)
        RunTraining = 0;
        CurrentTrial = 1;
    else
        RunTraining = 0;
        CurrentTrial = data.trial+1;
    end
   
else
    RunTraining = 1;
    StartTrainingTrial = 1;
    data.RndNumSeed = sum(100*clock);
    rand('seed',data.RndNumSeed); 
    randn('seed',data.RndNumSeed);
end

    %% Training 

    if RunTraining == 1
        % Define signal and noise distributions for training and
        % experimental block
        data.LowerOrientationBound = ceil(-90+data.StdDev*4);
        data.UpperOrientationBound = floor(90-data.StdDev*5-(data.StdDevCombined-data.StdDev));
        X = data.LowerOrientationBound:data.UpperOrientationBound;
            
        X = -90:90;
        R = 1:numel(X);
        index = R(ceil(numel(R) * rand(1,1))); % Pick a random mean for signal
        M_signal = X(index);
        M_noise = M_signal + data.StdDevCombined;

        trainingData.MeanSignal = M_signal;
        trainingData.MeanNoise = M_noise;
        trainingData.StdDevSignal = data.StdDev;
        trainingData.StdDevNoise = data.StdDev;

        data.MeanSignal = M_signal;
        data.MeanNoise = M_noise;
        data.StdDevSignal = data.StdDev;
        data.StdDevNoise = data.StdDev;



        % Before beginning the experimental tasks we need to train the
        % participants on the categories

        % Directions for category training
        Screen(win, 'FillRect', grey);
        Screen('TextFont',win,'helvetica');
        Screen('TextSize',win,32);
        text=sprintf('Category training\n\nOn each trial you will see an ellipse.\nThere is an equal chance it belongs to\nthe red or green category.\n\nPress 1 if it belongs to the red category.\nPress 2 if it belongs to the green category.\n\n<Press the spacebar to continue>');
        [nx ny bbox] = DrawFormattedText(win,text,'center', 'center', [255 255 255]);
        Screen('Flip',win);
        while 1
            [keydown, secs, keycode, deltaSecs] = KbCheck;
            if keydown && keycode(KbName('space'))
                break
            elseif keydown && keycode(KbName('ESCAPE'))
                Screen('Closeall');
            end
        end
        % Train the categories (200 trials)
        for ii = StartTrainingTrial:trainingData.NumTrials
            trainingData.trial(ii,i) = ii;
            TrialType = [1 2]; % Where 1 represents category B (red) and 2 represents category A (green)
            trainingData.TrialType(ii,i) = TrialType(ceil(numel(TrialType) * rand(1,1)));
            if trainingData.TrialType(ii,i) == 1
                Angle_noise = trainingData.StdDevNoise(i)*randn(1,1)+trainingData.MeanNoise(i);
                trainingData.TrueAngle(ii,i) = Angle_noise;
                % Code everything from -90 to 90
                if and(Angle_noise <= 90, Angle_noise >= -90)
                    trainingData.EllipseAngle(ii,i) = Angle_noise;
                elseif and(Angle_noise <= 180, Angle_noise > 90)
                    trainingData.EllipseAngle(ii,i) = Angle_noise-180;
                elseif and(Angle_noise < -90, Angle_noise >= -180)
                    trainingData.EllipseAngle(ii,i) = Angle_noise+180;
                elseif and(Angle_noise < -180, Angle_noise >= -270)
                    trainingData.EllipseAngle(ii,i) = Angle_noise+180;
                elseif and(Angle_noise <= 270, Angle_noise > 180)
                    trainingData.EllipseAngle(ii,i) = Angle_noise-180;
                end
            elseif trainingData.TrialType(ii,i) == 2
                Angle_signal = trainingData.StdDevSignal(i)*randn(1,1)+trainingData.MeanSignal(i);
                trainingData.TrueAngle(ii,i) = Angle_signal;
                % Code everything from -90 to 90
                if and(Angle_signal <= 90, Angle_signal >= -90)
                    trainingData.EllipseAngle(ii,i) = Angle_signal;
                elseif and(Angle_signal <= 180, Angle_signal > 90)
                    trainingData.EllipseAngle(ii,i) = Angle_signal-180;
                elseif and(Angle_signal < -90, Angle_signal >= -180)
                    trainingData.EllipseAngle(ii,i) = Angle_signal+180;
                elseif and(Angle_signal < -180, Angle_signal >= -270)
                    trainingData.EllipseAngle(ii,i) = Angle_signal+180;
                elseif and(Angle_signal <= 270, Angle_signal > 180)
                    trainingData.EllipseAngle(ii,i) = Angle_signal-180;
                end
            end

            % Ensure the ellipse is always 4 x 1 deg regardless of
            % orientation

            %Step 1: Calculate the pixels/inch on diagonal of stimulus
            %orientation
            if and(trainingData.EllipseAngle(ii,i) >= atan(ScreenHeightInch/ScreenWidthInch), trainingData.EllipseAngle(ii,i) <= 90)
                Opposite = ScreenHeightInch;
                Adjacent = Opposite/atan(trainingData.EllipseAngle(ii,i)*(pi/180));
                HeightInch = Opposite;
                WidthInch = Adjacent;
            elseif and(trainingData.EllipseAngle(ii,i) >= 0, trainingData.EllipseAngle(ii,i) < atan(ScreenHeightInch/ScreenWidthInch))
                Adjacent = ScreenWidthInch;
                Opposite = tan(trainingData.EllipseAngle(ii,i)*(pi/180))*Adjacent;
                HeightInch = Adjacent;
                WidthInch = Opposite;
            elseif and(trainingData.EllipseAngle(ii,i) < 0, trainingData.EllipseAngle(ii,i) >= -atan(ScreenHeightInch/ScreenWidthInch))
                Adjacent = ScreenWidthInch;
                Opposite = abs(tan(trainingData.EllipseAngle(ii,i)*(pi/180))*Adjacent);
                HeightInch = Opposite;
                WidthInch = Adjacent;
            elseif and(trainingData.EllipseAngle(ii,i) < -atan(ScreenHeightInch/ScreenWidthInch), trainingData.EllipseAngle(ii,i) >= -90)
                angleWant = 90-trainingData.EllipseAngle(ii,i);
                Adjacent = ScreenHeightInch;
                Opposite = tan(angleWant)*Adjacent;
                HeightInch = Adjacent;
                WidthInch = Opposite;
            end

            % Step 2: Calculate the size of the ellipse in pixels    
            HeightPix = (ScreenHeightPix*HeightInch)/ScreenHeightInch;
            WidthPix = (ScreenWidthPix*WidthInch)/ScreenWidthInch;
            dpix = sqrt(HeightPix^2 + WidthPix^2);
            dinch = sqrt(HeightInch^2 + WidthInch^2);
            PPI = dpix/dinch;
            FirstStimHeightPix = PPI*StimHeightInch;
            FirstStimWidthPix = PPI*StimWidthInch;

            Screen(win, 'FillRect', grey);
            Screen('TextFont',win,'helvetica');
            Screen('TextSize',win,32);
            text=sprintf('+');
            DrawFormattedText(win,text,'center', 'center', [255 255 255]);
            Screen('Flip', win');
            WaitSecs(.5);

            % Display black ellipse and wait for response
            RectEllipse = [0 0 FirstStimWidthPix FirstStimHeightPix];
            % Rotate rectangle
            posX = winrect(3)/2;
            posY = winrect(4)/2;
            angle = 90-trainingData.EllipseAngle(ii,i);
            Screen('glPushMatrix', win)
            Screen('glTranslate', win, posX, posY)
            Screen('glRotate', win, angle, 0, 0);
            Screen('glTranslate', win, -posX, -posY)
            Screen('FillOval', win, [0 0 0], CenterRectOnPoint(RectEllipse, posX, posY));
            Screen('glPopMatrix', win)
            Screen('Flip',win, []);
            WaitSecs(.3);

            Screen(win, 'FillRect', grey);
            Screen('TextFont',win,'helvetica');
            Screen('TextSize',win,32);
            text=sprintf('+');
            DrawFormattedText(win,text,'center', 'center', [255 255 255]);
            Screen('Flip', win);

            while 1
                [keydown, secs, keycode, deltasecs] = KbCheck;
                if keydown && keycode(KbName('1!'))
                    TrialTypeEstimate=1;
                    break
                elseif keydown && keycode(KbName('2@'))
                    TrialTypeEstimate=2;
                    break
                elseif keydown && keycode(KbName('ESCAPE'))
                    Screen('Closeall');
                end
            end

            trainingData.response(ii,i) = TrialTypeEstimate;

            % Score particpant's response
            if trainingData.TrialType(ii,i) == 1 % Display red fixation
                Screen(win, 'FillRect', grey);
                Screen('TextFont',win,'helvetica');
                Screen('TextSize',win,32);
                text=sprintf('+');
                DrawFormattedText(win,text,'center', 'center', [255 0 0]);
                % Hit or miss?
                if trainingData.response(ii,i) == 1
                    trainingData.score(ii,i) = 1;
                elseif trainingData.response(ii,i) == 2
                    trainingData.score(ii,i) = 0;
                end
            elseif trainingData.TrialType(ii,i) == 2 % Display green fixation
                Screen(win, 'FillRect', grey);
                Screen('TextFont',win,'helvetica');
                Screen('TextSize',win,32);
                text=sprintf('+');
                DrawFormattedText(win,text,'center', 'center', [0 255 0]);
                % Correct reject or false alarm?
                if trainingData.response(ii,i) == 2
                    trainingData.score(ii,i) = 1;
                elseif trainingData.response(ii,i) == 1
                    trainingData.score(ii,i) = 0;
                end
            end
            Screen('Flip', win);

            if trainingData.score(ii,i) == 1
                sound(beep_correct, fs_correct);
            else
                sound (beep_incorrect, fs_incorrect);
            end

            WaitSecs(.3);

            % Display progress every 50 trails
            if and(mod(trainingData.trial(ii,i), 50) == 0, trainingData.trial(ii,i) ~= trainingData.NumTrials)
                TrialString = num2str(trainingData.trial(ii,i));
                TotalString = num2str(trainingData.NumTrials);
                Screen(win, 'FillRect', grey);
                Screen('TextFont',win,'helvetica');
                Screen('TextSize',win,32);
                FirstLine = strcat('You have completed', {' '}, TrialString, {' '}, 'out of', {' '}, TotalString, {' '}, 'trials.');
                SecondLine = '<Press the spacebar to continue>';
                text = strcat(FirstLine,'\n\n',SecondLine);
                text = char(text);
                [nx ny bbox] = DrawFormattedText(win,text,'center', 'center', [255 255 255]);
                Screen('Flip',win);
                while 1
                    [keydown, secs, keycode, deltaSecs] = KbCheck;
                    if keydown && keycode(KbName('space'))
                       break
                    elseif keydown && keycode(KbName('ESCAPE'))
                        Screen('Closeall');
                    end
                end
            elseif trainingData.trial(ii,i) == trainingData.NumTrials
                TrialString = num2str(trainingData.trial(ii,i));
                Screen(win, 'FillRect', grey);
                Screen('TextFont',win,'helvetica');
                Screen('TextSize',win,32);
                text = sprintf('You have completed the category training block.\n\n<Please find the experimenter before continuing>');
                [nx ny bbox] = DrawFormattedText(win,text,'center', 'center', [255 255 255]);
                Screen('Flip',win);
                while 1
                    [keydown, secs, keycode, deltaSecs] = KbCheck;
                    if keydown && keycode(KbName('ENTER'))
                       break
                    elseif keydown && keycode(KbName('ESCAPE'))
                        Screen('Closeall');
                    end
                end
            end
            save(Temp, 'trainingData', 'data');
        end
    
                        
        % Get a measure of how well people learned the categories

        % Directions for measuring the prototypical ellipse from the red
        % category
        Screen(win, 'FillRect', grey);
        Screen('TextFont',win,'helvetica');
        Screen('TextSize',win,32);
        text=sprintf('Move the mouse left or right rotate the ellipse so that the\norientation matches the average orientation\nof all the ellipses belonging to the RED category.\n\n<Press the spacebar to continue>');
        [nx ny bbox] = DrawFormattedText(win,text,'center', 'center', [255 255 255]);
        Screen('Flip',win);
        while 1  
            [keydown, secs, keycode, deltaSecs] = KbCheck;
            if keydown && keycode(KbName('space'))
               break
            elseif keydown && keycode(KbName('ESCAPE'))
                Screen('Closeall');
            end
        end
        WaitSecs(.3);
        X = -90:90;
        R = 1:numel(X);
        index = R(ceil(numel(R) * rand(1,1))); % Pick a random starting orientation
        StartingOrientation = X(index);
        trainingData.RedEllipseStartingOrientation(i) = StartingOrientation;
         %Step 1: Calculate the pixels/inch on diagonal of stimulus
        %orientation
        Opposite = ScreenHeightInch;
        Adjacent = Opposite/atan(StartingOrientation*(pi/180));
        HeightInch = Opposite;
        WidthInch = Adjacent;

        % Step 2: Calculate the size of the ellipse in pixels    
        HeightPix = (ScreenHeightPix*HeightInch)/ScreenHeightInch;
        WidthPix = (ScreenWidthPix*WidthInch)/ScreenWidthInch;
        dpix = sqrt(HeightPix^2 + WidthPix^2);
        dinch = sqrt(HeightInch^2 + WidthInch^2);
        PPI = dpix/dinch;
        FirstStimHeightPix = PPI*StimHeightInch;
        FirstStimWidthPix = PPI*StimWidthInch;

        Screen(win, 'FillRect', grey);
        Screen('Flip', win');

        % Display black ellipse
        RectEllipse = [0 0 FirstStimWidthPix FirstStimHeightPix];
        % Rotate rectangle
        posX = winrect(3)/2;
        posY = winrect(4)/2;
        angle = 90-StartingOrientation;
        Screen('glPushMatrix', win)
        Screen('glTranslate', win, posX, posY)
        Screen('glRotate', win, angle, 0, 0);
        Screen('glTranslate', win, -posX, -posY)
        Screen('FillOval', win, [0 0 0], CenterRectOnPoint(RectEllipse, posX, posY));
        Screen('glPopMatrix', win)
        Screen('Flip',win, []);

         x = []; 
        [x(1),~,buttons] = GetMouse(whichScreen);
        % Track mouse to rotate
        while ~any(buttons)
            % Track and scroll
            [x(end+1),~,buttons] = GetMouse(whichScreen);
            DiffPixels = x(end-1)-x(end); % Difference in number of pixels
            DiffDegrees = .5*DiffPixels; % One pixel corresponds to 1/2 a degree
            % Make sure StartingOrientation + DiffDegrees 
            RotationAngle = 90-(StartingOrientation+DiffDegrees);
            RotationAngle = mod(RotationAngle, 180);
            posX = winrect(3)/2;
            posY = winrect(4)/2;
            Screen('glPushMatrix', win)
            Screen('glTranslate', win, posX, posY)
            Screen('glRotate', win, RotationAngle, 0, 0);
            Screen('glTranslate', win, -posX, -posY)
            Screen('FillOval', win, [0 0 0], CenterRectOnPoint(RectEllipse, posX, posY));
            Screen('glPopMatrix', win)
            Screen('Flip', win);
            StartingOrientation = StartingOrientation+DiffDegrees;
        end

        % Record orientation and compare to mean of the red category
        trainingData.RedMeanEstimate(i) = 90-RotationAngle;
         % Directions for measuring the prototypical ellipse from the green
        % category
        Screen(win, 'FillRect', grey);
        Screen('TextFont',win,'helvetica');
        Screen('TextSize',win,32);
        text=sprintf('Move the mouse left or right rotate the ellipse so that the\norientation matches the average orientation\nof all the ellipses belonging to the GREEN category.\n\n<Press the spacebar to continue>');
        [nx ny bbox] = DrawFormattedText(win,text,'center', 'center', [255 255 255]);
        Screen('Flip',win);
        while 1
            [keydown, secs, keycode, deltaSecs] = KbCheck;
            if keydown && keycode(KbName('space'))
               break
            elseif keydown && keycode(KbName('ESCAPE'))
                Screen('Closeall');
            end
        end
        WaitSecs(.3);

        X = -90:90;
        R = 1:numel(X);
        index = R(ceil(numel(R) * rand(1,1))); % Pick a random starting orientation
        StartingOrientation = X(index);
        trainingData.GreenEllipseStartingOrientation(i) = StartingOrientation;

        %Step 1: Calculate the pixels/inch on diagonal of stimulus
        %orientation
        Opposite = ScreenHeightInch;
        Adjacent = Opposite/atan(StartingOrientation*(pi/180));
        HeightInch = Opposite;
        WidthInch = Adjacent;

        % Step 2: Calculate the size of the ellipse in pixels    
        HeightPix = (ScreenHeightPix*HeightInch)/ScreenHeightInch;
        WidthPix = (ScreenWidthPix*WidthInch)/ScreenWidthInch;
        dpix = sqrt(HeightPix^2 + WidthPix^2);
        dinch = sqrt(HeightInch^2 + WidthInch^2);
        PPI = dpix/dinch;
        FirstStimHeightPix = PPI*StimHeightInch;
        FirstStimWidthPix = PPI*StimWidthInch;

        Screen(win, 'FillRect', grey);
        Screen('Flip', win');

        % Display vertical black ellipse
        RectEllipse = [0 0 FirstStimWidthPix FirstStimHeightPix];
        % Rotate rectangle
        posX = winrect(3)/2;
        posY = winrect(4)/2;
        angle = 90-StartingOrientation;
        Screen('glPushMatrix', win)
        Screen('glTranslate', win, posX, posY)
        Screen('glRotate', win, angle, 0, 0);
        Screen('glTranslate', win, -posX, -posY)
        Screen('FillOval', win, [0 0 0], CenterRectOnPoint(RectEllipse, posX, posY));
        Screen('glPopMatrix', win)
        Screen('Flip',win, []);

        x = [];
        [x(1),y,buttons] = GetMouse(whichScreen);
        % Track mouse to rotate
        while ~any(buttons)
            % Track and scroll
            [x(end+1),y,buttons] = GetMouse(whichScreen);
            DiffPixels = x(end-1)-x(end); % Difference in number of pixels
            DiffDegrees = .5*DiffPixels; % One pixel corresponds to 1/2 a degree
            % Make sure StartingOrientation + DiffDegrees 
            RotationAngle = 90-(StartingOrientation+DiffDegrees);
            RotationAngle = mod(RotationAngle, 180);
            posX = winrect(3)/2;
            posY = winrect(4)/2;
            Screen('glPushMatrix', win)
            Screen('glTranslate', win, posX, posY)
            Screen('glRotate', win, RotationAngle, 0, 0);
            Screen('glTranslate', win, -posX, -posY)
            Screen('FillOval', win, [0 0 0], CenterRectOnPoint(RectEllipse, posX, posY));
            Screen('glPopMatrix', win)
            Screen('Flip', win);
            StartingOrientation = StartingOrientation+DiffDegrees;
        end

        % Record orientation and compare to mean of the green category
        trainingData.GreenMeanEstimate(i) = 90-RotationAngle;

        save(Temp, 'trainingData', 'data');
            
    
        Screen(win, 'FillRect', grey);
        Screen('TextFont',win,'helvetica');
        Screen('TextSize',win,32);
        text=sprintf('Take a quick break!\n\n<Press the spacebar to continue>');
        [nx ny bbox] = DrawFormattedText(win,text,'center', 'center', [255 255 255]);
        Screen('Flip',win);
        while 1
            [keydown, secs, keycode, deltaSecs] = KbCheck;
            if keydown && keycode(KbName('space'))
                RunTraining = 0;
                CurrentTrial = 1;
               break
            elseif keydown && keycode(KbName('ESCAPE'))
                Screen('Closeall');
            end
        end
    end
        
    
    
    
 
 %% Experiment Block 
  
 if RunTraining == 0
     
  
     
     
            % Prelim probabilities generator
            % Precalculate p(A) and p(B) for each trial using a sample and
            % hold procedure
            
            
            
           % 5 probabilities 3 nonrepeating perumtations 

            % Randomly shuffle probability sequence three times
            P1 = Shuffle(P);
            P2 = Shuffle(P);
            P3 = Shuffle(P);

            %Concatinate permutations
            Probs = [P1 P2 P3];
            
            % Find any repeats and swap them
            
            if Probs(5) == Probs(6)
                Probs([6 7]) = Probs([7 6]);
            end

            if Probs(10) == Probs(11)
                Probs([11 12]) = Probs([12 11]);
            end
            
            SampleHoldLength = datasample(ChangeRange,15); % Randomly sample a hold length
            Change = 1; % Keep track of where to change in loop 
            count = 1; % Indexing hold lengths and Probs

            pA = [];
            
            
            while numel(pA) < data.NumTrials

                pA(Change:((Change) + SampleHoldLength(count))) = Probs(count);

                Change = numel(pA) + 1;

                count = count + 1;

            end


            data.pA(:,i) = pA(1:data.NumTrials);
            data.pB(:,i) = 1-data.pA(:,i);
            data.SampleHoldLength = SampleHoldLength(1:count);

            Screen(win, 'FillRect', grey);
            Screen('TextFont',win,'helvetica');
            Screen('TextSize',win,32);
            text=sprintf('For the Experiment Block, you will again\ncategorize ellipses by pressing 1 or 2 on the keyboard\nwith your left hand, just as you did in the training.\n\n<Press the spacebar to continue>');
            [nx ny bbox] = DrawFormattedText(win,text,'center', 'center', [255 255 255]);
            Screen('Flip',win);
            while 1
                [keydown, secs, keycode, deltaSecs] = KbCheck;
                if keydown && keycode(KbName('space'))
                   break
                elseif keydown && keycode(KbName('ESCAPE'))
                    Screen('Closeall');
                end
            end
            
            FlushEvents;
            text=sprintf('But now on every fifth trial a line will appear.\nMove the line with the mouse using your right hand,\nto where to think a RED ellipse will fall COUNTER-CLOCKWISE of the line\nand a GREEN ellipse will fall CLOCKWISE of the line.\nClick the mouse to set the line, and you will be shown an ellipse drawn\nfrom one of the categories and recieve feedback on your line placement.')
            [nx ny bbox] = DrawFormattedText(win,text,'center', 'center', [255 255 255]);
            Screen('Flip',win);
            while 1
                [keydown, secs, keycode, deltaSecs] = KbCheck;
                if keydown && keycode(KbName('space'))
                   break
                elseif keydown && keycode(KbName('ESCAPE'))
                    Screen('Closeall');
                end
            end
            
            FlushEvents;
            text=sprintf('The probabilities of each category will NOT be the same during this portion,\nand will change over the course of the experiment.\nYou will have to take this into account during both\ncategorizing and line setting tasks.')
            [nx ny bbox] = DrawFormattedText(win,text,'center', 'center', [255 255 255]);
            Screen('Flip',win);
            while 1
                [keydown, secs, keycode, deltaSecs] = KbCheck;
                if keydown && keycode(KbName('space'))
                   break
                elseif keydown && keycode(KbName('ESCAPE'))
                    Screen('Closeall');
                end
            end
            % Trial setup
            
            for j = CurrentTrial:data.NumTrials
                
                % Choose ellipse from category A or B with p(A) and p(B).
                % Use the same categories that were used in the training
                % block
                data.trial(j,i) = j;
                TrialType = [1 2]; % Where 1 represents category B (red) and 2 represents category A (green)
                RandEllipse = rand(1,1);
                if RandEllipse <= data.pA(j,i)
                    data.TrialType(j,i) = 2;
                    Angle_signal = data.StdDevSignal(i)*randn(1,1)+data.MeanSignal(i);
                    data.TrueAngle(j,i) = Angle_signal;
                    % Code everything from -90 to 90
                    if and(Angle_signal <= 90, Angle_signal >= -90)
                        data.EllipseAngle(j,i) = Angle_signal;
                    elseif and(Angle_signal <= 180, Angle_signal > 90)
                        data.EllipseAngle(j,i) = Angle_signal-180;
                    elseif and(Angle_signal < -90, Angle_signal >= -180)
                        data.EllipseAngle(j,i) = Angle_signal+180;
                    elseif and(Angle_signal < -180, Angle_signal >= -270)
                        data.EllipseAngle(j,i) = Angle_signal+180;
                    elseif and(Angle_signal <= 270, Angle_signal > 180)
                        data.EllipseAngle(j,i) = Angle_signal-180;
                    end
                else
                     data.TrialType(j,i) = 1;
                    Angle_noise = data.StdDevNoise(i)*randn(1,1)+data.MeanNoise(i);
                    data.TrueAngle(j,i) = Angle_noise;
                    % Code everything from -90 to 90
                    if and(Angle_noise <= 90, Angle_noise >= -90)
                        data.EllipseAngle(j,i) = Angle_noise;
                    elseif and(Angle_noise <= 180, Angle_noise > 90)
                        data.EllipseAngle(j,i) = Angle_noise-180;
                    elseif and(Angle_noise < -90, Angle_noise >= -180)
                        data.EllipseAngle(j,i) = Angle_noise+180;
                    elseif and(Angle_noise < -180, Angle_noise >= -270)
                        data.EllipseAngle(j,i) = Angle_noise+180;
                    elseif and(Angle_noise <= 270, Angle_noise > 180)
                        data.EllipseAngle(j,i) = Angle_noise-180;
                    end
                end
                
                % Ensure the ellipse is always 4 x 1 deg regardless of
                % orientation
                   
                %Step 1: Calculate the pixels/inch on diagonal of stimulus
                %orientation
                if and(data.EllipseAngle(j,i) >= atan(ScreenHeightInch/ScreenWidthInch), data.EllipseAngle(j,i) <= 90)
                    Opposite = ScreenHeightInch;
                    Adjacent = Opposite/atan(data.EllipseAngle(j,i)*(pi/180));
                    HeightInch = Opposite;
                    WidthInch = Adjacent;
                elseif and(data.EllipseAngle(j,i) >= 0, data.EllipseAngle(j,i) < atan(ScreenHeightInch/ScreenWidthInch))
                    Adjacent = ScreenWidthInch;
                    Opposite = tan(data.EllipseAngle(j,i)*(pi/180))*Adjacent;
                    HeightInch = Adjacent;
                    WidthInch = Opposite;
                elseif and(data.EllipseAngle(j,i) < 0, data.EllipseAngle(j,i) >= -atan(ScreenHeightInch/ScreenWidthInch))
                    Adjacent = ScreenWidthInch;
                    Opposite = abs(tan(data.EllipseAngle(j,i)*(pi/180))*Adjacent);
                    HeightInch = Opposite;
                    WidthInch = Adjacent;
                elseif and(data.EllipseAngle(j,i) < -atan(ScreenHeightInch/ScreenWidthInch), data.EllipseAngle(j,i) >= -90)
                    angleWant = 90-data.EllipseAngle(j,i);
                    Adjacent = ScreenHeightInch;
                    Opposite = tan(angleWant)*Adjacent;
                    HeightInch = Adjacent;
                    WidthInch = Opposite;
                end
                
                
                
                % Step 2: Calculate the size of the ellipse in pixels
                HeightPix = (ScreenHeightPix*HeightInch)/ScreenHeightInch;
                WidthPix = (ScreenWidthPix*WidthInch)/ScreenWidthInch;
                dpix = sqrt(HeightPix^2 + WidthPix^2);
                dinch = sqrt(HeightInch^2 + WidthInch^2);
                PPI = dpix/dinch;
                FirstStimHeightPix = PPI*StimHeightInch;
                FirstStimWidthPix = PPI*StimWidthInch;
                
                
                % Overt Trial
                if mod(j,OvertTrialFreq)==0
                
                    % Choose a random starting orientation for the line
                    X = -90:90;
                    R = 1:numel(X);
                    index = R(ceil(numel(R) * rand(1,1))); % Pick a random starting orientation
                    StartingOrientation = X(index);
                    data.StartingOrientation(j,i) = StartingOrientation;
                    data.TrialCondition(j,i) = 1;
                    % Display line
                    RotationAngle = 90-StartingOrientation;
                    Screen('DrawTexture', win, Texture1, [], [], RotationAngle); 
                    Screen('Flip', win);

                    x = [];
                    [x(1),~,buttons] = GetMouse(whichScreen);
                    % Track mouse to rotate
                    while ~any(buttons)
                        % Track and scroll
                        [x(end+1),~,buttons] = GetMouse(whichScreen);
                        DiffPixels = x(end-1)-x(end); % Difference in number of pixels
                        DiffDegrees = .5*DiffPixels; % One pixel corresponds to 1/2 a degree
                        % Make sure StartingOrientation + DiffDegrees is
                        % between [0, 180] for proper display
                        RotationAngle = 90-(StartingOrientation+DiffDegrees);
                        RotationAngle = mod(RotationAngle, 180);
                        Screen('DrawTexture', win, Texture1, [], [], RotationAngle); 
                        Screen('Flip', win);
                        StartingOrientation = StartingOrientation+DiffDegrees;
                    end

                    data.criterion(j,i) = 90-RotationAngle; % Record participant's rotation angle

                    RectEllipse = [0 0 FirstStimWidthPix FirstStimHeightPix];
                    posX = winrect(3)/2;
                    posY = winrect(4)/2;
                    angle = 90-data.EllipseAngle(j,i);
                    Screen('glPushMatrix', win)
                    Screen('glTranslate', win, posX, posY)
                    Screen('glRotate', win, angle, 0, 0);
                    Screen('glTranslate', win, -posX, -posY)

                   % Compare particpant's rotation angle to the random draw from the
                    % signal or noise distribution
                    if data.TrialType(j,i) == 1 % Display red ellipse
                        Screen('FillOval', win, [255 0 0], CenterRectOnPoint(RectEllipse, posX, posY));
                        Screen('glPopMatrix', win)
                        % Hit or miss?
                        if or(and(data.criterion(j,i) > 0, data.EllipseAngle(j,i) > 0), and(data.criterion(j,i) < 0, data.EllipseAngle(j,i) < 0))
                            if data.criterion(j,i) <= data.EllipseAngle(j,i)
                                data.score(j,i) = 1;
                            elseif data.criterion(j,i) > data.EllipseAngle(j,i)
                                data.score(j,i) = 0;
                            end
                        elseif and(data.criterion(j,i) > 0, data.EllipseAngle(j,i) < 0)
                            EZ = data.EllipseAngle(j,i)-data.criterion(j,i);
                            ZE = data.criterion(j,i)-data.EllipseAngle(j,i);
                            if mod(EZ,180) < mod(ZE,180)
                                data.EllipseAngle(j,i) = mod(data.EllipseAngle(j,i), 180);
                            else
                                data.EllipseAngle(j,i) = data.EllipseAngle(j,i);
                            end
                            if data.criterion(j,i) <= data.EllipseAngle(j,i)
                                data.score(j,i) = 1;
                            elseif data.criterion(j,i) > data.EllipseAngle(j,i)
                                data.score(j,i) = 0;
                            end
                        elseif and(data.criterion(j,i) < 0, data.EllipseAngle(j,i) > 0)
                            EZ = data.EllipseAngle(j,i)-data.criterion(j,i);
                            ZE = data.criterion(j,i)-data.EllipseAngle(j,i);
                            if mod(EZ,180) > mod(ZE,180)
                                data.criterion(j,i) = mod(data.criterion(j,i), 180);
                            else
                                data.criterion(j,i) = data.criterion(j,i);
                            end
                            if data.criterion(j,i) <= data.EllipseAngle(j,i)
                                data.score(j,i) = 1;
                            elseif data.criterion(j,i) > data.EllipseAngle(j,i)
                                data.score(j,i) = 0;
                            end
                        end 
                    elseif data.TrialType(j,i) == 2 % Display green ellipse
                        Screen('FillOval', win, [0 255 0], CenterRectOnPoint(RectEllipse, posX, posY));
                        Screen('glPopMatrix', win)
                        % Correct reject or false alarm?
                        if or(and(data.criterion(j,i) > 0, data.EllipseAngle(j,i) > 0), and(data.criterion(j,i) < 0, data.EllipseAngle(j,i) < 0))
                            if data.criterion(j,i) >= data.EllipseAngle(j,i)
                                data.score(j,i) = 1;
                            elseif data.criterion(j,i) < data.EllipseAngle(j,i)
                                data.score(j,i) = 0;
                            end
                        elseif and(data.criterion(j,i) > 0, data.EllipseAngle(j,i) < 0)
                            EZ = data.EllipseAngle(j,i)-data.criterion(j,i);
                            ZE = data.criterion(j,i)-data.EllipseAngle(j,i);
                            if mod(EZ,180) < mod(ZE,180)
                                data.EllipseAngle(j,i) = mod(data.EllipseAngle(j,i), 180);
                            else
                                data.EllipseAngle(j,i) = data.EllipseAngle(j,i);
                            end  
                            if data.criterion(j,i) >= data.EllipseAngle(j,i)
                                data.score(j,i) = 1;
                            elseif data.criterion(j,i) < data.EllipseAngle(j,i)
                                data.score(j,i) = 0;
                            end
                        elseif and(data.criterion(j,i) < 0, data.EllipseAngle(j,i) > 0)
                            EZ = data.EllipseAngle(j,i)-data.criterion(j,i);
                            ZE = data.criterion(j,i)-data.EllipseAngle(j,i);
                            if mod(EZ,180) > mod(ZE,180)
                                data.criterion(j,i) = mod(data.criterion(j,i), 180);
                            else
                                data.criterion(j,i) = data.criterion(j,i);
                            end
                            if data.criterion(j,i) >= data.EllipseAngle(j,i)
                                data.score(j,i) = 1;
                            elseif data.criterion(j,i) < data.EllipseAngle(j,i)
                                data.score(j,i) = 0;
                            end
                        end
                    end


                    data.response(j,i) = data.criterion(j,i); % Keep track of all responses regardles of condition

                   % Display number of points earned
                    Points = sum(data.score(:,i));
                    data.Points(j,i) = Points;
                    P = num2str(Points);
                    Screen('TextFont',win,'helvetica');
                    Screen('TextSize',win,42);
                    text = strcat('Points:', {' '}, P);
                    text = char(text);
                    [nx, ny, textbounds] = DrawFormattedText(win, text, 'center', 20, [255 255 255]);

                    % Display criterion
                    Screen('DrawTexture', win, Texture1, [], [], RotationAngle); 
                    Screen('Flip',win, []);

                    if data.score(j,i) == 1
                        sound(beep_correct, fs_correct);
                    else
                        sound(beep_incorrect, fs_incorrect);
                    end

                    WaitSecs(.3);
                    
                           
                else
                    Screen('TextFont',win,'helvetica');
                    Screen('TextSize',win,32);
                    text=sprintf('+');
                    DrawFormattedText(win,text,'center', 'center', [255 255 255]);
                    Screen('Flip', win');
                    WaitSecs(.5);

                    RectEllipse = [0 0 FirstStimWidthPix FirstStimHeightPix];
                    % Rotate rectangle
                    posX = winrect(3)/2;
                    posY = winrect(4)/2;
                    angle = 90-data.EllipseAngle(j,i);
                    Screen('glPushMatrix', win)
                    Screen('glTranslate', win, posX, posY)
                    Screen('glRotate', win, angle, 0, 0);
                    Screen('glTranslate', win, -posX, -posY)
                    Screen('FillOval', win, [0 0 0], CenterRectOnPoint(RectEllipse, posX, posY));
                    Screen('glPopMatrix', win)
                    Screen('Flip',win, []);
                    WaitSecs(.3);

                    Screen('TextFont',win,'helvetica');
                    Screen('TextSize',win,32);
                    text=sprintf('+');
                    DrawFormattedText(win,text,'center', 'center', [255 255 255]);
                    Screen('Flip', win);

                    while 1
                        [keydown, secs, keycode, deltasecs] = KbCheck;
                        if keydown && keycode(KbName('1!'))
                            TrialTypeEstimate=1;
                            break
                        elseif keydown && keycode(KbName('2@'))
                            TrialTypeEstimate=2;
                            break
                        elseif keydown && keycode(KbName('ESCAPE'))
                            Screen('Closeall');
                        end
                    end

                    data.TrialCondition = 2;
                    data.response(j,i) = TrialTypeEstimate;

                     % Score particpant's response
                    if data.TrialType(j,i) == 1 % Display red fixation
                        Screen('TextFont',win,'helvetica');
                        Screen('TextSize',win,32);
                        text=sprintf('+');
                        DrawFormattedText(win,text,'center', 'center', [255 0 0]);
                        % Hit or miss?
                        if data.response(j,i) == 1
                            data.score(j,i) = 1;
                        elseif data.response(j,i) == 2
                            data.score(j,i) = 0;
                        end
                    elseif data.TrialType(j,i) == 2 % Display green fixation
                        Screen('TextFont',win,'helvetica');
                        Screen('TextSize',win,32);
                        text=sprintf('+');
                        DrawFormattedText(win,text,'center', 'center', [0 255 0]);
                        % Correct reject or false alarm?
                        if data.response(j,i) == 2
                            data.score(j,i) = 1;
                        elseif data.response(j,i) == 1
                            data.score(j,i) = 0;
                        end
                    end



                    % Display number of points earned
                    Points = sum(data.score(:,i));
                    data.Points(j,i) = Points;
                    P = num2str(Points);
                    Screen('TextFont',win,'helvetica');
                    Screen('TextSize',win,42);
                    text = strcat('Points:', {' '}, P);
                    text = char(text);
                    [nx, ny, textbounds] = DrawFormattedText(win, text, 'center', 20, [255 255 255]);
                    Screen('Flip',win, []);

                    if data.score(j,i) == 1
                        sound(beep_correct, fs_correct);
                    else
                        sound(beep_incorrect, fs_incorrect);
                    end
                end

         % Display progress every 50 trails
                if and(mod(data.trial(j,i), 50) == 0, data.trial(j,i) ~= data.NumTrials)
                    TrialString = num2str(data.trial(j,i));
                    TotalString = num2str(data.NumTrials);
                    Screen(win, 'FillRect', grey);
                    Screen('TextFont',win,'helvetica');
                    Screen('TextSize',win,32);
                    FirstLine = strcat('You have completed', {' '}, TrialString, {' '}, 'out of', {' '}, TotalString, {' '} , 'trials.');
                    SecondLine = '<Press the spacebar to continue>';
                    text = strcat(FirstLine,'\n\n',SecondLine);
                    text = char(text);
                    [nx ny bbox] = DrawFormattedText(win,text,'center', 'center', [255 255 255]);
                    Screen('Flip',win);
                    while 1
                        [keydown, secs, keycode, deltaSecs] = KbCheck;
                        if keydown && keycode(KbName('space'))
                           break
                        elseif keydown && keycode(KbName('ESCAPE'))
                            Screen('Closeall');
                        end
                    end
                end
                
                save(Temp, 'trainingData', 'data');
            end
            
            
            
        %Split data for overt and covert trials
            
        data.OvertTrialFreq = OvertTrialFreq;    
        data.criterion = data.response(OvertTrialFreq:OvertTrialFreq:end);
        data.catResponse = data.response;
        data.catResponse(OvertTrialFreq:OvertTrialFreq:end) = [];
        data.OvScore = data.score(OvertTrialFreq:OvertTrialFreq:end);
        data.CovScore = data.score; 
        data.CovScore(OvertTrialFreq:OvertTrialFreq:end) = [];
            
        save(Temp, 'trainingData', 'data');
        Screen(win, 'FillRect', grey);
        Screen('TextFont',win,'helvetica');
        Screen('TextSize',win,32);
        text=sprintf('Thank you for your participation!');
        [nx ny bbox] = DrawFormattedText(win,text,'center', 'center', [255 255 255]);
        Screen('Flip',win);
        while 1
            [keydown, secs, keycode, deltaSecs] = KbCheck;
            if  keydown && keycode(KbName('ESCAPE'))
                ShowCursor;
                Screen('Closeall');
                echo off
                break
            end
        end


% Save the datafile
save(datafile, 'trainingData', 'data');

% % Move the datafile to the ExperimentalData folder
% SourceFile = strcat('/e/4.1/p3/norton/ChangingCategoryProbabilities/ExperimentalTasks/', datafile);
% DestinationFile = '/e/4.1/p3/norton/ChangingCategoryProbabilities/ExperimentalData';
% movefile(SourceFile, DestinationFile);

% Delete the temporary data file
delete(Temp);

end
        
                
                
                
                
        