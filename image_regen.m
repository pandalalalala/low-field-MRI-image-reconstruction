function [recon_image,error_LMS_nn] = image_regen(new_E_M,new_Signal,ssimmap,recon_image)
[pre_recon_image,error_LMS_nn] = LSMethod_gpu(new_E_M,new_Signal);
ssimarray = reshape(ssimmap, 1,numel(ssimmap));
[~,hole_col,~] = find(ssimarray < 0.9);
disp(size(hole_col))
for i = 1:length(pre_recon_image)
    recon_image(hole_col(i)) = pre_recon_image(i);
end
end
