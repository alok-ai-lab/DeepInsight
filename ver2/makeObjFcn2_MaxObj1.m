function ObjFcn = makeObjFcn2(XTrain,YTrain,XValidation,YValidation,Parm)
measure=Parm.ObjFcnMeasure;
ObjFcn = @valErrorFun;
    function [valError,cons,fileName] = valErrorFun(optVars)
        imageSize = [size(XTrain,1) size(XTrain,2) size(XTrain,3)];
        numClasses = numel(unique(YTrain));
        %initialNumFilters = round((max(imageSize)/2)/sqrt(optVars.NetworkDepth));
        numMaxPools=3;
        PoolSizeAvg = floor(max(imageSize)/(2^(numMaxPools)));
        %filterSize = 5;
        
        layers = [
                imageInputLayer(imageSize,'Name','input')
    
                convolution2dLayer(Parm.filterSize,Parm.initialNumFilters,'Padding','same','Name','conv_1')%3,8
                batchNormalizationLayer('Name','BN_1');
                reluLayer('Name','relu_1');   
    
                maxPooling2dLayer(2,'Stride',2,'Name','MaxPool_1')
    
                convolution2dLayer(Parm.filterSize,2*Parm.initialNumFilters,'Padding','same','Name','conv_2')%3,16
                batchNormalizationLayer('Name','BN_2');
                reluLayer('Name','relu_2');   
    
                maxPooling2dLayer(2,'Stride',2,'Name','MaxPool_2')
    
                convolution2dLayer(Parm.filterSize,4*Parm.initialNumFilters,'Padding','same','Name','conv_3')%3,32
                batchNormalizationLayer('Name','BN_3')
                reluLayer('Name','relu_3')   
    
                maxPooling2dLayer(2,'Stride',2,'Name','MaxPool_3')
    
                convolution2dLayer(Parm.filterSize,8*Parm.initialNumFilters,'Padding','same','Name','conv_4')%3,32
                batchNormalizationLayer('Name','BN_4')
                reluLayer('Name','relu_4') 
    
%     maxPooling2dLayer(2,'Stride',2,'Name','MaxPool_4')
%      
%     convolution2dLayer(filterSize,16*filterNum,'Padding','same','Name','conv_5')%3,32
%     batchNormalizationLayer('Name','BN_5')
%     reluLayer('Name','relu_5') 
    
    
    additionLayer(2,'Name','add')
     
     
    averagePooling2dLayer(2,'Stride',2,'Name','avpool')
    fullyConnectedLayer(numClasses,'Name','FC')
    softmaxLayer('Name','softmax')
    classificationLayer('Name','ClassOut')];

layers2 = [
    convolution2dLayer(Parm.filterSize2,Parm.initialNumFilters,'Padding','same','Name','l2_conv_1')%3,8
    batchNormalizationLayer('Name','l2_BN_1');
    reluLayer('Name','l2_relu_1');   
    
    maxPooling2dLayer(2,'Stride',2,'Name','l2_MaxPool_1')
    
    convolution2dLayer(Parm.filterSize2,2*Parm.initialNumFilters,'Padding','same','Name','l2_conv_2')%3,16
    batchNormalizationLayer('Name','l2_BN_2');
    reluLayer('Name','l2_relu_2');   
    
    maxPooling2dLayer(2,'Stride',2,'Name','l2_MaxPool_2')
    
    convolution2dLayer(Parm.filterSize2,4*Parm.initialNumFilters,'Padding','same','Name','l2_conv_3')%3,32
    batchNormalizationLayer('Name','l2_BN_3')
    reluLayer('Name','l2_relu_3')   
    
    maxPooling2dLayer(2,'Stride',2,'Name','l2_MaxPool_3')
    
    convolution2dLayer(Parm.filterSize2,8*Parm.initialNumFilters,'Padding','same','Name','l2_conv_4')%3,32
    batchNormalizationLayer('Name','l2_BN_4')
    reluLayer('Name','l2_relu_4') 
    
%     maxPooling2dLayer(2,'Stride',2,'Name','l2_MaxPool_4')
%      
%     convolution2dLayer(8,160,'Padding','same','Name','l2_conv_5')%3,32
%     batchNormalizationLayer('Name','l2_BN_5')
%     reluLayer('Name','l2_relu_5')     
];

lgraph = layerGraph(layers);

lgraph = addLayers(lgraph,layers2);
lgraph = connectLayers(lgraph,'input','l2_conv_1');
lgraph = connectLayers(lgraph,'l2_relu_4','add/in2');

%figure; plot(lgraph)


        
        
%         layers = [
%             imageInputLayer(imageSize)
%             
%             % The spatial input and output sizes of these convolutional
%             % layers are 32-by-32, and the following max pooling layer
%             % reduces this to 16-by-16.
%             convBlock(optVars.filterSize,initialNumFilters,optVars.NetworkDepth)
%             maxPooling2dLayer(2,'Stride',2) 
%             % 1. maxPool
%             
%             % The spatial input and output sizes of these convolutional
%             % layers are 16-by-16, and the following max pooling layer
%             % reduces this to 8-by-8.
%             convBlock(optVars.filterSize,2*initialNumFilters,optVars.NetworkDepth)
%             maxPooling2dLayer(2,'Stride',2) 
%             % 2. maxPool
%             
%             % The spatial input and output sizes of these convolutional
%             % layers are 8-by-8. The global average pooling layer averages
%             % over the 8-by-8 inputs, giving an output of size
%             % 1-by-1-by-4*initialNumFilters. With a global average
%             % pooling layer, the final classification output is only
%             % sensitive to the total amount of each feature present in the
%             % input image, but insensitive to the spatial positions of the
%             % features.
%             convBlock(optVars.filterSize,4*initialNumFilters,optVars.NetworkDepth)
%             maxPooling2dLayer(2,'Stride',2)   
%             % 3. maxPool
%             
%             convBlock(optVars.filterSize,8*initialNumFilters,optVars.NetworkDepth)
%             %averagePooling2dLayer(PoolSizeAvg)
%             
%             % Add the fully connected layer and the final softmax and
%             % classification layers.
%             fullyConnectedLayer(numClasses)
%             softmaxLayer
%             classificationLayer];

            augimdsTrain = augmentedImageDatastore(imageSize(1:2),XTrain,YTrain);
            augimdsValidation = augmentedImageDatastore(imageSize(1:2),XValidation,YValidation);    
            
            miniBatchSize = Parm.miniBatchSize;
            validationFrequency = floor(numel(YTrain)/miniBatchSize);
            if validationFrequency<1
                validationFrequency=1;
            end
            
        options = trainingOptions('sgdm',...
            'InitialLearnRate',Parm.InitialLearnRate,...
            'Momentum',Parm.Momentum,...
            'ExecutionEnvironment','multi-gpu',...
            'MaxEpochs',Parm.MaxEpochs, ...
            'LearnRateSchedule','piecewise',...
            'LearnRateDropPeriod',35,...
            'LearnRateDropFactor',0.1,...
            'MiniBatchSize',miniBatchSize,...
            'L2Regularization',Parm.L2Regularization,...
            'Shuffle','every-epoch',...
            'Verbose',false,...
            'Plots','training-progress',...
            'ValidationData',{XValidation,YValidation},...
            'ValidationPatience',Inf,...
            'ValidationFrequency',validationFrequency);
  %'Plots','none',...     
  %'MaxEpochs',100,...
  
       %  'Plots','training-progress',...
        
%         imageAugmenter = imageDataAugmenter( ...
%     'RandRotation',[-5,5], ...
%     'RandXTranslation',[-3 3], ...
%     'RandYTranslation',[-3 3]);
%  
%         datasource = augmentedImageDatastore(imageSize,XTrain,YTrain,...
%             'DataAugmentation',imageAugmenter,...
%             'OutputSizeMode','randcrop');
        
%                 trainedNet = trainNetwork(datasource,lgraph,options);
           rng('default');
           trainedNet = trainNetwork(augimdsTrain,lgraph,options);
           close(findall(groot,'Tag','NNET_CNN_TRAININGPLOT_FIGURE'))
         
            [YPredicted,probs] = classify(trainedNet,augimdsValidation);
            if strcmp(measure,'accuracy')
                valError = 1 - mean(YPredicted == YValidation);
                %display('accuracy');
            else
                [a,b,c,auc] = perfcurve(YValidation,probs(:,2),'2');
                valError = 1 - auc;
                %display('auc based');
            end
        
             fileName = num2str(valError) + ".mat";
        save(fileName,'trainedNet','valError','options')
        cons = [];
        
    end
end
 
