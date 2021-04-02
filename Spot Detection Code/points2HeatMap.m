function HM = points2HeatMap(points,imSize,sigma)

I = zeros(imSize,imSize);
rc = round([imSize-points(:,2) points(:,1)]);
for i = 1:size(points,1)
    if rc(i,1) > 0 && rc(i,1) <= imSize && rc(i,2) > 0 && rc(i,2) <= imSize
        I(rc(i,1),rc(i,2)) = I(rc(i,1),rc(i,2))+1;
    end
end
HM = filterGauss2D(I,sigma);

end