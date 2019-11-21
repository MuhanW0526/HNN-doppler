function [acc, e]=cnnTestData(cnn, VX, VY, numImages)
% Validate CNN Accuracy
%   VData: validation data, [x-dim, y-dim, channel-num, data-count]
%   VLabel: validation label, [1, data-count]
%   numImages: number of images that want to validate

images=gpuArray(single(VX(:, :, :, 1:numImages)));
mb_labels=gpuArray(VY(:, 1:numImages));

% if to.PCAflag==1
%             for iLayer=1:cnn.LNum
%                 if cnn.Layers{iLayer}.type==9
%                     fltLayer=iLayer;
%                     break;
%                 end
%             end
%             OptData=cnnFilter(images, cnn.Layers{fltLayer});
%         else
%             OptData=[];
%         end

cnn=cnnFeedForward(cnn, images);
[~, preds]=max(cnn.OutData{cnn.LNum}, [], 1);
e=(preds==mb_labels);
acc=gather(sum(preds==mb_labels)/numImages);