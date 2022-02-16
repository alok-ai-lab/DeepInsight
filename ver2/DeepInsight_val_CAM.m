function [Accuracy,auc,C,probs] = DeepInsight_val_CAM(dset,Out)
% [Accuracy,auc,C,probs] = DeepInsight_val_CAM(Data,model)

%Out.bestIdx = BayesObject.IndexOfMinimumTrace(end);
%Out.fileName = BayesObject.UserDataTrace{Out.bestIdx};
current_dir=pwd;
cd DeepResults
savedStruct = load(Out.fileName);
%Out.valError = savedStruct.valError
cd(current_dir);

if size(dset.XTrain,3)<3
    dset.XValidation = cat(3,dset.XValidation,dset.XValidation,dset.XValidation);
end
dset = rmfield(dset,'XTrain');
dset = rmfield(dset,'YTrain');
dset = rmfield(dset,'XTest');
dset = rmfield(dset,'YTest');

STest = size(dset.XValidation,1:2);
inputSize = savedStruct.trainedNet.Layers(1).InputSize(1:2);

if STest(1)~= inputSize(1) | STest(2)~=inputSize(2)
    augT=augmentedImageDatastore(inputSize,dset.XValidation);
    [YPredicted,probs] = classify(savedStruct.trainedNet,augT);
    valError = 1 - mean(YPredicted == dset.YValidation);
    Accuracy = 1-valError;
    C=confusionmat(dset.YValidation,YPredicted);
else

    [YPredicted,probs] = classify(savedStruct.trainedNet,dset.XValidation);
    valError = 1 - mean(YPredicted == dset.YValidation);
    Accuracy = 1-valError;
    C=confusionmat(dset.YValidation,YPredicted);
end
if max(double(dset.YValidation))==2
    [a,b,c,auc] = perfcurve(dset.YValidation,probs(:,2),'2');
end
end
save('Probability.mat','probs');
