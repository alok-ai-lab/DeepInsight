close all;
clear all;

netName = "squeezenet";
net = eval(netName);

inputSize = net.Layers(1).InputSize(1:2);
classes = net.Layers(end).Classes;
layerName = activationLayerName(netName);

im = imread('ngc6543a.jpg');
imResized = imresize(im,[inputSize(1),inputSize(2)]);
imageActivations = activations(net,imResized,layerName);

scores = squeeze(mean(imageActivations,[1,2]));
    
if netName ~= "squeezenet"
        fcWeights = net.Layers(end-2).Weights;
        fcBias = net.Layers(end-2).Bias;
        scores =  fcWeights*scores + fcBias;
        
        [~,classIds] = maxk(scores,3);
        
        weightVector = shiftdim(fcWeights(classIds(1),:),-1);
        classActivationMap = sum(imageActivations.*weightVector,3);
else    
        [~,classIds] = maxk(scores,3);
        classActivationMap = imageActivations(:,:,classIds(1));
end

scores = exp(scores)/sum(exp(scores));
maxScores = scores(classIds);
labels = classes(classIds);

subplot(1,2,1)
imshow(im)

subplot(1,2,2)
CAMshow(im,classActivationMap)
title(string(labels) + ", " + string(maxScores));

drawnow
    

function CAMshow(im,CAM)
imSize = size(im);
CAM = imresize(CAM,imSize(1:2));
CAM = normalizeImage(CAM);
CAM(CAM<0.2) = 0;
cmap = jet(255).*linspace(0,1,255)';
CAM = ind2rgb(uint8(CAM*255),cmap)*255;

combinedImage = double(rgb2gray(im))/2 + CAM;
combinedImage = normalizeImage(combinedImage)*255;
imshow(uint8(combinedImage));

%## Find which pixels are expressed #### (by Alok)
H=combinedImage(:,:,1); %let it do for 'R' only
R=H/255;
[row,col]=ind2sub(size(R),find(R>0.9));
figure; imshow(R)
%##################################################
end

function N = normalizeImage(I)
minimum = min(I(:));
maximum = max(I(:));
N = (I-minimum)/(maximum-minimum);
end

function layerName = activationLayerName(netName)

if netName == "squeezenet"
    layerName = 'relu_conv10';
elseif netName == "goolenet"
    layerName = 'inception_5b-output';
elseif netName == "resnet18"
    layerName = 'res5b_relu';
elseif netName == "mobilenetv2"
    layerName = 'out_relu';
else
    layerName = 'relu32';
end
end