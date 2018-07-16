clc;
clear all;
close all;
%moved into config.m
%% get signals from simulation
config
images = import_images_june_2018(image_path, imformat, nlimit, ifresize, numrows, numcols);
%%
% E_M2 = getE_M2(E_M); % based on svd method
%%
for n_image = 1097:length(images)
%     Obj_model = double(images{n_image});
%     Obj_model = Obj_model(:,:,1);
%     [Sign, Sign_time] = sig_gen_simul(Obj_model,E_M, dX, dY, dZ, gamma, Plank_h, T, k, N_per, N_angle, coil_total, Sample_N);
% % image frame
%     pic_size = sqrt(size(E_M,2)); % assume the reconstructed image to be squre
%     [X_mri, Y_mri] = meshgrid(-pic_size/2+.5:pic_size/2-.5,-pic_size/2+.5:pic_size/2-.5);
% 
% 
% 
% % TSVD
% %   [recon_image_TSVD,error_TSVD_nn] = TSVD(E_M,Sign);
%     recon_image_TSVD = TSVD_fast(E_M2,Sign);    
%     picture_TSVD = reshape(recon_image_TSVD,pic_size,pic_size);
%     picture_TSVD = cat(3, picture_TSVD,picture_TSVD,picture_TSVD);
%     picture_TSVD = imresize(picture_TSVD, [256,256]);
%     imwrite(picture_TSVD, [datapath, '\testBTSVD\', int2str(n_image-1096), '_B.jpg'])
    imwrite(images{n_image}, [datapath, '\testA\', int2str(n_image-1096), '_A.jpg'])

end
