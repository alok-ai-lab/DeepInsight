function Out = DeepInsight_train_norm_CAM(XTrain,YTrain,XValidation,YValidation,Parm)
% Out = DeepInsight_train_norm_CAM(XTrain,YTrain,XValidation,YValidation,Parm)

if nargin <5
    Parm.UsePreviousModel = 0;
end

if Parm.UsePreviousModel == 0
    % change parameters as desired
    if Parm.MaxObj>1   
        if Parm.ParallelNet==1
        optimVars = [
            optimizableVariable('InitialLearnRate',[1e-5 1e-1],'Transform','log')
            optimizableVariable('Momentum',[0.8 0.95])
            optimizableVariable('L2Regularization',[1e-10 1e-2],'Transform','log')
            optimizableVariable('filterSize',[2 6],'Type','integer')
            optimizableVariable('filterSize2',[4 12],'Type','integer')
            optimizableVariable('initialNumFilters',[2 4],'Type','integer')];
        else
        optimVars = [
            optimizableVariable('InitialLearnRate',[1e-5 1e-1],'Transform','log')
            optimizableVariable('Momentum',[0.8 0.95])
            optimizableVariable('L2Regularization',[1e-10 1e-2],'Transform','log')];
        end
    else
        optimVars = [
            optimizableVariable('InitialLearnRate',[Parm.InitialLearnRate Parm.InitialLearnRate+eps],'Transform','log')
            optimizableVariable('Momentum',[Parm.Momentum Parm.Momentum+eps])
            optimizableVariable('L2Regularization',[Parm.L2Regularization Parm.L2Regularization+eps],'Transform','log')];
    end
%     if strcmp(Parm.ObjFc,'accuracy')
%         ObjFcn = makeObjFcn_Squeezenet(XTrain,YTrain,XValidation,YValidation); % working-model
%     else
%         ObjFcn = makeObjFcn_Squeezenet_OthMes(XTrain,YTrain,XValidation,YValidation); % working-model
%     end
    if Parm.TransLearn==1
        ObjFcn = makeObjFcn_TransLearn(XTrain,YTrain,XValidation,YValidation,Parm);
    else
        if Parm.ParallelNet==1
            if Parm.MaxObj>1
                ObjFcn = makeObjFcn2(XTrain,YTrain,XValidation,YValidation,Parm);
            else
                ObjFcn = makeObjFcn2_MaxObj1(XTrain,YTrain,XValidation,YValidation,Parm);
            end
        else
        ObjFcn = makeObjFcn(XTrain,YTrain,XValidation,YValidation,Parm); % working-model
        end
    end

    current_dir=pwd;
    cd DeepResults
    BayesObject = bayesopt(ObjFcn,optimVars,...
        'MaxObj',Parm.MaxObj,...
        'MaxTime',Parm.MaxTime*60*60,...
        'IsObjectiveDeterministic',false,...    
        'UseParallel',false);
else
   
    optimVars = [
        optimizableVariable('InitialLearnRate',[Parm.InitialLearnRate Parm.InitialLearnRate+eps],'Transform','log')
        optimizableVariable('Momentum',[Parm.Momentum Parm.Momentum+eps])
        optimizableVariable('L2Regularization',[Parm.L2Regularization Parm.L2Regularization+eps],'Transform','log')];


    %ObjFcn = makeObjFcn_Squeezenet(XTrain,YTrain,XValidation,YValidation); % working-model
    if Parm.TransLearn==1
        ObjFcn = makeObjFcn_TransLearn(XTrain,YTrain,XValidation,YValidation,Parm);
    else
        if Parm.ParallelNet==1
            if Parm.MaxObj>1
                ObjFcn = makeObjFcn2(XTrain,YTrain,XValidation,YValidation,Parm);
            else
                ObjFcn = makeObjFcn2_MaxObj1(XTrain,YTrain,XValidation,YValidation,Parm);
            end
        else
        ObjFcn = makeObjFcn(XTrain,YTrain,XValidation,YValidation,Parm); % working-model
        end
    end

    current_dir=pwd;
    cd DeepResults
    BayesObject = bayesopt(ObjFcn,optimVars,...
        'MaxObj',Parm.MaxObj,...
        'MaxTime',Parm.MaxTime*60*60,...
        'IsObjectiveDeterministic',false,...    
        'UseParallel',false);
end


Out.bestIdx = BayesObject.IndexOfMinimumTrace(end);
Out.fileName = BayesObject.UserDataTrace{Out.bestIdx};
savedStruct = load(Out.fileName);
Out.valError = savedStruct.valError
cd(current_dir);

%[YPredicted,probs] = classify(savedStruct.trainedNet,XTest);
%testError = 1 - mean(YPredicted == YTest)
%Accuracy = 1-testError
