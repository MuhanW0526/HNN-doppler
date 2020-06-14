function fltOutput=cnnCS(images, CLayer)

numImages=size(images, 4);
numFilter=size(images, 3);
fltOutput=zeros(CLayer.OutDim(1), CLayer.OutDim(2), numFilter, numImages);

for inum=1:numImages
    for iflt=1:numFilter
        image=images(:, :, iflt, inum);
        CSImage=CLayer.A*image(:);
        fltOutput(:, 1, iflt, inum)=CSImage;
    end
end