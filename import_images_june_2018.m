%% this function was specifically written for the 22 MRI image phantoms.
% It might onnly be useful for the simulation, but the small modification
% at the end could be helpful later in reconstructing images. The original
% size and modified sized are already determined therefore the parameters
% are set in the following manner.

% this function is amended on 21st of June to fit more options of importing
% images, the image dataset is stored elsewhere in dropbox, therefore this 
% function is going to be updated along with the data
function images = import_images_june_2018(image_path, imformat, nlimit, ifresize, numrows, numcols)
imagefiles = dir([image_path,'\*.',imformat]);
% Get list of all PNG files in this directory
% DIR returns as a structure array.  You will need to use () and . to get
% the file names.

nfiles = length(imagefiles); % Number of files found  
nfiles = min(nlimit, nfiles);
for i =1:nfiles
  currentfilename = [imagefiles(i).folder,'\',imagefiles(i).name];
  currentimage = imread(currentfilename);
  images{i} = currentimage;
end
if ifresize
    for i =1:nfiles
        images{i} = imresize(images{i},[numrows numcols]);
    end
end
end