%% this function takes a image matrix and return the matrix index to specify the points of head area
function [head_area, pre_image_out] = head_polygon_multiple(image_in, threshold, loos_parameter,polyfit_order)
if nargin < 2
    threshold = 0.55;
end
if nargin < 3
    loos_parameter = 1.2;
end
if nargin < 4
    polyfit_order = 3;
end
[~,pre_image_out1] = head_polygon_plus(image_in, threshold, loos_parameter,polyfit_order);
threshold = threshold * 1.2;
[~,pre_image_out2] = head_polygon_plus(pre_image_out1, threshold, loos_parameter,polyfit_order);
threshold = threshold * 1.2;
[head_area,pre_image_out] = head_polygon_plus(pre_image_out2, threshold, loos_parameter,polyfit_order);

end