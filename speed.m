clear

imageNames = [
  "001.jpg" 
  "002.jpg"
  "003.jpg"
  "004.jpg"
  "005.jpg"
  "006.jpg"
  "007.jpg"
  "008.jpg"
  "009.jpg"
  "010.jpg"
  "011.jpg"
];

% imageNames = [
%   "fire01.jpg"
%   "fire02.jpg"
% ];

% [x1, y1] = distanceFromCamera(200, 220)
% [x2, y2] = distanceFromCamera(300, 220)
% abs(x1 - x2)
% return;
lastDist = 0;
carCoords = zeros(1, length(imageNames)*2);
for i = 1:length(imageNames)
    % disp(imageName);
    [bwImage, props] = imageInfo(imageNames(i));
    
    
    [width, height] = bbDimensions(props.BoundingBox);
    
    [x, y] = distanceFromCamera(props.Centroid(1), props.Centroid(2));
    
    
    if lastDist == 0
        carCoords(i*2) = y;
        carCoords(i*2-1) = x;
    end
    [width, height, ratio] = carDimensions(props.BoundingBox, props.Centroid);
    disp([width, height]);
    
    % disp([x, y]);
end
% carCoords
disp("DISTANCES:")
dists = [];
for i = 1:2:length(carCoords)-2
% i = 1;
    x1 = carCoords(i);
    y1 = carCoords(i+1);
    x2 = carCoords(i+2);
    y2 = carCoords(i+3);

    dist = sqrt(abs(x1 - x2)^2 + abs(y1 - y2)^2);

    dists = [dists, dist];
end
% dists

% mean(dists) * 10


% distance from camera origin, i.e. the center.
% this is from the ground, where
function [xDistance, yDistance, xAngle, yAngle] = distanceFromCamera(x, y)
    PIXEL_ANGLE = 0.042;
    yAngle = 60;
    
    if y > 320
         yAngle = yAngle + (abs(320 - y) * PIXEL_ANGLE);
    elseif y < 320
        yAngle = yAngle + (abs(320 - y) * PIXEL_ANGLE);
    end
    
    % Find the distance using trig
    % disp(["the angle y: ", yAngle]);
    
    yDistance = 7 * (tand(yAngle));

    xAngle = 0;
    if x > 240
         xAngle = xAngle + (abs(240 - x) * PIXEL_ANGLE);
    elseif x < 240
        xAngle = xAngle - (abs(240 - x) * PIXEL_ANGLE);
    end
    
    % xAngle = xAngle + abs(240 - x) * PIXEL_ANGLE;
    


    % disp(["the angle x: ", xAngle]);
    % xDistance = yDistance / (tand(xAngle));

    % hyp = yDistance / sind(yAngle);
    hyp = 7 / cosd(yAngle);
    
    
    xDistance = sind(xAngle) * hyp;
    % disp(["y: ", yDistance, "hyp: ", hyp, "x", xDistance]);
end

function [width, height, ratio] = carDimensions(bb, center)
    % center(2) + bb(4)/2
    % [x, y]= distanceFromCamera(bb(1), bb(2));
    [xDistance1, yDistance1] = distanceFromCamera(bb(1), bb(2));
    [xDistance2, yDistance2] = distanceFromCamera(bb(1) + bb(3), bb(2) + bb(4));
    % bb(1) + bb(3)
    width = abs(xDistance2 - xDistance1);
    height = abs(yDistance2 - yDistance1);
    % width = 0;
    % height = 0;
    % [xxx, yyy] = distanceFromCamera(240, 480)
    % [xxxx] = distanceFromCamera(240)
    ratio = 0;
end


function [width, height] = bbDimensions(bb)
    width = bb(3);
    height = bb(4);
end

function [bwImage, props] = imageInfo(im)
    i = imread(im);

    i_g = im2gray(i);
    
    i_mask = createMask(i);
    
    
    se2 = strel("square", 10);
    i_open = imopen(i_mask, se2);
    % figure, imshow(i_open)
    
    se3 = strel("square", 15);
    i_close = imclose(i_open, se3);
    
    % figure, imshow(i_close)
    
    cc = bwconncomp(i_close);
    allProps = regionprops(cc, "BoundingBox", "Centroid", "Area");

    % get biggest area
    [~, biggestIndex] = max([allProps.Area]);
    props = allProps(biggestIndex);
    % rectangle('Position',props.BoundingBox,'EdgeColor','green');
    bwImage = i_close;
end

function [BW,maskedRGBImage] = createMask(RGB)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder app. The colorspace and
%  range for each channel of the colorspace were set within the app. The
%  segmentation mask is returned in BW, and a composite of the mask and
%  original RGB images is returned in maskedRGBImage.

% Auto-generated by colorThresholder app on 15-Nov-2023
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2hsv(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 0;
channel1Max = 0;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.25;
channel2Max = 1.000;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0;
channel3Max = 1;

% Create mask based on chosen histogram thresholds
sliderBW = ( (I(:,:,1) >= channel1Min) | (I(:,:,1) <= channel1Max) ) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

% Initialize output masked image based on input image.
maskedRGBImage = RGB;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end
