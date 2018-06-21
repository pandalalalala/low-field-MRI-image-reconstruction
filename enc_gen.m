function E_M = enc_gen(X,Y, B0_complete, dt, Sample_N, N_angle, coil_total, Elev, r, Segment, I0, phi0, Pc, Azi, CurrentDir)

%area used to mri.
[x_range, y_range] = size(X);% OR Y
Num_all_points = numel(X); % OR Y

% single coil calculation
for n = 1:coil_total
    [B1x(:,n),B1y(:,n),B1z(:,n),CoilTraj(:,:,n)]=CoilBiotSavart_SUTD2018(X,Y,Pc(n,:),Azi(1,n),Elev,r,Segment,CurrentDir(1,n),I0,phi0);
end

% cal 8-coil aggregate
B1X =zeros(x_range*y_range,1);
B1Y =zeros(x_range*y_range,1);
B1Z =zeros(x_range*y_range,1);
for n=1:coil_total
    [B1xx(:,n),B1yy(:,n),B1zz(:,n),CoilTraj(:,:,n)]=CoilBiotSavart_SUTD2018(X,Y,Pc(n,:),Azi(1,n),Elev,r,Segment,CurrentDir(1,n),I0,phi0);
    B1X(:,1) = B1X(:,1)+B1xx(:,n);
    B1Y(:,1) = B1Y(:,1)+B1yy(:,n);
    B1Z(:,1) = B1Z(:,1)+B1zz(:,n);
end


% form encoding matrix
NUMB_EQ = N_angle*Sample_N*coil_total;
E_M(Num_all_points,NUMB_EQ) = 0;

for n_an=1:N_angle
    angle = 2*(n_an-1)*pi/N_angle; % rotating anticlockwise rangement: pi

    B_crop = inst_B_crop(B0_complete,angle,X,Y);
    B0_array = reshape(B_crop,Num_all_points,1);

    % subtract the component || to B0
    B1X_r = B1X-(B1X*cos(angle)+B1Y*sin(angle))*cos(angle);
    B1Y_r = B1Y-(B1X*cos(angle)+B1Y*sin(angle))*sin(angle);

    % B1 when the component of B1 || B0 is removed
    B1_array = B1X_r-1i.*B1Y_r;
    %B1_array = reshape(B1_r,Num_all_points,1,coil_total);

    w0 = 1e6* B0_array.*2*pi; %*gamma is included in the measurement

    for cn = 1:coil_total
        for sn = 1:Sample_N
            t = (sn-1)*dt;
            nn = (n_an-1)*Sample_N*coil_total+(cn-1)*Sample_N+sn;
            E_M(:,nn) = w0.*( -real(B1_array(cn)).*sin(t*w0)+imag(B1_array(cn)).*cos(t*w0));      % original/since B1_array is now a column vector, the index should be set accordingly

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