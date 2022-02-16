function CAMshow(im,CAM)

imSize = size(im);
CAM = imresize(CAM,imSize(1:2));
CAM = normalizeImage(CAM);
CAM(CAM<0.2) = 0;
cmap = jet(255).*linspace(0,1,255)';
CAM = ind2rgb(uint8(CAM*255),cmap)*255;

combinedImage = double(rgb2gray(im))/2 + CAM;
combinedImage = normalizeImage(combinedImage)*255;
imshow(uint8(combinedImage));


%## Find which pixels are expressed #### (by Alok)
% H=combinedImage(:,:,1); %let it do for 'R' only
% R=H/255;
% [row,col]=ind2sub(size(R),find(R>Threshold));
% % if FIG==1
% %    figure; imshow(R);
% % end
% 
% IND=sub2ind(size(R),row,col);
% if FIG==1
%    B=ones(size(R));
%    B(IND)=R(IND);
%    figure; 
%    subplot(1,2,1); imshow(B);
%    title('Area by activation')
%    
%    C=uint8(ones(size(R))*255);
%    im2=im(:,:,1);
%    C(IND)=im2(IND);
%    subplot(1,2,2); imshow(C)
%    title('Genes selected')
% end

%##################################################
end