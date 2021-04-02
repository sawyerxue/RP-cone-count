function folderHeatMap(inDirPath,imSize,sigma)

fplist = listfiles(inDirPath, 'Coords');
npairs = length(fplist);

xy = [];
xyLeft = [];
xyRight = [];
for i = 1:npairs
    imPathTable = fplist{i};
    [pathstr,name] = fileparts(imPathTable);
    
    inFilePath = [pathstr filesep name '.csv'];
    T = readtable(inFilePath);
    A = table2array(T);
    
    if contains(name,'OS') % left eye
        xyLeft = [xyLeft; A(:,1:2)];
        xy = [xy; [-A(:,1) A(:,2)]]; % mirroring with respect to vertical axis
    elseif contains(name,'OD') % right eye
        xyRight = [xyRight; A(:,1:2)];
        xy = [xy; A(:,1:2)];
    end
end

ss = get(0,'ScreenSize');

if ~isempty(xyLeft)
%     figure, plot(xyLeft(:,1),xyLeft(:,2),'.'), axis equal, title('left')

    xyLeft = (xyLeft+1)/2*imSize;
    HMLeft = points2HeatMap(xyLeft,imSize,sigma);
    figure('Position',[ss(3)/4 ss(4)/3 ss(4)/2 ss(4)/2])
    imagesc(HMLeft/max(HMLeft(:)))
    axis equal
    axis off
    title('left')
    colorbar
end

if ~isempty(xyRight)
%     figure, plot(xyRight(:,1),xyRight(:,2),'.'), axis equal, title('right')
    
    xyRight = (xyRight+1)/2*imSize;
    HMRight = points2HeatMap(xyRight,imSize,sigma);
    figure('Position',[2*ss(3)/4 ss(4)/3 ss(4)/2 ss(4)/2])
    imagesc(HMRight/max(HMRight(:)))
    axis equal
    axis off
    title('right')
    colorbar
end

if ~isempty(xy)
%     figure, plot(xy(:,1),xy(:,2),'.'), axis equal, title('mirrored left, right')
    
    xy = (xy+1)/2*imSize;
    HMAll = points2HeatMap(xy,imSize,sigma);
    figure('Position',[3*ss(3)/4 ss(4)/3 ss(4)/2 ss(4)/2])
    imagesc(HMAll/max(HMAll(:)))
    axis equal
    axis off
    title('mirrored left, right')
    colorbar
end

end