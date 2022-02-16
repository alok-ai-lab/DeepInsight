clear all;
close all;

%Prepare_Data with DeepInsight
%
%Description of Datasets
% 1. dataset1.mat is RNA-seq (1.5GB)
% 2. dataset2.mat is ringnorm-DELVE (560KB)
% 3. dataset3.mat is vowels (3.6MB)
% 4. dataset4.mat is Madelon (2.1MB)
% 5. dataset5.mat is Relathe (696KB)

%Parm.fid=fopen('Results.txt','a+');
Parm.Method = ['tSNE']; % 1) tSNE 2) kpca or 3) pca 4) umap
%Parm.Dist = 'euclidean'; % For tSNE only 1) Mahalanobis 2) cosine 3) euclidean 4) chebychev (default: cosine)
Parm.Max_Px_Size = 227;%inf;%227 for SqueezeNet
Parm.MPS_Fix=1;
%Parm.MPS_Fix = 1; % if this val is 1 then screen will be 
                  % Max_Px_Size x Max_Px_Size (e.g. 120x120), otherwise 
                  % automatically decided by the distribution of the input data.
                  
Parm.ValidRatio = 0.1; % ratio of validation data/Training data
Parm.Seed = 108; % random seed to distribute training and validation sets
Parm.Norm = 2; % Select '1' for Norm-1, '2' for Norm-2 and '0' for automatically select the best Norm (either 1 or 2).
Parm.Stage = 2; % '1', '2', '3', '4', '5' depending upon which stage of DeepInsight-FS to run.
Parm.FileRun = 'Run18'; % where previous results are stored. If no results are stored then used 'Run1'

Parm.SnowFall = 1; % Put 1 if you want to use SnowFall compression algorithm
if Parm.SnowFall==1
    Parm.MPS_Fix=0;
    Parm.Max_Px_Size = inf; 
    Parm.SnowFall_A = 227;%Parm.Max_Px_Size;
    Parm.SnowFall_B = 227;%Parm.Max_Px_Size;
end


for j=1:1%1:3 %1:5

current_dir=pwd;
cd ~/data/Data_DeepInsight/Data
load(['dataset',num2str(j),'.mat']);
cd(current_dir);
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
    else
        Stage1 = load('Genes.mat');
        Genes = Stage1.Genes;
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
    cd ../../../
    
    if strcmp(lower(genesCompressed),'yes')==1
        dset.Xtrain = dset.Xtrain(Genes_compressed,:);
        dset.Xtest = dset.Xtest(Genes_compressed,:);
        dset.dim = length(Genes_compressed);
    else
        dset.Xtrain = dset.Xtrain(Genes,:);
        dset.Xtest = dset.Xtest(Genes,:);
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
    save('Out1.mat','-struct','Out1','-v7.3');

    Out2 = Prepare_Data_norm(dset,2,Parm);
    Out2.Method = Parm.Method;
    Out2.Max_Px_Size = Parm.Max_Px_Size;
    Out2.SnowFall = Parm.SnowFall;
    save('Out2.mat','-struct','Out2','-v7.3');
elseif Parm.Norm==1
    Out1 = Prepare_Data_norm(dset,1,Parm);
    Out1.Method = Parm.Method;
    Out1.Max_Px_Size = Parm.Max_Px_Size;
    Out1.SnowFall = Parm.SnowFall;
    save('Out1.mat','-struct','Out1','-v7.3');
elseif Parm.Norm==2
    Out2 = Prepare_Data_norm(dset,2,Parm);
    Out2.Method = Parm.Method;
    Out2.Max_Px_Size = Parm.Max_Px_Size;
    Out2.SnowFall = Parm.SnowFall;
    save('Out2.mat','-struct','Out2','-v7.3');
end

