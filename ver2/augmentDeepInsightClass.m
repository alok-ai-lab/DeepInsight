function [XTrainNewClass,YTrainNewClass] = augmentDeepInsightClass(XTrain,YTrain,num,j,inx)

inx_class = inx(double(YTrain)==j);
        cnt=1;
        for k=1:length(inx_class)
            for n=k+1:length(inx_class)
                XTrainNewClass(:,:,:,cnt) = uint8(0.5*(double(XTrain(:,:,:,inx_class(k)))+double(XTrain(:,:,:,inx_class(n)))));
                YTrainNewClass(cnt,1) = categorical(j);
                cnt=cnt+1;
                if n<=length(inx_class)-1
                XTrainNewClass(:,:,:,cnt) = uint8((1/3)*(double(XTrain(:,:,:,inx_class(k)))+double(XTrain(:,:,:,inx_class(n)))+ ...
                    double(XTrain(:,:,:,inx_class(n+1)))));
                YTrainNewClass(cnt,1) = categorical(j);
                cnt=cnt+1;
                end
                if cnt > num
                    return
                end
            end
        end
end
