close all;
clear all;

curr_dir =pwd;

FILES = {'PDX_Paclitaxel','PDX_Gemcitabine','PDX_Cetuximab','PDX_Erlotinib','TCGA_Docetaxel','TCGA_Cisplatin','TCGA_Gemcitabine'};


cd ~/data/MoliData/
file=FILES{3};
cd(file)
dset.Xtrain(:,:,1)=load([file,'_train_expression.txt']);
dset.Xtrain(:,:,2)=load([file,'_train_cna.txt']);
dset.Xtrain(:,:,3)=load([file,'_train_mutation.txt']);
tr_lab=textread([file,'_train_response.txt'],'%s');
tr_lab=cell2mat(tr_lab);
tr_lab=(tr_lab=='R');

%dset.Xtrain=cat(2,dset.Xtrain(:,tr_lab==1,:),dset.Xtrain(:,tr_lab==0,:));
%dset.num_tr=[sum(tr_lab==1),sum(tr_lab==0)];

dset.Xtest(:,:,1)=load([file,'_test_expression.txt']);
dset.Xtest(:,:,2)=load([file,'_test_cna.txt']);
dset.Xtest(:,:,3)=load([file,'_test_mutation.txt']);
ts_lab=textread([file,'_test_response.txt'],'%s');
ts_lab=cell2mat(ts_lab);
ts_lab=(ts_lab=='R');

%dset.Xtest=cat(2,dset.Xtest(:,ts_lab==1,:),dset.Xtest(:,ts_lab==0,:));
%dset.num_tst=[sum(ts_lab==1),sum(ts_lab==0)];

dset.class=2;
dset.dim=size(dset.Xtrain,1);

dset.Set=file;

tr_lab=double(tr_lab);
ts_lab=double(ts_lab);
tr_lab(tr_lab==0)=2;
ts_lab(ts_lab==0)=2;

for omics=1:3;
cd ~/MatWorks/Unsup/liblinear-2.11/matlab/
model=train(double(tr_lab),sparse(double(dset.Xtrain(:,:,omics)')),['-s 0','liblinear_options',]);
[predicted_lablel,acc,probs]=predict(double(ts_lab),sparse(double(dset.Xtest(:,:,omics)')),model,['-b 1']);

%model=train(double(tr_lab),sparse(double([dset.Xtrain(:,:,1);dset.Xtrain(:,:,2);dset.Xtrain(:,:,3)]')),['-s 0','liblinear_options',]);
%[predicted_lablel,acc,probs]=predict(double(ts_lab),sparse(double([dset.Xtest(:,:,1);dset.Xtest(:,:,2);dset.Xtest(:,:,3)]')),model,['-b 1']);
cd(curr_dir);

[a,b,c,auc] = perfcurve(double(ts_lab),probs(:,2),'1');

C = confusionmat(ts_lab,predicted_lablel)
TP=C(1,1);
FN=C(1,2);
FP=C(2,1);
TN=C(2,2);
Sens(omics)=TP/(TP+FN)
Spec(omics)=TN/(TN+FP)
end

cd ~/MatWorks/Unsup/liblinear-2.11/matlab/
%model=train(double(tr_lab),sparse(double(dset.Xtrain(:,:,omics)')),['-s 0','liblinear_options',]);
%[predicted_lablel,acc,probs]=predict(double(ts_lab),sparse(double(dset.Xtest(:,:,omics)')),model,['-b 1']);

model=train(double(tr_lab),sparse(double([dset.Xtrain(:,:,1);dset.Xtrain(:,:,2);dset.Xtrain(:,:,3)]')),['-s 0','liblinear_options',]);
[predicted_lablel,acc,probs]=predict(double(ts_lab),sparse(double([dset.Xtest(:,:,1);dset.Xtest(:,:,2);dset.Xtest(:,:,3)]')),model,['-b 1']);
cd(curr_dir);

[a,b,c,auc] = perfcurve(double(ts_lab),probs(:,2),'1');

C = confusionmat(ts_lab,predicted_lablel)
TP=C(1,1);
FN=C(1,2);
FP=C(2,1);
TN=C(2,2);
Sens(4)=TP/(TP+FN)
Spec(4)=TN/(TN+FP)

fprintf('\nSensitivity-> Exp: %6.2f; CNA: %6.2f; MUT: %6.2f; ALL: %6.2f;\n',Sens(1),Sens(2),Sens(3),Sens(4));
fprintf('\nSpecificity-> Exp: %6.2f; CNA: %6.2f; MUT: %6.2f; ALL: %6.2f;\n',Spec(1),Spec(2),Spec(3),Spec(4));




