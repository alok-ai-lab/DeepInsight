# DeepInsight Version 2
This repository contains the updated version of the original MatLab code for DeepInsight.

Download <i>DeepInsight_Ver2.tar.gz or DeepInsight_Ver2</i> folder.

## Whats added?
1)	Ease of using DeepInsight with proper handling of parameters through the function Parameters.m

2)	Several pretrained CNN nets can be used such as ResNet, GoogleNet, EfficientNetB0 etc. simply by changing the option Parm.NetName in the file DeepInsight.m. Custom made nets can be used by changing Parm.ParalleNet=1. At present parallel net used in the original DeepInsight work has been used. However, modify the functions ‘makeObjFcn2.m’ and ‘makeObjFc2_MaxObj1.m’ as per your new design.

3)	Use of Bayesian optimization technique (BOT) to tune hyperparameters can be made by changing Parm.MaxObj. If Parm.MaxObj=1 then NO BOT will be used; i.e., CNN net will be trained by using predefined hyperparameters in Parameters.m file.

4)	Several distances of t-SNE can be used by changing Parm.Dist parameter such as ‘euclidean’, ‘hamming’, ‘chebychev’, ‘cosine’, ‘correlation’ and ‘mahalanobis’. Other than t-SNE, the following functions can also be used ‘umap’, kernel PCA (kpca) and ‘pca’.

5)	Previously only 1D layer (grapscale) was used. In this updated version, 3D layers or color images can be used.

## Important functions
1)	<i>Parameters.m</i> to define all the relevant parameters and dataset for DeepInsight and CNN net.

2)	<i>DeepInsight.m</i> performs conversion of non-image to image, train the CNN net, and then evaluates the model using the test set of data.

3)	<i>Main.m</i> is the main function to execute DeepInsight.m

4)	Demo data is available at "/DeepInsight_Ver2/Data"


## Example Run 
## A)	Run using Bayesian Optimization technique.

Setup a dataset and initial parameters

1)	Check the example data structure in /DeepInsight_Ver2/Data/dataset1.mat. The structure of dataset1.mat is:

  <p><i>

	Xtrain:		[13494 x 689 double]
  
  	num_tr:		[361 328]
  
  	Xtest:		[13494 x 80 double]
  
  	num_tst:	[40 40]
  
  	class:		2
  
  	dim:		13494
  
	Set:		‘PDX_Pcalitaxel’
</i></p>
  

<i>‘Xtrain’</i> is the training set where 13494 rows are the number of features or dimensions with 689 samples.

<i>‘num_tr’</i> is the number of training samples per class; i.e, 361 samples in class 1 and 328 samples in class 2. In total 361+328=689. Note all the 361 samples in ‘Xtrain’ should belong to ‘class 1’, and the next 328 samples should belong to ‘class 2’. When you create your own data, please make sure to put the samples in this order.

<i>‘Xtest’</i> is the test set. Here, 80 samples are used.

<i>‘num_tst’</i> is the number of samples per class. Here first 40 samples belong to ‘class 1’ and next ‘40’ samples belong to ‘class 2’.

<i>‘class’</i> is the number of classes of the dataset. Here it is 2.

<i>‘Set’</i> is the name of the dataset. In this example, it is ‘PDX_Paclitaxel’ drug data.

Save your new datasets in the above structure format and give name as ‘dataset2.mat’, ‘dataset3.mat’ and so on. You can test multiple datasets in one run by changing Line 5 of Main.m. Currently, it is set as “for j=1:1”. If you have 5 datasets stored in "/Data" folder then simply change Line 5 as “for j=1:5”.

2)	Open Parameters.m function. Change Parm.MaxObj =2 (Line 21). This would allow 2 objective functions to be created. For better performance with BOT, higher value of Parm.MaxObj is desirable.

3)	Default CNN net (Line 41 of Parameters.m) is Parm.NetName = ‘resnet50’. However, change as required.

4)	Check maximum epochs at Line 52 of Parameters.m, Parm.MaxEpochs = 100. You may reduce to ‘2’ for faster training time.

5)	According to your GPU capacity, change miniBatchSize at Line 55, Parm.miniBatchSize=256. If memory issues are coming then reduce it to ‘128’ or ‘64’ or ‘32’ or ‘16’ or ‘8’.

6)	Line 58 of Parameters.m defines the strategy of feature mapping. Default is Parm.FeatureMap=1; i.e., if 3 layers of data is used (e.g. expression, methylation, and mutation) then the first layer (expression) of data will be used to find pixel coordinates. If you want all the layers to contribute equally in finding the pixel coordinates then use Parm.FeatureMap=0. However, in this example, only 1 layer is available so this parameter will not be used.

7)	Line 62 of Parameters.m defines transfer learning. If you want to use your pretrained DAGnet to train the new model then use Parm.TransLearn=1 and save your DAGnet, named as ‘model.mat’ file, in the folder "/DeepInsight_Ver2/Models/Run32/Stage1/". Alternatively, modify Lines 76-84 to suit your model. For example, run transfer learning option has not been used.

8)	Default Norm is ‘2’ (please see DeepInsight paper for details). Other parameters are given and illustrated in Parameters.m file. However, please change as required.

## Running DeepInsight Ver2

1.	Open and Run <i>Main.m</i> file.
 
2.	To view pixel framework with rotations made, open "FIGS/pixel_frame.jpg" file. 

   (in Ubuntu terminal)
   
	eog FIGS/pixel_frame.jpg 
   ![alt text](https://github.com/alok-ai-lab/DeepInsight/blob/master/ver2/FIGS/pixel_frame.jpg?raw=true)	

3.	The mapped data is saved as Out2.mat (since Norm ‘2’ was used, if Norm ‘1’ is used then output file would be Out1.mat).

4.	To see the mapped tabular data on the pixel frame, load the output file.

   		dset=load(‘Out2.mat’);

5.	Take any two samples belong to different classes for plotting.


		figure; subplot(1,2,1), imagesc(dset.XTrain(:,:,1,11)); title(‘Class 1, Sample 11’);
		subplot(1,2,2), imagesc(dset.XTrain(:,:,1,612)); title(‘Class 2, Sample 612’);
		colormap pink 
 	![alt text](https://github.com/alok-ai-lab/DeepInsight/blob/master/ver2/FIGS/Sample_Comparison.jpg?raw=true)

	Zoom some parts to see the difference between samples of different classes.

		 subplot(1,2,1), axis([45 75 115 140]);
		 subplot(1,2,2), axis([45 75 115 140]);
 	![alt text](https://github.com/alok-ai-lab/DeepInsight/blob/master/ver2/FIGS/Sample_Comparison_Zoomed.jpg?raw=true)

6.	Results of the run is stored in file "/DeepInsight_Ver2/DeepInsight_Results.txt" and the model is stored in "/DeepInsight_Ver2/DeepResults/<*.mat>". The model file can be called by loading “model.mat” file in DeepInsight_Ver2 folder (it over writes the previous file). 

   		cat DeepInsight_Results.txt

   		Run1
   		…..
   		Method: tsne
   		Distance: hamming
   		…..
   		Input Size 1 x Input Size 2 x Input Size 3: 224 x 224 x 1
   		Dataset: PDX_Paclitaxel
   		Net: resnet50
   		…..
   		… Test Accuracy: 0.9875; ValErr: 0.0145
   		…….

## B) Run without Bayesian Optimization Technique
1. Open Parameters.m file and goto Line 21. Change Parm.MaxObj=1.

2. Define hyperparamters: InitialLearnRate, Momentum and L2Regularization parameters (Line 31 - Line 33).

3. Run Main.m. If you want to view training progress of CNN then go to makeObjFcn*.m file and change 'Plots','none' to 'Plots','training-progress'.

## Reference
Sharma, A., Vans, E., Shigemizu, D. *et al.* DeepInsight: A methodology to transform a non-image data to an image for convolution neural network architecture. *Sci Rep* **9**, 11399 (2019). https://doi.org/10.1038/s41598-019-47765-6


