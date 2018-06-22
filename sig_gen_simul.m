% simulates signal generating: s = E*m
function [Sign, Sign_time] = sig_gen_simul(Obj_model,E_M, dX, dY, dZ, gamma, Plank_h, T, k, N_per, N_angle, coil_total, Sample_N)

Obj_model_n = reshape(Obj_model,numel(Obj_model),1);
Volume = dX*dY*dZ*1e-9;
N_proton = N_per*Volume;
m0 = (N_proton*0.5*1.5*(gamma*Plank_h/2/pi)^2)/3/k/T;

M0 = m0 * Obj_model_n;
M0 = normalize(M0,'range');
Sign = E_M * M0;

for n_an=1:N_angle
    for c_n=1:coil_total
        for t_n=1:Sample_N
            nn = (n_an-1)*Sample_N*coil_total+(c_n-1)*Sample_N+t_n;
            Sign_time(n_an,t_n,c_n) = Sign(nn);
        end
    end
end
end