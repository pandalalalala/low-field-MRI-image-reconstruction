%% this function takes a image matrix and return the matrix index to specify the points of head area
function [head_area,pre_image_out] = head_polygon_plus(image_in, threshold, loos_parameter,polyfit_order)
a = size(image_in,1);
b = size(image_in,2);
[X,Y] = meshgrid(1:a,1:b);
image_in = normalize(image_in, 'range');

if nargin < 2
    threshold = 0.55;
end
if nargin < 3
    loos_parameter = 1.2;
end
if nargin < 4
    polyfit_order = 3;
end

image_in(image_in(:,:) <threshold) = 0; % 0.55 is an imperical parameter found

[row,col,~] = find(image_in~=0);
[T,R] = cart2pol(row - a/2, col - b/2);

coords = [T,R];
coords = sortrows(coords,1);

[x,y] = pol2cart(coords(:,1),polyval(polyfit(coords(:,1),coords(:,2),polyfit_order),coords(:,1))*loos_parameter);

pcolor(image_in)
hold on
x = x +a/2;
y = y +b/2;
plot(x,y)

k = boundary(x,y);
head_area = inpolygon(X,Y,x(k),y(k));

pre_image_out = image_in;
pre_image_out(~head_area) = 0;
pcolor(pre_image_out)
end