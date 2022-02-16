function layerName = activationLayerName(netName)

if netName == "squeezenet"
    layerName = 'relu_conv10';
elseif netName == "googlenet"
    layerName = 'inception_5b-output';
elseif netName == "resnet18"
    layerName = 'res5b_relu';
elseif netName == "mobilenetv2"
    layerName = 'out_relu';
elseif netName == "efficientnetb0" 
    layerName = 'efficientnet-b0|model|head|global_average_pooling2d|GlobAvgPool';
elseif netName == "efficientnet-b0"
    layerName = 'efficientnet-b0|model|head|global_average_pooling2d|GlobAvgPool';
elseif netName == "resnet50"
    layerName = 'activation_49_relu';
elseif netName == "resnet101"
    layerName = 'res5c_relu';
elseif netName == "nasnetlarge"
    layerName = 'activation_520';
elseif netName == "inceptionresnetv2"
    layerName = 'conv_7b_ac';
end
end
