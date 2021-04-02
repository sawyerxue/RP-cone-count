function imgLoG  = logPointSourceDetection(img, mask, sigma, alpha)

if ~isa(img, 'double')
    img = double(img);
end

% Gaussian kernel
w = ceil(4*sigma);
x = -w:w;
g = exp(-x.^2/(2*sigma^2));

% convolutions
imgXT = padarrayXT(img, [w w], 'symmetric');
fg = conv2(g', g, imgXT, 'valid');

% Laplacian of Gaussian
gx2 = g.*x.^2;
imgLoG = 2*fg/sigma^2 - (conv2(g, gx2, imgXT, 'valid')+conv2(gx2, g, imgXT, 'valid'))/sigma^4;
imgLoG = imgLoG / (2*pi*sigma^2);

% select by robust statistics
PSMags = imregionalmax(imgLoG).*imgLoG;

BgMask = not(mask);

PSMagsB = PSMags.*BgMask;
psmagsB = PSMagsB(PSMagsB > 0);
psmagsB = psmagsB(:);

rmB = median(psmagsB); % robust mean
rsB = mad(psmagsB,1);
rSigma = 1.4826*rsB; % robust std

if rSigma == 0
    rSigma = max(std(psmagsB),0.000001);
    disp('warning: found robust std = 0 for background pixels in logPointSourceDetection');
    disp('check your image for compression artifacts');
    if rSigma > 0.000001
        disp('(using <std> instead of <robust std> for thresholding)');
    end
end

imgLoG = PSMags.*(PSMags > rmB+alpha*rSigma);

end