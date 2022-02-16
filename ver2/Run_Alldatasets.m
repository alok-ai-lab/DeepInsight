close all
clear all

for j=1:1
    fprintf('\n dataset %d\n',j);
    [Accuracy(j),ValErr(j),C{j},AUC(j)] = DeepInsight(j);
end
