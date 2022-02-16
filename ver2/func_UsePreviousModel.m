function [upm,Momentum,InitialLearnRate,L2Regularization] = func_UsePreviousModel(PromptOption)

%prompt = 'Do you want to use previous model parameters to avoid Bayesian Opt for CNN? Type Y for Yes and N for No.: ';
%PromptOption = input(prompt,'s');
if strcmp(lower(PromptOption),'y')==1
    upm = 1;
    model = load('model.mat')
    cd DeepResults
       net = load(model.fileName);
    cd ../
    Momentum = net.options.Momentum;
    InitialLearnRate = net.options.InitialLearnRate;
    L2Regularization = net.options.L2Regularization;
else
    upm = 0;
    Momentum=[];
    InitialLearnRate=[];
    L2Regularization=[];
end

end