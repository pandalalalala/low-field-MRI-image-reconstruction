function [new_E, new_signal,picture] = signal_regen(E,signal, ssimmap, picture)
% [row,col,~] = find(ssimmap <= 0.9);
% picture(row,col) = 0; these two lines are actually quite good!
picture(ssimmap(:,:) <0.9) = 0;
m = reshape(picture, numel(picture),1);
new_signal = signal - E * m;
ssimarray = reshape(ssimmap, 1,numel(ssimmap));
new_E = E;
[~,col,~] = find(ssimarray >= 0.9);
new_E(:,col) = [];
end