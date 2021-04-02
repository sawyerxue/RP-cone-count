function [im,spots,n]=sawyer(image,r,cx,cy,sigma,logThr)
%image should be the entire file path for the tiff
%save correct channel - take double - this is the input image
a=imread(image,1);
im=a(:,:,2);
im=im2double(im);
% fitCircleAndDetectSpots(I,fgThr,estRad,resFac,sigma,logThr,guiMode,countRadius)
[mask,ps,imgLoG] = fitdefCircleAndDetectSpots(im,-0.4,1600,0.05,sigma,logThr,0.1,r,cx,cy);

 n=size(ps.rows,1);
 spots=im+(imgLoG>0);
figure;imshow(im+(imgLoG>0))
end
