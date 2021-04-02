function [mask,radRowCol,ps,imgLoG] = fitCircleAndDetectSpots(I,fgThr,estRad,resFac,sigma,logThr,guiMode,countRadius)
%sigma of log filter, log threshold
if guiMode
    h = waitbar(0,'Computing...');
end

resEstRad = estRad*resFac;
J = snormalize(I) > fgThr;
J = imresize(J,resFac);
J = double(J);

if guiMode
    waitbar(1/3,h)
end

[circMask, radRowCol] = fitCircle(J,resEstRad,countRadius);
radRowCol = round(radRowCol/resFac);

if guiMode
    waitbar(2/3,h)
end

mask = imresize(circMask,size(I),'nearest');
imgLoG  = logPointSourceDetection(I, mask, sigma, logThr);
imgLoG = imgLoG.*mask;
[r,c] = find(imgLoG > 0);
ps.rows = r;
ps.cols = c;

if guiMode
    delete(h)
    imshowlinkedquartet(adapthisteq(I),imresize(J,size(I),'nearest'),mask,imgLoG > 0,...
                        {'image','threshold','circle','spots'})
end
        %figure;imshow(adapthisteq(I)+double(mask))                
            
end