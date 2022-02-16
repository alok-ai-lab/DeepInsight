function func_Smote_Augment(NUM)
curr_dir=pwd;
Data_path='~/data/MoliData/MoliMatData_artem_v2';
%NUM=1;
cd(Data_path)
load(['dataset',num2str(NUM),'.mat'])
cd(curr_dir)

Ytrain = [ones(1,dset.num_tr(1)),ones(1,dset.num_tr(2))*2];

%Xnew = smote(dset.Xtrain(:,dset.num_tr(1)+1:end,1)',dset.num_tr(1)/dset.num_tr(2),7);%[],4,'Class',Ytrain');

for j=1:3 
    [XtrainNew,Cnew] = smote(dset.Xtrain(:,:,j)',[],round(dset.num_tr(1)/dset.num_tr(2)+1),'Class',Ytrain');
    dset.Xtrain2(:,:,j)=XtrainNew';
end
dset.num_tr=[sum(Cnew==1),sum(Cnew==2)];
dset.Xtrain=dset.Xtrain2;
dset = rmfield(dset,'Xtrain2');


cd(Data_path)
save(['dataset',num2str(NUM),'aug.mat'],'dset','-v7.3');
cd(curr_dir);
