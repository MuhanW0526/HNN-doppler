function out = cnnTransform_GPU(images, CLayer)

    switch CLayer.TName
        case {'FFT', 'fft'}
            out = fft(fft(images, [], 1), [], 2);
        case {'DWT', 'dwt'}
            numImage = size(images, 4);
            numFilter = size(images, 3);
            out_ = gpuArray.zeros(CLayer.OutDim(1), CLayer.OutDim(2), numFilter, 4, numImage, 'single');

            parfor inum = 1:numImage
                for iflt = 1:numFilter
                    wOut = gpuArray.zeros(CLayer.OutDim(1), CLayer.OutDim(2), 4, 'single');
                    [wOut(:, :, 1), wOut(:, :, 2), wOut(:, :, 3), wOut(:, :, 4)] = dwt2(images(:, :, iflt, inum));
                    out_(:, :, iflt, :, inum) = wOut;
                    % out_(:, :, (iflt - 1) * 4 + 2, inum) = LH;
                    % out_(:, :, (iflt - 1) * 4 + 3, inum) = HL;
                    % out_(:, :, (iflt - 1) * 4 + 4, inum) = HH;
                end
            end

            out = reshape(out_, CLayer.OutDim(1), CLayer.OutDim(2), numFilter * 4, numImage);
        case {'PCA', 'pca'}
            numImage = size(images, 4);
            numFilter = size(images, 3);
            % out=gpuArray.zeros(size(images), 'single');
            out_ = zeros(size(images), 'single');
            images_ = gather(images);

            parfor inum = 1:numImage
                for iflt = 1:numFilter
                    [U, S, V] = svd(images_(:, :, iflt, inum));
                    U = U(:, CLayer.PCADim);
                    S = S(CLayer.PCADim, :);
                    PCAImage = U * S * V';
                    out_(:, :, iflt, inum) = single(PCAImage);
                end
            end

            out = gpuArray(out_);
        case {'ABS', 'abs'}
            out = abs(images);
        case {'ARG', 'arg'}
            out = angle(images);
        case {'REAL', 'real'}
            out = real(images);
        case {'IMAG', 'imag'}
            out = imag(images);
        case {'MAXPOOL', 'maxpool'}
            CLayer.poolMethod = 'max';
            [~, out] = cnnPool_GPU(CLayer, images);
        case {'MEANPOOL', 'meanpool'}
            CLayer.poolMethod = 'mean';
            [~, out] = cnnPool_GPU(CLayer, images);
        case {'LOWPASS', 'lowpass'}
        case {'HIGHPASS', 'highpass'}
        otherwise
            error('Unknown Transformation Type!');
    end

end