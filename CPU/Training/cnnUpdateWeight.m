function cnn = cnnUpdateWeight(cnn)

    for iLayer = 1:cnn.LNum

        switch cnn.Layers{iLayer}.type
            case 3
                % Fully Connected Layer
                cnn.W_grad{iLayer} = cnn.Delta{iLayer + 1} * cnn.OutData{iLayer - 1}';
                cnn.B_grad{iLayer} = sum(cnn.Delta{iLayer + 1}, 2);
                cnn.dW{iLayer} = cnn.to.mom * cnn.dW{iLayer} + cnn.to.alpha * cnn.W_grad{iLayer} / cnn.to.batch_size + cnn.to.lambda * cnn.dW{iLayer};
                cnn.dB{iLayer} = cnn.to.mom * cnn.dB{iLayer} + cnn.to.alpha * cnn.B_grad{iLayer} / cnn.to.batch_size;
                cnn.Layers{iLayer}.W = cnn.Layers{iLayer}.W - cnn.dW{iLayer};
                cnn.Layers{iLayer}.B = cnn.Layers{iLayer}.B - cnn.dB{iLayer};
            case 2
                % Convolutional Layer
                [cnn.W_grad{iLayer}, cnn.B_grad{iLayer}] = cnnConvGrad(cnn. OutData{iLayer - 1}, cnn.Delta{iLayer + 1});
                cnn.dW{iLayer} = cnn.to.mom * cnn.dW{iLayer} + cnn.to.alpha * cnn.W_grad{iLayer} / cnn.to.batch_size + cnn.to.lambda * cnn.dW{iLayer};
                cnn.dB{iLayer} = cnn.to.mom * cnn.dB{iLayer} + cnn.to.alpha * cnn.B_grad{iLayer} / cnn.to.batch_size;
                cnn.Layers{iLayer}.W = cnn.Layers{iLayer}.W - cnn.dW{iLayer};
                cnn.Layers{iLayer}.B = cnn.Layers{iLayer}.B - cnn.dB{iLayer};
            case 1
                % Hybrid Convolutional Layer
                cnn.W_grad{iLayer}.Ka = sum(cnn.Delta{iLayer}.Ka(:));
                cnn.W_grad{iLayer}.Kr = sum(cnn.Delta{iLayer}.Kr(:));
                cnn.dW{iLayer}.Ka = cnn.to.mom * cnn.dW{iLayer}.Ka + cnn.to.alpha * cnn.W_grad{iLayer}.Ka / cnn.to.batch_size;
                cnn.dW{iLayer}.Kr = cnn.to.mom * cnn.dW{iLayer}.Kr + cnn.to.alpha * cnn.W_grad{iLayer}.Kr / cnn.to.batch_size;
                cnn.Layers{iLayer}.Ka = cnn.Layers{iLayer}.Ka - cnn.dW{iLayer}.Ka;
                cnn.Layers{iLayer}.Kr = cnn.Layers{iLayer}.Kr - cnn.dW{iLayer}.Kr;
            case 10
                % BLOB Layer
                for inet = 1:cnn.Layers{iLayer}.NNum
                    tcnn = cnn.Layers{iLayer}.Nets{inet};
                    tcnn = cnnUpdateWeight(tcnn);
                    cnn.Layers{iLayer}.Nets{inet} = tcnn;
                end

            case 11
                % %             % Batched Normalization Layer
                cnn.dW{iLayer}.dgamma = cnn.to.mom * cnn.dW{iLayer}.dgamma + cnn.to.alpha * cnn.W_grad{iLayer}.dgamma / cnn.to.batch_size;
                cnn.dW{iLayer}.dbeta = cnn.to.mom * cnn.dW{iLayer}.dbeta + cnn.to.alpha * cnn.W_grad{iLayer}.dbeta / cnn.to.batch_size;
                cnn.Layers{iLayer}.gamma = cnn.Layers{iLayer}.gamma - cnn.dW{iLayer}.dgamma;
                cnn.Layers{iLayer}.beta = cnn.Layers{iLayer}.beta - cnn.dW{iLayer}.dbeta;
        end

    end

end