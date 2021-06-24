    sim('Sim_mdl/Test_Model_HR12_2016')
    Masp = Input.QAMGC_mgstr(2:end);
    Vxx_intk_air_flow = Input.Vxx_intk_air_flow(2:end);
    Vxx_cyl_pump_flow_sw = Input.Vxx_cyl_pump_flow_sw(2:end);
    Vxx_cyl_pump_flow_sim = Qasp(2:end-1);
    Masp_IFP=double(Masp_mdl(2:end-1,1));
    Vxx_avg_eng_spd = Input.N_rpm(2:end); % rpm
    Vxx_intk_mfld_prs = Input.Pman_kPa(2:end); % kPa
    
    movlp_bas=double(Movlp_bas(2:end-1,1));
    movlp_bas_nomi=double(Movlp_bas_nomi(2:end-1,1));
    mivc_bas =double(Mivc_bas(2:end-1,1));
    mevc_bas=double(Mevc_bas(2:end-1,1));
    mevc_bas_nomi=double(Mevc_bas_nomi(2:end-1,1));
    prs_ratio = double(Pexh_ratio(2:end-1,1));
    prs_diff = double(Pexh_diff(2:end-1,1));
    Movlp_mdl = double(Movlp(2:end-1,1));
    
    err_rel_maf = Masp_IFP./Masp-1;
    try 
        Data_rep.Vxx_rich_mes;
    catch
        Data_rep.Vxx_rich_mes = Data_rep.Vxx_rich_mes_100ms;
    end
    err_rel_eal = (1./(Data_rep.Vxx_ol_ti_fac(2:end).*Data_rep.Vxx_mv_cl_ti_fac(2:end)./Data_rep.Vxx_rich_mes(2:end))-1);
    Vxx_eal = Data_rep.Vxx_eal(2:end);
    Vxx_eal_cible_rich_mes = Data_rep.Vxx_ol_ti_fac(2:end).*Data_rep.Vxx_mv_cl_ti_fac(2:end)./Data_rep.Vxx_rich_mes(2:end).*Vxx_eal;    
    Plot_ovlp;
    suplabel(strrep(name_list{k},'_','\_') ,'t');