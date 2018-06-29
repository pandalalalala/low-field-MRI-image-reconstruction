% start: 4 April 2018 %tested on May 31st
clc;
clear;
close all;
%% get signals from simulation
config
images = import_images_june_2018(image_path, imformat, nlimit, ifresize, numrows, numcols);

for k = 1:5
Obj_model = double(images{k});
%     E_M = enc_gen(X,Y, B0_complete, dt, Sample_N, N_angle, coil_total,...
%     Elev, r, Segment, I0, phi0, Pc, Azi, CurrentDir); % the encoding
%     matrix is problemetic on 21st June.
[Sign, Sign_time] = sig_gen_simul(Obj_model,E_M, dX, dY, dZ, gamma, Plank_h, T, k, N_per, N_angle, coil_total, Sample_N);
%% image frame
pic_size = sqrt(size(E_M,2)); % assume the reconstructed image to be squre
[X_mri, Y_mri] = meshgrid(-pic_size/2+.5:pic_size/2-.5,-pic_size/2+.5:pic_size/2-.5);

%% === Added noise ===
Sign = add_noise(Sign, Sign_time, Sample_N, N_angle, Noise_level);


%% iteration Kaczmarz_su
[recon_image_IT,error_IT_nn]=Kaczmarz_su(E_M,Sign,1,3); % lambda = 1, max iteration is 3
picture_IT = reshape(recon_image_IT ,pic_size,pic_size);
[peaksnrIT,snrIT] = psnr(picture_IT,normalize(Obj_model,'range'));
[ssimval, ssimmap] = ssim(picture_IT,normalize(Obj_model,'range'));
fprintf('The picture_IT PSNR value is %0.4f.\n',peaksnrIT);
fprintf('The picture_IT SSIM value is %0.4f.\n',ssimval);
imwrite(picture_IT, sprintf('Iteration,abs,image %d .png',k))

%% figures
subplot (1,5,k), pcolor(X_mri,Y_mri,picture_IT);                    shading flat; title(sprintf('Iteration,abs,image %d',k),'fontsize',12); xlabel('x(mm)','fontsize',12); ylabel('y(mm)','fontsize',12);pbaspect ([2 2 1])
end