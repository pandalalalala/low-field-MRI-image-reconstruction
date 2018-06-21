%% this function takes a image matrix and return the matrix index to specify the points of head area
function head_area = head_polygon(image_in, shrink_parameter)
maximum = max(max(image_in));

if nargin < 2
    shrink_parameter = 0.55;
end
image_in(image_in(:,:) <shrink_parameter*maximum) = 0; % 0.55 is an imperical parameter found
[row,col,~] = find(image_in~=0);
k = boundary(col,row);
[X,Y]=meshgrid(1:size(image_in,1),1:size(image_in,2));
head_area = inpolygon(X,Y,col(k),row(k));
end