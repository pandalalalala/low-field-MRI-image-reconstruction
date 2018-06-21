function blurimage = blurr_center(picture)

[a,b] = size(picture);
Iblur = imgaussfilt(picture(round(a/4):round(3*a/4), round(b/4):round(3*b/4)), 2);
picture(round(a/4):round(3*a/4), round(b/4):round(3*b/4)) = Iblur;
blurimage = picture;
end