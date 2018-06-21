function E_M = enc_gen(X,Y)

% constants
fs=1e5; %sample frequency
dt=1/fs; %sample time
Sample_N=26;% Sample Number

% the following parameters could be likely changed
N_angle=50;% Rotating angle
coil_n=8;%Coil Number


load B0_complete_measurement.mat % Input Magnetic Field
%area used to mri.
[x_range, y_range] = size(X);% OR Y
Num_all_points = numel(X); % OR Y
[B1x, B1y, B1z, Pos,~]=Coil_Sensitivity(X,Y);

% add B1 mask % size(B1x) = 5476 * 8
COIL_N=length(Pos(:,1))-(8-coil_n);

B1X=zeros(x_range,y_range,COIL_N);
B1Y = B1X;
B1Z = B1X;

for C_n=1:COIL_N
    B1X(:,:,C_n)=reshape(B1x(C_n,:),x_range,y_range);
    B1Y(:,:,C_n)=reshape(B1y(C_n,:),x_range,y_range);
    B1Z(:,:,C_n)=reshape(B1z(C_n,:),x_range,y_range);
end

C_n=2;
% figure, title(sprintf('Coil%d',C_n));hold on
% X_mri = X;
% Y_mri = Y;
% subplot 221, pcolor(X_mri,Y_mri,sqrt(B1X(:,:,C_n).^2+B1Y(:,:,C_n).^2));         shading flat;hold on, quiver(X_mri(1:10:N_x_mri,1:10:N_y_mri),Y_mri(1:10:N_x_mri,1:10:N_y_mri), B1X(1:10:N_x_mri,1:10:N_y_mri,C_n), B1Y(1:10:N_x_mri,1:10:N_y_mri,C_n),1,'r');title('abs(X+Y)','fontsize',12); xlabel('x(mm)','fontsize',12); ylabel('y(mm)','fontsize',12);colorbar;
% subplot 222, pcolor(X_mri,Y_mri,(B1X(:,:,C_n)));                                shading flat;title('(X)','fontsize',12); xlabel('x(mm)','fontsize',12); ylabel('y(mm)','fontsize',12);colorbar;
% subplot 223, pcolor(X_mri,Y_mri,(B1Y(:,:,C_n)));                                shading flat;title('(Y)','fontsize',12);xlabel('x(mm)','fontsize',12);ylabel('y(mm)','fontsize',12);colorbar;
% subplot 224, pcolor(X_mri,Y_mri,(B1Z(:,:,C_n)));                                shading flat;title('(Z)','fontsize',12); xlabel('x(mm)','fontsize',12); ylabel('y(mm)','fontsize',12);colorbar;

% form encoding matrix
NUMB_EQ=N_angle*Sample_N*COIL_N;
E_M(Num_all_points,NUMB_EQ)=0;
% E_M = gpuArray(E_M);
for n_an=1:N_angle
    angle = 2*(n_an-1)*pi/N_angle; % rotating anticlockwise rangement: pi

    B_crop = inst_B_crop(B0_complete,angle,X,Y);
    B0_array = reshape(B_crop,Num_all_points,1);

    % subtract the component || to B0
    B1X_r = B1X-(B1X*cos(angle)+B1Y*sin(angle))*cos(angle);
    B1Y_r = B1Y-(B1X*cos(angle)+B1Y*sin(angle))*sin(angle);

    % B1 when the component of B1 || B0 is removed
    B1_r = B1X_r-1i.*B1Y_r;
    B1_array = reshape(B1_r,Num_all_points,1,COIL_N);

    w0 = 1e9* B0_array.*2*pi; %*gamma is included in the measurement

    for c_n = 1:COIL_N
        for t_n = 1:Sample_N
            t = (t_n-1)*dt;
            nn = (n_an-1)*Sample_N*COIL_N+(c_n-1)*Sample_N+t_n;
            E_M(:,nn) = w0.*( -real(B1_array(:,c_n)).*sin(t*w0)+imag(B1_array(:,c_n)).*cos(t*w0));      % original

            % the encoding ter  m: [B1_r0.*exp(-1i.*w0.*t)]
            % the imag part of [B1_r0.*exp(-1i.*w0.*t)] gives the same
            % reconstructure
            % the real part of [B1_r0.*exp(-1i.*w0.*t)] gives a better
            % accuracy
        end
    end
end

E_M = E_M.';
end


%% crop out a matrix of FOV in a give B field 3*n array, 
function B_crop = inst_B_crop(B0_complete,angle,X,Y)

c = cos(angle);
s = sin(angle);
R = [c -s;
    s c];

B0_complete(1:2,:) = R * B0_complete(1:2,:);
B_crop = griddata(B0_complete(1,:),B0_complete(2,:),B0_complete(3,:),X,Y);
end