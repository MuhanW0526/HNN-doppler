function [DeltaKa, DeltaKr]=cnnDeconvolveRadar(RLayer, Delta, images)

numImages=size(images, 4);
if RLayer.useGPU==1
    DeltaKa=single(gpuArray.zeros(RLayer.OutDim(1), RLayer.OutDim(2), numImages));
    DeltaKr=single(gpuArray.zeros(RLayer.OutDim(1), RLayer.OutDim(2), numImages));

    HFSize=floor((RLayer.FDim-1)/2);
    Theta=single(pi)*RLayer.Ka*(([-HFSize:HFSize].'/RLayer.PRF).^2*single(gpuArray.ones(1, RLayer.FDim(1))))-single(pi)*RLayer.Kr*(single(gpuArray.ones(RLayer.FDim(2),1))*single(pi)*RLayer.Kr*(([-HFSize:HFSize]/RLayer.Fsr).^2));
    FKaSinsingle(pi)*([-HFSize:HFSize].'/RLayer.PRF).^2*single(gpuArray.ones(1, RLayer.FDim(1))).*sin(Theta);
    FKaCos=single(pi)*([-HFSize:HFSize].'/RLayer.PRF).^2*single(gpuArray.ones(1, RLayer.FDim(1))).*cos(Theta);
    FKrSin=single(gpuArray.ones(RLayer.FDim(2),1))*single(pi)*(([-HFSize:HFSize]/RLayer.Fsr).^2).*sin(Theta);
    FKrCos=single(gpuArray.ones(RLayer.FDim(2),1))*single(pi)*(([-HFSize:HFSize]/RLayer.Fsr).^2).*cos(Theta);
    parfor i_im=1:numImages
        r_image=rot90(gpuArray(squeeze(single(real(images(:, :, i_im))))), 2);
        i_image=rot90(gpuArray(squeeze(single(imag(images(:, :, i_im))))), 2);
        DeltaKa(:, :, i_im)=squeeze(real(Delta(:, :, :, i_im))).*(conv2(r_image, FKaSin, 'valid')+conv2(i_image, FKaCos, 'valid'))+squeeze(imag(Delta(:, :, :, i_im))).*(conv2(i_image, FKaSin, 'valid')-conv2(r_image, FKaCos, 'valid'));
        DeltaKr(:, :, i_im)=squeeze(real(Delta(:, :, :, i_im))).*(-conv2(r_image, FKrSin, 'valid')-conv2(i_image, FKrCos, 'valid'))+squeeze(imag(Delta(:, :, :, i_im))).*(-conv2(i_image, FKrSin, 'valid')+conv2(r_image, FKrCos, 'valid'));  
    end
else
    DeltaKa=single(zeros(RLayer.OutDim(1), RLayer.OutDim(2), numImages));
    DeltaKr=single(zeros(RLayer.OutDim(1), RLayer.OutDim(2), numImages));

    HFSize=floor((RLayer.FDim-1)/2);
    Theta=single(pi)*RLayer.Ka*(([-HFSize:HFSize].'/RLayer.PRF).^2*single(ones(1, RLayer.FDim(1))))-single(pi)*RLayer.Kr*(single(ones(RLayer.FDim(2),1))*single(pi)*RLayer.Kr*(([-HFSize:HFSize]/RLayer.Fsr).^2));
    FKaSinsingle(pi)*([-HFSize:HFSize].'/RLayer.PRF).^2*single(ones(1, RLayer.FDim(1))).*sin(Theta);
    FKaCos=single(pi)*([-HFSize:HFSize].'/RLayer.PRF).^2*single(ones(1, RLayer.FDim(1))).*cos(Theta);
    FKrSin=single(ones(RLayer.FDim(2),1))*single(pi)*(([-HFSize:HFSize]/RLayer.Fsr).^2).*sin(Theta);
    FKrCos=single(ones(RLayer.FDim(2),1))*single(pi)*(([-HFSize:HFSize]/RLayer.Fsr).^2).*cos(Theta);
    parfor i_im=1:numImages
        r_image=rot90(squeeze(single(real(images(:, :, i_im)))), 2);
        i_image=rot90(squeeze(single(imag(images(:, :, i_im)))), 2);
        DeltaKa(:, :, i_im)=squeeze(real(Delta(:, :, :, i_im))).*(conv2(r_image, FKaSin, 'valid')+conv2(i_image, FKaCos, 'valid'))+squeeze(imag(Delta(:, :, :, i_im))).*(conv2(i_image, FKaSin, 'valid')-conv2(r_image, FKaCos, 'valid'));
        DeltaKr(:, :, i_im)=squeeze(real(Delta(:, :, :, i_im))).*(-conv2(r_image, FKrSin, 'valid')-conv2(i_image, FKrCos, 'valid'))+squeeze(imag(Delta(:, :, :, i_im))).*(-conv2(i_image, FKrSin, 'valid')+conv2(r_image, FKrCos, 'valid'));  
    end
end