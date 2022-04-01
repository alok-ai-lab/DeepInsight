function [XTrainNew,YTrainNew] = augmentDeepInsight(XTrain,YTrain,num)
% augment non-image samples to make it balance for DeepInsight procedure

class = length(unique(double(YTrain)));

for j=1:class
    max_class(j) = sum(double(YTrain)==j);
end
inx=1:length(double(YTrain));
XTrainNew=[]; YTrainNew=[];
for j=1:class
    if max_class(j) < num
        [XTrainNewClass,YTrainNewClass] = augmentDeepInsightClass(XTrain,YTrain,num,j,inx);     
        XTrainNew = cat(4,XTrainNew,XTrainNewClass);
        YTrainNew = [YTrainNew;YTrainNewClass];
    end
end
XTrainNew=cat(4,XTrain,XTrainNew);
YTrainNew=[YTrain;YTrainNew];
