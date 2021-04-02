function analizeFolder(inDirPath,tokens,prmts,guiMode)

fplist = listfiles(inDirPath, tokens{1});
npairs = length(fplist);

if guiMode
    h = waitbar(0,sprintf('Analyzing pair 1 of %d', npairs));
end

summaryCell = cell(npairs,7);

for i = 1:npairs
    if guiMode
        waitbar((i-1)/npairs,h,sprintf('Analyzing pair %d of %d', i, npairs))
    end
    
    % --------------------------------------------------
    % nuclei
    
    imPathSpots = fplist{i};
    I = imread(imPathSpots);
    channelIndex = 2;
    I = I(:,:,channelIndex);
    if isa(I,'uint8')
        I = double(I)/255;
    elseif isa(I,'uint16')
        I = double(I)/65535;
    end
    [radRowCol,spotsCoord] = irisPointSourceDetectionBot.Headless(I,prmts.psdPrmts);
    
    y = -(spotsCoord.rows-radRowCol(2));
    x = spotsCoord.cols-radRowCol(3);
    d = sqrt(x.^2+y.^2);
    rad = radRowCol(1);
    innCirc = d < prmts.psdPrmts.InnCircCoef*rad;
    x = x/rad;
    y = y/rad;

    % --------------------------------------------------
    % vessel

    imPathVessel = strrep(imPathSpots,tokens{1},tokens{2});        
    I = imread(imPathVessel);
    channelIndex = 1;
    I = I(:,:,channelIndex);
    if isa(I,'uint8')
        I = double(I)/255;
    elseif isa(I,'uint16')
        I = double(I)/65535;
    end
    centRadDir = irisOrientVesselDetectionBot.Headless(I,prmts.ovdPrmts);
    v = centRadDir{3};
    
    ag = atan2(v(2),v(1));
    if ag < 0
        rotAng = -pi/2-ag;
    else
        rotAng = pi/2-ag;
    end
    
    % --------------------------------------------------
    % rotate, write table
    
    rotMatrix = [cos(rotAng) -sin(rotAng); sin(rotAng) cos(rotAng)];
    xy = rotMatrix*[x'; y'];
    xRot = xy(1,:)';
    yRot = xy(2,:)';
    T = array2table([xRot yRot innCirc],'VariableNames',{'x','y','inn_cir'});
    imPathTable = strrep(imPathSpots,tokens{1},'Coords');
    [pathstr,name] = fileparts(imPathTable);
    outFilePath = [pathstr filesep name '.csv'];
    writetable(T,outFilePath);
    
    % --------------------------------------------------
    % summary
    
    imName = strrep(imPathSpots,tokens{1},'___');
    [~,name] = fileparts(imName);
    summaryCell{i,1} = name;
    summaryCell{i,2} = rotAng/pi*180;
    summaryCell{i,3} = sum(innCirc);
    summaryCell{i,4} = sum(not(innCirc));
    summaryCell{i,5} = radRowCol(1);
    summaryCell{i,6} = radRowCol(2);
    summaryCell{i,7} = radRowCol(3);
    
%     figure
%     subplot(2,2,1)
%     plot(x(innCirc),y(innCirc),'.r'), hold on
%     plot(x(not(innCirc)),y(not(innCirc)),'.g'), hold off, axis equal
%     subplot(2,2,2)
%     plot(xRot,yRot,'.'), axis equal
%     subplot(2,2,3)
%     imshow(I)
%     subplot(2,2,4)
%     imshow(imrotate(I,rotAng/pi*180,'crop'))
%     pause
end
if guiMode
    close(h)
end

variableNames = {'image','rot_angle','n_spots_in','n_spots_out','rad','c_row','c_col'};
T = cell2table(summaryCell,'VariableNames',variableNames);
writetable(T,[inDirPath filesep '_Summary.xls']);

end