function [recon_image,error_LMS_nn] = image_regen(new_E_M,new_signal,ssimmap,recon_image)
[pre_recon_image,error_LMS_nn] = TSVD(new_E_M,new_signal);
ssimarray = reshape(ssimmap, 1,numel(ssimmap));
threshold = 0.9;
[~,hole_col,~] = find(ssimarray < threshold);
disp(size(hole_col))
for i = 1:length(pre_recon_image)
    recon_image(hole_col(i)) = pre_recon_image(i);
end
end
