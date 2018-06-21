function E_M2 = getE_M2(E_M)
    [U,S,V]=svd(E_M);
    [m,n]=size(S);
    Sinv=zeros(m,n);
    for ii=1:m
        for jj=1:n
            if(ii==jj)
                if(S(ii,jj)>=5e5)
                    Sinv(ii,jj)=1/S(ii,jj);
                end
            end
        end
    end
    E_M2=V*Sinv.'*U.';
end