%% =========Least squares method 1=========
function  [recon_image,error_LMS_nn] = LSMethod(E_M,Sign)
    tic;
    r_near=E_M'\Sign';
    error_LMS_nn=norm(Sign'-E_M'*r_near,2)/norm(Sign',2);
    recon_image=normalize_range(abs(r_near))';
    toc;
end