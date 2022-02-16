function Sel = LogRegRed(dset)

current_dir=pwd;
YTrain=[];
for c=1:dset.class
    YTrain = [YTrain;ones(dset.num_tr(c),1)*c];;
end

N = 3000;
GeneSel_flag=0;

cd ~/MatWorks/Unsup/liblinear-2.11/matlab/
for k=1:3
model{k}=train(double(YTrain),sparse(double(dset.Xtrain(:,:,k)')),['-s 0','liblinear_options',]);
end
%[predicted_lablel,acc,c]=predict(double(Out.YValidation),sparse(double(dset.XValidation(:,:,1)')),model,['-b 1'])
cd(current_dir);

MaxCapacity=N;%260;
if model{1}.nr_class ==2
    for k=1:3
        model{k}.nr_class=1;
    end
end
for k=1:3
for j=1:model{k}.nr_class
    abs_w = abs(model{k}.w(j,:));
    [rw,col]=sort(abs_w,'descend');
    if GeneSel_flag==0
        Select{j}=col(1:MaxCapacity);
    else
        Select{j}=Gene_sel(col(1:MaxCapacity));
    end
end
All_genes=cell2mat(Select);
Sel{k}=unique(All_genes);
end
length(Sel{k})
Across_diff_platforms = cell2mat(Sel);
Sel = unique(Across_diff_platforms);
end