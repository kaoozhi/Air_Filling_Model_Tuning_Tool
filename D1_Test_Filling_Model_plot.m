clear
close all
clc
addpath(genpath(cd))

%% Engine Geometry Input
B  = 136.5e-3;    % Longueur de la bielle (en m)
M  = 44.63e-3;     % Longueur de la manivelle (en m)
Dp = 0e-3;        % D?saxage polaris? du piston (en m)(Rbm*sqrt(1-(Nu*Nu)))
Dv = 0.5e-3;      % D?saxage polaris? du vilebrequin (en m)
A  = 75.5e-3;     % Diam?tre al?sage (en m)
Vm = 3.6329e-05;  % Volume mort (en m3)


%% Load model
% load MapFilling_Aspirated_1215_DataBase_all
load MapFilling_Aspirated_0120_2_DataBase_all

data_list = {'SDS/2757/SDS_calib_all_extrap','SDS/2757/SDS_calib_all',...
    'VVT0/2757/H5F6_E_083','VVT0/2757/H5F6_E_123','VVT0/2758A/H5F6_E_027',...
    'VVTauto/2757/H5F6_E_266','VVTauto/2757/H5F6_E_310','VVTauto/2757/H5F6_E_326','VVTauto/2757/H5F6_E_498','VVTauto/2758A/H5F6_E_049','VVTauto/2764/H5F6_E_036','VVTauto/2761A_CATA/H5F_E_121',...
    'VH/ISO_VH_low_load_1000mbar'};

Masp_all=[];
Masp_est_all=[];
Cxb_cyl_fill_mdl_ex_vlv_cls_angl_cyl_vol=[310.0000000 316.0000000 322.0000000 328.0000000 334.0000000 340.0000000 346.0000000 352.0000000 358.0000000 364.0000000 370.0000000 376.0000000 382.0000000 388.0000000 394.0000000 400.0000000 ];
Cxb_cyl_fill_mdl_intk_vlv_cls_angl_cyl_vol=[430.0000000 438.6666667 447.3333333 456.0000000 464.6666667 473.3333333 482.0000000 490.6666667 499.3333333 508.0000000 516.6666667 525.3333333 534.0000000 542.6666667 551.3333333 560.0000000 ];
Cxp_cyl_fill_mdl_ex_vlv_cls_angl_cyl_vol = Volume_HR12(Cxb_cyl_fill_mdl_ex_vlv_cls_angl_cyl_vol);
Cxp_cyl_fill_mdl_intk_vlv_cls_angl_cyl_vol = Volume_HR12(Cxb_cyl_fill_mdl_intk_vlv_cls_angl_cyl_vol);
Cxm_eng_cool_pump_intk_vlv_flow_efy = [0.100000001490116,0.0649999976158142,0.0500000007450581,0.0350000001490116,0.0299999993294478,0.0299999993294478,0.0250000003725290,0.0250000003725290,0.0250000003725290,0.0250000003725290,0.0250000003725290,0.0250000003725290,0.0250000003725290,0.0250000003725290,0.0250000003725290,0.0250000003725290];
Cxb_intk_vlv_flow_efy = [0,12,24,36,48,60,72,84,96,108,120,132,144,156,168,180];
for kk = 1:length(data_list)
    %% Load data

    Data = load(['Input_data/DataBase/' data_list{kk} '.mat']);


    Ne = Data.N; % rpm
    Masp = Data.QAMGC; % mg
    Pman = Data.MAP*1e3; % Pa
    Tman = Data.MAT+273.15; % K
    Tco = Data.TCO+273.15; %K
    Texh = Data.T_AVT+273.15; %K
    VVTint = Data.VVTCA;%degCA
    VVTexh = Data.VVTCE;%degCA
    
    QA = Data.QA;%kg/h
    
    Tvlv = (Tco-Tman).*interp1(Cxb_intk_vlv_flow_efy,Cxm_eng_cool_pump_intk_vlv_flow_efy,QA/3.6)+Tman;
    Tman = Tvlv;
    
    Ne = min(6500,Ne);
    IVC = MapFilling_Aspirated.IVC-VVTint;
    EVC = MapFilling_Aspirated.EVC+VVTexh;
    delta_IVC = interp1(MapFilling_Aspirated.delta_ivc.x,MapFilling_Aspirated.delta_ivc.y,Ne);
    Vivc = interp1(Cxb_cyl_fill_mdl_intk_vlv_cls_angl_cyl_vol,Cxp_cyl_fill_mdl_intk_vlv_cls_angl_cyl_vol,IVC-delta_IVC);
    Vevc = interp1(Cxb_cyl_fill_mdl_ex_vlv_cls_angl_cyl_vol,Cxp_cyl_fill_mdl_ex_vlv_cls_angl_cyl_vol,EVC);
    
    
    VVTint = min(60,VVTint);
    VVTint = max(0,VVTint);
    VVTexh = min(60,VVTexh);
    VVTexh = max(0,VVTexh);
    %
    
    %% Compute estimation
    alpha1 = interp2(MapFilling_Aspirated.Alpha1.x,MapFilling_Aspirated.Alpha1.y,MapFilling_Aspirated.Alpha1.z',Ne,Pman);
    alpha2 = interp2(MapFilling_Aspirated.Alpha2.x,MapFilling_Aspirated.Alpha2.y,MapFilling_Aspirated.Alpha2.z',Ne,Pman);
    alpha3 = interp2(MapFilling_Aspirated.Alpha3.x,MapFilling_Aspirated.Alpha3.y,MapFilling_Aspirated.Alpha3.z',Ne,Pman);
    OF = interp2(MapFilling_Aspirated.OF.x,MapFilling_Aspirated.OF.y,MapFilling_Aspirated.OF.z,VVTint,VVTexh);
    R = MapFilling_Aspirated.R;
    Masp_est = (alpha1.*Pman.*Vivc./(R*Tman) - alpha2.*OF.*1e6./Ne  - max(0,alpha3.*Vevc)).*1e6;
    Migr_est = max(0,(alpha2.*OF.*1e6./Ne  + max(0,alpha3.*Vevc)).*1e6);
    IGR = Migr_est.*Tman./Texh./(Migr_est.*Tman./Texh+Masp_est);
    
    
    %% Plot performance figures
    ftsz = 14;
    
    err_mean = 100*nanmean(abs((Masp-Masp_est)./Masp));
    count_totp = length(Masp);
    count_tot = sum(~isnan(Masp_est));
    rel_error = abs(Masp_est./Masp*100-100);
    count_b10pct = sum(rel_error<10);
    count_b5pct = sum(rel_error<5);
    count_b3pct = sum(rel_error<3);
    disp('    -----------------------------------------')
    disp(['    ' data_list{kk}])
    disp(['    Average error : ' num2str(err_mean,'%0.2f') ' %'])
    disp(['    Total estimated data points : ' num2str(count_tot) ' (' num2str(count_tot/count_totp*100,'%0.1f') '%)'])
    disp(['    Below 10% error data points : ' num2str(count_b10pct) ' (' num2str(count_b10pct/count_totp*100,'%0.1f') '%)'])
    disp(['    Below 5% error data points : ' num2str(count_b5pct) ' (' num2str(count_b5pct/count_totp*100,'%0.1f') '%)'])
    disp(['    Below 3% error data points : ' num2str(count_b3pct) ' (' num2str(count_b3pct/count_totp*100,'%0.1f') '%)'])
    disp('    -----------------------------------------')
    
    figure
    set(gcf,'position',[20 50 1600 450],'PaperPositionMode','auto');
    
    ax(1) = subplot(311);
    hold on; grid
    plot(Masp,'-x','linewidth',2)
    p = plot(Masp_est,'-o','linewidth',2);
    C = get(p,'color');
    xlabel('Point number','fontsize',ftsz)
    ylabel('Masp (mg/str)','fontsize',ftsz)
    xlim([1 length(Masp)])
    lg = legend('measurement','model');
    set(lg,'fontsize',ftsz);
    title(strrep(data_list{kk},'_','\_'))
    ax(2) = subplot(312);
    hold on; grid
    plot(Masp_est./Masp,'x','color',C,'linewidth',2)
    plot(Masp*0+0.95,'k--')
    plot(Masp*0+1.05,'k--')
    xlim([1 length(Masp)])
    ylim([0.8 1.2])
    xlabel('Point number','fontsize',ftsz)
    ylabel('Relative Estimation (-)','fontsize',ftsz)
    ax(3) = subplot(313);
    hold on; grid
    plot(IGR*100,'-o','color',C)
    xlim([1 length(Masp)])
    ylim([-10 30])
    xlabel('Point number','fontsize',ftsz)
    ylabel('IGR (%)','fontsize',ftsz)
    
    x = -20:20;
    figure, hist(100*(Masp-Masp_est)./Masp,x), grid
    xlim([x(1) x(end)])
    xlabel('Relative error (%)','fontsize',ftsz)
    eval(['ylabel(''Number of points (total = ',num2str(sum(~isnan(Masp_est))),')'',''fontsize'',',num2str(ftsz),')'])
    tt = title([strrep(data_list{kk},'_','\_') ' - Mean relative error: ',num2str(err_mean),' %']);
    set(tt,'fontsize',ftsz);
    set(gcf,'PaperPositionMode','Auto');
    
   
    Masp_all=[Masp_all;Masp];
    Masp_est_all=[Masp_est_all;Masp_est];
    
end

% figure
% set(gcf,'position',[100 100 1200 600],'PaperPositionMode','auto');
% 
% ax(1) = subplot(211);
% hold on, grid
% plot(Masp_all,'-*'), plot(Masp_est_all,'-o')
% xlabel('Point number','fontsize',ftsz)
% ylabel('Masp (mg/str)','fontsize',ftsz)
% lg = legend('Measurement','Model');
% set(lg,'fontsize',ftsz);
% tt=['SDS+VVT0+VVTauto (' num2str(length(Masp_all)) 'points)'];
% title(tt)
% ax(2) = subplot(212);
% hold on, grid
% plot(Masp_all,Masp_all+.05*Masp_all,'r','linewidth',2)
% plot(Masp_all,Masp_all-.05*Masp_all,'r','linewidth',2)
% plot(Masp_all,Masp_est_all,'.')
% xlim([min(Masp_all) max(Masp_all)])
% ylim([min(Masp_all) max(Masp_all)])
% xlabel('Masp measure (mg/str)','fontsize',ftsz)
% ylabel('Masp model (mg/str)','fontsize',ftsz)
% lg = legend('+- 5%');
% set(lg,'fontsize',ftsz,'location','northwest');
% set(gcf,'PaperPositionMode','Auto');
% 
% err_mean_all = 100*nanmean(abs((Masp_all-Masp_est_all)./Masp_all));
% x = -20:20;
% figure, hist(100*(Masp_all-Masp_est_all)./Masp_all,x), grid
% xlim([x(1) x(end)])
% xlabel('Relative error (%)','fontsize',ftsz)
% eval(['ylabel(''Number of points (total = ',num2str(length(Masp_all)),')'',''fontsize'',',num2str(ftsz),')'])
% tt = title(['All dataset(' num2str(length(Masp_all)) 'points): Mean relative error:' ,num2str(err_mean_all),' %']);
% set(tt,'fontsize',ftsz);
% set(tt,'fontsize',12);
% set(gcf,'PaperPositionMode','Auto');
% title('SDS+VVT0 (2693 points)');

