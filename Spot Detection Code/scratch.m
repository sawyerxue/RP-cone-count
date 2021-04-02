%% nuclei detection

imIndex = 1;
imagePath = sprintf('/home/mc457/files/CellBiology/IDAC/Marcelo/Cepko/Wu/Images/Spots%d.tif',imIndex);
channelIndex = 2;

I = imread(imagePath);
I = I(:,:,channelIndex);

if isa(I,'uint8')
    I = double(I)/255;
elseif isa(I,'uint16')
    I = double(I)/65535;
end



thr = -0.4;
estRad = 1600;
resizeFactor = 1/20;

resEstRad = estRad*resizeFactor;

J = snormalize(I) > thr;
J = imresize(J,resizeFactor);
J = double(J);


[circMask, radRowCol] = fitCircle(J,resEstRad);

% imshowlinkedduo(J,circMask)



sigma = 2.0;
mask = imresize(circMask,size(I),'nearest');
imgLoG  = logPointSourceDetection(I, mask, sigma, 50);
imgLoG = imgLoG.*mask;
% imshowlinkedpair(adapthisteq(I),imgLoG > 0)
[r,c] = find(imgLoG > 0);
% imshow(adapthisteq(I)), hold on, spy(imgLoG > 0), hold off

axesfigure
imshow(adapthisteq(I)), hold on, plot(c,r,'o'), hold off
% axesfigure
% imshow(mask)



%% angle detection


imIndex = 4;
imagePath = sprintf('/home/mc457/files/CellBiology/IDAC/Marcelo/Cepko/Wu/Images/Vessel%d.tif',imIndex);
channelIndex = 1;

I = imread(imagePath);
I = I(:,:,channelIndex);

if isa(I,'uint8')
    I = double(I)/255;
elseif isa(I,'uint16')
    I = double(I)/65535;
end


J = snormalize(I) > thr;
J = imresize(J,resizeFactor);
J = double(J);



[circMask, radRowCol] = fitCircle(J,resEstRad);

% imshowlinkedduo(J,circMask)

sigma = 1;
I2 = imresize(I,resizeFactor);
[~,theta,nms] = steerableDetector(I2,4,sigma);
E = bwmorph(edge(J,'canny',0.5,sigma),'dilate',1);
R = snormalize(nms) > 3;
C = not(bwmorph(circMask,'erode',20));
M = R & not(E) & not(C);
imshowlinkedquartet(R, E, C, M)


[H,T,R] = hough(M);
P  = houghpeaks(H,10,'threshold',ceil(0.3*max(H(:))));
lines = houghlines(M,T,R,P,'FillGap',3,'MinLength',5);
axesfigure, imshow(0.5*M), hold on

ds = zeros(length(lines),2);
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    plot(xy(:,1),xy(:,2),'LineWidth',1,'Color','green');

    p1 = xy(2,:);
    p0 = xy(1,:);
    
    d = p1-p0;
    d = d/norm(d);
    ds(k,:) = d;
    
    % plot beginnings and ends of lines
%     plot(p0(1),p0(2),'x','LineWidth',1,'Color','red');
%     plot(p1(1),p1(2),'x','LineWidth',1,'Color','green');
    
    plot(radRowCol(3),radRowCol(2),'oy')
end


% mean shift on sphere
kms = 2;
% kms can be thought of as inverse of 'bandwidth' in mean shift literature parlance
% rule of thumb: for n equally spaced clusters on the 2D disk set k = n
[c,l] = vmf180(ds,kms);

imc = fliplr(radRowCol(2:3));

x = imc(1)+radRowCol(1)*ds(:,1);
y = imc(2)+radRowCol(1)*ds(:,2);
plot(x,y,'.r')
x = imc(1)+radRowCol(1)*c(:,1);
y = imc(2)+radRowCol(1)*c(:,2);
plot(x,y,'or')

nc = max(l); % number of clusters
nvpc = zeros(nc,1); % number of votes per cluster
for i = 1:nc
    nvpc(i) = sum(l == i);
end

if nc == 1
    v = c;
elseif nc == 2
    if dot(c(1,:),c(2,:)) > cos(pi/4) % clusters very close
        v = sum(c);
        v = v/norm(v); % mean of two clusters (directions)
    else % pick cluster with the most votes
        [~,im] = max(nvpc);
        v = c(im,:);
    end
else % pick two clusters with the most votes, handle as in nc == 2
    [~,im1] = max(nvpc);
    nvpc(im1) = 0;
    [~,im2] = max(nvpc);
    c1 = c(im1,:);
    c2 = c(im2,:);
    if dot(c1,c2) > cos(pi/4) % clusters very close
        v = c1+c2;
        v = v/norm(v); % mean of two clusters (directions)
    else % pick cluster with the most votes
        v = c1;
    end
end

x = imc(1)+radRowCol(1)*v(1);
y = imc(2)+radRowCol(1)*v(2);
plot(x,y,'*y'), hold off







