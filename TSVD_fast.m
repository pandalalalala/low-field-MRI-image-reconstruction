function recon_image = TSVD_fast(E_M2,Sign)
    tic;
    r_near=E_M2*Sign;
    recon_image=normalize(abs(r_near),'range');
    disp('TSVD method done!')
    toc
end