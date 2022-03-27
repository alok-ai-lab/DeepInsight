function [Genes,Genes_compressed,G]= func_SaveModels(Parm)

% Feature selection of DeepInsight-FS

model = load('model.mat')
netName = Parm.NetName;
cd DeepResults
net = load(model.fileName);
cd ../


FileRun = Parm.FileRun;
Stages = Parm.Stage;
Ask = Parm.SaveModels;

if strcmp(Parm.PATH{1}(end),'/')==0
    Parm.PATH{1} = [Parm.PATH{1},'/'];
end
if strcmp(Parm.PATH{2}(end),'/')==0
    Parm.PATH{2} = [Parm.PATH{2},'/'];
end

inputSize = net.trainedNet.Layers(1).InputSize(1:2);
classes = net.trainedNet.Layers(end).Classes;
layerName = activationLayerName(netName);

if model.Norm==1
    Data = load('Out1.mat');
else
    Data = load('Out2.mat');
end
if Parm.Augment==1
    Data.YTrain = Data.orgYTrain;
end

if strcmp(lower(Ask),'y')==1
    Directory = [Parm.PATH{2},FileRun,'/Stage',num2str(Stages),'/'];
    if isfolder(Directory(1:end-8))==0
        unix(['mkdir ',Directory(1:end-8)]);
    end
    if isfolder(Directory)==0
        unix(['mkdir ',Directory(1:end-1)]);
    end
    if model.Norm==1
        unix(['cp Out1.mat ',Directory]);
    else
        unix(['cp Out2.mat ',Directory]);
    end
    unix(['cp model.mat ',Directory]);
    unix(['cp DeepResults/',num2str(model.fileName),' ',Directory]);
    disp('Files Saved...');
end
