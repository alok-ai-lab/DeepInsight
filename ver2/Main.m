close all
clear all

% Eg. with dataset1.mat
for j=1:1
    fprintf('\n dataset %d\n',j);
    [Accuracy(j),ValErr(j),C{j},AUC(j)] = DeepInsight(j);
end
