classdef lineScanBot < handle    
    properties
        Image
        ImageHandle
        Figure
        Axis
        LineHandle
        
        MouseIsDown
        p0
        p1
        Dialog
        LowerThreshold
        UpperThreshold
    end
    
    methods
        function bot = lineScanBot(I)
            bot.Image = I;
            
            bot.Figure = figure('NumberTitle','off', ...
                                'Name','Line Scan Bot', ...
                                'CloseRequestFcn',@bot.closeFigure, ...
                                'WindowButtonMotionFcn', @bot.mouseMove, ...
                                'WindowButtonDownFcn', @bot.mouseDown, ...
                                'WindowButtonUpFcn', @bot.mouseUp, ...
                                'Resize','on');

            bot.Axis = axes('Parent',bot.Figure,'Position',[0 0 1 1]);
            bot.ImageHandle = imshow(bot.Image);
            hold on
            bot.LineHandle = plot([-2 -1],[-2 -1],'-y'); % placeholder, outside view, just to get LineHandle
            hold off
            bot.MouseIsDown = false;
            
            dwidth = 300;
            dborder = 10;
            cwidth = dwidth-2*dborder;
            cheight = 20;
            
            bot.Dialog = dialog('WindowStyle', 'normal',...
                                'Name', 'Line Scan Bot',...
                                'CloseRequestFcn', @bot.closeDialog,...
                                'Position',[100 100 dwidth 4*dborder+4*cheight],...
                                'Resize','off');
            
            % lower threshold slider
            bot.LowerThreshold = 0;
            LowerThresholdSlider = uicontrol('Parent',bot.Dialog,'Style','slider','Min',0,'Max',1,'Value',bot.LowerThreshold,'Position',[dborder 3*dborder+3*cheight cwidth cheight],'Tag','lts');
            addlistener(LowerThresholdSlider,'Value','PostSet',@bot.continuousSliderManage);
            
            % upper threshold slider
            bot.UpperThreshold = 1;
            UpperThresholdSlider = uicontrol('Parent',bot.Dialog,'Style','slider','Min',0,'Max',1,'Value',bot.UpperThreshold,'Position',[dborder 2*dborder+2*cheight cwidth cheight],'Tag','uts');
            addlistener(UpperThresholdSlider,'Value','PostSet',@bot.continuousSliderManage);
            
            % quit button
            uicontrol('Parent',bot.Dialog,'Style','pushbutton','String','Done','Position',[dborder dborder cwidth 2*cheight],'Callback',@bot.buttonQuitPushed);
            
            uiwait(msgbox({'Draw a line perpendicular to main vessel',...
                           'to fit a 2-gaussian mixture model.',...
                           'If fit is proper, take note of smalest sigma.'},'Hint','modal'));
            uiwait(bot.Dialog)
        end
        
        function buttonQuitPushed(bot,src,callbackdata)
            delete(bot.Figure);
            delete(bot.Dialog);
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
            if bot.MouseIsDown
                p = bot.Axis.CurrentPoint;
                col = round(p(1,1));
                row = round(p(1,2));

                if row > 0 && row <= size(bot.Image,1) && col > 0 && col <= size(bot.Image,2)
                    row0 = bot.p0(1);
                    col0 = bot.p0(2);

                    set(bot.LineHandle,'XData',[col0 col],'YData',[row0 row]);
                else
                    bot.MouseIsDown = false;
                    bot.p0 = [];
                    bot.p1 = [];
                end
            end
        end
        
        function mouseDown(bot,src,callbackdata)
            p = bot.Axis.CurrentPoint;
            col = round(p(1,1));
            row = round(p(1,2));
            if row > 0 && row <= size(bot.Image,1) && col > 0 && col <= size(bot.Image,2)
                bot.p0 = [row; col];
                bot.MouseIsDown = true;
            end
        end
        
        function mouseUp(bot,src,callbackdata)
            p = bot.Axis.CurrentPoint;
            col = round(p(1,1));
            row = round(p(1,2));
            if row > 0 && row <= size(bot.Image,1) && col > 0 && col <= size(bot.Image,2)
                bot.p1 = [row; col];
                bot.MouseIsDown = false;

                set(bot.LineHandle,'XData',[],'YData',[]);

                bot.fitGauss1D();
            end
            bot.p0 = [];
            bot.p1 = [];
        end
        
        function fitGauss1D(bot)
            if ~isempty(bot.p0) && ~isempty(bot.p1)
                v = bot.p1-bot.p0;
                d = norm(v);
                if d > 0
                    v = v/d;
                    I = bot.Image;
                    
                    % J = 0.5*I;
                    np = round(d);
                    values = zeros(1,np);
                    for r = 0:np-1
                        row = round(bot.p0(1)+r*v(1));
                        col = round(bot.p0(2)+r*v(2));
                        % J(row,col) = 1;
                        values(r+1) = I(row,col);
                    end
                    figureQSS
                    subplot(1,2,1)
                    imshow(I), hold on
                    plot([bot.p0(2) bot.p1(2)],[bot.p0(1) bot.p1(1)],'-y'), hold off
                    subplot(1,2,2)
                    x = 0:np-1;
                    y = values;
                    plot(x,y,'b'), hold on
                    f = fit(x',y','gauss2');
                    plot(f,x,y), hold off
                    title(sprintf('Gauss2 Fit\nsigmas: %.02f, %.02f', f.c1, f.c2));
                end
            end
        end
    end
end
