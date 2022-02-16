function [Accuracy,auc,C,probs] = DeepInsight_test_CAM(dset,Out)
% [Accuracy,auc] = DeepInsight_test_CAM(dset,Out)

%Out.bestIdx = BayesObject.IndexOfMinimumTrace(end);
%Out.fileName = BayesObject.UserDataTrace{Out.bestIdx};
current_dir=pwd;
cd DeepResults
savedStruct = load(Out.fileName);
%Out.valError = savedStruct.valError
cd(current_dir);

STest = size(dset.XTest,1:2);
inputSize = savedStruct.trainedNet.Layers(1).InputSize(1:2);

if STest(1)~= inputSize(1) | STest(2)~=inputSize(2)
    augT=augmentedImageDatastore(inputSize,dset.XTest);
    [YPredicted,probs] = classify(savedStruct.trainedNet,augT);
    testError = 1 - mean(YPredicted == dset.YTest);
    Accuracy = 1-testError;
    C=confusionmat(dset.YTest,YPredicted);
else

    [YPredicted,probs] = classify(savedStruct.trainedNet,dset.XTest);
    testError = 1 - mean(YPredicted == dset.YTest);
    Accuracy = 1-testError;
    C=confusionmat(dset.YTest,YPredicted);
end
if max(double(dset.YTest))==2
    [a,b,c,auc] = perfcurve(dset.YTest,probs(:,2),'2');
else
    auc=[];
end
end
