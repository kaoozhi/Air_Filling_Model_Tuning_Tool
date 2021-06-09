clear
close all
addpath(genpath(cd))

load MapFilling_Aspirated_0318_2_DataBase_all

run('Cal_basic.m')
run('Calib_mdl_RSA.m')
Gen_calib_for_sim;

% data_list = {'Alti/0m/ExportPCMAP_07-05-2021_HR12_BAL11_MC502_65A_0m_20C_ISO_NTQI_EGR_OFF1_filtered_extracted'};
data_list = {'Alti/HR12_BAL11_MC502_65A_1000_1500_2000_2500m_calib_2500m_valid_conc'};
% data_list = {'Alti/2500m/Valid/ExportPCMAP_31-05-2021_HR12_BAL11_MC502_65A_2500m_20C_ISO_NTQI_EGR_off_valid_filtered_extracted'};

% data_list = {'Alti/2500m/Calib/ExportPCMAP_12-05-2021_HR12_BAL11_MC502_65A_2500m_20C_ISO_NTQI_EGR_OFF_1_filtered_extracted',...
%     'Alti/2500m/Calib/ExportPCMAP_12-05-2021_HR12_BAL11_MC502_65A_2500m_20C_ISO_NTQI_EGR_OFF_1',...
%     'Alti/2500m/Valid/ExportPCMAP_31-05-2021_HR12_BAL11_MC502_65A_2500m_20C_ISO_NTQI_EGR_off_valid_filtered_extracted',...
%     'Alti/2500m/Valid/ExportPCMAP_31-05-2021_HR12_BAL11_MC502_65A_2500m_20C_ISO_NTQI_EGR_off_valid',...
%     'Alti/2000m/ExportPCMAP_12-05-2021_HR12_BAL11_MC502_65A_2000m_20C_ISO_NTQI_EGR_OFF_1_filtered_extracted',...
%     'Alti/2000m/ExportPCMAP_12-05-2021_HR12_BAL11_MC502_65A_2000m_20C_ISO_NTQI_EGR_OFF_1',...
%     'Alti/1500m/ExportPCMAP_12-05-2021_HR12_BAL11_MC502_65A_1500m_20C_ISO_NTQI_EGR_OFF_1_filtered_extracted',...
%     'Alti/1500m/ExportPCMAP_12-05-2021_HR12_BAL11_MC502_65A_1500m_20C_ISO_NTQI_EGR_OFF_1',...
%     'Alti/1000m/ExportPCMAP_12-05-2021_HR12_BAL11_MC502_65A_1000m_20C_ISO_NTQI_EGR_OFF_1_filtered_extracted',...
%     'Alti/1000m/ExportPCMAP_12-05-2021_HR12_BAL11_MC502_65A_1000m_20C_ISO_NTQI_EGR_OFF_1'};


Cnx_cyl_fill_ex_mfld_prs_cor_cho =2;
name_list = data_list;
% load Cal_cor_alti_0527;
% load Cal_cor_alti_0527_v2;
% run('Cal_cor_alti_0602.m')
% load Cal_cor_alti_0531_cyrille;
% load Cal_cor_alti_0607;

for k = 1: length(data_list)
    
    Data = load(['Input_data/' data_list{k} '.mat']);
    var_names= fieldnames(Data);
    
    for i=1:length(var_names)
        temp_var_name = strrep(var_names{i},'_XETK_1','');
        Data_rep.(temp_var_name) = repmat(Data.(var_names{i}),1,1);
    end
    
    
    %% Bench Labels
    
    %     Input.N_rpm = Data_rep.N; % rpm
    % %     Input.Pman_kPa = Data_rep.P_A_COL/10; % kPa
    %     Input.Pman_kPa = Data_rep.MAP; % kPa
    %     Input.Tman_degC = Data_rep.MAT; % degC
    %     Input.QA_kgh = Data_rep.QA; % degC
    %     Input.Texh_degC = Data_rep.T_AVT; % degC
    %     Input.VVTint_degCA = Data_rep.VVTCA;% degCA;
    %     Input.VVTexh_degCA = Data_rep.VVTCE;% degCA;
    %     Input.QAMGC_mgstr = Data_rep.QAMGC;% mg/str;
    %     try
    %         Input.Tco_degC = Data_rep.TCO;
    %     catch
    %         Input.Tco_degC = ones(size(Input.N_rpm))*90;
    %     end
    %     try
    % %         Input.Patm_kPa = Data_rep.BARO/10;
    %         Input.Patm_kPa = Data_rep.AMPECU;
    %     catch
    %         Input.Patm_kPa = ones(size(Input.N_rpm))*101.3;
    %     end
    %
    %     try
    %         Input.Pdif_rel_kPa = Data_rep.PDIF_REL;
    %     catch
    %         Input.Pdif_rel_kPa= zeros(size(Input.N_rpm));
    %     end
    %
    %     Input.Vxx_cyl_pump_flow_sw = Data_rep.CYLPUMPFLW;
    %     Input.Vxx_intk_air_flow = Input.QA_kgh/3.6;
    
    % %% SW Labels INCA
    %     Input.N_rpm = Data_rep.Vxx_avg_eng_spd_XETK_1; % rpm
    %     Input.Pman_kPa = Data_rep.Vxx_intk_mfld_prs_XETK_1; % kPa
    %     Input.Tman_degC = Data_rep.Vxx_intk_mfld_temp_XETK_1; % degC
    %     try
    %     Input.Texh_degC = Data_rep.Vxx_ex_mfld_temp_XETK_1; % degC
    %     catch
    %     Input.Texh_degC = 750*ones(size(Data_rep.Vxx_avg_eng_spd_XETK_1)); % degC
    %     end
    %     Input.VVTint_degCA = Data_rep.Vxx_vvt_intk_angl_XETK_1;% degCA;
    %     Input.VVTexh_degCA = Data_rep.Vxx_vvt_ex_angl_XETK_1;% degCA;
    %     Input.QAMGC_mgstr = Data_rep.Vxx_intk_air_flow_XETK_1./(3.*Data_rep.Vxx_avg_eng_spd_XETK_1/120/1000);% mg/str;
    %     Input.QA_kgh=Data_rep.Vxx_intk_air_flow_XETK_1*3.6;%g/s
    %
    %     try
    %         Input.Tco_degC = Data_rep.Vxx_eng_cool_temp_XETK_1;
    %     catch
    %         Input.Tco_degC = ones(size(Input.N_rpm))*90;
    %     end
    %
    %     try
    % %         Input.Patm_kPa = Data_rep.BARO/10;
    %         Input.Patm_kPa = Data_rep.Vxx_atm_prs_XETK_1;
    %     catch
    %         Input.Patm_kPa = ones(size(Input.N_rpm))*101.3;
    %     end
    %
    %     try
    %         Input.Pdif_rel_kPa = Data_rep.Vxx_pft_rel_diff_prs_XETK_1;
    %     catch
    %         Input.Pdif_rel_kPa= zeros(size(Input.N_rpm));
    %     end
    %
    %     Input.Vxx_cyl_pump_flow_sw = Data_rep.Vxx_cyl_pump_flow_XETK_1;
    %     Input.Vxx_intk_air_flow = Data_rep.Vxx_intk_air_flow_XETK_1;
    
    % Input.eta_wu=Vxt_cyl_fill_efy_para_mdl__0__XETK_1;
    
    %% SW Labels
    Input.N_rpm = Data_rep.Vxx_avg_eng_spd; % rpm
    Input.Pman_kPa = Data_rep.Vxx_intk_mfld_prs; % kPa
    Input.Tman_degC = Data_rep.Vxx_intk_mfld_temp; % degC
    try
        Input.Texh_degC = Data_rep.Vxx_ex_mfld_temp; % degC
    catch
        Input.Texh_degC = 750*ones(size(Data_rep.Vxx_avg_eng_spd)); % degC
    end
    Input.VVTint_degCA = Data_rep.Vxx_vvt_intk_angl;% degCA;
    Input.VVTexh_degCA = Data_rep.Vxx_vvt_ex_angl;% degCA;
    Input.QAMGC_mgstr = Data_rep.Vxx_intk_air_flow./(3.*Data_rep.Vxx_avg_eng_spd/120/1000);% mg/str;
    Input.QA_kgh=Data_rep.Vxx_intk_air_flow*3.6;%g/s
    
    try
        Input.Tco_degC = Data_rep.Vxx_eng_cool_temp;
    catch
        Input.Tco_degC = ones(size(Input.N_rpm))*90;
    end
    
    try
        %Input.Patm_kPa = Data_rep.BARO/10;
        Input.Patm_kPa = Data_rep.Vxx_atm_prs;
    catch
        Input.Patm_kPa = ones(size(Input.N_rpm))*101.3;
    end
    
    try
        Input.Pdif_rel_kPa = Data_rep.Vxx_pft_rel_diff_prs;
    catch
        Input.Pdif_rel_kPa= zeros(size(Input.N_rpm));
    end
    
    Input.Vxx_cyl_pump_flow_sw = Data_rep.Vxx_cyl_pump_flow;
    Input.Vxx_intk_air_flow = Data_rep.Vxx_intk_air_flow;
    
    Cbx_cyl_fill_efy_opt_cho = true;
    ipoint=(0:1:length(Input.N_rpm)-1)';
    dt = 0.1;
    
    
    %% Step1: Run simulation w/o correction
    Launch_sim_cor_alti;
    err_cyl_flow_base =  err_cyl_flow;
    
    %% Step2: Tune tables and run simulation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% To do: load tuned calibration file of Cxm_cyl_fill_mdl_intk_mfld_prs_diff_cor_fac
    xlspath = 'Calib_cor_alti_0531_Cyrille.xlsx';
    [num_input text_input all_input]=xlsread(xlspath,1);
    Cxm_cyl_fill_mdl_intk_mfld_prs_diff_cor_fac = num_input(2:end,2:end)';
    %% To do: tune Cxp_cyl_fill_mdl_intk_mfld_prs_diff
    Cxb_cyl_fill_mdl_intk_mfld_prs_diff_bas = [-40,-20,-12,-5,0,6,12,16,18,20,22,25,26.5,29,30,35];
    Cxp_cyl_fill_mdl_intk_mfld_prs_diff = [-40,-20,-12,-5,0,6,12,16,18,20,22,25-2,27-3.5,29-4,30-4,35-4];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Run simulation w/ tuned values
    Cxm_cyl_fill_mdl_ex_mfld_prs_rat_cor_fac = ones(16);
    Launch_sim_cor_alti;
    figure
    surf(Cxb_cyl_fill_eng_spd,Cxb_cyl_fill_intk_mfld_prs, Cxm_cyl_fill_mdl_intk_mfld_prs_diff_cor_fac')
    zlabel('f')
    xlabel('Engine speed(rpm)')
    ylabel('Corrected Pman(kPa)')
    title('MAP = h(N,P_{man\_cor})')
    
    
    %% Step3: reoptimize values of Cxm_cyl_fill_mdl_ex_mfld_prs_rat_cor_fac
    err_cyl_flow_h = err_cyl_flow;
    Optim_cor_P3_alpha3;
    
    %     clear Data_rep
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To do: uncomment sections bellow to save calibration
% Cal_alti.Cxb_cyl_fill_mdl_intk_mfld_prs_diff_bas = Cxb_cyl_fill_mdl_intk_mfld_prs_diff_bas;
% Cal_alti.Cxm_cyl_fill_mdl_ex_mfld_prs_rat_cor_fac = Cxm_cyl_fill_mdl_ex_mfld_prs_rat_cor_fac;
% Cal_alti.Cxm_cyl_fill_mdl_intk_mfld_prs_diff_cor_fac=Cxm_cyl_fill_mdl_intk_mfld_prs_diff_cor_fac;
% Cal_alti.Cxp_cyl_fill_mdl_intk_mfld_prs_diff = Cxp_cyl_fill_mdl_intk_mfld_prs_diff;

% save('Tool_Correction_P3\Calib\Cal_cor_alti_.mat','-struct','Cal_alti');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



