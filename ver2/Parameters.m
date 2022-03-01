function Parm = Parameters(DSETnum)
%define parameters

Parm.Method = ['tsne']; % 1) tSNE 2) kpca or 3) pca 4) umap
Parm.Dist = 'hamming';% ONLY for tSNE 1) mahalanobis 2) cosine 3) euclidean 4) chebychev 5) correlation 6) hamming
Parm.Max_Px_Size = 224;% 227; %inf; 227 for SqueezeNet, 224 for EfficientNetB0 (however, not necessary to change)
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
Parm.MaxObj = 2; % maximum objective functions for Bayesian Optimization Technique
%NOTE: if Parm.MaxObj=1 then Bayesian Optimization Technique (BOT) will not
%be used to find hyperparameters. Instead, the following values will be
%used. Please define hyperparameters as required.

% Example if Parm.MaxObj=20 then 20 objective functions will be used to
% find the best hyperparameters using BOT.

Parm.ParallelNet = 0; % if '1' then parallel net (from original DeepInsight project) will be used using makeObjFcn2.m
if Parm.MaxObj==1
    Parm.InitialLearnRate=4.98661e-5;
    Parm.Momentum=0.801033;
    Parm.L2Regularization=1.25157e-2;
    % if net is parallel (custom made) using  makeObjFcn2.m file
    if Parm.ParallelNet==1
        Parm.initialNumFilters = 4;
        Parm.filterSize = 12;
        Parm.filterSize2 = 2;
    end
end

Parm.NetName = 'resnet50';%%'inceptionresnetv2';%'nasnetlarge';%;%alexnet;% %squeezenet;%'efficientnetb0';%; 'googlenet'; '
Parm.net = eval(Parm.NetName);

if Parm.ParallelNet==1
    Parm.NetName = 'ParallelNet';
    Parm = rmfield(Parm,'net');
end

fprintf('\nCNN net: %s\n',Parm.NetName);

Parm.MaxEpochs = 100;%100;
Parm.MaxTime = 50; % (in hours) Max. training time in hours to run a model. 

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

% modify as per the local and path of your saved DAGnet
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
end