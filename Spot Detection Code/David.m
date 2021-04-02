function [im,spots,n,n_outside,ps]=David(image,sigma,logThr)
%image should be the entire file path for the tiff
%save correct channel - take double - this is the input image
a=imread(image,1);
im=a(:,:,2);
im=im2double(im);
% fitCircleAndDetectSpots(I,fgThr,estRad,resFac,sigma,logThr,guiMode,countRadius)
[mask,radRowCol,ps,psComp,imgLoG,imgLoGComp] = fitCircleAndDetectSpotsDavid(im,-0.4,1600,0.05,sigma,logThr,0.1,0.46);


 n=size(ps.rows,1);
 n_outside=size(psComp.rows,1);

 
 
 spots=im+(imgLoG>0);
figure;imshow(im+(imgLoG>0));title 'Spots Detected Within Radius';
figure;imshow(im+(imgLoGComp>0)); title 'Spots Detected Outside Radius';
end
