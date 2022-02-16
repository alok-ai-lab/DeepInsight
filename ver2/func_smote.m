function [dset,YTrain] = func_smote(dset,YTrain)

Ytrain = [ones(1,dset.num_tr(1)),ones(1,dset.num_tr(2))*2];

%Xnew = smote(dset.Xtrain(:,dset.num_tr(1)+1:end,1)',dset.num_tr(1)/dset.num_tr(2),7);%[],4,'Class',Ytrain');

for j=1:3 
    [XtrainNew,Cnew] = smote(dset.Xtrain(:,:,j)',[],round(dset.num_tr(1)/dset.num_tr(2)+1),'Class',Ytrain');
    dset.Xtrain2(:,:,j)=XtrainNew';
end
dset.num_tr=[sum(Cnew==1),sum(Cnew==2)];
dset.Xtrain=dset.Xtrain2;
dset = rmfield(dset,'Xtrain2');
YTrain = categorical(Cnew);
