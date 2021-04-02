classdef irisPointSourceDetectionBot < handle    
    properties
        Prmts
        
        Figure
        Axis
        
        Image
        ImageHandle
        
        BoxHandle
        
        CircleHandle
        InnCircHandle
        RadRowCol
        
        SpotsHandle
        SpotsCoord
        
        MouseIsDown
        p0
        p1
        Dialog
        LowerThreshold
        UpperThreshold
        CheckboxOverlay % to overlay spots/circle
        
        FgThr
        FgThrEdit
        FgThrText
        
        EstRad
        EstRadEdit
        EstRadText
        EstRadLine
        EstimatingRadius
        
        ResFac
        ResFacEdit
        ResFacText
        
        Sigma
        SigmaEdit
        SigmaText
        
        LoGThr
        LoGThrEdit
        LoGThrText
        
        InnCircCoef
        InnCircCoefEdit
        InnCircCoefText
    end
    
    methods
        function bot = irisPointSourceDetectionBot(I)
            bot.Image = I;
            
            bot.Figure = figure('NumberTitle','off', ...
                                'Name','Iris Point Source Detection Bot', ...
                                'CloseRequestFcn',@bot.closeFigure, ...
                                'WindowButtonMotionFcn', @bot.mouseMove, ...
                                'WindowButtonDownFcn', @bot.mouseDown, ...
                                'WindowButtonUpFcn', @bot.mouseUp, ...
                                'Resize','on');

            bot.Axis = axes('Parent',bot.Figure,'Position',[0 0 1 1]);
            bot.ImageHandle = imshow(bot.Image);
            hold on
            bot.BoxHandle = plot([-2 -1],[-2 -1],'-y'); % placeholder, outside view, just to get BoxHandle
            bot.SpotsHandle = plot(-1,-1,'ob'); % placeholder, outside view, just to get SpotsHandle
            bot.CircleHandle = plot([-2 -1],[-2 -1],'-g'); % placeholder, outside view, just to get CircleHandle
            bot.InnCircHandle = plot([-2 -1],[-2 -1],'-g'); % placeholder, outside view, just to get InnCircHandle
            hold off
            bot.MouseIsDown = false;
            bot.EstimatingRadius = false;
            
            dwidth = 300;
            dborder = 10;
            cwidth = dwidth-2*dborder;
            cheight = 20;
            
            bot.Dialog = dialog('WindowStyle', 'normal',...
                                'Name', 'Iris PSD Bot',...
                                'CloseRequestFcn', @bot.closeDialog,...
                                'Position',[100 100 dwidth 12*dborder+12*cheight],...
                                'Resize','off');

            % text boxes
            bot.FgThr = -0.4;
            uicontrol('Parent',bot.Dialog,'Style','text','String','FgThr','HorizontalAlignment','left','Position',[dborder 11*dborder+11*cheight (dwidth-dborder)/3-dborder cheight]);
            uicontrol('Parent',bot.Dialog,'Style','edit','String',sprintf('%.02f', bot.FgThr),'HorizontalAlignment','left','Position',[(dwidth-dborder)/3+dborder 11*dborder+11*cheight (dwidth-dborder)/3-dborder cheight],'Tag','FgThr');

            bot.EstRad = 1600;
            uicontrol('Parent',bot.Dialog,'Style','text','String','EstRad','HorizontalAlignment','left','Position',[dborder 10*dborder+10*cheight (dwidth-dborder)/3-dborder cheight]);
            uicontrol('Parent',bot.Dialog,'Style','edit','String',sprintf('%.02f', bot.EstRad),'HorizontalAlignment','left','Position',[(dwidth-dborder)/3+dborder 10*dborder+10*cheight (dwidth-dborder)/3-dborder cheight],'Tag','EstRad');
            uicontrol('Parent',bot.Dialog,'Style','pushbutton','String','Help','Position',[2*((dwidth-dborder)/3-dborder)+3*dborder 10*dborder+10*cheight (dwidth-dborder)/3-dborder cheight],'Callback',@bot.helpButtonPushed,'Tag','helpEstRad');

            bot.ResFac = 0.05;
            uicontrol('Parent',bot.Dialog,'Style','text','String','ResFac','HorizontalAlignment','left','Position',[dborder 9*dborder+9*cheight (dwidth-dborder)/3-dborder cheight]);
            uicontrol('Parent',bot.Dialog,'Style','edit','String',sprintf('%.02f', bot.ResFac),'HorizontalAlignment','left','Position',[(dwidth-dborder)/3+dborder 9*dborder+9*cheight (dwidth-dborder)/3-dborder cheight],'Tag','ResFac');

            bot.Sigma = 2;
            uicontrol('Parent',bot.Dialog,'Style','text','String','Sigma','HorizontalAlignment','left','Position',[dborder 8*dborder+8*cheight (dwidth-dborder)/3-dborder cheight]);
            uicontrol('Parent',bot.Dialog,'Style','edit','String',sprintf('%.02f', bot.Sigma),'HorizontalAlignment','left','Position',[(dwidth-dborder)/3+dborder 8*dborder+8*cheight (dwidth-dborder)/3-dborder cheight],'Tag','Sigma');
            uicontrol('Parent',bot.Dialog,'Style','pushbutton','String','Help','Position',[2*((dwidth-dborder)/3-dborder)+3*dborder 8*dborder+8*cheight (dwidth-dborder)/3-dborder cheight],'Callback',@bot.helpButtonPushed,'Tag','helpSigma');

            bot.LoGThr = 50;
            uicontrol('Parent',bot.Dialog,'Style','text','String','LoGThr','HorizontalAlignment','left','Position',[dborder 7*dborder+7*cheight (dwidth-dborder)/3-dborder cheight]);
            uicontrol('Parent',bot.Dialog,'Style','edit','String',sprintf('%.02f', bot.LoGThr),'HorizontalAlignment','left','Position',[(dwidth-dborder)/3+dborder 7*dborder+7*cheight (dwidth-dborder)/3-dborder cheight],'Tag','LoGThr');

            bot.InnCircCoef = 0.66;
            uicontrol('Parent',bot.Dialog,'Style','text','String','InnCircCoef','HorizontalAlignment','left','Position',[dborder 6*dborder+6*cheight (dwidth-dborder)/3-dborder cheight]);
            uicontrol('Parent',bot.Dialog,'Style','edit','String',sprintf('%.02f', bot.InnCircCoef),'HorizontalAlignment','left','Position',[(dwidth-dborder)/3+dborder 6*dborder+6*cheight (dwidth-dborder)/3-dborder cheight],'Tag','InnCircCoef');
            
            % button fit
            uicontrol('Parent',bot.Dialog,'Style','pushbutton','String','Fit circle and detect spots','Position',[dborder 5*dborder+5*cheight cwidth cheight],'Callback',@bot.buttonFitAndDetectPushed);
            
            % overlay checkbox
            bot.CheckboxOverlay = uicontrol('Parent',bot.Dialog,'Style','checkbox','String','Overlay spots/circle on image','Position',[dborder 4*dborder+4*cheight cwidth cheight],'Callback',@bot.checkboxOverlayClicked);
            
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
            bot.Prmts.LoGThr = bot.LoGThr;
            bot.Prmts.Sigma = bot.Sigma;
            bot.Prmts.ResFac = bot.ResFac;
            bot.Prmts.EstRad = bot.EstRad;
            bot.Prmts.FgThr = bot.FgThr;
            bot.Prmts.InnCircCoef = bot.InnCircCoef;
            
            uiwait(bot.Dialog)
        end
        
        function gatherParameters(bot)
            for i = 1:length(bot.Dialog.Children)
                tag = bot.Dialog.Children(i).Tag;
                if strcmp(tag,'LoGThr')
                    bot.LoGThr = str2double(bot.Dialog.Children(i).String);
                elseif strcmp(tag,'Sigma')
                    bot.Sigma = str2double(bot.Dialog.Children(i).String);
                elseif strcmp(tag,'ResFac')
                    bot.ResFac = str2double(bot.Dialog.Children(i).String);
                elseif strcmp(tag,'EstRad')
                    bot.EstRad = str2double(bot.Dialog.Children(i).String);
                elseif strcmp(tag,'FgThr')
                    bot.FgThr = str2double(bot.Dialog.Children(i).String);
                elseif strcmp(tag,'InnCircCoef')
                    bot.InnCircCoef = str2double(bot.Dialog.Children(i).String);
                end
            end
        end
        
        function buttonFitAndDetectPushed(bot,src,callbackdata)
            bot.gatherParameters();
            
            [bot.RadRowCol,bot.SpotsCoord] = fitCircleAndDetectSpots(bot.Image,bot.FgThr,bot.EstRad,bot.ResFac,bot.Sigma,bot.LoGThr,true);
            
            set(bot.SpotsHandle,'XData',[],'YData',[]);
            set(bot.CircleHandle,'XData',[],'YData',[]);
            set(bot.InnCircHandle,'XData',[],'YData',[]);
            bot.CheckboxOverlay.Value = 0;
            
%             y = -(bot.SpotsCoord.rows-bot.RadRowCol(2));
%             x = bot.SpotsCoord.cols-bot.RadRowCol(3);
%             d = sqrt(x.^2+y.^2);
%             rad = bot.RadRowCol(1);
%             figure
%             idx = d < bot.InnCircCoef*rad;
%             plot(x(idx),y(idx),'.r'), hold on
%             idx = d >= bot.InnCircCoef*rad;
%             plot(x(idx),y(idx),'.b'), hold off
        end
        
        function helpButtonPushed(bot,src,callbackdata)
            if strcmp(src.Tag,'helpEstRad')
                bot.EstimatingRadius = true;
                bot.EstRadLine = imdistline(bot.Axis);
                uiwait(msgbox({'Move the ends of the line in the figure',...
                               'to match an approximate radius of the iris.'...
                               'To remove line from image, right-click on it'...
                               'and select Delete.'},'Hint','modal'));
            elseif strcmp(src.Tag,'helpSigma')
                delete(bot.EstRadLine)
                bot.EstimatingRadius = false;
                uiwait(msgbox({'Draw a rectangle around a spot', 'to estimate sigma of fitting gaussian.'},'Hint','modal'));
            end
        end
        
        function buttonQuitPushed(bot,src,callbackdata)
            bot.gatherParameters();
            
            bot.Prmts.LoGThr = bot.LoGThr;
            bot.Prmts.Sigma = bot.Sigma;
            bot.Prmts.ResFac = bot.ResFac;
            bot.Prmts.EstRad = bot.EstRad;
            bot.Prmts.FgThr = bot.FgThr;
            bot.Prmts.InnCircCoef = bot.InnCircCoef;
            
            delete(bot.Figure);
            delete(bot.Dialog);
        end
        
        function checkboxOverlayClicked(bot,src,callbackdata)
            if ~isempty(bot.SpotsCoord)
                if src.Value == 1
                    set(bot.SpotsHandle,'XData',bot.SpotsCoord.cols,'YData',bot.SpotsCoord.rows);
                    ags = linspace(0,2*pi,2*pi*bot.RadRowCol(1));
                    x = bot.RadRowCol(3)+bot.RadRowCol(1)*cos(ags);
                    y = bot.RadRowCol(2)+bot.RadRowCol(1)*sin(ags);
                    set(bot.CircleHandle,'XData',x,'YData',y);
                    ags = linspace(0,2*pi,2*pi*bot.InnCircCoef*bot.RadRowCol(1));
                    x = bot.RadRowCol(3)+bot.InnCircCoef*bot.RadRowCol(1)*cos(ags);
                    y = bot.RadRowCol(2)+bot.InnCircCoef*bot.RadRowCol(1)*sin(ags);
                    set(bot.InnCircHandle,'XData',x,'YData',y);
                else
                    set(bot.SpotsHandle,'XData',[],'YData',[]);
                    set(bot.CircleHandle,'XData',[],'YData',[]);
                    set(bot.InnCircHandle,'XData',[],'YData',[]);
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
        
        function mouseMove(bot,src,callbackdata)
            if bot.EstimatingRadius == false
                if bot.MouseIsDown
                    p = bot.Axis.CurrentPoint;
                    col = round(p(1,1));
                    row = round(p(1,2));

                    if row > 0 && row <= size(bot.Image,1) && col > 0 && col <= size(bot.Image,2)
                        row0 = bot.p0(1);
                        col0 = bot.p0(2);

                        rowA = min(row0,row);
                        rowB = max(row0,row);
                        colA = min(col0,col);
                        colB = max(col0,col);

                        set(bot.BoxHandle,'XData',[colA colB colB colA colA],'YData',[rowA rowA rowB rowB rowA]);
                    else
                        bot.MouseIsDown = false;
                        bot.p0 = [];
                        bot.p1 = [];
                    end
                end
            end
        end
        
        function mouseDown(bot,src,callbackdata)
            if bot.EstimatingRadius == false
                p = bot.Axis.CurrentPoint;
                col = round(p(1,1));
                row = round(p(1,2));
                if row > 0 && row <= size(bot.Image,1) && col > 0 && col <= size(bot.Image,2)
                    bot.p0 = [row; col];
                    bot.MouseIsDown = true;
                end
            end
        end
        
        function mouseUp(bot,src,callbackdata)
            if bot.EstimatingRadius == false
                p = bot.Axis.CurrentPoint;
                col = round(p(1,1));
                row = round(p(1,2));
                if row > 0 && row <= size(bot.Image,1) && col > 0 && col <= size(bot.Image,2)
                    bot.p1 = [row; col];
                    bot.MouseIsDown = false;

                    set(bot.BoxHandle,'XData',[],'YData',[]);

                    bot.fitGauss2D();
                end
                bot.p0 = [];
                bot.p1 = [];
            end
        end
        
        function fitGauss2D(bot)
            if ~isempty(bot.p0) && ~isempty(bot.p1)
                pA = bot.p0; pB = bot.p1;
                rowA = min(pA(1),pB(1));
                rowB = max(pA(1),pB(1));
                colA = min(pA(2),pB(2));
                colB = max(pA(2),pB(2));
                BI = bot.Image(rowA:rowB,colA:colB);
                [y,x] = meshgrid(1:size(BI,2),1:size(BI,1));
                [fitresult, zfit, fiterr, zerr, resnorm, rr] = fmgaussfit(x,y,BI);
                evalFit(x,y,BI,zfit,fitresult)
            end
        end
    end
    
    methods (Static)
        function [radRowCol,spotsCoord] = Headless(I,prmts)
            [radRowCol,spotsCoord] = fitCircleAndDetectSpots(I,prmts.FgThr,prmts.EstRad,prmts.ResFac,prmts.Sigma,prmts.LoGThr,false);
        end
    end
end
