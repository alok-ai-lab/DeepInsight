# DeepInsight Version 2

## Whats added?
1) DeepInsight.m is the main function file.

2) Several pretrained CNN nets such as ResNet, InceptionResNetV2, EfficientNetB0 etc can be used by changing option Parm.NetName in DeepInsight.m file.

3) Use of Bayesian Optimization Technique (BOT) to tune hyperparameters can be used just by changing Parm.MaxObj paramter in DeepInsight.m function. If Parm.MaxObj=1 then NO BOT will be used; i.e. CNN net will be executed using Parm.Momentum, Parm.InitialLearnRate and Parm.L2Regularization parameters.

4) Several distances of t-SNE can be used by changing Parm.Dist parameter such as 'euclidean', 'hamming', chebychev' etc.

5) Previously only 1D layer (grayscale) was used. In this version, 3D layers or color images can be used.
 

## Details:
1) Run_Alldatasets.m is the main program to execute DeepInsight algorithm.

2) DeepInsight.m is the main function of Run_Alldatasets.m

2) Demo dataset is provided to verify the code.

3) MaxTime is the maximum training time for the DeepInsight algorithm, which is currently set as 24 hours per norm (note 2 norms are used, so maxim training time is 48 hours). The MaxTime is set in DeepInsight_train_norm.m code at Line 132. Please reduce this time to verify the algorithm. If you prefer 2 hours then set MaxTime as 2\*60\*60 at Line 132.

4) Change the Convolutional Neural Network (CNN) architecture as desired.

5) The MaxEpochs is set to 100 in makeObjFcn.m for Bayesian Optimization. If you set as 1 then NO BOT will be used. This will improve the processing time of training.

## Reference
Sharma, A., Vans, E., Shigemizu, D. *et al.* DeepInsight: A methodology to transform a non-image data to an image for convolution neural network architecture. *Sci Rep* **9**, 11399 (2019). https://doi.org/10.1038/s41598-019-47765-6


