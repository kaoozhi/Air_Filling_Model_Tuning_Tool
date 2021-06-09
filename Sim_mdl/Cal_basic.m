Nxx_atm_kpa=101.3;
Nxx_k_degc=273.15;
Nxx_kilo_bas=1000;
Nxx_wht_pgc_j_kg=287;
% Cbx_cyl_fill_efy_opt_cho=1;
Cnx_cyl_nr_conf=3;
Cnx_cyl_fill_ex_mfld_prs_cor_cho=0;
Cxx_cyl_vol=3.9961e-04*3;
Cxm_cyl_fill_mdl_intk_mfld_prs_diff_cor_fac=ones(16);
Cxm_cyl_fill_mdl_ex_mfld_prs_rat_cor_fac=ones(16);
Cxb_cyl_fill_mdl_intk_mfld_prs_diff_bas= [-100 -86.67 -73.33 -60 -46.67 -33.33 -20 -6.67  6.67  20 33.33 46.67 60 73.33 86.67 100];
Cxp_cyl_fill_mdl_intk_mfld_prs_diff=Cxb_cyl_fill_mdl_intk_mfld_prs_diff_bas;
Cxb_cyl_fill_mdl_ex_mfld_prs_rat_bas= [0 0.330 0.670 1 1.33 1.67 2 2.33 2.67 3 3.33 3.67 4 4.33 4.67 5];
Cxp_cyl_fill_mdl_ex_mfld_prs_rat=Cxb_cyl_fill_mdl_ex_mfld_prs_rat_bas;

%% New calibration added for 7-0
Cxm_cyl_fill_trap_area_eng_spd_intk_mfld_prs = zeros(16);
Cxb_cyl_fill_trap_area_vvt_intk = [0.0000 10.0000 20.0000 30.0000 40.0000 50.0000 60.0000 61.0000 ];
Cxb_cyl_fill_trap_area_vvt_ex = [0.0000 10.0000 20.0000 30.0000 40.0000 50.0000 60.0000 61.0000 ];
Cxm_cyl_fill_trap_area_vvt_intk_vvt_ex = zeros(8);
Cxm_cyl_fill_trap_area_vvt_intk_vvt_ex_l_lift = zeros(8);
Cxx_cyl_fill_trap_area_l_thd = 0.1;
Cxx_cyl_fill_trap_area_h_thd = 0.2;
Cxx_cyl_fill_trap_efy_dz_l_thd = 1;
Cxx_min_cyl_fill_mdl_ex_mfld_prs_rat_cor = 0;
Cxx_cyl_fill_trap_efy_dz_pos_slop = 0.5;
Cxx_cyl_fill_trap_efy_dz_neg_slop = -0.5;
