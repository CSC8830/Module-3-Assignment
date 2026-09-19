function blurSpatialVsFrequencyDemo
% Blur an image in the spatial domain and the frequency domain, then
% compare the results to show the equivalence of convolution and
% multiplication in the Fourier domain.

I = im2double(imread('cameraman.tif'));
if ndims(I) == 3
    I = rgb2gray(I);
end

h = fspecial('gaussian', [9 9], 2);

% Spatial-domain filtering
Ispatial = imfilter(I, h, 'conv', 'same', 0);

% Frequency-domain filtering
Ifreq = fftLinearConvSame(I, h);

% Validation
diffImage = Ispatial - Ifreq;
maxAbsDiff = max(abs(diffImage), [], 'all');
rmse = sqrt(mean(diffImage.^2, 'all'));

% Display
figure
subplot(2,2,1), imshow(I, []), title('Original')
subplot(2,2,2), imshow(Ispatial, []), title('Spatial-domain blur')
subplot(2,2,3), imshow(Ifreq, []), title('Frequency-domain blur')
subplot(2,2,4), imshow(abs(diffImage), []), title('Absolute difference')

fprintf('Max abs difference: %.3e\n', maxAbsDiff);
fprintf('RMSE: %.3e\n', rmse);
end

function Y = fftLinearConvSame(X, H)
% Linear convolution via FFT, cropped to match imfilter(...,'same',0).

fullSize = size(X) + size(H) - 1;

Xf = fft2(X, fullSize(1), fullSize(2));
Hf = fft2(ifftshift(H), fullSize(1), fullSize(2));

Yfull = real(ifft2(Xf .* Hf));

rowStart = floor(size(H,1) / 2) + 1;
colStart = floor(size(H,2) / 2) + 1;

rowIdx = rowStart:rowStart + size(X,1) - 1;
colIdx = colStart:colStart + size(X,2) - 1;

Y = Yfull(rowIdx, colIdx);
end
