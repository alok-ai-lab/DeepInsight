function [IND,Genes,Genes_compressed] = findActivatedPoints(Data,classes,inputSize,net,netName,layerName,Dmat,Threshold,FIG,Sample)

im = Data.XTrain(:,:,:,Sample); %cat(3,Data.XTrain(:,:,:,Sample),Data.XTrain(:,:,:,Sample),Data.XTrain(:,:,:,Sample));%imread('ngc6543a.jpg');
imResized = imresize(im,[inputSize(1),inputSize(2)]);
%gpuDevice(1);
%options=trainingOptions('sgdm','ExecutionEnvironment','gpu');
imageActivations = activations(net.trainedNet,imResized,layerName);

scores = squeeze(mean(imageActivations,[1,2]));
    
if netName ~= "squeezenet"
        fcWeights = net.trainedNet.Layers(end-2).Weights;
        fcBias = net.trainedNet.Layers(end-2).Bias;
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

if FIG==1
figure
subplot(1,2,1)
imshow(im);
title(['Sample ',num2str(Sample)]);

subplot(1,2,2)
CAMshow(im,classActivationMap);
title('Activation area');

pause(1);

figure
subplot(1,2,1)
imagesc(Data.XTrain(:,:,1,Sample))
colormap hot
colorbar
%imshow(im)
title(['Sample ',num2str(Sample),' in color']);

subplot(1,2,2)
CAMshow(im,classActivationMap);
title('Activation area');

pause(1);
end

%Threshold = 0.5;
%Dmat = 'R'; % R for Red; G for Green; B for Blue
IND = CAMind(im,classActivationMap,Threshold,Dmat,FIG);

inputSize = size(Data.XTrain,1:2);
[Genes,Genes_compressed] = findGenes(IND,Data.xp,Data.yp,inputSize);

end
