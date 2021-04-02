function [c,r,v] = detectOrientVessel(I,foregThr,estimRad,resizeFac,sigma,steerThr,dilateAmt,erodeAmt,guiMode)

% threshold, resize
if guiMode
    h = waitbar(0,'Computing...');
end

J = snormalize(I) > foregThr;
J = imresize(J,resizeFac);
J = double(J);
resEstRad = estimRad*resizeFac;

% fit circle
if guiMode
    waitbar(1/4,h)
end

[circMask, radRowCol] = fitCircle(J,resEstRad);

% steerable filtering, morphology
if guiMode
    waitbar(2/4,h)
end

I2 = imresize(I,resizeFac);
[~,~,nms] = steerableDetector(I2,4,sigma);
R = snormalize(nms) > steerThr;
E = bwmorph(edge(J,'canny',0.5,sigma),'dilate',dilateAmt);
C = bwmorph(circMask,'erode',erodeAmt);
M = R & not(E) & C;

if guiMode
    figureQSS

    ax1 = subplot(1,5,1);
    imshow(R), title('steer. filt.')

    ax2 = subplot(1,5,2);
    imshow(E), title('edges')

    ax3 = subplot(1,5,3);
    imshow(C), title('morph. circle')

    ax4 = subplot(1,5,4);
    imshow(M), title('select. edges')
end

% find main neuron direction
if guiMode
    waitbar(3/4,h)
end

[H,T,R] = hough(M);
P  = houghpeaks(H,10,'threshold',ceil(0.3*max(H(:))));
lines = houghlines(M,T,R,P,'FillGap',3,'MinLength',5);

if guiMode
    ax5 = subplot(1,5,5);
    imshow(0.5*M), hold on
end

ds = zeros(length(lines),2);
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    
    if guiMode
        plot(xy(:,1),xy(:,2),'LineWidth',1,'Color','green');
        plot(radRowCol(3),radRowCol(2),'oy')
    end

    p1 = xy(2,:);
    p0 = xy(1,:);
    
    d = p1-p0;
    d = d/norm(d);
    ds(k,:) = d;
end

kms = 2;
[c,l] = vmf180(ds,kms);

imc = fliplr(radRowCol(2:3));

x = imc(1)+radRowCol(1)*ds(:,1);
y = imc(2)+radRowCol(1)*ds(:,2);
if guiMode
    plot(x,y,'.r') % direction candidates
end
x = imc(1)+radRowCol(1)*c(:,1);
y = imc(2)+radRowCol(1)*c(:,2);
if guiMode
    plot(x,y,'or') % direction clusters
end

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

if guiMode
    plot(x,y,'*y') % main direction
    plot([imc(1) x], [imc(2) y], '.-y'), hold off
    title('main direc.')
    linkaxes([ax1, ax2, ax3, ax4, ax5], 'xy')
end

x0 = imc(1)/resizeFac;
y0 = imc(2)/resizeFac;
c = round([y0 x0]); % center (row, col)
r = radRowCol(1)/resizeFac; % radius
v = fliplr(v); % main vessel direction (row-col coord system)

if guiMode
    delete(h)
end

end