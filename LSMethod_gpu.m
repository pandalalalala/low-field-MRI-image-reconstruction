%% =========Least squares method GPU=========
function  [recon_image,error_LMS_nn] = LSMethod_gpu(E_M,Sign)
    tic;
    E_M = gpuArray(E_M);
    Sign = gpuArray(Sign);
    r_near=E_M\Sign;
    error_LMS_nn=0;%norm(Sign'-E_M'*r_near,2)/norm(Sign',2);
    recon_image=normalize(abs(r_near),'range');
    recon_image=gather(recon_image);
    disp('LSMethod_gpu done')
    toc
end