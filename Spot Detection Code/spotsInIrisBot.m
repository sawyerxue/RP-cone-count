clear, clc

mode = 0;
IPSDB = [];
IOVDB = [];
while 1
    switch mode
        case 0 % startup
            SIBSD = sibStartupDialog;
            mode = SIBSD.Choice;
            if mode == 0 % quit
                break
            end
        case 1 % setup spots
            [filename, pathname] = uigetfile({'*.tif','Image (.tif)'});
            if filename ~= 0
                channelIndex = 2;
                I = imread([pathname filesep filename]);
               I = I(:,:,channelIndex);
                if isa(I,'uint8')
                    I = double(I)/255;
                elseif isa(I,'uint16')
                    I = double(I)/65535;
                end
                IPSDB = irisPointSourceDetectionBot(I);
            end
            mode = 0;
        case 2 % setup vessel
            [filename, pathname] = uigetfile({'*.tif','Image (.tif)'});
            if filename ~= 0
                channelIndex = 1;
                I = imread([pathname filesep filename]);
                I = I(:,:,channelIndex);
                if isa(I,'uint8')
                    I = double(I)/255;
                elseif isa(I,'uint16')
                    I = double(I)/65535;
                end
                IOVDB = irisOrientVesselDetectionBot(I);
            end
            mode = 0;
        case 3 % save parameters
            if isempty(IPSDB)
                uiwait(msgbox('Spot detection parameters not set!','Oops','modal'));
            elseif isempty(IOVDB)
                uiwait(msgbox('Orientation vessel parameters not set!','Oops','modal'));
            else
                sibPrmts.psdPrmts = IPSDB.Prmts;
                sibPrmts.ovdPrmts = IOVDB.Prmts;
                [filename, pathname] = uiputfile('sibPrmts.mat', 'Save parameters as...');
                save([pathname filename],'sibPrmts');
            end
            mode = 0;
        case 4 % load parameters
            [filename, pathname] = uigetfile({'*.mat','sibPrmts (.mat)'});
            if filename ~= 0
                load([pathname filename]); % loads sibPrmts.mat
            end
            mode = 0;
        case 5 % analyze folder
            if exist('sibPrmts','var') == 0
                uiwait(msgbox('Please load or set parameters','Oops','modal'));
            else
                inDirPath = uigetdir;
                if inDirPath ~= 0
                    SIBTD = sibTokensDialog;
                    if ~isempty(SIBTD.Tokens)
                        analizeFolder(inDirPath,SIBTD.Tokens,sibPrmts,true);
                    end
                end
            end
            mode = 0;
    end
end