classdef sibStartupDialog < handle
    properties
        Choice
        Dialog
    end
   
    methods
        function dlg = sibStartupDialog
            dlg.Choice = 0;

            dwidth = 300;
            dborder = 10;
            bwidth = dwidth-2*dborder;
            bheight = 20;

            dlg.Dialog = dialog('WindowStyle', 'modal',...
                                'Name', 'SpotsInIrisBot',...
                                'CloseRequestFcn', @dlg.closeDialog,...
                                'Position',[100 100 dwidth 6*dborder+5*bheight],...
                                'Resize','off');
            
            uicontrol('Parent',dlg.Dialog,'Style','pushbutton','String','Set-up point-source detection','Position',[dborder 5*dborder+4*bheight bwidth bheight],'Callback',@dlg.buttonSetupSpotsPushed);
            
            uicontrol('Parent',dlg.Dialog,'Style','pushbutton','String','Set-up orient. vessel detection','Position',[dborder 4*dborder+3*bheight bwidth bheight],'Callback',@dlg.buttonSetupNeuronPushed);
            
            uicontrol('Parent',dlg.Dialog,'Style','pushbutton','String','Save parameters','Position',[dborder 3*dborder+2*bheight bwidth bheight],'Callback',@dlg.buttonSaveParametersPushed);
            
            uicontrol('Parent',dlg.Dialog,'Style','pushbutton','String','Load parameters','Position',[dborder 2*dborder+bheight bwidth bheight],'Callback',@dlg.buttonLoadParametersPushed);
            
            uicontrol('Parent',dlg.Dialog,'Style','pushbutton','String','Analyze folder','Position',[dborder dborder bwidth bheight],'Callback',@dlg.buttonScoreFolderPushed);
            
            uiwait(dlg.Dialog)
        end
       
        function closeDialog(dlg,src,callbackdata)
            dlg.Choice = 0;
            delete(dlg.Dialog);
        end
        
        function buttonSetupSpotsPushed(dlg,src,callbackdata)
            dlg.Choice = 1;
            delete(dlg.Dialog);
        end
        
        function buttonSetupNeuronPushed(dlg,src,callbackdata)
            dlg.Choice = 2;
            delete(dlg.Dialog);
        end
        
        function buttonSaveParametersPushed(dlg,src,callbackdata)
            dlg.Choice = 3;
            delete(dlg.Dialog);
        end
        
        function buttonLoadParametersPushed(dlg,src,callbackdata)
            dlg.Choice = 4;
            delete(dlg.Dialog);
        end
        
        function buttonScoreFolderPushed(dlg,src,callbackdata)
            dlg.Choice = 5;
            delete(dlg.Dialog);
        end
   end
end