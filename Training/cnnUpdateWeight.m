function cnn=cnnUpdateWeight(cnn)

for iLayer=1:cnn.LNum
    switch cnn.Layers{iLayer}.type
        case 3
            % Fully Connected Layer
            cnn.W_grad{iLayer}=cnn.Delta{iLayer+1}*cnn.OutData{iLayer-1}';
            cnn.B_grad{iLayer}=sum(cnn.Delta{iLayer+1}, 2);
            cnn.dW{iLayer}=cnn.to.mom*cnn.dW{iLayer}+single(cnn.to.alpha)*(cnn.W_grad{iLayer}/single(cnn.to.batch_size)+single(cnn.to.lambda)*cnn.dW{iLayer});
            cnn.dB{iLayer}=cnn.to.mom*cnn.dB{iLayer}+single(cnn.to.alpha)*cnn.B_grad{iLayer}/single(cnn.to.batch_size);
            cnn.Layers{iLayer}.W=cnn.Layers{iLayer}.W-cnn.dW{iLayer};
            cnn.Layers{iLayer}.B=cnn.Layers{iLayer}.B-cnn.dB{iLayer};
        case 2
            % Convolutional Layer
            [cnn.W_grad{iLayer}, cnn.B_grad{iLayer}]=cnnConvGrad(cnn. OutData{iLayer-1}, cnn.Delta{iLayer+1});
            cnn.dW{iLayer}=cnn.to.mom*cnn.dW{iLayer}+single(cnn.to.alpha)*(cnn.W_grad{iLayer}/single(cnn.to.batch_size)+single(cnn.to.lambda)*cnn.dW{iLayer});
            cnn.dB{iLayer}=cnn.to.mom*cnn.dB{iLayer}+single(cnn.to.alpha)*cnn.B_grad{iLayer}/single(cnn.to.batch_size);
            cnn.Layers{iLayer}.W=cnn.Layers{iLayer}.W-cnn.dW{iLayer};
            cnn.Layers{iLayer}.B=cnn.Layers{iLayer}.B-cnn.dB{iLayer};
        case 1
            % Hybrid Convolutional Layer
            cnn.W_grad{iLayer}.Ka=sum(cnn.Delta{iLayer}.Ka(:));
            cnn.W_grad{iLayer}.Kr=sum(cnn.Delta{iLayer}.Kr(:));
            cnn.dW{iLayer}.Ka=to.mom*cnn.dW{iLayer}.Ka+single(cnn.to.alpha)*cnn.W_grad{iLayer}.Ka/single(cnn.to.batch_size);
            cnn.dW{iLayer}.Kr=to.mom*cnn.dW{iLayer}.Kr+single(cnn.to.alpha)*cnn.W_grad{iLayer}.Kr/single(cnn.to.batch_size);
            cnn.Layers{iLayer}.Ka=cnn.Layers{iLayer}.Ka-cnn.dW{iLayer}.Ka;
            cnn.Layers{iLayer}.Kr=cnn.Layers{iLayer}.Kr-cnn.dW{iLayer}.Kr;
        case 10
            % BLOB Layer
            for inet=1:cnn.Layers{iLayer}.NNum
                tcnn=cnn.Layers{iLayer}.Nets{inet};
                tcnn=cnnUpdateWeight(tcnn);
                cnn.Layers{iLayer}.Nets{inet}=tcnn;
            end
    end
end