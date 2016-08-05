setenv('PSYCH_ALLOW_DANGEROUS', '1')
Screen('Preference', 'SkipSyncTests', 1)
grey = 128; % Background color
whichScreen = max(Screen('Screens'));
[win, winrect] = Screen('OpenWindow', whichScreen, grey);
Screen(win, 'FillRect', grey);
Screen('TextFont',win,'Helvetica');
Screen('TextSize',win,32);
ListenChar(2);
while 1
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
        if keyIsDown && keyCode(KbName('1!')) 
            text=sprintf('For the Experiment Block, you will again\ncategorize ellipses by pressing 1 for RED and 2 for GREEN\njust as you did in the training.');
            [nx ny bbox] = DrawFormattedText(win,text,'center', 'center', [255 255 255]);
            Screen('Flip',win);
            KbWait(-1);
        end
        if keyIsDown && keyCode(KbName('2@'))
            text=sprintf('But now on every fifth trial a line will appear.\n\nRotate the line using the mouse such that if you think a\nRED ellipse will appear it will be COUNTER-CLOCKWISE of the line and if you think a\nGREEN ellipse will appear it will be CLOCKWISE of the line.\n\nClick the mouse to set the line. You will then be shown an ellipse\nfrom one of the two categories.')
            
            [nx ny bbox] = DrawFormattedText(win,text,'center', 'center', [255 255 255]);
            Screen('Flip',win);
            KbWait(-1);
        end
        if keyIsDown && keyCode(KbName('3#'))
            text=sprintf('The probabilities of each category will NOT necessarily be 50/50\nand will change over time.\n\nTry your best to maximize your score!')
            [nx ny bbox] = DrawFormattedText(win,text,'center', 'center', [255 255 255]);
            Screen('Flip',win);
            KbWait(-1);
        end
        if keyIsDown && keyCode(KbName('4$'))
            text=sprintf('Once you have chosen the orientation, click the mouse to set the line.\n You will then get feedback ')
            [nx ny bbox] = DrawFormattedText(win,text,'center', 'center', [255 255 255]);
            Screen('Flip',win);
            KbWait(-1);
        end
        if keyIsDown && keyCode(KbName('0)'))
            break
        end
end
ListenChar(0)
sca;