%% this function was specifically written for the 22 MRI image phantoms.
% It might onnly be useful for the simulation, but the small modification
% at the end could be helpful later in reconstructing images. The original
% size and modified sized are already determined therefore the parameters
% are set in the following manner.
function obj = brain_images_may_2018(n_image)
np_image = int2str(n_image + 22);
name_image = ['brian_images\IM_000',np_image,'.TIF']; %read image according to numbers
M = imread(name_image);
M = double(M);

orig_size = 512; % the original image size was 512x512
simul_size = 74; % the size used in simulation is 74x74
dim_limit = 60; % the diameter of scanning are is 120 mm, it is also related to the B0 field
[X,Y] = meshgrid(linspace(-dim_limit,dim_limit,orig_size));
[Xq,Yq] = meshgrid(linspace(-dim_limit,dim_limit,simul_size));
Vq = interp2(X,Y,M,Xq,Yq);

obj = (Vq - min(min(Vq))) ./ (max(max(Vq)) - min(min(Vq))); % normal the input phantom from 0~1

%% a small modification on the outside circle of phantom, as there should not be signals generated here
x = 1:simul_size;
y = x;
[X,Y] = meshgrid(x,y); 
idx=(X-simul_size/2).^2+(Y-simul_size/2).^2>= (36^2);
obj(idx) = 0;
end