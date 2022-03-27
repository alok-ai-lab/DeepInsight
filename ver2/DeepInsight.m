function [Accuracy,ValErr,C,AUC] = DeepInsight(DSETnum)
%find classification accuracy and/or auc
close all;

Parm = Parameters(DSETnum); % define revelant paramters and dataset. Change as required in Parameters.m file.

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
[Accuracy(Parm.Stage),ValErr(Parm.Stage),Momentum(Parm.Stage),...
    L2Reg(Parm.Stage),InitLR(Parm.Stage),AUC(Parm.Stage),C,prob1] = func_TrainModel(Parm);

fprintf(fid2,'Net: %s\n',Parm.NetName);
fprintf(fid2,'ObjFcnMeasure: %s\n',Parm.ObjFcnMeasure);
fprintf('Stage: %d; Test Accuracy: %6.4f; ValErr: %4.4f; \n',Parm.Stage,Accuracy(Parm.Stage),ValErr(Parm.Stage));
fprintf('Momentum: %g; L2Regularization: %g; InitLearnRate: %g\n',Momentum(Parm.Stage),L2Reg(Parm.Stage),InitLR(Parm.Stage));
fprintf(fid2,'Stage: %d; Test Accuracy: %6.4f; ValErr: %4.4f; \n',Parm.Stage,Accuracy(Parm.Stage),ValErr(Parm.Stage));
fprintf(fid2,'Momentum: %g; L2Regularization: %g; InitLearnRate: %g\n',Momentum(Parm.Stage),L2Reg(Parm.Stage),InitLR(Parm.Stage));
display('Training model ends');
fprintf('\n');

% save models
if strcmp(lower(Parm.SaveModels),'y')==1
    func_SaveModels(Parm);
end
end
