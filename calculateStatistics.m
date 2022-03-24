function [output] = calculateStatistics(image,settings)
%CALCULATESTATISTICS will input an image and output the statistics availabe
%to the visual system to drive a vergence response. this is for sonisha
%neupane's thesis experiment, with rowan candy and probably for all future
%data mining from the experiment. the idea is that the spatial properties
%of the image may influence the fidelity of the vergence response. they
%will record vergence ballistics and ultimate relate them to the spatial
%properties of the images calculated here. 
% image = input image (with or without scotoma)
% settings = a struct of settings 
% output = output statistics
%
% ESS 8/14/2020


%%%%% run through every receptive field and calculate statistics
iter            = length(settings.receptiveFields);

%%%%% generate gabor filters
gBorientation   = settings.gaborBankOrientation;
gBsfs           = settings.gaborBankSpatialFrequency;

for i = 1:iter
    disp(['starting iteration ' num2str(i) ' of ' num2str(iter) ' receptive field sizes'])
    disp(['calculating contrast image...'])
    output.RFs(i).contrastImage = calculateContrast(image, settings.receptiveFields(i));
    
    %disp(['drawing gabor patches...'])
    gB = createGaborBank(settings.receptiveFields(i), gBsfs, gBorientation);
    %disp(['calculating contrast and SF images...'])
    output.RFs(i).mag  = processOrientationSF(image,gB);
end


%%%%% store some information
output.RFsizes = settings.receptiveFields;
output.Orientations = gBorientation;
output.SFs = gBsfs;



end

function [contrastImage] = calculateContrast(image, receptiveField)
%%%%% this will generate a contrast image of contrast ovre a receptive
%%%%% field in receptiveFieldPixels

%%%% generate a radially symmetric raised cosine window of size receptive
%%%% field
wind = cosWindow2(receptiveField, 1);
wind = wind./sum(wind(:));

%%%%%%%%%%%%%%%%% calculate local luminance and contrast
localLum = conv2(image, wind, 'valid');       
localPower = (conv2(image.^2, wind, 'valid') - ((localLum).^2));
localPower(localPower <=0 ) = 0.00001; % shouldn't ever happen, but just in case
localPower = sqrt(localPower);
contrastImage = localPower./localLum;

end

function [cosWin] = cosWindow2(winSize,winFactor)
%COSWINDOW2 Creates a 2D cosine window
%
% Example: 
%   cosWin = lib.COSWINDOW2([101 101], 1, 1);
% 
% Output:
%   cosWin:  2D cosine window
% 
% v1.0 Johannes Burge


if length(winSize) == 1
   winSize = repmat(winSize,1,2); 
end
winSizeMin = min(winSize);

% Check for legal values of winFactor
if rem(1,winFactor) ~= 0
   error(['cosWindow: winFactor must divide zero evenly. Current value = ' num2str(winFactor)]);
end

if mod(winSizeMin,2) == 0 %Even
    pos = (-winSizeMin/2):(winSizeMin/2-1);  
elseif mod(winSizeMin,2) == 1 %Odd
    pos = (-(winSizeMin-1)/2):((winSizeMin-1)/2);
end

[xx, yy] = meshgrid(pos);
rr = sqrt(xx.^2 + yy.^2);
hannWinRadius = max(abs(xx(:))).*winFactor;
cosWin = cosdRadial(xx,yy,.5/hannWinRadius,.5,.5);
cosWin(rr >= hannWinRadius) = 0;

end

function [Z] = cosdRadial(Xdeg,Ydeg,freqCycDeg,amp,dc)
%COSDRADIAL Radially symmetric cosine with specified frequency at locations Xdeg, Ydeg
%
% Example: 
%   Return all coordinates with 128 spacing between them
%		[X Y] = meshgrid(linspace(-180,180));
%		Z = lib.COSDRADIAL(X,Y,3,1);
%
% radially symmetric cosine with specified frequency at locations Xdeg, Ydeg
%
% Output:   
%	Z:	height of cosine
%
% Johannes Burge


phi = 0;
Z = amp.*cosd(360.*freqCycDeg.*sqrt(Xdeg.^2 + Ydeg.^2) + phi) + dc; 

end

function [gaborBank] = createGaborBank(size, SFRange, Orientations)
%CREATEGABORBANK will create a sequence of gabors over a SF and Orientation
%range, to be dot-producted with an image bank at some point down the line.
%Size is  the pixel size, SFRange is the SF of the sinewave  (in cycles per image) and Orientations
%is the orientation of the gabor; all of these are scaled to have unit
%volume. every orientation and sf will have a quadrature pair (one in sine
%phase and one in cosine phase). if you wanted the true RF response you'd
%calculate the squared sum of these images. if you are using a winner take
%all approach, then this shouldn't matter too much. 


%%%%%%%%%%% convert to radians
Orientations = deg2rad(Orientations);

gaborBank = struct;
counter = 1;

for i = 1:length(SFRange)
    for j= 1:length(Orientations)
        for k = 1:2 % two phases for each orientation/sf combo
            
            %%%%%%%%%%% create the meshgrid;
            [X,Y] = meshgrid(linspace(-pi, pi, size), linspace(-pi, pi, size));
            %X = X + ((pi/2)*k);
            % = Y + ((pi/2)*k);
            
            a = cos(Orientations(j)) * SFRange(i);
            b = sin(Orientations(j)) * SFRange(i);
            
            %%%%%%%%%% generate sinewave
            sinw=exp(-((X/90).^2)-((Y/90).^2)).*(sin(a(:,1).*X +  (pi/2*k) +b(:,1).*Y+ (pi/2*k)));
            
            %%%%%%%%%% generate 2D gaussian
            gaussian=exp(-((X/1).^2)-((Y/1).^2));
            
            %%%%%%%%%% create gabor
            gabor = sinw.*gaussian;
            
            gaborBank(counter).gabor = gabor;
            gaborBank(counter).SF = SFRange(i);
            gaborBank(counter).Orientation = Orientations(j);
            gaborBank(counter).Phase = k;
            counter = counter + 1;
            
            
        end
    end
end
end

function [mag] = processOrientationSF(image, gB)
%PROCESSORIENTATIONSF processes responses of tuned gabor patches
% gB = the bank of gabor filters to convolve with the image
% image = the image
% mag = results of the convolution

%%%% for every entry in the gabor bank, find the response at each
%%%% pixel


for q = 1:length(gB)
    
    [mag(:,:,q)] = conv2(image, gB(q).gabor, 'valid');
    
end


%%%%%%determine the entry in the gabor bank with the peak response
%%%%%%at each pixel
% [m, n, ~] = size(mag);
% [~, ind] = max(mag,[],3);
% 
% Orientation = nan(1, m*n);
% SF          = nan(1, m*n);
% 
% %%%%% find the orientation and SF of the peak response
% for k = 1:m*n
%     Orientation(k)      =  gB(ind(k)).Orientation;
%     SF(k)               =  gB(ind(k)).SF;
%     
% end
% 
% %%%%%% return the results at each pixel
% results.orientation(:,:) = reshape(Orientation, [m n]);
% results.sf(:,:) =  reshape(SF, [m n]);
% %results.responses(:,:,:) = mag;

end
