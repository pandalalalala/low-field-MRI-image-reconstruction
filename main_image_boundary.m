% start: 4 April 2018 %tested on May 31st
clc;
clear;
close all;
%% get signals from simulation
config
images = import_images_june_2018(image_path, imformat, nlimit, ifresize, numrows, numcols);
% E_M= enc_gen(X,Y);
[Sign, Sign_time] = sig_gen_simul(Obj_model,E_M);
%% image frame
pic_size = sqrt(size(E_M,1)); % assume the reconstructed image to be squre
[X_mri, Y_mri] = meshgrid(-pic_size/2+.5:pic_size/2-.5,-pic_size/2+.5:pic_size/2-.5);

%% === Added noise ===
Sign = add_noise(Sign, Sign_time);

%% Least squares method 1
[recon_image_LSM,error_LMS_nn] = LSMethod(E_M,Sign);
picture_LSM = reshape(recon_image_LSM(1,:),pic_size,pic_size);

%% iteration Kaczmarz_su
[recon_image_IT,error_IT_nn]=Kaczmarz_su(E_M,Sign,1,10); % lambda = 1, max iteration is 10
picture_IT = reshape(recon_image_IT(1,:),pic_size,pic_size);

%% TSVD
[recon_image_TSVD,error_TSVD_nn] = TSVD(E_M,Sign);
picture_TSVD = reshape(recon_image_TSVD(1,:),pic_size,pic_size);




%% Least squares method boundary
[recon_image_LSM,error_LMS_nn] = LSMethod_boundary(E_M,Sign);
picture_LSM2 = reshape(recon_image_LSM(1,:),pic_size,pic_size);

%% iteration Kaczmarz_su boundary
[recon_image_IT,error_IT_nn]=Kaczmarz_su_boundary(E_M,Sign); % lambda = 1, max iteration is 10
picture_IT2 = reshape(recon_image_IT(1,:),pic_size,pic_size);

%% TSVD
[recon_image_TSVD,error_TSVD_nn] = TSVD_boundary(E_M,Sign);
picture_TSVD2 = reshape(recon_image_TSVD(1,:),pic_size,pic_size);

%% figures
figure
subplot 241, pcolor(X_mri,Y_mri,Obj_model);                     shading flat; title('object','fontsize',12); xlabel('x(mm)','fontsize',12); ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1]) %colormap gray;
subplot 242, pcolor(X_mri,Y_mri,Obj_model);                     shading flat; title('object','fontsize',12); xlabel('x(mm)','fontsize',12); ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1])

subplot 243, pcolor(X_mri,Y_mri,picture_LSM);                   shading flat; title('LSM,abs,no boundary','fontsize',12); xlabel('x(mm)','fontsize',12); ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1])
subplot 245, pcolor(X_mri,Y_mri,picture_IT);                    shading flat; title('Iteration,abs,no boundary','fontsize',12); xlabel('x(mm)','fontsize',12); ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1])
subplot 247, pcolor(X_mri,Y_mri,picture_TSVD);                  shading flat; title('TSVD,abs,no boundary','fontsize',12); xlabel('x(mm)','fontsize',12); ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1])

subplot 244,pcolor(X_mri,Y_mri,picture_LSM2);                   shading flat;title('LSM,abs, with boundary restriction','fontsize',12);xlabel('x(mm)','fontsize',12);ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1])% colormap gray;
subplot 246,pcolor(X_mri,Y_mri,picture_IT2);                   shading flat; title('Iteration,abs, without boundary restriction','fontsize',12); xlabel('x(mm)','fontsize',12); ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1])
subplot 248,pcolor(X_mri,Y_mri,picture_TSVD2);                   shading flat;title('TSVD with boundary restriction, abs','fontsize',12);xlabel('x(mm)','fontsize',12);ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1])% colormap gray;




%% =========Least squares method 2=========
function  [recon_image,error_LMS_nn] = LSMethod_boundary(E_M,Sign)
    tic;
    % iteration Kaczmarz_su
    [pre_recon_image_IT,~]=Kaczmarz_su(E_M,Sign,1,3); % lambda = 1, max iteration is 2
    pic_size = sqrt(size(E_M,1)); % assume the reconstructed image to be squre
    picture_IT = reshape(pre_recon_image_IT(1,:),pic_size,pic_size);
    head_area = reshape(head_polygon(picture_IT,0.4),1,pic_size*pic_size);
    
    E_M(~head_area,:) = [];
    
    [pre_recon_image,error_LMS_nn] = LSMethod(E_M,Sign);    

    
    [~,head_col,~] = find(head_area~=0);
    recon_image = double(head_area)*0;
    disp(length(pre_recon_image))
    for i = 1:length(pre_recon_image)
        recon_image(head_col(i)) = pre_recon_image(i);
    end
    toc;
end

%% =========Least squares method 2=========
function  [recon_image,error_LMS_nn] = Kaczmarz_su_boundary(E_M,Sign)
    tic;
    % iteration Kaczmarz_su
    [pre_recon_image_IT,~]=Kaczmarz_su(E_M,Sign,1,3); % lambda = 1, max iteration is 2
    pic_size = sqrt(size(E_M,1)); % assume the reconstructed image to be squre
    picture_IT = reshape(pre_recon_image_IT(1,:),pic_size,pic_size);
    head_area = reshape(head_polygon(picture_IT,0.4),1,pic_size*pic_size);
    
    E_M(~head_area,:) = [];
    
    [pre_recon_image,error_LMS_nn] = Kaczmarz_su(E_M,Sign,1,10);    

    
    [~,head_col,~] = find(head_area~=0);
    recon_image = double(head_area)*0;
    disp(length(pre_recon_image))
    for i = 1:length(pre_recon_image)
        recon_image(head_col(i)) = pre_recon_image(i);
    end
    toc;
end

%% =========TSVD squares method boundary=========
function  [recon_image,error_LMS_nn] = TSVD_boundary(E_M,Sign)
    tic;
    % iteration Kaczmarz_su
    [pre_recon_image_IT,~]=Kaczmarz_su(E_M,Sign,1,3); % lambda = 1, max iteration is 2
    pic_size = sqrt(size(E_M,1)); % assume the reconstructed image to be squre
    picture_IT = reshape(pre_recon_image_IT(1,:),pic_size,pic_size);
    head_area = reshape(head_polygon(picture_IT,0.4),1,pic_size*pic_size);
    
    E_M(~head_area,:) = [];
    
    [pre_recon_image,error_LMS_nn] = TSVD(E_M,Sign);    

    
    [~,head_col,~] = find(head_area~=0);
    recon_image = double(head_area)*0;
    disp(length(pre_recon_image))
    for i = 1:length(pre_recon_image)
        recon_image(head_col(i)) = pre_recon_image(i);
    end
    toc;
end