function Out = Prepare_Data_norm(dset,NORM,Parm)
% Out = Prepare_Data_norm(dset,NORM,Parm)

if exist('Parm')==0
   Parm.Method = ['tSNE']; % other methods 2) kpca or 3) pca 
   Parm.Max_Px_Size = 227;
   Parm.MPS_Fix = 1; % if this val is 1 then screen will be Max_Px_Size x Max_Px_Size (eg 120x120 )
                     % otherwise automatically decided by the distribution
                     % of the input data.
   Parm.ValidRatio = 0.1; % 0.1 of Train data will be used as Validation data
   Parm.Seed = 108; %random seed
   Parm.SnowFall_A = Parm.Max_Px_Size;
   Parm.SnowFall_B = Parm.Max_Px_Size;
   Parm.SnowFall = 1;
end 

%Take data on "as is" basis; i.e., no change in Train and Test data
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
dset.XValidation = dset.Xtrain(:,idx,:);
dset.Xtrain(:,idx,:) = [];
Out.YValidation = Out.YTrain(idx);
Out.YTrain(idx) = [];
for j=1:dset.class
    dset.num_tr(j)=sum(double(Out.YTrain)==j);
    dset.num_val(j)=sum(double(Out.YValidation)==j);
end


switch NORM
    case 1
        % Norm-3 in org code
        Out.Norm=1;
    %fprintf(Parm.fid,'\nNORM-1\n');
    fprintf('\nNORM-1\n');
    %########### Norm-1 ###################
    for dsz=1:size(dset.Xtrain,3)
        Out.Max=max(dset.Xtrain(:,:,dsz)')';
        Out.Min=min(dset.Xtrain(:,:,dsz)')';
        dset.Xtrain(:,:,dsz)=(dset.Xtrain(:,:,dsz)-Out.Min)./(Out.Max-Out.Min);
        dset.XValidation(:,:,dsz) = (dset.XValidation(:,:,dsz)-Out.Min)./(Out.Max-Out.Min);
        dset.Xtest(:,:,dsz) = (dset.Xtest(:,:,dsz)-Out.Min)./(Out.Max-Out.Min);
    end
    dset.Xtrain(isnan(dset.Xtrain))=0;
    dset.Xtest(isnan(dset.Xtest))=0;
    dset.XValidation(isnan(dset.XValidation))=0;
    dset.XValidation(dset.XValidation>1)=1;
    dset.XValidation(dset.XValidation<0)=0;
    dset.Xtest(dset.Xtest>1)=1;
    dset.Xtest(dset.Xtest<0)=0;
    %######################################
   
    
    case 2
        % norm-6 in org ocde
        Out.Norm=2;
    %fprintf(Parm.fid,'\nNORM-2\n');
    fprintf('\nNORM-2\n');
    %########### Norm-2 ###################
    for dsz=1:size(dset.Xtrain,3)
        Out.Min=min(dset.Xtrain(:,:,dsz)')';
        dset.Xtrain(:,:,dsz)=log(dset.Xtrain(:,:,dsz)+abs(Out.Min)+1);
    
        indV = dset.XValidation(:,:,dsz)<Out.Min;
        indT = dset.Xtest(:,:,dsz)<Out.Min;
        for j=1:size(dset.Xtrain,1)
            dset.XValidation(j,indV(j,:),dsz)=Out.Min(j); 
            dset.Xtest(j,indT(j,:),dsz)=Out.Min(j);
        end
  
        dset.XValidation(:,:,dsz) = log(dset.XValidation(:,:,dsz)+abs(Out.Min)+1);
        dset.Xtest(:,:,dsz)=log(dset.Xtest(:,:,dsz)+abs(Out.Min)+1);
        Out.Max=max(max(dset.Xtrain(:,:,dsz)));
        dset.Xtrain(:,:,dsz)=dset.Xtrain(:,:,dsz)/Out.Max;
        dset.XValidation(:,:,dsz) = dset.XValidation(:,:,dsz)/Out.Max;
        dset.Xtest(:,:,dsz) = dset.Xtest(:,:,dsz)/Out.Max;
    end
    dset.XValidation(dset.XValidation>1)=1;
    dset.Xtest(dset.Xtest>1)=1;
    %######################################
end


Q.Method = Parm.Method;%['tSNE'];
Q.Max_Px_Size = Parm.Max_Px_Size;%120;
Q.SnowFall = Parm.SnowFall;
if any(strcmp('Dist',fieldnames(Parm)))==1
    Q.Dist=Parm.Dist;
end
if Q.SnowFall==1
    Q.SnowFall_A = Parm.SnowFall_A;
    Q.SnowFall_B = Parm.SnowFall_B;
end
Q.z=1; % if Q.z=1 then z values will be output and snow-fall will not be used.
if Parm.FeatureMap==0
    disp('multi-omics data used for Cart2Pixel');
for dsz=1:size(dset.Xtrain,3)
    Q.data = dset.Xtrain(:,:,dsz);
%     if dsz==3
%         Q.data = Q.data+eps;
%     end
% if Q.z==0
%     if Parm.MPS_Fix==1
%         [Out.XTrain,Out.xp,Out.yp,Out.A,Out.B,Out.Base] = Cart2Pixel(Q,Q.Max_Px_Size,Q.Max_Px_Size);
%     else
%         [Out.XTrain,Out.xp,Out.yp,Out.A,Out.B,Out.Base] = Cart2Pixel(Q);
%     end
% else
    if Parm.MPS_Fix==1
        [Out.z{dsz}] = Cart2Pixel(Q,Q.Max_Px_Size,Q.Max_Px_Size);
    else
        [Out.z{dsz}] = Cart2Pixel(Q);
    end
    Out.z{dsz} = (Out.z{dsz} - min(min(Out.z{dsz})))/(max(max(Out.z{dsz}))-min(min(Out.z{dsz})));
end
Out.z = cell2mat(Out.z);
Q.data = Out.z;
Out = rmfield(Out,'z');
end

Q.z=0;
if Parm.FeatureMap>0
    switch Parm.FeatureMap
        case 1
            disp('Expression data used for Cart2Pixel');
        case 2
            disp('Methylation data used for Cart2Pixel');
        case 3
            disp('Mutation data used for Cart2Pixel');
    end
    Q.data = dset.Xtrain(:,:,Parm.FeatureMap); 
end
if Parm.MPS_Fix==1
    [tmp,Out.xp,Out.yp,Out.A,Out.B,Out.Base] = Cart2Pixel(Q,Q.Max_Px_Size,Q.Max_Px_Size);
else
    [tmp,Out.xp,Out.yp,Out.A,Out.B,Out.Base] = Cart2Pixel(Q);
end

fprintf('\n Pixels: %d x %d\n',Out.A,Out.B);
clear Q

for dsz = 1:size(dset.Xtrain,3)
    for j=1:length(Out.YTrain)
        Out.XTrain(:,:,dsz,j) = ConvPixel(dset.Xtrain(:,j,dsz),Out.xp,Out.yp,Out.A,Out.B,Out.Base,0);
    end
end
dset.Xtrain=[];

close all;
for dsz = 1:size(dset.Xtest,3)
    for j=1:length(Out.YTest)
        Out.XTest(:,:,dsz,j) = ConvPixel(dset.Xtest(:,j,dsz),Out.xp,Out.yp,Out.A,Out.B,Out.Base,0);
    end
end
dset.Xtest=[];

for dsz=1:size(dset.XValidation,3)
    for j=1:length(Out.YValidation)
        Out.XValidation(:,:,dsz,j) = ConvPixel(dset.XValidation(:,j,dsz),Out.xp,Out.yp,Out.A,Out.B,Out.Base,0);
    end
end
dset.XValidation=[];
Out.C = size(Out.XTrain,3);
% for j=1:length(Out.YTrain)
%     Out.XTrain(:,:,1,j) = Out.M{j};
% end
% clear M X Y
%Out = rmfield(Out,'M');

% Out.XTrain = uint8(mat2gray(Out.XTrain)*255);
% Out.XValidation = uint8(mat2gray(Out.XValidation)*255);
% Out.XTest = uint8(mat2gray(Out.XTest)*255);

end

