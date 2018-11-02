    % start: 4 April 2018 %tested on May 31st
clc;
clear;
close all;
% get signals from simulation
config

index = 1:5476;
index1 = reshape(index,74,74);
index1(:,65:74)=[];
index1(65:74,:)=[];
index2 = reshape(index1,1,64*64);
E_M = E_M(:,index2);
E_M2 = getE_M2(E_M); % based on svd method
%%
images = import_images_june_2018(image_path, imformat, nlimit, ifresize, numrows, numcols);
for n_image = 1:length(images)
    Obj_model = (images{n_image});
    obj_n = imnoise(Obj_model);
    Obj_model = double(Obj_model(:,:,1));
    obj_n = double(obj_n(:,:,1));
    [Sign, Sign_time] = sig_gen_simul(Obj_model,E_M, dX, dY, dZ, gamma, Plank_h, T, k, N_per, N_angle, coil_total, Sample_N);
    [Sign_n, Sign_time_n] = sig_gen_simul(obj_n,E_M, dX, dY, dZ, gamma, Plank_h, T, k, N_per, N_angle, coil_total, Sample_N);

    pic_size = sqrt(size(E_M,2)); % assume the reconstructed image to be squre
%     [X_mri, Y_mri] = meshgrid(-pic_size/2+.5:pic_size/2-.5,-pic_size/2+.5:pic_size/2-.5);
    Sign1 = Sign;
    Sign_n1 = Sign_n;
    SignM = reshape(Sign, [104, 100]);
    Sign_nM = reshape(Sign_n, [104, 100]);
    
% Least squares method boundary
    Sign = add_noise(Sign, Sign_time, Sample_N, N_angle, Noise_level);
    Sign_n = add_noise(Sign_n, Sign_time_n, Sample_N, N_angle, Noise_level);


    [recon_image_LSM,error_LMS_nn] = LSMethod_gpu(E_M,Sign);
    picture_LSM2= reshape(recon_image_LSM ,pic_size,pic_size);
    subplot 141, imshow(uint8(Obj_model))
    subplot 142, imshow(picture_LSM2)
    
    [recon_image_LSM_n,error_LMS_n] = LSMethod_gpu(E_M,Sign_n);
    picture_LSM3= reshape(recon_image_LSM_n ,pic_size,pic_size);
    subplot 143, imshow(uint8(obj_n))
    subplot 144, imshow(picture_LSM3)
end  

%%
    figure 
    subplot 131, pcolor(SignM), shading flat, pbaspect([2 2 1]), colorbar
    subplot 132, pcolor(Sign_nM), shading flat, pbaspect([2 2 1]), colorbar
    subplot 133, pcolor(SignM - Sign_nM), shading flat, pbaspect([2 2 1]), colorbar
%%
    shape = [25, 416];
    SignM = reshape(Sign, shape);
    Sign_nM = reshape(Sign_n, shape);
    Sign_nM = Sign_nM*1e-7;
    SignM = SignM*1e-7;
    figure 
    subplot 131, pcolor(SignM), shading flat, pbaspect([shape, 1]), colorbar
    subplot 132, pcolor(Sign_nM), shading flat, pbaspect([shape, 1]), colorbar
    subplot 133, pcolor(SignM - Sign_nM), shading flat, pbaspect([shape, 1]), colorbar

    
%     picture_LSM2 = cat(3, picture_LSM2,picture_LSM2,picture_LSM2);
    
%     picture_LSM2 = imresize(picture_LSM2, [256,256]);
%     imwrite(picture_LSM2,['G:\wenchuan\traintest\set_for_high_resolution_features\lessnoise64H_2\',num2str(n_image.','%04d'),'_C.jpg'])
%%Added noise
%     Sign = add_noise(Sign, Sign_time, Sample_N, N_angle, Noise_level);


%  LSM 
% TSVD boundary
% TSVD
%   [recon_image_TSVD,error_TSVD_nn] = TSVD(E_M,Sign);
%     recon_image_TSVD = TSVD_fast(E_M2,Sign);    
%     picture_TSVD = reshape(recon_image_TSVD,pic_size,pic_size);
%     picture_TSVD = cat(3, picture_TSVD,picture_TSVD,picture_TSVD);
%     picture_TSVD = imresize(picture_TSVD, [256,256]);
%     imwrite(picture_TSVD, [datapath, '\testBTSVD\', int2str(n_image-1096), '_B.jpg'])
%     imwrite(images{n_image}, [datapath, '\testA\', int2str(n_image-1096), '_A.jpg'])
%     imwrite(picture_TSVD,['G:\wenchuan\traintest\lessnoise64\',num2str(n_image.','%04d'),'_B.jpg'])
%     imwrite(Obj_model,['G:\wenchuan\traintest\hr256\',num2str(n_image.','%04d'),'_A.jpg'])

% end


