function [mask,ps,imgLoG] = fitdefCircleAndDetectSpots(I,fgThr,estRad,resFac,sigma,logThr,guiMode,r,cx,cy)
%sigma of log filter, log threshold
if guiMode
    h = waitbar(0,'Computing...');
end

if guiMode
    waitbar(1/3,h)
end
% 
% %For David:
% [circMask, radRowCol] = fitCircle(J,resEstRad,countRadius);
% radRowCol = round(radRowCol/resFac);

if guiMode
    waitbar(2/3,h)
end

%For Sawyer line 25
[circMask] = definedCircMask(I,r,cx,cy);
mask = imresize(circMask,size(I),'nearest');
imgLoG  = logPointSourceDetection(I, mask, sigma, logThr);
imgLoG = imgLoG.*mask;
[r,c] = find(imgLoG > 0);
ps.rows = r;
ps.cols = c;

if guiMode
    delete(h)
    imshowlinkedquartet(adapthisteq(I),imresize(I,size(I),'nearest'),mask,imgLoG > 0,...
                        {'image','threshold','circle','spots'})
end
        %figure;imshow(adapthisteq(I)+double(mask))   
        %figure;imshow(adapthisteq(I)+imgLoG>0)
            
end