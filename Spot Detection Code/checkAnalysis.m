function checkAnalysis(inDirPath,tokens)

fplist = listfiles(inDirPath, tokens{1});
npairs = length(fplist);

scsz = get(0,'ScreenSize'); % scsz = [left botton width height]
f = [];

T = readtable([inDirPath filesep '_Summary.xls']);
C = table2cell(T);
rotAngles = cat(1,C{:,2});
radii = cat(1,C{:,5});
cRows = cat(1,C{:,6});
cCols = cat(1,C{:,7});

for i = 1:npairs
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
    N = adapthisteq(I);
    N = imresize(N,0.1);
    N = insertShape(N, 'circle', 0.1*[cCols(i) cRows(i) radii(i)], 'LineWidth', 3);
    
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
    V = adapthisteq(I);
    V = imresize(V,0.1);
    
    
    % --------------------------------------------------
    % rotate, read/show results
    
    imPathTable = strrep(imPathSpots,tokens{1},'Coords');        
    [pathstr,name] = fileparts(imPathTable);
    inFilePath = [pathstr filesep name '.csv'];
    T = readtable(inFilePath);
    A = table2array(T);
    x = A(:,1);
    y = A(:,2);
    innCirc = A(:,3) > 0;
    
    RN = imrotate(N,rotAngles(i),'crop');
    RV = imrotate(V,rotAngles(i),'crop');
    
    if isempty(f)
        f = figure('Position',[scsz(3)/4 scsz(4)/4 scsz(3)/2 scsz(4)/2],'NumberTitle','off');
    end
    f.Name = name;
    disp(name)
    
    subplot(1,5,1)
    imshow(V)
    title('main vessel')
    subplot(1,5,2)
    imshow(RV)
    title('rot main vessel')
    subplot(1,5,3)
    imshow(N)
    title('spots')
    subplot(1,5,4)
    imshow(RN)
    title('rot spots')
    subplot(1,5,5)
    plot(x(innCirc),y(innCirc),'.r'), hold on
    plot(x(not(innCirc)),y(not(innCirc)),'.b'), hold off
    axis equal, axis([-1 1 -1 1])
    title(sprintf('rotated, normalized\nspot coordinates'))
    pause
end
delete(f)

end