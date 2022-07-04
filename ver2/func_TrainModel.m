function [Accuracy,ValErr,Momentum,L2Reg,InitLR,AUC,C,prb] = func_TrainModel(Parm)
%Train Model (training DeepInsight-FS)


% run Prepare_Data.m %TCGA RNA-seq data will be prepared using tSNE algorithm
% see Prepare_Data.m for details

curr_dir = pwd;
addpath(curr_dir);

Parm.fid=fopen('Results.txt','a+');
Parm.UsePreviousModel = 0;
%Parm.net=net;
%Parm.ObjcFcMeasure=ObjFcMeasure;
%if nargin<3
%    Parm.ObjFcMeasure='accuracy'
%else
%    Parm.ObjFcMeasure=ObjFcMeasure;
%end

[upm,Mo,Init,Reg] = func_UsePreviousModel(Parm.UsePrevModel); %UsePrevMod 'y for yes and 'n' for no
Parm.UsePreviousModel = upm; 
if upm==0
    if Parm.MaxObj~=1
        Parm.Momentum = Mo; Parm.InitialLearnRate = Init; Parm.L2Regularization = Reg;
    end
end



if Parm.Norm==2
    [model, Norm]  = DeepInsight_train_CAM(Parm,2); % if you want to use Norm 2 only
elseif Parm.Norm==1
	[model, Norm] = DeepInsight_train_CAM(Parm,1);
else
    [model, Norm]  = DeepInsight_train_CAM(Parm); % best norm will be determined by the algorithm
end
model.Norm=Norm;
save('model.mat','-struct','model','-v7.3');

if Norm==1
    Data = load('Out1.mat');
else
    Data = load('Out2.mat');
end

if isfield(Data,'XTest')==0
    Test_Empty=1;
else
    if isempty(Data.XTest)==1
        Test_Empty=1;
    else
        Test_Empty=0;
    end
end

if size(Data.XTrain,3)==1
    if Test_Empty==0
    Data.XTest = cat(3,Data.XTest,Data.XTest,Data.XTest);
    end
    Data.XValidation = cat(3,Data.XValidation,Data.XValidation,Data.XValidation);
elseif size(Data.XTrain,3)==2
    if Test_Empty==0
    Data.XTest = cat(3,Data.XTest(:,:,1,:),Data.XTest(:,:,2,:),Data.XTest(:,:,1,:));
    end
    Data.XValidation = cat(3,Data.XValidation(:,:,1,:),Data.XValidation(:,:,2,:),Data.XValidation(:,:,1,:));
end
Data = rmfield(Data,'XTrain');
Data = rmfield(Data,'YTrain');
%Data = rmfield(Data,'XValidation');
%Data = rmfield(Data,'YValidation');

if Test_Empty==0
[Accuracy,AUC,C,prob_test] = DeepInsight_test_CAM(Data,model);
prb.test=prob_test;
prb.YTest=Data.YTest;
end
% NOTE: AUC is for two class problem only, otherwise its value would be 'NaN

%find validation probabilities
Data.XTest = Data.XValidation;
Data.YTest = Data.YValidation;
[Accuracy_val,AUC_val,C_val,prob_val] = DeepInsight_test_CAM(Data,model);
prb.val=prob_val;
prb.YValidation=Data.YValidation;
if Test_Empty==1
    fprintf('\nNOTE: Test set is NOT available!\n');
    fprintf('Performance measures are for Validation SET\n');
    Accuracy=Accuracy_val;
    AUC=AUC_val;
    C=C_val;
end

% %find train probabilities
% Data.XTest = Data.XTrain;
% Data.YTest = Data.YTrain;
% [Accuracy_train,AUC_train,C_train,prob_train] = DeepInsight_test_CAM(Data,model);
% prb.train=prob_train;
% prb.YTrain=Data.YTrain;


fclose(Parm.fid);
ValErr = model.valError;
cd DeepResults	
f=load(model.fileName);
cd ..
warning off;
if isfield(struct(f.options),'Momentum')==1
    Momentum = f.options.Momentum;
else
    Momentum=0;
end
L2Reg = f.options.L2Regularization;
InitLR = f.options.InitialLearnRate;
if isempty(AUC)==1
    AUC=nan;
end


