close all;
clear all;

Parm.ValidRatio = 0.1; % ratio of validation data/Training data
Parm.Seed = 108; % random seed to distribute training and validation sets
GeneSel_flag=0;


for j=1:1%1:3 %1:5

current_dir=pwd;
cd ~/data/Data_DeepInsight/Data
load(['dataset',num2str(j),'.mat']);
cd(current_dir);
end

% pre-filtered genes 
GeneSel_flag=1;
curr_dir=pwd;
cd Models/Run12/Stage1/
Gene_sel = load('tcga20180626.rnaseq_fpkm_uq.protien_coding_rows.txt');%PC
%cd Models/Run15/Stage1
%Gene_sel = load('tcga20180626.rnaseq_fpkm_uq.non_pseudogene_rows.txt'); %NP
cd(curr_dir);
dset.Xtrain = dset.Xtrain(Gene_sel,:);
dset.Xtest = dset.Xtest(Gene_sel,:);
dset.dim = length(Gene_sel);
% ##################

TrueLabel=[];
for j=1:dset.class
    TrueLabel=[TrueLabel,ones(1,dset.num_tr(j))*j];
end

Out.YTest=[];
for j=1:dset.class
   Out.YTest=[Out.YTest,ones(1,dset.num_tst(j))*j];
end
Out.YTest=categorical(Out.YTest)';
Out.YTrain=categorical(TrueLabel)';

q=1:length(TrueLabel);
clear idx
for j=1:dset.class
    rng=q(double(TrueLabel)==j);
    rand('seed',Parm.Seed);
    idx{j} = rng(randperm(length(rng),round(length(rng)*Parm.ValidRatio)));
end
idx=cell2mat(idx);
dset.XValidation = dset.Xtrain(:,idx);
dset.Xtrain(:,idx) = [];
Out.YValidation = Out.YTrain(idx);
Out.YTrain(idx) = [];

for j=1:max(double(Out.YTrain))
    num_tr(j)=sum(double(Out.YTrain)==j);
    num_ts(j)=sum(double(Out.YTest)==j);
    num_val(j)=sum(double(Out.YValidation)==j);
end
dset.num_tr=num_tr;
dset.num_tst=num_ts;
dset.num_val=num_val;


current_dir = pwd;
if size(Out.YTrain,1)<size(Out.YTrain,2)
    Out.YTrain=Out.YTrain';
end

cd ~/MatWorks/Unsup/liblinear-2.11/matlab/
model=train(double(Out.YTrain),sparse(double(dset.Xtrain')),['-s 0','liblinear_options',]);
[predicted_lablel,acc,c]=predict(double(Out.YValidation),sparse(double(dset.XValidation(:,:,1)')),model,['-b 1'])
cd(current_dir);

MaxCapacity=300;%260;
for j=1:model.nr_class
    abs_w = abs(model.w(j,:));
    [rw,col]=sort(abs_w,'descend');
    if GeneSel_flag==0
        Select{j}=col(1:MaxCapacity);
    else
        Select{j}=Gene_sel(col(1:MaxCapacity));
    end
end
All_genes=cell2mat(Select);
All_genes=unique(All_genes);
length(All_genes)


dset.Genes = Select;
%save('dset_RNAseq.mat', '-struct', 'dset','-v7.3');

GeneNames(Select,0);


