function [circMask] = definedCircMask(J,r,cx,cy)
%countRadius gives the proportion of retina radius to compute number of
%spots in

[y,x] = meshgrid(1:size(J,2),1:size(J,1));
%circMask = sqrt((x-radRowCol(2)).^2+(y-radRowCol(3)).^2) < radRowCol(1);
%circMask = sqrt((x-radRowCol(2)).^2+(y-radRowCol(3)).^2) < radRowCol(1)*countRadius;
circMask = sqrt((x-cx).^2+(y-cy).^2) < r;

% C = insertShape(J,'circle',[radRowCol(3) radRowCol(2) radRowCol(1)],'LineWidth',3);

% figureQSS
% subplot(1,3,1), imshow(J)
% subplot(1,3,2), imshow(C)
% subplot(1,3,3), imshow(circMask)
% % pause
% 

end