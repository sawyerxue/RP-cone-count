function A = unnormalizedcirccentlikl(I,rad,sc,nor)

[nr,nc] = size(I);

rrs = zeros(2,nor);
crs = zeros(2,nor);

rr1 = rad+1;
rr2 = nr-rad;
cr1 = rad+1;
cr2 = nc-rad;

S = zeros(rr2-rr1+1,cr2-cr1+1);

for or = 1:nor
    ang = (or-1)/nor*2*pi;
    rrs(1,or) = rr1+round(rad*cos(ang));
    rrs(2,or) = rr2+round(rad*cos(ang));
    crs(1,or) = cr1+round(rad*sin(ang));
    crs(2,or) = cr2+round(rad*sin(ang));
end

for or = 1:nor
    J = I(rrs(1,or):rrs(2,or),...
        crs(1,or):crs(2,or));
    
    ang = (or-1)/nor*360;
    [~,mi] = smorlet(1,sc,ang,1);

%     R = conv2(J,mr,'same');
    Z = conv2(J,mi,'same');
    
    S = S+Z.*(Z > 0);
%     S = sqrt(R.^2+Z.^2);
end

A = zeros(nr,nc);
% S = (S/max(max(S))).^2;
A(rr1:rr2,cr1:cr2) = S;

end