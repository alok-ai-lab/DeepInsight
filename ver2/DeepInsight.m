function [Accuracy,ValErr,C,AUC] = DeepInsight(DSETnum)
%find classification accuracy and/or auc
close all;

Parm.Method = ['tsne'];%tsne'];%['tSNE']; % 1) tSNE 2) kpca or 3) pca 4) umap
Parm.Dist = 'hamming';%'hamming';%'hamming';%hamming';%'hamming'; % For tSNE only 1) mahalanobis 2) cosine 3) euclidean 4) chebychev 5) correlation 6) hamming (default: cosine)
Parm.Max_Px_Size = 224;%224;%224;% 227; %inf; 227 for SqueezeNet, 224 EfficientNetB0 (however, not necessary to change)
Parm.MPS_Fix=1;
%Parm.MPS_Fix = 1; % if this val is 1 then screen will be 
                  % Max_Px_Size x Max_Px_Size (e.g. 227x227), otherwise 
                  % automatically decided by the distribution of the input data.
                  
Parm.ValidRatio = 0.1; % ratio of validation data/Training data
Parm.Seed = 108; % random seed to distribute training and validation sets
Parm.Norm = 2; % Select '1' for Norm-1, '2' for Norm-2 and '0' for automatically select the best Norm (either 1 or 2).
Parm.FileRun = 'Run1';
Parm.SnowFall = 0;%1; % Put 1 if you want to use SnowFall compression algorithm
Parm.UsePrevModel = 'n'; % 'y' for yes and 'n' for no (for CNN). For 'y' the hyperparameter of previous stages will be used.
Parm.SaveModels = 'y'; % 'y' for saving models or 'n' for not saving
Parm.Stage=1; % '1', '2', '3', '4', '5' depending upon which stage of DeepInsight-FS to run.
Parm.ObjFcnMeasure = 'accuracy';%'accuracy' or 'other' % select objective function valError (accuracy or other (for other measures eg sensitiity, specificity, auc etc)
Parm.MaxObj = 1; % maximum objective functions for Bayesian Optimization Technique
if Parm.MaxObj==1
	Parm.InitialLearnRate = 4.98661e-5;
	Parm.Momentum = 0.801033;
	Parm.L2Regularization = 1.25157e-2;
end
Parm.MaxEpochs = 100;%100;
Parm.MaxTime = 50; % (in hours) Max. training time in hours to run a model.  
Parm.NetName = 'resnet50';%'resnet50';%'resnet50';%'inceptionresnetv2';%'inceptionresnetv2';%'resnet50';%'inceptionresnetv2';%'resnet50';%'nasnetlarge';%'inceptionresnetv2';%'nasnetlarge';%resnet50';%alexnet;% efficientnetb0;%efficientnetb0;%squeezenet;%'efficientnetb0';%'squeezenet'; 'googlenet'; 'efficientnetb0';
Parm.net = eval(Parm.NetName);%resnet50;%alexnet;% efficientnetb0;%efficientnetb0;%squeezenet;%'efficientnetb0';%'squeezenet'; 'googlenet'; 'efficientnetb0';
Parm.miniBatchSize = 256;
Parm.Augment = 0;%1; % '1' toaugment training data, otherwise set it '0'
Parm.ApplyFS = 0; %if '1' then apply Feature Selection using logreg otherwise '0'
Parm.FeatureMap = 1; % if '0' means use 'All' omics data for Cart2Pixel;
                     % if '1' means use 'EXP' omics data only
                     % if '2' means use 'MET' omics data only
                     % if '3' means use 'MUT' omics data only
Parm.TransLearn = 0; % learn from previous datasets '1' for yes


%Define where you want to store the model and FIGS, and path of Data
%(default settings are given here)
curr_dir=pwd;
FIGS_path = [curr_dir,'/FIGS/'];
Models_path = [curr_dir,'/Models/'];
Data_path = [curr_dir,'/Data/'];
Parm.PATH{1} =  FIGS_path; %'~/Dropbox/Public/FIGS/DeepInsight_CAM_FS/'; %Store figures in this folder
Parm.PATH{2} = Models_path; %'~/MatWorks/Unsup/DeepInsight-FS_pkg/Models/'; % Store model in this folder
Parm.PATH{3} = Data_path; % store your data here

if Parm.TransLearn==1
    Parm.TLdir = 'Run32';
    Parm.TLfile = [Models_path,Parm.TLdir,'/Stage1/model.mat'];
    cd(Parm.TLfile(1:end-9)); 
    Mod = load(Parm.TLfile);
    ModF = load(Mod.fileName);
    cd(curr_dir);
    Parm.DAGnet = ModF.trainedNet;
end

% Dataset name
Parm.Dataname = ['dataset',num2str(DSETnum),'.mat'];%e.g. 'dataset1.mat'

%output file
fid2 = fopen('DeepInsight_Results.txt','a+');
fprintf(fid2,'\n');
fprintf(fid2,'%s',Parm.FileRun);
fprintf(fid2,'\n');
fprintf(fid2,'SnowFall: %d\n',Parm.SnowFall);
fprintf(fid2,'Method: %s\n',Parm.Method);
if any(strcmp('Dist',fieldnames(Parm)))==1
    fprintf(fid2,'Distance: %s\n',Parm.Dist);
else
    fprintf(fid2,'Distance is not applicable or Deafult\n');
end
fprintf(fid2,'Use Previous Model: %s\n',Parm.UsePrevModel);

%begin DeepInsight transformation
    fprintf(fid2,'Stage %d Begins\n',Parm.Stage);
    fprintf('Stage %d Begins\n',Parm.Stage);
    display('Starting Data preparation by DeepInsight');
    [InputSz1,InputSz2,InputSz3,Init_dim,SET] = func_Prepare_Data(Parm);
    
    fprintf('Input Size 1 x Input Size 2 x Input Size 3: %d x %d x %d\n',InputSz1,InputSz2,InputSz3);
    fprintf(fid2,'Input Size 1 x Input Size 2 x Input Size 3: %d x %d x %d\n',InputSz1,InputSz2,InputSz3);
    fprintf(fid2,'Dataset: %s\n',SET);
    display('Data preparation ends');
    fprintf('\n');

%begin execuitng CNN     
display('Training model begins: Net1');
[Accuracy(Parm.Stage),ValErr(Parm.Stage),Momentum(Parm.Stage),L2Reg(Parm.Stage),InitLR(Parm.Stage),AUC(Parm.Stage),C,prob1] = func_TrainModel(Parm);
fprintf(fid2,'Net: %s\n',Parm.NetName);
fprintf(fid2,'ObjFcnMeasure: %s\n',Parm.ObjFcnMeasure);
fprintf('Stage: %d; Test Accuracy: %6.4f; ValErr: %4.4f; \n',Parm.Stage,Accuracy(Parm.Stage),ValErr(Parm.Stage));
fprintf('Momentum: %g; L2Regularization: %g; InitLearnRate: %g\n',Momentum(Parm.Stage),L2Reg(Parm.Stage),InitLR(Parm.Stage));
fprintf(fid2,'Stage: %d; Test Accuracy: %6.4f; ValErro: %4.4f; \n',Parm.Stage,Accuracy(Parm.Stage),ValErr(Parm.Stage));
fprintf(fid2,'Momentum: %g; L2Regularization: %g; InitLearnRate: %g\n',Momentum(Parm.Stage),L2Reg(Parm.Stage),InitLR(Parm.Stage));
display('Training model ends');
fprintf('\n');
end
