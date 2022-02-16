function IND = CAMind(im,CAM,Threshold,Dmat,FIG)

if nargin <3
    Threshold=0.5;
    Dmat = 'R';
    FIG=0;
elseif nargin <4
    Dmat = 'R';
    FIG=0;
elseif nargin <5
    FIG=0;
end

imSize = size(im);
CAM = imresize(CAM,imSize(1:2));
CAM = normalizeImage(CAM);
CAM(CAM<0.2) = 0;
cmap = jet(255).*linspace(0,1,255)';
CAM = ind2rgb(uint8(CAM*255),cmap)*255;

combinedImage = double(rgb2gray(im))/2 + CAM;
combinedImage = normalizeImage(combinedImage)*255;


if strcmp('r',lower(Dmat))==1
    H=combinedImage(:,:,1); %let it do for 'R' or Red
    DmatStr='Red';
elseif strcmp('g',lower(Dmat))==1
    H=combinedImage(:,:,2); %let it do for 'G' or Green
    DmatStr='Green';
elseif strcmp('b',lower(Dmat))==1
    H=combinedImage(:,:,3); %let it do for 'B' or Blue
    DmatStr='Blue';
else
    disp('Error: 2Dmat not defined, use string R, G or B');
end
%## Find which pixels are expressed #### (by Alok)
% H=combinedImage(:,:,1); %let it do for 'R' only
R=H/255;
[row,col]=ind2sub(size(R),find(R>Threshold));
if FIG==1
   figure; imshow(R);
   title(['2D matrix used is ',DmatStr]);
end

IND=sub2ind(size(R),row,col);
if FIG==1
   B=ones(size(R));
   B(IND)=R(IND);
   figure; 
   subplot(1,2,1); imshow(B);
   title('Area by activation')
   
   C=uint8(ones(size(R))*255);
   im2=im(:,:,1);
   C(IND)=im2(IND);
   subplot(1,2,2); imshow(C)
   title('Genes selected')
end

%##################################################
end