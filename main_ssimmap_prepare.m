% start: 4 April 2018 %tested on May 31st
clc;
clear;
close all;
%% get signals from simulation
config
images = import_images_june_2018(image_path, imformat, nlimit, ifresize, numrows, numcols);
for i = 6:1000
Obj_model = double(images{i});
Obj_model = Obj_model(:,:,1);
%     E_M = enc_gen(X,Y, B0_complete, dt, Sample_N, N_angle, coil_total,...
%     Elev, r, Segment, I0, phi0, Pc, Azi, CurrentDir); % the encoding
%     matrix is problemetic on 21st June.
[Sign, Sign_time] = sig_gen_simul(Obj_model,E_M, dX, dY, dZ, gamma, Plank_h, T, k, N_per, N_angle, coil_total, Sample_N);
%% image frame
pic_size = sqrt(size(E_M,2)); % assume the reconstructed image to be squre
[X_mri, Y_mri] = meshgrid(-pic_size/2+.5:pic_size/2-.5,-pic_size/2+.5:pic_size/2-.5);

%% === Added noise ===
Sign = add_noise(Sign, Sign_time, Sample_N, N_angle, Noise_level);

%% TSVD
[recon_image_TSVD,error_TSVD_nn] = TSVD_boundary(E_M,Sign);
picture_TSVD2 = reshape(recon_image_TSVD ,pic_size,pic_size);
% [peaksnrTSVD2,snrTSVD2] = psnr(picture_TSVD2,normalize(Obj_model,'range'));
[ssimval, ssimmap] = ssim(picture_TSVD2,normalize(Obj_model,'range'));  
% fprintf('The picture_TSVD2 SSIM value is %0.4f.\n',ssimval);
picture_TSVD2 = imresize(picture_TSVD2,[256,256]);
picture_TSVD2 = cat(3,picture_TSVD2,picture_TSVD2,picture_TSVD2);

ssimmap = imresize(ssimmap,[256,256]);
ssimmap = cat(3,ssimmap,ssimmap,ssimmap);
imwrite(picture_TSVD2, ['C:\Users\BioMedEM\Dropbox\5.1\scripts_and_data\encgen_simulator_and_imrecon\picture_TSVD2\', int2str(i),'_A.jpg'])
imwrite(ssimmap, ['C:\Users\BioMedEM\Dropbox\5.1\scripts_and_data\encgen_simulator_and_imrecon\ssimmap\', int2str(i),'_B.jpg'])

%% figures
% figure
% subplot 241, pcolor(X_mri,Y_mri,Obj_model);                     shading flat; title('object','fontsize',12); xlabel('x(mm)','fontsize',12); ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1]) %colormap gray;
% subplot 242, pcolor(X_mri,Y_mri,Obj_model);                     shading flat; title('object','fontsize',12); xlabel('x(mm)','fontsize',12); ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1])
% 
% subplot 243, pcolor(X_mri,Y_mri,picture_LSM);                   shading flat; title('LSM,abs,no boundary','fontsize',12); xlabel('x(mm)','fontsize',12); ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1])
% subplot 245, pcolor(X_mri,Y_mri,picture_IT);                    shading flat; title('Iteration,abs,no boundary','fontsize',12); xlabel('x(mm)','fontsize',12); ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1])
% subplot 247, pcolor(X_mri,Y_mri,picture_TSVD);                  shading flat; title('TSVD,abs,no boundary','fontsize',12); xlabel('x(mm)','fontsize',12); ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1])
% 
% subplot 244,pcolor(X_mri,Y_mri,picture_LSM2);                   shading flat;title('LSM,abs, with boundary restriction','fontsize',12);xlabel('x(mm)','fontsize',12);ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1])% colormap gray;
% subplot 246,pcolor(X_mri,Y_mri,picture_IT2);                    shading flat; title('Iteration,abs, without boundary restriction','fontsize',12); xlabel('x(mm)','fontsize',12); ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1])
% subplot 248,pcolor(X_mri,Y_mri,picture_TSVD2);                  shading flat;title('TSVD with boundary restriction, abs','fontsize',12);xlabel('x(mm)','fontsize',12);ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1])% colormap gray;

end

%% regulation functions
function [head_area, E_M] = preregulateSimpleBoundary(E_M,Sign)
    [pre_recon_image_IT,~]=Kaczmarz_su(E_M,Sign,1,3); % lambda = 1, max iteration is 2
    pic_size = sqrt(size(E_M,2)); % assume the reconstructed image to be squre
    picture_IT = reshape(pre_recon_image_IT ,pic_size,pic_size);
    head_area = reshape(head_polygon_plus(picture_IT,0.55),1,pic_size*pic_size);    
    E_M(:, ~head_area) = [];
end

function recon_image = postregulateSimpleBoundary(head_area, pre_recon_image)
    [~,head_col,~] = find(head_area~=0);
    recon_image = double(head_area)*0;
    disp(length(pre_recon_image))
    for i = 1:length(pre_recon_image)
        recon_image(head_col(i)) = pre_recon_image(i);
    end
end

%% TSVD method with boundary regulation
function  [recon_image,error_LMS_nn] = TSVD_boundary(E_M,Sign)
    tic;
    % iteration Kaczmarz_su
    [head_area, E_M] = preregulateSimpleBoundary(E_M,Sign);    
    [pre_recon_image,error_LMS_nn] = TSVD(E_M,Sign);   
    recon_image = postregulateSimpleBoundary(head_area, pre_recon_image);
    toc;
end