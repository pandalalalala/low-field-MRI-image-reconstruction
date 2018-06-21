function [recon_image,error_IT_nn]=Kaczmarz_su(A,b,lambda,maxIter)
% tic;

if nargin < 4
    lambda=1;
    maxIter=10;
end

[m_unk,n_unk]=size(A);

x_k=zeros(n_unk,1);
x_kn=zeros(n_unk,1); 
% error=zeros(maxIter,1);
k=1;

for  Iter=1:1:maxIter
    for nn=1:m_unk
        x_kn=x_k+lambda*((b(k)-A(k,:)*x_k)/(norm(A(k,:),2))^2)*A(k,:)';
        x_k=x_kn;
        k=rem(k+1,m_unk)+1
        x=x_kn;
    end
    err = norm(b-A*x,2)/norm(b,2)
%     error(Iter)=err;
end
x = x';
recon_image=normalize_range(x);
error_IT_nn = 0;%min(error);
% toc
end
