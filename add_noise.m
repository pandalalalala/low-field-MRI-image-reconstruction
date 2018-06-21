% add noise onto signal vector
function Sign_n = add_noise(Sign, Sign_time)
%% = constants =
Sample_N=26;% Sample Number
N_angle=50;% Rotating angle
Noise_level=-70; % noise level in time domain (dB)

V_noise_wgn_t=(10^(Noise_level/20)).*max(max(abs(Sign_time(1,:,:))))*wgn(Sample_N*8*N_angle,1,1,'real')';
% wg_noise = wgn(Sample_N*COIL_N*N_angle,1,1,'real')';
Sign_n=Sign+V_noise_wgn_t;
end