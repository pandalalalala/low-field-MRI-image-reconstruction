% start: 4 April 2018 %tested on May 31st
clc;
clear all;
close all;
%moved into config.m
%% get signals from simulation
config
images = import_images_june_2018(image_path, imformat, nlimit, ifresize, numrows, numcols);
for n_image = 1:length(images)
    Obj_model = double(images{n_image});
%     E_M = enc_gen(X,Y, B0_complete, dt, Sample_N, N_angle, coil_total,...
%     Elev, r, Segment, I0, phi0, Pc, Azi, CurrentDir); % the encoding
%     matrix is problemetic on 21st June.
    [Sign, Sign_time, M0] = sig_gen_simul(Obj_model,E_M, dX, dY, dZ, gamma, Plank_h, T, k, N_per, N_angle, coil_total, Sample_N);
%% image frame
    pic_size = sqrt(size(E_M,2)); % assume the reconstructed image to be squre
    [X_mri, Y_mri] = meshgrid(-pic_size/2+.5:pic_size/2-.5,-pic_size/2+.5:pic_size/2-.5);


%% Least squares method 1
    [recon_image_LSM,error_LMS_nn] = LSMethod_gpu(E_M,Sign);
    picture_LSM = reshape(recon_image_LSM,pic_size,pic_size);

%% iteration Kaczmarz_su
    [recon_image_IT,error_IT_nn]=Kaczmarz_su(E_M,Sign,1,10); % lambda = 1, max iteration is 10
    picture_IT = reshape(recon_image_IT,pic_size,pic_size);

%% TSVD
%   [recon_image_TSVD,error_TSVD_nn] = TSVD(E_M,Sign);
    E_M2 = getE_M2(E_M); % based on svd method
    recon_image_TSVD = TSVD_fast(E_M2,Sign);
    picture_TSVD = reshape(recon_image_TSVD,pic_size,pic_size);



%% === Added noise ===
    Sign_n = add_noise(Sign, Sign_time);


%% Least squares method, noise
    [recon_image_LSM,error_LMS_ns] = LSMethod_gpu(E_M,Sign_n);
    picture_LSM_ns = reshape(recon_image_LSM(1,:),pic_size,pic_size);

%% iteration Kaczmarz_su
    [recon_image_IT,error_IT_ns]=Kaczmarz_su(E_M,Sign_n,1,80); % lambda = 1, max iteration is 10
    picture_IT_ns = reshape(recon_image_IT(1,:),pic_size,pic_size);

%% TSVD, noise
    [recon_image_TSVD,error_TSVD_ns] = TSVD(E_M,Sign_n);
    picture_TSVD_ns = reshape(recon_image_TSVD(1,:),pic_size,pic_size);


%% figures
    figure
    subplot 241, pcolor(X_mri,Y_mri,Obj_model);                     shading flat; title('object','fontsize',12); xlabel('x(mm)','fontsize',12); ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1]) %colormap gray;
    subplot 242, pcolor(X_mri,Y_mri,Obj_model);                     shading flat; title('object','fontsize',12); xlabel('x(mm)','fontsize',12); ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1])

    subplot 243, pcolor(X_mri,Y_mri,picture_LSM);                   shading flat; title('LSM,abs,no noise','fontsize',12); xlabel('x(mm)','fontsize',12); ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1])
    subplot 245, pcolor(X_mri,Y_mri,picture_IT);                    shading flat; title('Iteration,abs,no noise','fontsize',12); xlabel('x(mm)','fontsize',12); ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1])
    subplot 247, pcolor(X_mri,Y_mri,picture_TSVD);                  shading flat; title('TSVD,abs,no noise','fontsize',12); xlabel('x(mm)','fontsize',12); ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1])

    subplot 244,pcolor(X_mri,Y_mri,picture_TSVD);                   shading flat;title('LSM,abs,noise','fontsize',12);xlabel('x(mm)','fontsize',12);ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1])% colormap gray;
    subplot 246,pcolor(X_mri,Y_mri,picture_TSVD);                   shading flat; title('Iteration,abs,noise','fontsize',12); xlabel('x(mm)','fontsize',12); ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1])
    subplot 248,pcolor(X_mri,Y_mri,picture_TSVD);                   shading flat;title('TSVD noise, abs','fontsize',12);xlabel('x(mm)','fontsize',12);ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1])% colormap gray;
end




%% with noise
errors = [error_LMS_nn; error_IT_nn; error_TSVD_nn; error_LMS_ns; error_IT_ns; error_TSVD_ns];
% NRMSEs = [NRMSEs; NRMSE_LMS_nn; NRMSE_IT_nn; NRMSE_TSVD_nn; NRMSE_LMS_ns; NRMSE_IT_ns; NRMSE_TSVD_ns];
% 
% one of the calculations of NRMSE
% NRMSE_LMS_nn=(100*(norm(Tr1-Obj_model*m0)))/norm(Obj_model*m0);