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
    ftsz = 10;
    
    figure;
    nb_col = 1;
    Vxx_cyl_pump_flow = Vxx_cyl_pump_flow_sim;
    
    Vxx_cyl_pump_flow_nomi = (mivc_bas - movlp_bas_nomi -mevc_bas_nomi).*(3.*Vxx_avg_eng_spd/120/1000);
    
    
    set(gcf,'position',[0 0 1600 900],'PaperPositionMode','auto');
    ax(1) = subplot(4,nb_col,1);
    hold on; grid
    
    p = plot(Vxx_cyl_pump_flow,'o','linewidth',1);
    C = get(p,'color');
    plot(Vxx_cyl_pump_flow_nomi,'o','linewidth',1);
    plot(Vxx_intk_air_flow,'x','linewidth',1);
    ylabel('MAF (g/s)','fontsize',ftsz)
    xlim([1 length(Masp)])
    lg = legend('model w/ cor','model w/o cor','HFM','Location','Best');
    title('MAF - Comparaison')
    
    ax(3) = subplot(4,nb_col,2);
    
    
    hold on; grid
    err_cyl_flow = Vxx_cyl_pump_flow./Vxx_intk_air_flow-1;
    err_cyl_flow_nomi = Vxx_cyl_pump_flow_nomi./Vxx_intk_air_flow-1;
    plot(err_cyl_flow,'x','linewidth',1)
    plot(err_cyl_flow_nomi,'x','linewidth',1)
    plot(Vxx_intk_air_flow*0+0.95-1,'k--')
    plot(Vxx_intk_air_flow*0+1.05-1,'k--')
    legend('model w/ cor','model w/o cor','Location','Best');
    xlim([1 length(Masp)])
    ylim([0.8 1.2]-1)
    %      xlabel('Point number','fontsize',ftsz)
    ylabel('Relative error (-)','fontsize',ftsz)
    
    linkaxes([ax(1),ax(3)],'x');
    ax(5) = subplot(4,nb_col,[3 4]);
%     temp_y = Vxx_intk_air_flow./(Vxx_intk_air_flow+1);
    EngineMap_notext(Vxx_avg_eng_spd,Vxx_intk_mfld_prs+prs_diff,Vxx_cyl_pump_flow,Vxx_intk_air_flow,'MODEL W/ COR');
%     VVTCA = Input.VVTint_degCA(2:end);
%     VVTCE = Input.VVTexh_degCA(2:end);
%     x = Vxx_intk_air_flow;
%     temp_y = x./(x+1);

%     EngineMap_notext(Vxx_avg_eng_spd,Vxx_intk_mfld_prs+prs_diff,x, temp_y,'HFM[g/s]');
%     ax(2) = subplot(422);
%     hold on; grid
%     plot(Vxx_eal_cible_rich_mes,'x','linewidth',1)
%     p = plot(Vxx_eal,'o','linewidth',1);
%     C = get(p,'color');
%     ylabel('EAL [-]','fontsize',ftsz)
%     xlim([1 length(Masp)])
%     lg = legend('EAL\_cible','EAL','Location','Best');
%     title('EAL - Comparaison')
%     
%     ax(4) = subplot(424);
%     err_eal = Vxx_eal./Vxx_eal_cible_rich_mes-1;
%     hold on; grid
%     plot(err_eal,'x','color',C,'linewidth',1.5)
%     plot(Vxx_eal_cible_rich_mes*0+0.05,'k--')
%     plot(Vxx_eal_cible_rich_mes*0-0.05,'k--')
%     xlim([1 length(Vxx_eal_cible_rich_mes)])
%     ylim([0.8 1.2]-1)
%     %      xlabel('Point number','fontsize',ftsz)
%     ylabel('Relative Estimation (-)','fontsize',ftsz)
%     linkaxes([ax(2),ax(4)],'x');
%     ax(6) = subplot(4,2,[6 8]);
%     EngineMap_notext(Vxx_avg_eng_s    pd,Vxx_intk_mfld_prs,Vxx_eal,Vxx_eal_cible_rich_mes,'EAL');

    suplabel(strrep(name_list{k},'_','\_') ,'t');