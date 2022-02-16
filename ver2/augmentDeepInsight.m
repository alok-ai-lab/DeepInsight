function [XTrainNew,YTrainNew] = augmentDeepInsight(XTrain,YTrain)
% augment non-image samples to make it balance for DeepInsight procedure

class = length(unique(double(YTrain)));

for j=1:class
    max_class(j) = sum(double(YTrain)==j);
end
[row,col]=sort(max_class,'descend');
MaxClass = col(1);
MaxClassVal = row(1);
MinClass = col(end);
MinClassVal = row(end);
MinClassVal_samples = MinClassVal*(MinClassVal+1)/2;% + (MinClassVal-1)*(MinClassVal-2)/2;
num = MinClassVal_samples-MaxClassVal;
AUG=1000;
if num>1000
    num=1000;
    AUG=100;
end

if num>0
    %perform
    inx=1:length(double(YTrain));
    XTrainNew=[];
    YTrainNew=[];
    for j=1:class
        num = MinClassVal_samples - max_class(j);
        if num > 1000
            num=1000;
        end
        [XTrainNewClass,YTrainNewClass] = augmentDeepInsightClass(XTrain,YTrain,num,j,inx);     
        XTrainNew = cat(4,XTrainNew,XTrainNewClass);
        YTrainNew = [YTrainNew;YTrainNewClass];
    end
    inx2=1:length(double(YTrainNew));
    for j=1:class
        [XTrainNewClass,YTrainNewClass] = augmentDeepInsightClass(XTrainNew,YTrainNew,AUG,j,inx2);
        XTrainNew = cat(4,XTrainNew,XTrainNewClass);
        YTrainNew = [YTrainNew;YTrainNewClass];
    end
else
    inx=1:length(double(YTrain));
    XTrainNew=[];
    YTrainNew=[];
    for j=1:class
        num = MaxClassVal - max_class(j);
        if num>0
        [XTrainNewClass,YTrainNewClass] = augmentDeepInsightClass(XTrain,YTrain,num,j,inx);     
        XTrainNew = cat(4,XTrainNew,XTrainNewClass);
        YTrainNew = [YTrainNew;YTrainNewClass];
        else
            [XTrainNewClass,YTrainNewClass] = augmentDeepInsightClass(XTrain,YTrain,AUG,j,inx);
            XTrainNew = cat(4,XTrainNew,XTrainNewClass);
            YTrainNew = [YTrainNew;YTrainNewClass];
        end
        
    end
    inx2=1:length(double(YTrainNew));
    for j=1:class
        if j ~= MaxClass
            [XTrainNewClass,YTrainNewClass] = augmentDeepInsightClass(XTrainNew,YTrainNew,AUG,j,inx2);
            XTrainNew = cat(4,XTrainNew,XTrainNewClass);
            YTrainNew = [YTrainNew;YTrainNewClass];
        end
    end
    disp('samples in lower class are too scarce to make an estimate');
%    XTrainNew=[];
%    YTrainNew=[];
end
XTrainNew=cat(4,XTrain,XTrainNew);
YTrainNew=[YTrain;YTrainNew];

% inx=1:length(double(YTrain));
% for j=col(2:end)
%     inx_class = inx(double(YTrain)==j);
%     XTrainNew(:,:,:,1) = XTrain(:,:,:,inx_class(1));
%     YTrainNew(1) = categorical(inx_class(1));
%     cnt=1;
%     for k=1:length(inx_class)
%         for n=k+1:length(inx_class)
%             XTrainNew(:,:,:,cnt) = uint8(0.5*(double(XTrain(:,:,:,inx_class(k)))+double(XTrain(:,:,:,inx_class(n)))));
%             cnt=cnt+1;
%         end
%     end
%     
% end