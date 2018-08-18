function head_area = temp()
Obj_model = imread('C:\Users\Wenchuan\Dropbox\imdataset\nic\c2.png');
Obj_model = imresize(Obj_model,[74, 74]);
Obj_model = Obj_model(:,:,1);

[row,col,~] = find(Obj_model>=0.3*max(max(Obj_model)));
k = boundary(col,row);
[X,Y]=meshgrid(1:size(Obj_model,1),1:size(Obj_model,2));
head_area = inpolygon(X,Y,col(k),row(k));
imshow(head_area)
size(head_area)
head_area = reshape(head_area, 1, 74*74);
end