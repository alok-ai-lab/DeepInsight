function [A,B,C,Init_dim,SET] = func_Prepare_Data(Parm)

%Prepare_Data with DeepInsight
%
%Description of Datasets
% 1. dataset1.mat is RNA-seq (1.5GB)
% 2. dataset2.mat is ringnorm-DELVE (560KB)
% 3. dataset3.mat is vowels (3.6MB)
% 4. dataset4.mat is Madelon (2.1MB)
% 5. dataset5.mat is Relathe (696KB)

if Parm.SnowFall==1
    Parm.MPS_Fix=0;
    Parm.SnowFall_A = Parm.Max_Px_Size;
    Parm.SnowFall_B = Parm.Max_Px_Size;
    Parm.Max_Px_Size = 1e+5;%inf;  % inf gives precision error if data values are very large eg 1e+17
end


if strcmp(Parm.PATH{3}(end),'/')==0
    Parm.PATH{3} = [Parm.PATH{3},'/'];
end
current_dir=pwd;
cd(Parm.PATH{3})
%load(['dataset1.mat']);
load(Parm.Dataname);
cd(current_dir);
Init_dim = dset.dim;
SET=dset.Set;

%##### augment data ####
% for j=1:dset.class
%     cnt=1;
%     tr=[];
%     for m=1+sum(dset.num_tr(1:j-1)):sum(dset.num_tr(1:j))-1
%         for n=2+sum(dset.num_tr(1:j-1)):sum(dset.num_tr(1:j))
%             if cnt<=1000
%                 tr(:,cnt,:) = [0.5*(dset.Xtrain(:,m,:)+dset.Xtrain(:,n,:))];
%                 cnt=cnt+1;
%             end
%         end
%     end
%     Num_TR(j)=size(tr,2)+dset.num_tr(j);
%     TR{j}=cat(2,dset.Xtrain(:,1+sum(dset.num_tr(1:j-1)):sum(dset.num_tr(1:j)),:),tr);
% end
% dset.Xtrain=[TR{1},TR{2}];
% dset.num_tr=Num_TR;
% clear tr TR cnt Num_TR
%#######################

if Parm.ApplyFS==1
    Sel = LogRegRed(dset);
    dset.Xtrain = dset.Xtrain(Sel,:,:);
    dset.Xtest = dset.Xtest(Sel,:,:);
    dset.dim = length(Sel);
    Init_dim = dset.dim;
end

% Prepare_Data(dset,Parm);
%
% dset is a data struct (dset.Xtrain, dset.XValidation,...)
%
% Out is the output in struct format

%fprintf(Parm.fid,'\nDataset: %s\n',dset.Set);
fprintf('\nDataset: %s\n',dset.Set);


Stages=Parm.Stage; % {1,2,3,4 or 5}
FileRun = Parm.FileRun; %Run1, Run2, Run3 or Run4
Directory = ['Models/',FileRun,'/Stage1'];
genesCompressed = 'no'; %'yes' or 'no'
if Stages > 1
    %RUN1, Run2 etc.
    cd(Directory)
    if strcmp(lower(genesCompressed),'yes')==1
        Stage1 = load('Genes_compressed.mat');
        Genes_compressed = Stage1.Genes_compressed;
        Init_dim = length(Genes_compressed);
    else
        Stage1 = load('Genes.mat');
        Genes = Stage1.Genes;
        Init_dim = length(Genes);
    end
    %Stage1 = load('Genes_compressed.mat');
    %Genes_compressed = Stage1.Genes_compressed; 
    % This is the output of Stage 1, using this line will execute Stage 2
    
    if Stages > 2  
        cd ../Stage2
        if strcmp(lower(genesCompressed),'yes')==1
            Stage2 = load('Genes_compressed.mat');
            Genes_compressed = Stage1.Genes_compressed(Stage2.Genes_compressed);
        else
            Stage2 = load('Genes.mat');
            Genes = Stage1.Genes(Stage2.Genes);
        end
        %Stage2 = load('Genes_compressed.mat');
        %Genes_compressed = Stage1.Genes_compressed(Stage2.Genes_compressed); 
        % This is the output of Stage 2, using this line will execute Stage 3
    end

    if Stages > 3
        cd ../Stage3
        if strcmp(lower(genesCompressed),'yes')==1
            Stage3 = load('Genes_compressed.mat');
            Genes_compressed = Stage1.Genes_compressed(Stage2.Genes_compressed(Stage3.Genes_compressed));
        else
            Stage3 = load('Genes.mat');
            Genes = Stage1.Genes(Stage2.Genes(Stage3.Genes));
        end
        %Stage3 = load('Genes_compressed.mat');
        %Genes_compressed = Stage1.Genes_compressed(Stage2.Genes_compressed(Stage3.Genes_compressed)); 
        %This is the output of Stage 3, using this line will execute Stage 4 
    end
    
    if Stages > 4
        cd ../Stage4
        if strcmp(lower(genesCompressed),'yes')==1
            Stage4 = load('Genes_compressed.mat');
            Genes_compressed = Stage1.Genes_compressed(Stage2.Genes_compressed(Stage3.Genes_compressed(Stage4.Genes_compressed)));
        else
            Stage4 = load('Genes.mat');
            Genes = Stage1.Genes(Stage2.Genes(Stage3.Genes(Stage4.Genes)));
        end
        %This is the output of Stage 4, using this line will execute Stage 5 
    end
 
    if Stages > 5
        cd ../Stage5
        if strcmp(lower(genesCompressed),'yes')==1
            Stage5 = load('Genes_compressed.mat');
            Genes_compressed = Stage1.Genes_compressed(Stage2.Genes_compressed(Stage3.Genes_compressed(Stage4.Genes_compressed(Stage5.Genes_compressed))));
        else
            Stage5 = load('Genes.mat');
            Genes = Stage1.Genes(Stage2.Genes(Stage3.Genes(Stage4.Genes(Stage5.Genes))));
        end
        %This is the output of Stage 5, using this line will execute Stage 6 
    end
    
    cd ../../../
    
    if strcmp(lower(genesCompressed),'yes')==1
        dset.Xtrain = dset.Xtrain(Genes_compressed,:,:);
        dset.Xtest = dset.Xtest(Genes_compressed,:,:);
        dset.dim = length(Genes_compressed);
    else
        dset.Xtrain = dset.Xtrain(Genes,:,:);
        dset.Xtest = dset.Xtest(Genes,:,:);
        dset.dim = length(Genes);
    end
end

% for tsne exact algorithm, it is important to remove all zero rows
% if dset.dim < 5000
%     for j=1:size(dset.Xtrain,1)
%         q(j)=sum(dset.Xtrain(j,:));
%     end
%     r=(q~=0);
%     dset.Xtrain = dset.Xtrain(r,:);
%     dset.Xtest  = dset.Xtest(r,:);
% end

if Parm.Norm==0
    Out1 = Prepare_Data_norm(dset,1,Parm);
    Out1.Method = Parm.Method;
    Out1.Max_Px_Size = Parm.Max_Px_Size;
    Out1.SnowFall = Parm.SnowFall;
    if Parm.Augment==1
        Out1.orgYTrain = Out1.YTrain;
        Out1.orgYValidation = Out1.YValidation;
        [Out1.XTrain,Out1.YTrain] = augmentDeepInsight(Out1.XTrain,Out1.YTrain,Parm.aug_tr);
        [Out1.XValidation,Out1.YValidation] = augmentDeepInsight(Out1.XValidation,Out1.YValidation,Parm.aug_val);
    end
    A = Out1.A;
    B = Out1.B;
    C = Out1.C;
    save('Out1.mat','-struct','Out1','-v7.3');

    Out2 = Prepare_Data_norm(dset,2,Parm);
    Out2.Method = Parm.Method;
    Out2.Max_Px_Size = Parm.Max_Px_Size;
    Out2.SnowFall = Parm.SnowFall;
    if Parm.Augment==1
        Out2.orgYTrain = Out2.YTrain;
        Out2.orgYValidation = Out2.YValidation;
        [Out2.XTrain,Out2.YTrain] = augmentDeepInsight(Out2.XTrain,Out2.YTrain,Parm.aug_tr);
        [Out2.XValidation,Out2.YValidation] = augmentDeepInsight(Out2.XValidation,Out2.YValidation,Parm.aug_val);
    end
    A = Out2.A;
    B = Out2.B;
    C = Out2.C;
    save('Out2.mat','-struct','Out2','-v7.3');
elseif Parm.Norm==1
    Out1 = Prepare_Data_norm(dset,1,Parm);
    Out1.Method = Parm.Method;
    Out1.Max_Px_Size = Parm.Max_Px_Size;
    Out1.SnowFall = Parm.SnowFall;
    if Parm.Augment==1
        Out1.orgYTrain = Out1.YTrain;
        Out1.orgYValidation = Out1.YValidation;
        [Out1.XTrain,Out1.YTrain] = augmentDeepInsight(Out1.XTrain,Out1.YTrain,Parm.aug_tr);
        [Out1.XValidation,Out1.YValidation] = augmentDeepInsight(Out1.XValidation,Out1.YValidation,Parm.aug_val);
    end
    A = Out1.A;
    B = Out1.B;
    C = Out1.C;
    save('Out1.mat','-struct','Out1','-v7.3');
elseif Parm.Norm==2
    Out2 = Prepare_Data_norm(dset,2,Parm);
    Out2.Method = Parm.Method;
    Out2.Max_Px_Size = Parm.Max_Px_Size;
    Out2.SnowFall = Parm.SnowFall;
    if Parm.Augment==1
        Out2.orgYTrain = Out2.YTrain;
        Out2.orgYValidation = Out2.YValidation;
        [Out2.XTrain,Out2.YTrain] = augmentDeepInsight(Out2.XTrain,Out2.YTrain,Parm.aug_tr);
        [Out2.XValidation,Out2.YValidation] = augmentDeepInsight(Out2.XValidation,Out2.YValidation,Parm.aug_val);
    end
    A = Out2.A;
    B = Out2.B;
    C = Out2.C;
    save('Out2.mat','-struct','Out2','-v7.3');
end

