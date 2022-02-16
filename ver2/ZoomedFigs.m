%obsolete
%Zoomed figures
%Run after FeatureSelection_CAM.m

for class=1:10
    n = (double(Data.YTrain)==class);
    [n,Sample]=max(n);
    Sample
Tr=Data.XTrain(:,:,1,Sample);
B=uint8(ones(size(Tr))*255);
B(IND)=Tr(IND);
figure; 
%imshow(B);
imagesc(B);
xlim([115 145]);
ylim([175 195]);
colormap pink
title(['Genes selected for all Training data: class ',num2str(class)]);

cd ~/Dropbox/Public/FIGS/DeepInsight_CAM_FS/Run2/Stage3/Genes_All_Training_10classes_ZOOMED/
saveas(gcf,['Zoomed_Genes_Class',num2str(class),'.fig']);
cd ~/MatWorks/Unsup/DeepInsight_CAM_FS/
close(gcf);
end
