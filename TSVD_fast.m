function recon_image = TSVD_fast(E_M2,Sign)
    tic
    r_near=Sign*E_M2;
    recon_image=normalize_range(abs(r_near));
    toc
end