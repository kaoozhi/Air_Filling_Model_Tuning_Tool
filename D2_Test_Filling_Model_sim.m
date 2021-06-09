% clear
close all
clc
addpath(genpath(cd))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To do: load calibration
load MapFilling_Aspirated_0318_2_DataBase_all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Gen_calib_for_sim;
run('Cal_basic.m')
run('Calib_mdl_RSA.m')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To do: choose dataset to be tested
% data_list = {'SDS/2757/SDS_calib_all_extrap','SDS/2757/SDS_calib_all',...
%     'VVT0/2757/H5F6_E_083','VVT0/2757/H5F6_E_123','VVT0/2758A/H5F6_E_027',...
%     'VVTauto/2757/H5F6_E_266','VVTauto/2757/H5F6_E_310','VVTauto/2757/H5F6_E_326','VVTauto/2757/H5F6_E_498','VVTauto/2758A/H5F6_E_049','VVTauto/2764/H5F6_E_036','VVTauto/2761A_CATA/H5F_E_121',...
%     'VH/ISO_VH_low_load_1000mbar'};
data_list ={'VVTauto/2764/H5F6_E_036', 'VVTauto/2764/H5F6_E_179'};
name_list = data_list;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Cnx_cyl_fill_ex_mfld_prs_cor_cho = 0;
for k = 1: length(data_list)
    
    Data = load(['Input_data/DataBase/' data_list{k} '.mat']);
    
    var_names= fieldnames(Data);
    for i=1:length(var_names)
        
        Data_rep.(var_names{i}) = repmat(Data.(var_names{i}),1,10);
        Data_rep.(var_names{i}) = reshape(Data_rep.(var_names{i})',size(Data_rep.(var_names{i}),1)*10,1);
    end
    
    Input.N_rpm = Data_rep.N; % rpm
    %     Input.Pman_kPa = Data_rep.P_A_COL/10; % kPa
    Input.Pman_kPa = Data_rep.MAP; % kPa
    
    try
        %         Input.Patm_kPa = Data_rep.BARO/10;
        Input.Patm_kPa = Data_rep.AMPECU;
    catch
        Input.Patm_kPa = ones(size(Input.N_rpm))*101.3;
    end
    
    try
        Input.Pdif_rel_kPa = Data_rep.PDIF_REL;
    catch
        Input.Pdif_rel_kPa= zeros(size(Input.N_rpm));
    end
    
    try
        Input.Vxx_cyl_pump_flow_sw = Data_rep.CYLPUMPFLW;
    catch
        Input.Vxx_cyl_pump_flow_sw = Data_rep.N*0;
    end
    
    
    Input.Tman_degC = Data_rep.MAT; % degC
    Input.QA_kgh = Data_rep.QA; %Kg/h
    Input.Texh_degC = Data_rep.T_AVT; % degC
    Input.VVTint_degCA = Data_rep.VVTCA;% degCA;
    Input.VVTexh_degCA = Data_rep.VVTCE;% degCA;
    Input.QAMGC_mgstr = Data_rep.QAMGC;% mg/str;
    try
        Input.Tco_degC = Data_rep.TCO;
    catch
        Input.Tco_degC = ones(size(Input.N_rpm))*90;
    end
    
    Cbx_cyl_fill_efy_opt_cho = true;
    ipoint=(0:1:length(Input.N_rpm)-1)';
    dt = 1;
    
    sim('Test_Model_HR12_2016.slx')
    
    figure(k)
    
    set(gcf,'position',[0 0 1600 450],'PaperPositionMode','auto');
    
    Masp_mes = downsample(Data_rep.QAMGC,10);
    
    Masp_IFP=downsample(double(Masp_mdl(2:end-1,1)),10);
    
    Masp_vect(k).mes= Masp_mes;
    Masp_vect(k).est= Masp_IFP;
    
    subplot(1,5,1)
    analysis_plot(Masp_IFP,Masp_mes,name_list{k},k);
    
    subplot(1,5,[2,3 4])
    EngineMap(Data.N, Data.MAP,Masp_IFP,Masp_mes,'MDL\_IFP');
    
    subplot(1,5,5)
    histerr(Masp_IFP, Masp_mes,'MDL\_IFP');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% To do: uncomment following codes to define path and save figures if needed
    %     fig_path = 'Figures/Cal_0318/';
    %     tt = [fig_path strrep(name_list{k}, '/', '_')];
    %     save_figs(tt);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    clear Data_rep
end


figure(k+1)
set(gcf,'position',[0 0 1600 450],'PaperPositionMode','auto');
for j=1:length(name_list)
    
    % Get the width and height of the figure
    lbwh = get(1, 'position');
    figw = lbwh(3);
    figh = lbwh(4);
    
    % Number of rows and columns of axes
    ncols = length(name_list);
    nrows = 1;
    
    % w and h of each axis in normalized units
    axisw = (1-0.1)/ncols;
    axish = (1 / nrows);
    
    % calculate the left, bottom coordinate of this subplot
    axisl = (axisw) *(j-1)+ 0.07;
    axisb = 0.15;
    
    %%Histogram:
    h=subplot(1,length(name_list),j);
    set(h, 'position', [axisl, axisb, axisw*0.8, axish*0.7]);
    analysis_plot(Masp_vect(j).est,Masp_vect(j).mes,name_list{j},j);
    
end
legend('MDL\_IFP','Location','Southeast')

