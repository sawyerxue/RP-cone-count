classdef irisOrientVesselDetectionBot < handle    
    properties
        Prmts
        
        Figure
        Axis
        
        Image
        ImageHandle
        
        CircleHandle
        DiagonalHandle
        CentRadDir
        
        MouseIsDown
        p0
        p1
        Dialog
        LowerThreshold
        UpperThreshold
        CheckboxOverlay % to overlay circle/diagonal
        
        ForegThr
        ForegThrEdit
        ForegThrText
        
        EstimRad
        EstimRadEdit
        EstimRadText
        EstRadLine
        
        ResizeFac
        ResizeFacEdit
        ResizeFacText
        
        Sigma
        SigmaEdit
        SigmaText
        
        SteerThr
        SteerThrEdit
        SteerThrText
        
        DilateAmt
        DilateAmtEdit
        DilateAmtText
        
        ErodeAmt
        ErodeAmtEdit
        ErodeAmtText
    end
    
    methods
        function bot = irisOrientVesselDetectionBot(I)
            bot.Image = I;
            
            bot.Figure = figure('NumberTitle','off', ...
                                'Name','Iris Orientation Vessel Detection Bot', ...
                                'CloseRequestFcn',@bot.closeFigure, ...
                                'Resize','on');

            bot.Axis = axes('Parent',bot.Figure,'Position',[0 0 1 1]);
            bot.ImageHandle = imshow(bot.Image);
            hold on
            bot.CircleHandle = plot([-2 -1],[-2 -1],'-g'); % placeholder, outside view, just to get CircleHandle
            bot.DiagonalHandle = plot([-2 -1],[-2 -1],'-g'); % placeholder, outside view, just to get DiagonalHandle
            hold off
            bot.MouseIsDown = false;
            
            dwidth = 300;
            dborder = 10;
            cwidth = dwidth-2*dborder;
            cheight = 20;
            
            bot.Dialog = dialog('WindowStyle', 'normal',...
                                'Name', 'Iris OVD Bot',...
                                'CloseRequestFcn', @bot.closeDialog,...
                                'Position',[100 100 dwidth 13*dborder+13*cheight],...
                                'Resize','off');

            % text boxes
            bot.ForegThr = -0.4;
            uicontrol('Parent',bot.Dialog,'Style','text','String','ForegThr','HorizontalAlignment','left','Position',[dborder 12*dborder+12*cheight (dwidth-dborder)/3-dborder cheight]);
            uicontrol('Parent',bot.Dialog,'Style','edit','String',sprintf('%.02f', bot.ForegThr),'HorizontalAlignment','left','Position',[(dwidth-dborder)/3+dborder 12*dborder+12*cheight (dwidth-dborder)/3-dborder cheight],'Tag','ForegThr');

            bot.EstimRad = 1600;
            uicontrol('Parent',bot.Dialog,'Style','text','String','EstimRad','HorizontalAlignment','left','Position',[dborder 11*dborder+11*cheight (dwidth-dborder)/3-dborder cheight]);
            uicontrol('Parent',bot.Dialog,'Style','edit','String',sprintf('%.02f', bot.EstimRad),'HorizontalAlignment','left','Position',[(dwidth-dborder)/3+dborder 11*dborder+11*cheight (dwidth-dborder)/3-dborder cheight],'Tag','EstimRad');
            uicontrol('Parent',bot.Dialog,'Style','pushbutton','String','Help','Position',[2*((dwidth-dborder)/3-dborder)+3*dborder 11*dborder+11*cheight (dwidth-dborder)/3-dborder cheight],'Callback',@bot.helpButtonPushed,'Tag','helpEstRad');

            bot.ResizeFac = 0.05;
            uicontrol('Parent',bot.Dialog,'Style','text','String','ResizeFac','HorizontalAlignment','left','Position',[dborder 10*dborder+10*cheight (dwidth-dborder)/3-dborder cheight]);
            uicontrol('Parent',bot.Dialog,'Style','edit','String',sprintf('%.02f', bot.ResizeFac),'HorizontalAlignment','left','Position',[(dwidth-dborder)/3+dborder 10*dborder+10*cheight (dwidth-dborder)/3-dborder cheight],'Tag','ResizeFac');

            bot.Sigma = 1;
            uicontrol('Parent',bot.Dialog,'Style','text','String','Sigma','HorizontalAlignment','left','Position',[dborder 9*dborder+9*cheight (dwidth-dborder)/3-dborder cheight]);
            uicontrol('Parent',bot.Dialog,'Style','edit','String',sprintf('%.02f', bot.Sigma),'HorizontalAlignment','left','Position',[(dwidth-dborder)/3+dborder 9*dborder+9*cheight (dwidth-dborder)/3-dborder cheight],'Tag','Sigma');
            uicontrol('Parent',bot.Dialog,'Style','pushbutton','String','Help','Position',[2*((dwidth-dborder)/3-dborder)+3*dborder 9*dborder+9*cheight (dwidth-dborder)/3-dborder cheight],'Callback',@bot.helpButtonPushed,'Tag','helpSigma');

            bot.SteerThr = 3;
            uicontrol('Parent',bot.Dialog,'Style','text','String','SteerThr','HorizontalAlignment','left','Position',[dborder 8*dborder+8*cheight (dwidth-dborder)/3-dborder cheight]);
            uicontrol('Parent',bot.Dialog,'Style','edit','String',sprintf('%.02f', bot.SteerThr),'HorizontalAlignment','left','Position',[(dwidth-dborder)/3+dborder 8*dborder+8*cheight (dwidth-dborder)/3-dborder cheight],'Tag','SteerThr');
            
            bot.DilateAmt = 1;
            uicontrol('Parent',bot.Dialog,'Style','text','String','DilateAmt','HorizontalAlignment','left','Position',[dborder 7*dborder+7*cheight (dwidth-dborder)/3-dborder cheight]);
            uicontrol('Parent',bot.Dialog,'Style','edit','String',sprintf('%.02f', bot.DilateAmt),'HorizontalAlignment','left','Position',[(dwidth-dborder)/3+dborder 7*dborder+7*cheight (dwidth-dborder)/3-dborder cheight],'Tag','DilateAmt');
            
            bot.ErodeAmt = 20;
            uicontrol('Parent',bot.Dialog,'Style','text','String','ErodeAmt','HorizontalAlignment','left','Position',[dborder 6*dborder+6*cheight (dwidth-dborder)/3-dborder cheight]);
            uicontrol('Parent',bot.Dialog,'Style','edit','String',sprintf('%.02f', bot.ErodeAmt),'HorizontalAlignment','left','Position',[(dwidth-dborder)/3+dborder 6*dborder+6*cheight (dwidth-dborder)/3-dborder cheight],'Tag','ErodeAmt');

            % button fit
            uicontrol('Parent',bot.Dialog,'Style','pushbutton','String','Detect orientation vessel','Position',[dborder 5*dborder+5*cheight cwidth cheight],'Callback',@bot.buttonDetectPushed);
            
            % overlay checkbox
            bot.CheckboxOverlay = uicontrol('Parent',bot.Dialog,'Style','checkbox','String','Overlay circle/orientation on image','Position',[dborder 4*dborder+4*cheight cwidth cheight],'Callback',@bot.checkboxOverlayClicked);
            
            % lower threshold slider
            bot.LowerThreshold = 0;
            LowerThresholdSlider = uicontrol('Parent',bot.Dialog,'Style','slider','Min',0,'Max',1,'Value',bot.LowerThreshold,'Position',[dborder 3*dborder+3*cheight cwidth cheight],'Tag','lts');
            addlistener(LowerThresholdSlider,'Value','PostSet',@bot.continuousSliderManage);
            
            % upper threshold slider
            bot.UpperThreshold = 1;
            UpperThresholdSlider = uicontrol('Parent',bot.Dialog,'Style','slider','Min',0,'Max',1,'Value',bot.UpperThreshold,'Position',[dborder 2*dborder+2*cheight cwidth cheight],'Tag','uts');
            addlistener(UpperThresholdSlider,'Value','PostSet',@bot.continuousSliderManage);
            
            % quit button
            uicontrol('Parent',bot.Dialog,'Style','pushbutton','String','Done setting parameters','Position',[dborder dborder cwidth 2*cheight],'Callback',@bot.buttonQuitPushed);
            
            % default parameters
            bot.Prmts.ForegThr  = bot.ForegThr;
            bot.Prmts.EstimRad  = bot.EstimRad;
            bot.Prmts.ResizeFac = bot.ResizeFac;
            bot.Prmts.Sigma     = bot.Sigma;
            bot.Prmts.SteerThr  = bot.SteerThr;
            bot.Prmts.DilateAmt = bot.DilateAmt;
            bot.Prmts.ErodeAmt  = bot.ErodeAmt;
            
            uiwait(bot.Dialog)
        end
        
        function gatherParameters(bot)
            for i = 1:length(bot.Dialog.Children)
                tag = bot.Dialog.Children(i).Tag;
                if strcmp(tag,'ErodeAmt')
                    bot.ErodeAmt = str2double(bot.Dialog.Children(i).String);
                elseif strcmp(tag,'DilateAmt')
                    bot.DilateAmt = str2double(bot.Dialog.Children(i).String);
                elseif strcmp(tag,'SteerThr')
                    bot.SteerThr = str2double(bot.Dialog.Children(i).String);
                elseif strcmp(tag,'Sigma')
                    bot.Sigma = str2double(bot.Dialog.Children(i).String);
                elseif strcmp(tag,'ResizeFac')
                    bot.ResizeFac = str2double(bot.Dialog.Children(i).String);
                elseif strcmp(tag,'EstimRad')
                    bot.EstimRad = str2double(bot.Dialog.Children(i).String);
                elseif strcmp(tag,'ForegThr')
                    bot.ForegThr = str2double(bot.Dialog.Children(i).String);
                end
            end
        end
        
        function buttonDetectPushed(bot,src,callbackdata)
            bot.gatherParameters();
            
            [c,r,v] = detectOrientVessel(bot.Image,bot.ForegThr,bot.EstimRad,bot.ResizeFac,bot.Sigma,bot.SteerThr,bot.DilateAmt,bot.ErodeAmt,true);
            bot.CentRadDir = {c,r,v};
            set(bot.DiagonalHandle,'XData',[],'YData',[]);
            set(bot.CircleHandle,'XData',[],'YData',[]);
            bot.CheckboxOverlay.Value = 0;
            
%             ag = atan2(v(2),v(1))/pi*180;
%             if ag < 0
%                 rotAng = -90-ag;
%             else
%                 rotAng = 90-ag;
%             end
%             J = 0.5*bot.Image;
%             for i = 1:r
%                 row = round(c(1)+i*v(1));
%                 col = round(c(2)+i*v(2));
%                 J(row-1:row+1,col-1:col+1) = 1;
%                 
%                 row = round(c(1)+i*cos(0));
%                 col = round(c(2)+i*sin(0));
%                 J(row-1:row+1,col-1:col+1) = 0;
%             end
%             figure
%             subplot(1,2,1), imshow(J)
%             subplot(1,2,2), imshow(imrotate(J,rotAng,'crop'))
        end
        
        function helpButtonPushed(bot,src,callbackdata)
            if strcmp(src.Tag,'helpEstRad')
                bot.EstRadLine = imdistline(bot.Axis);
                uiwait(msgbox({'Move the ends of the line in the figure',...
                               'to match an approximate radius of the iris.'...
                               'To remove line from image, right-click on it'...
                               'and select Delete.'},'Hint','modal'));
            elseif strcmp(src.Tag,'helpSigma')
                delete(bot.EstRadLine)
                
                rf = [];
                for i = 1:length(bot.Dialog.Children)
                    if strcmp(bot.Dialog.Children(i).Tag,'ResizeFac')
                        rf = str2double(bot.Dialog.Children(i).String);
                        break;
                    end
                end
                if ~isempty(rf)
                    bot.Figure.Visible = 'off';
                    bot.Dialog.Visible = 'off';
                    
                    I = imresize(bot.Image,rf);
                    lineScanBot(I);
                    
                    bot.Figure.Visible = 'on';
                    bot.Dialog.Visible = 'on';
                end
            end
        end
        
        function buttonQuitPushed(bot,src,callbackdata)
            bot.gatherParameters();
            
            bot.Prmts.ForegThr  = bot.ForegThr;
            bot.Prmts.EstimRad  = bot.EstimRad;
            bot.Prmts.ResizeFac = bot.ResizeFac;
            bot.Prmts.Sigma     = bot.Sigma;
            bot.Prmts.SteerThr  = bot.SteerThr;
            bot.Prmts.DilateAmt = bot.DilateAmt;
            bot.Prmts.ErodeAmt  = bot.ErodeAmt;
            
            delete(bot.Figure);
            delete(bot.Dialog);
        end
        
        function checkboxOverlayClicked(bot,src,callbackdata)
            if ~isempty(bot.CentRadDir)
                c = bot.CentRadDir{1}; r = bot.CentRadDir{2}; v = bot.CentRadDir{3};
                if src.Value == 1
                    dA = c-r*v;
                    dB = c+r*v;
                    set(bot.DiagonalHandle,'XData',[dA(2) dB(2)],'YData',[dA(1) dB(1)]);
                    
                    ags = linspace(0,2*pi,2*pi*r);
                    x = c(1)+r*cos(ags);
                    y = c(2)+r*sin(ags);
                    set(bot.CircleHandle,'XData',x,'YData',y);
                else
                    set(bot.DiagonalHandle,'XData',[],'YData',[]);
                    set(bot.CircleHandle,'XData',[],'YData',[]);
                end
            end
        end
        
        function continuousSliderManage(bot,src,callbackdata)
            tag = callbackdata.AffectedObject.Tag;
            value = callbackdata.AffectedObject.Value;
            if strcmp(tag,'uts')
                bot.UpperThreshold = value;
            elseif strcmp(tag,'lts')
                bot.LowerThreshold = value;
            end
            I = bot.Image;
            I(I < bot.LowerThreshold) = bot.LowerThreshold;
            I(I > bot.UpperThreshold) = bot.UpperThreshold;
            I = I-min(I(:));
            I = I/max(I(:));
            bot.ImageHandle.CData = I;
        end
        
        function closeDialog(bot,src,callbackdata)
            delete(bot.Figure);
            delete(bot.Dialog);
        end
        
        function closeFigure(bot,src,callbackdata)
            delete(bot.Figure);
            delete(bot.Dialog);
        end
        
    end
    
    methods (Static)
        function centRadDir = Headless(I,prmts)
           [c,r,v] = detectOrientVessel(I,prmts.ForegThr,prmts.EstimRad,prmts.ResizeFac,prmts.Sigma,prmts.SteerThr,prmts.DilateAmt,prmts.ErodeAmt,false);
           centRadDir = {c,r,v};
        end
    end
end
