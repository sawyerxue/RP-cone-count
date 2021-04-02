function [circMask, radRowCol] = fitCircle(J,resEstRad,countRadius)
%countRadius gives the proportion of retina radius to compute number of
%spots in
%countRadius=0.41;
padSize = round(max(size(J))/4);
K = padarray(J,padSize*[1 1]);


sc = 5;
nor = 16;
radRowColMax = [];
for rad = resEstRad-15:5:resEstRad+15
    A = unnormalizedcirccentlikl(K,rad,sc,nor);
    A = imcrop(A,[padSize+1 padSize+1 size(J,2)-1 size(J,1)-1]);
    maxA = max(A(:));
    [r,c] = find(A == maxA);
    radRowColMax = [radRowColMax; [rad r(1) c(1) maxA]];
end


[~,im] = max(radRowColMax(:,4));
radRowCol = radRowColMax(im,1:3);

[y,x] = meshgrid(1:size(J,2),1:size(J,1));
%circMask = sqrt((x-radRowCol(2)).^2+(y-radRowCol(3)).^2) < radRowCol(1);
circMask = sqrt((x-radRowCol(2)).^2+(y-radRowCol(3)).^2) < radRowCol(1)*countRadius;


% C = insertShape(J,'circle',[radRowCol(3) radRowCol(2) radRowCol(1)],'LineWidth',3);

% figureQSS
% subplot(1,3,1), imshow(J)
% subplot(1,3,2), imshow(C)
% subplot(1,3,3), imshow(circMask)
% pause


end