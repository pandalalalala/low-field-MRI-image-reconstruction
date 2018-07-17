function [new_E_M, new_signal,picture] = signal_regen(E_M,signal, ssimmap, picture)
% [row,col,~] = find(ssimmap <= 0.9);
% picture(row,col) = 0; these two lines are actually quite good!
threshold = 0.9;
picture(ssimmap(:,:) <threshold) = 0;
m = reshape(picture, numel(picture),1);
new_signal = signal - E_M * m;
ssimarray = reshape(ssimmap, 1,numel(ssimmap));
new_E_M = E_M;
[~,col,~] = find(ssimarray >= threshold);
new_E_M(:,col) = [];
end