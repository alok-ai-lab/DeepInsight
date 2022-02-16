function ObjFcn = makeObjFcn_Squeezenet_OthMes(XTrain,YTrain,XValidation,YValidation)
% the objective function is NOT based on Validation Error but on Other
% Measure (OthMes) such as sensitivity, specificty, auc etc.
ObjFcn = @valErrorFun;
    function [valError,cons,fileName] = valErrorFun(optVars)
        imageSize = [size(XTrain,1) size(XTrain,2) size(XTrain,3)];
        numClasses = numel(unique(YTrain));
        %initialNumFilters = round((max(imageSize)/2)/sqrt(optVars.NetworkDepth));
        numMaxPools=3;
        PoolSizeAvg = floor(max(imageSize)/(2^(numMaxPools)));
        %filterSize = 5;
        
        
        net = squeezenet;%googlenet;
        %net.Layers(1);
        inputSize = net.Layers(1).InputSize;

        if isa(net,'SeriesNetwork') 
            lgraph = layerGraph(net.Layers); 
        else
            lgraph = layerGraph(net);
        end 

        [learnableLayer,classLayer] = findLayersToReplace(lgraph);

        %numClasses = numel(categories(imdsTrain.Labels));
        %numClasses = numel(categories(YTrain));
        if isa(learnableLayer,'nnet.cnn.layer.FullyConnectedLayer')
            newLearnableLayer = fullyConnectedLayer(numClasses, ...
            'Name','new_fc', ...
            'WeightLearnRateFactor',10, ...
            'BiasLearnRateFactor',10);
    
        elseif isa(learnableLayer,'nnet.cnn.layer.Convolution2DLayer')
            newLearnableLayer = convolution2dLayer(1,numClasses, ...
            'Name','new_conv', ...
            'WeightLearnRateFactor',10, ...
            'BiasLearnRateFactor',10);
        end

        lgraph = replaceLayer(lgraph,learnableLayer.Name,newLearnableLayer);

        newClassLayer = classificationLayer('Name','new_classoutput');
        lgraph = replaceLayer(lgraph,classLayer.Name,newClassLayer);

        %figure('Units','normalized','Position',[0.3 0.3 0.4 0.4]);
        %plot(lgraph)
        %ylim([0,10])


%###### Freeze Initial Layers ########
% layers = lgraph.Layers;
% connections = lgraph.Connections;
% 
% layers(1:10) = freezeWeights(layers(1:10));
% lgraph = createLgraphUsingConnections(layers,connections);
%######################################

% pixelRange = [-30 30];
% scaleRange = [0.9 1.1];
% imageAugmenter = imageDataAugmenter( ...
%     'RandXReflection',true, ...
%     'RandXTranslation',pixelRange, ...
%     'RandYTranslation',pixelRange, ...
%     'RandXScale',scaleRange, ...
%     'RandYScale',scaleRange);
% augimdsTrain = augmentedImageDatastore(inputSize(1:2),XValidation,YValidation, ...
%     'DataAugmentation',imageAugmenter);
        augimdsTrain = augmentedImageDatastore(inputSize(1:2),XTrain,YTrain);
        augimdsValidation = augmentedImageDatastore(inputSize(1:2),XValidation,YValidation);
% augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain);
%augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation);

        miniBatchSize = 10;
        % valFrequency = floor(numel(augimdsTrain.Files)/miniBatchSize);
        valFrequency = floor(size(XTrain,4)/miniBatchSize);
        gpuDevice(1);
        options = trainingOptions('sgdm', ...
            'InitialLearnRate',optVars.InitialLearnRate,...
            'Momentum',optVars.Momentum,...
            'ExecutionEnvironment','gpu',...
            'MiniBatchSize',miniBatchSize, ...
            'L2Regularization',optVars.L2Regularization,...
            'MaxEpochs',15, ...
            'Shuffle','every-epoch', ...
            'ValidationData',augimdsValidation, ...
            'ValidationFrequency',valFrequency, ...
            'Verbose',false, ...
            'Plots','none');

        %  'ExecutionEnvironment','multi-gpu',...
%            'Plots','training-progress');
       %     'Plots','none');
        
        %    'Plots','training-progress');

        trainedNet = trainNetwork(augimdsTrain,lgraph,options);
        close(findall(groot,'Tag','NNET_CNN_TRAININGPLOT_FIGURE'))
        
        [YPredicted,probs] = classify(trainedNet,augimdsValidation);
        %valError = 1 - mean(YPredicted == YValidation);
        [a,b,c,auc] = perfcurve(YValidation,probs(:,2),'1');
        valError = 1 - auc;
%         C=confusionmat(YValidation,YPredicted);
%         TP=C(1,1);
%         FN=C(1,2);
%         FP=C(2,1);
%         TN=C(2,2);
%         Sen=TP/(TP+FN);
%         Spec=TN/(TN+FP);
%         valError = 1 - Spec;
        
        fileName = num2str(valError) + ".mat";
        save(fileName,'trainedNet','valError','options')
        cons = [];
        
%         options = trainingOptions('sgdm',...
%             'InitialLearnRate',optVars.InitialLearnRate,...
%             'Momentum',optVars.Momentum,...
%             'ExecutionEnvironment','multi-gpu',...
%             'MaxEpochs',10, ...
%             'LearnRateSchedule','piecewise',...
%             'LearnRateDropPeriod',35,...
%             'LearnRateDropFactor',0.1,...
%             'MiniBatchSize',miniBatchSize,...
%             'L2Regularization',optVars.L2Regularization,...
%             'Shuffle','every-epoch',...
%             'Verbose',false,...
%             'Plots','none',...
%             'ValidationData',{XValidation,YValidation},...
%             'ValidationPatience',Inf,...
%             'ValidationFrequency',validationFrequency);
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
%            trainedNet = trainNetwork(XTrain,YTrain,lgraph,options);
%         close(findall(groot,'Tag','NNET_CNN_TRAININGPLOT_FIGURE'))
%         
%                YPredicted = classify(trainedNet,XValidation);
%         valError = 1 - mean(YPredicted == YValidation);
%         
%              fileName = num2str(valError) + ".mat";
%         save(fileName,'trainedNet','valError','options')
%         cons = [];
        
    end
end
 
