%% =========Least squares method 2=========
function  [recon_image,error_LMS_nn] = LSMethod_boundary(E_M,Sign)
    tic;
    % iteration Kaczmarz_su
    [pre_recon_image_IT,~]=Kaczmarz_su(E_M,Sign,1,3); % lambda = 1, max iteration is 2
    pic_size = sqrt(size(E_M,1)); % assume the reconstructed image to be squre
    picture_IT = reshape(pre_recon_image_IT(1,:),pic_size,pic_size);
    head_area = reshape(head_polygon(picture_IT,0.4),1,pic_size*pic_size);
    
    E_M(~head_area,:) = [];
    
%     [pre_recon_image,error_LMS_nn] = LSMethod(E_M,Sign);    
    [pre_recon_image,error_LMS_nn] = TSVD(E_M,Sign);    

    
    [~,head_col,~] = find(head_area~=0);
    recon_image = double(head_area)*0;
    disp(length(pre_recon_image))
    for i = 1:length(pre_recon_image)
        recon_image(head_col(i)) = pre_recon_image(i);
    end
    toc;
end