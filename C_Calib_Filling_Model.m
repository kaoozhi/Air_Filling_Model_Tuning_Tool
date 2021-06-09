clear
close all
clc

addpath(genpath(cd))
tic


%% Initialize variables
R = 287; % J/kg/K - gas constant
Ne_window = 20; % rpm  - engine speed selection window
Pman_window = 0.030e5; % Pa - manifold pressure selection window
err_threshold = 0.005; % nodim - dIVC optimisation stop criteria
smooth_alpha1 = [10 10]; % nodim - alpha1 smoothing parameter
smooth_alpha2 = [100 100]; % nodim - alpha2 smoothing parameter, for extrap use only
smooth_alpha3 = [100 100]; % nodim - alpha3 smoothing parameter, for extrap use only

%% Load experimental data
Ne = []; % rpm
Masp = []; % mg
Pman = []; % Pa
Tman = []; % K
Texh = []; % K
Tco = []; % K
QA = []; %Kg/h
VVTint = []; % degC
VVTexh = []; % degC

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% To do: Define database composition
data_list = {'SDS/2757/SDS_calib_all_extrap','SDS/2757/SDS_calib_all',...
    'VVT0/2757/H5F6_E_083','VVT0/2757/H5F6_E_123','VVT0/2758A/H5F6_E_027','VVT0/2988/H5F_E008','VVT0/3333/H5F_E35_37'...
    'VVTauto/2757/H5F6_E_266','VVTauto/2757/H5F6_E_310','VVTauto/2757/H5F6_E_326','VVTauto/2757/H5F6_E_498','VVTauto/2758A/H5F6_E_049','VVTauto/2764/H5F6_E_036','VVTauto/2761A_CATA/H5F_E_121',...
    'VVTauto/2988/H5F_E006', 'VVTauto/3333/H5F_E032',...
    'VH/ISO_VH_low_load_480mbar'};
%% To do : Define dataset weight
data_weight = [1 5, 25 25 25 25 25, 25 25 25 25 25 25 25 25 25, 25]; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for kk = 1:length(data_list)
    if data_weight(kk) > 0

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% To do: define database path
        Data = load(['Input_data/DataBase/' data_list{kk} '.mat']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        
        Ne = [Ne; repmat(Data.N,data_weight(kk),1)]; % rpm
        Masp = [Masp; repmat(Data.QAMGC*1e-6,data_weight(kk),1)]; % mg->kg
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% To do: choose right unit for intake manifold pressure
%         Pman = [Pman; repmat(Data.P_A_COL*1e2,data_weight(kk),1)]; % mbar -> Pa
        Pman = [Pman; repmat(Data.MAP*1e3,data_weight(kk),1)]; % kPa -> Pa
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        Tman = [Tman; repmat(Data.MAT+273.15,data_weight(kk),1)]; % K
        VVTint = [VVTint; repmat(Data.VVTCA,data_weight(kk),1)];
        VVTexh = [VVTexh; repmat(Data.VVTCE,data_weight(kk),1)];
        Tco = [Tco; repmat(Data.TCO+273.15,data_weight(kk),1)];
        QA = [QA; repmat(Data.QA,data_weight(kk),1)];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To do: Calculate valve temperature if model calibrated, otherwise comment code from line 67 to line 70:
Cxm_eng_cool_pump_intk_vlv_flow_efy = [0.100000001490116,0.0649999976158142,0.0500000007450581,0.0350000001490116,0.0299999993294478,0.0299999993294478,0.0250000003725290,0.0250000003725290,0.0250000003725290,0.0250000003725290,0.0250000003725290,0.0250000003725290,0.0250000003725290,0.0250000003725290,0.0250000003725290,0.0250000003725290];
Cxb_intk_vlv_flow_efy = [0,12,24,36,48,60,72,84,96,108,120,132,144,156,168,180];
Tvlv = (Tco-Tman).*interp1(Cxb_intk_vlv_flow_efy,Cxm_eng_cool_pump_intk_vlv_flow_efy,QA/3.6)+Tman;
Tman = Tvlv;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To do: Load valve profile data
load Data_distri/MAP_Distri
%% To do: Load pre-calibration file if exists, otherwise comment out line 77
% load MapFilling_Aspirated_0318_DataBase_all

%% To do: define EVC and IVC breakpoints for volume law
Cxb_cyl_fill_mdl_ex_vlv_cls_angl_cyl_vol=[310.0000000 316.0000000 322.0000000 328.0000000 334.0000000 340.0000000 346.0000000 352.0000000 358.0000000 364.0000000 370.0000000 376.0000000 382.0000000 388.0000000 394.0000000 400.0000000 ];
Cxb_cyl_fill_mdl_intk_vlv_cls_angl_cyl_vol=[430.0000000 438.6666667 447.3333333 456.0000000 464.6666667 473.3333333 482.0000000 490.6666667 499.3333333 508.0000000 516.6666667 525.3333333 534.0000000 542.6666667 551.3333333 560.0000000 ];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Cxp_cyl_fill_mdl_ex_vlv_cls_angl_cyl_vol = Volume_HR12(Cxb_cyl_fill_mdl_ex_vlv_cls_angl_cyl_vol);
Cxp_cyl_fill_mdl_intk_vlv_cls_angl_cyl_vol = Volume_HR12(Cxb_cyl_fill_mdl_intk_vlv_cls_angl_cyl_vol);

% Vivc
IVC = IVC_ref-VVTint;
Vivc = interp1(Cxb_cyl_fill_mdl_intk_vlv_cls_angl_cyl_vol,Cxp_cyl_fill_mdl_intk_vlv_cls_angl_cyl_vol,IVC);

% Vevc
EVC = EVC_ref+VVTexh;
Vevc = interp1(Cxb_cyl_fill_mdl_ex_vlv_cls_angl_cyl_vol,Cxp_cyl_fill_mdl_ex_vlv_cls_angl_cyl_vol,EVC);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To do: Define breakpoints
% Engine speed breakpoints
Ne_vect = [600 750 1000,1250,1500,1750,2100,2500,3000,3500,4000,4500,5000,5500,6000 6500];
% Intake manifold pressure breakpoints [Pa]
Pman_vect = 1e3*[12.0 24.0 36.0 48.0 66.0 84.0 102.0 120.0 144.0 168.0 192.0 216.0 240.0 264.0 288.0 312.0];
% VVT breakpoints for OF
VVTCA_list=[0 2 8 23 31 38 45 53 60];
VVTCE_list=[0 7 10 13 29 43 55 58 60];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

VVTint = min(60,VVTint);
VVTint = max(0,VVTint);
VVTexh = min(60,VVTexh);
VVTexh = max(0,VVTexh);
Ne = round(Ne/50)*50;

%% Initialize fitting parameters
if exist('MapFilling_Aspirated','var')
    OF = interp2(MapFilling_Aspirated.OF.x,MapFilling_Aspirated.OF.y,MapFilling_Aspirated.OF.z,VVTint,VVTexh);
    Alpha1 = MapFilling_Aspirated.Alpha1.z;
    Alpha2 = MapFilling_Aspirated.Alpha2.z;
    Alpha3 = MapFilling_Aspirated.Alpha3.z;
    delta_angle_ivc = interp1(MapFilling_Aspirated.delta_ivc.x,MapFilling_Aspirated.delta_ivc.y,Ne_vect);
else
    OF = interp2(OF_map.x,OF_map.y,OF_map.z,VVTint,VVTexh);
    Alpha1 = nan(length(Ne_vect),length(Pman_vect));
    Alpha2 = nan(length(Ne_vect),length(Pman_vect));
    Alpha3 = nan(length(Ne_vect),length(Pman_vect));
    delta_angle_ivc = Ne_vect*0;
end


delta_angle_evc = Ne_vect*0;
OF(isnan(OF)) = 0;
[VVT_X, VVT_Y] = meshgrid(VVTCA_list,VVTCE_list);
VVT_config = [VVT_X(:) VVT_Y(:)];
OF2 = gridfit(VVTint,VVTexh,OF,VVTCA_list,VVTCE_list);
OF = interp2(VVTCA_list,VVTCE_list,OF2,VVTint,VVTexh);
OF(isnan(OF)) = 0;

%% Calibrate model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To do: Define maximum iteration number
max_iter=100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To do: Define breakpoints
VVTvar_min = 5; % minimum number of VVT variations for alpha computation
nb_iter=1;
avg_error_OF_old = 1e6;
avg_error_OF_new = 1e5;
while avg_error_OF_old - avg_error_OF_new > 1e-6 && nb_iter<max_iter
    avg_error_OF_old = avg_error_OF_new;
    avg_error_divc_old = 1e6;
    avg_error_divc_new = 1e5;
    while avg_error_divc_old - avg_error_divc_new > 1e-6%err_threshold
        avg_error_divc_old = avg_error_divc_new;
        %-- Alpha 1-3 update
        [Alpha1, Alpha2, Alpha3] = update_alpha(...
                                Alpha1, Alpha2, Alpha3,...
                                Ne_vect, Pman_vect,...
                                Ne_window, Pman_window, VVTvar_min,...
                                VVTint, VVTexh,...
                                Masp, Ne, Pman, Vivc, R, Tman, OF, Vevc);      
        alpha1 = interp2(Ne_vect,Pman_vect,Alpha1',Ne,Pman);
        alpha2 = interp2(Ne_vect,Pman_vect,Alpha2',Ne,Pman);
        alpha3 = interp2(Ne_vect,Pman_vect,Alpha3',Ne,Pman);
        
        %-- dIVC update
        [delta_angle_ivc, delta_angle_evc] = update_divc(...
            delta_angle_ivc, delta_angle_evc, ...
            Ne_vect, Ne_window,...
            alpha1, alpha2, alpha3,...
            IVC, EVC,...
            Masp, Ne, Pman, R, Tman, OF);

        delta_IVC = interp1(Ne_vect,delta_angle_ivc,min(max(Ne,min(Ne_vect)),max(Ne_vect)));
        Vivc = Volume_HR12(IVC-delta_IVC);
        delta_EVC = interp1(Ne_vect,delta_angle_evc,min(max(Ne,min(Ne_vect)),max(Ne_vect)));
        Vevc = Volume_HR12(EVC-delta_EVC);
        
        Masp_est = (alpha1.*Pman.*Vivc./(R*Tman) - alpha2.*OF.*1e6./Ne  - alpha3.*Vevc);

%         Masp_est = (alpha1.*Pman.*Vivc./(R*Tman) - alpha2.*OF.*1e6./Ne  - max(0,alpha3.*Vevc));

        avg_error_divc_new = 100*nanmean(abs((Masp-Masp_est)./Masp));
    end
    % -- OF update
    OF2 = update_OF(...
            OF2,OF,...
            VVTCA_list, VVTCE_list,...
            VVT_config, VVTint, VVTexh,...
            alpha1, alpha2, alpha3,...
            Masp, Ne, Pman, Vivc, R, Tman, Vevc);
    OF = interp2(VVTCA_list,VVTCE_list,OF2,VVTint,VVTexh);
    
    Masp_est = (alpha1.*Pman.*Vivc./(R*Tman) - alpha2.*OF.*1e6./Ne  - alpha3.*Vevc);
%     Masp_est = (alpha1.*Pman.*Vivc./(R*Tman) - alpha2.*OF.*1e6./Ne  - max(0,alpha3.*Vevc));

    avg_error_OF_new = 100*nanmean(abs((Masp-Masp_est)./Masp));
    
    disp(['Iteration:' num2str(nb_iter) ', Mean error: ' num2str(avg_error_OF_new) '%' ])
    nb_iter=nb_iter+1;
    disp(['    -----------------------------------------']);
end

%% Smooth alpha1; recalculate alpha2 and alpha3
[Y, X] = meshgrid(Pman_vect,Ne_vect);
Alpha1 = gridfit(X(:),Y(:),Alpha1,Ne_vect,Pman_vect,'smoothness',smooth_alpha1)';
for i = 1:length(Ne_vect)
    for j = 1:length(Pman_vect)
        sel = find(abs(Ne-Ne_vect(i)) < Ne_window & abs(Pman-Pman_vect(j)) < Pman_window);
        uniqueVVT = unique([round(VVTint(sel)) round(VVTexh(sel))],'rows');
        if (length(uniqueVVT) >= VVTvar_min) % condition for fitting
            Alpha = [-OF(sel).*1e6./Ne(sel) -Vevc(sel)];
            Y = Masp(sel)-Alpha1(i,j).*Pman(sel).*Vivc(sel)./(R*Tman(sel));
            X_hat = Alpha\Y;
            Alpha2(i,j) = X_hat(1);
            Alpha3(i,j) = X_hat(2);
        end
    end
end

%% Extrapolate alpha1 (skip top)
[Y, X] = meshgrid(Pman_vect,Ne_vect);
Alpha1_new = gridfit(X(:),Y(:),Alpha1,Ne_vect,Pman_vect,'smoothness',smooth_alpha1)';
Alpha1(isnan(Alpha1))=Alpha1_new(isnan(Alpha1));

%% Extrapolate alpha2
[Y, X] = meshgrid(Pman_vect,Ne_vect);
Alpha2_new = gridfit(X(:),Y(:),Alpha2,Ne_vect,Pman_vect,'smoothness',smooth_alpha2)';
Alpha2(isnan(Alpha2))=Alpha2_new(isnan(Alpha2));

%% Extrapolate alpha3
[Y, X] = meshgrid(Pman_vect,Ne_vect);
Alpha3_new = gridfit(X(:),Y(:),Alpha3,Ne_vect,Pman_vect,'smoothness',smooth_alpha3)';

Alpha3(isnan(Alpha3))=Alpha3_new(isnan(Alpha3));

%% Figures : Fitting Parameters
ftsz = 14;
View = [60 15];

figure
set(gcf,'position',[100 100 1500 400],'PaperPositionMode','auto');

subplot(131)
S = surf(Ne_vect,Pman_vect.*1e-5,Alpha1');
xlabel('Ne (rpm)','fontsize',ftsz)
ylabel('Pman (bar)','fontsize',ftsz)
zlabel('alpha_1','fontsize',ftsz)
xlim([min(Ne_vect) max(Ne_vect)])
ylim([min(Pman_vect.*1e-5) max(Pman_vect.*1e-5)])
shading interp
set(S,'edgecolor','k')
view(View)
title('Alpha 1')

subplot(132)
S = surf(Ne_vect,Pman_vect.*1e-5,Alpha2');
xlabel('Ne (rpm)','fontsize',ftsz)
ylabel('Pman (bar)','fontsize',ftsz)
zlabel('alpha_2','fontsize',ftsz)
xlim([min(Ne_vect) max(Ne_vect)])
ylim([min(Pman_vect.*1e-5) max(Pman_vect.*1e-5)])
set(gcf,'PaperPositionMode','Auto');
shading interp
set(S,'edgecolor','k')
view(View)
title('Alpha 2')

subplot(133)
S = surf(Ne_vect,Pman_vect.*1e-5,Alpha3');
xlabel('Ne (rpm)','fontsize',ftsz)
ylabel('Pman (bar)','fontsize',ftsz)
zlabel('alpha_3','fontsize',ftsz)
xlim([min(Ne_vect) max(Ne_vect)])
ylim([min(Pman_vect.*1e-5) max(Pman_vect.*1e-5)])
set(gcf,'PaperPositionMode','Auto');
shading interp
set(S,'edgecolor','k')
view(View)
title('Alpha 3')

figure, surf(VVTCA_list,VVTCE_list,OF2)
xlabel('VVTCA (deg)','fontsize',ftsz)
ylabel('VVTCE (deg)','fontsize',ftsz)
zlabel('OF','fontsize',ftsz)
set(gcf,'PaperPositionMode','Auto');
colormap jet
shading interp
view(3)
title('OF')

figure
hold on
plot(Ne_vect,delta_angle_ivc,'x-','linewidth',2)
plot(Ne_vect,delta_angle_evc,'x-','linewidth',2)
xlabel('Ne (rpm)','fontsize',ftsz)
ylabel('IVC correction (?V)','fontsize',ftsz)
grid on
title('\delta IVC')

%% Estimate Masp
alpha1 = interp2(Ne_vect,Pman_vect,Alpha1',Ne,Pman);
alpha2 = interp2(Ne_vect,Pman_vect,Alpha2',Ne,Pman);
alpha3 = interp2(Ne_vect,Pman_vect,Alpha3',Ne,Pman);

Masp_est = (alpha1.*Pman.*Vivc./(R*Tman) - alpha2.*OF.*1e6./Ne - max(0,alpha3.*Vevc));
% Masp_est = (alpha1.*Pman.*Vivc./(R*Tman) - alpha2.*OF.*1e6./Ne - alpha3.*Vevc);

%% Figures : Estimation Results
err_mean = 100*nanmean(abs((Masp-Masp_est)./Masp));
count_totp = length(Masp);
count_tot = sum(~isnan(Masp_est));
rel_error = abs(Masp_est./Masp*100-100);
count_b5pct = sum(rel_error<5);
count_b3pct = sum(rel_error<3);
disp(['    -----------------------------------------'])
disp(['    Average error : ' num2str(err_mean,'%0.2f') ' %'])
disp(['    Total estimated data points : ' num2str(count_tot) ' (' num2str(count_tot/count_totp*100,'%0.1f') '%)'])
disp(['    Below 5% error data points : ' num2str(count_b5pct) ' (' num2str(count_b5pct/count_totp*100,'%0.1f') '%)'])
disp(['    Below 3% error data points : ' num2str(count_b3pct) ' (' num2str(count_b3pct/count_totp*100,'%0.1f') '%)'])
disp(['    -----------------------------------------'])

figure
set(gcf,'position',[100 100 1200 600],'PaperPositionMode','auto');

ax(1) = subplot(211);
hold on, grid
plot(Masp*1e6,'-*'), plot(Masp_est*1e6,'-o')
xlabel('Point number','fontsize',ftsz)
ylabel('Masp (mg/str)','fontsize',ftsz)
lg = legend('Measurement','Model');
set(lg,'fontsize',ftsz);
ax(2) = subplot(212);
hold on, grid
plot(Masp*1e6,Masp*1e6+.05*Masp*1e6,'r','linewidth',2)
plot(Masp*1e6,Masp*1e6-.05*Masp*1e6,'r','linewidth',2)
plot(Masp*1e6,Masp_est*1e6,'.')
xlim([min(Masp*1e6) max(Masp*1e6)])
ylim([min(Masp*1e6) max(Masp*1e6)])
xlabel('Masp measure (mg/str)','fontsize',ftsz)
ylabel('Masp model (mg/str)','fontsize',ftsz)
lg = legend('+- 5%');
set(lg,'fontsize',ftsz,'location','northwest');
set(gcf,'PaperPositionMode','Auto');

x = -20:20;
figure, hist(100*(Masp-Masp_est)./Masp,x), grid
xlim([x(1) x(end)])
xlabel('Relative error (%)','fontsize',ftsz)
eval(['ylabel(''Number of points (total = ',num2str(length(Masp)),')'',''fontsize'',',num2str(ftsz),')'])
tt = title(['Mean relative error: ',num2str(err_mean),' %']);
set(tt,'fontsize',ftsz);
set(gcf,'PaperPositionMode','Auto');
toc


%% Save model parameters
MapFilling_Aspirated.Alpha1.x = Ne_vect;
MapFilling_Aspirated.Alpha1.y = Pman_vect;
MapFilling_Aspirated.Alpha1.z = Alpha1;
MapFilling_Aspirated.Alpha2.x = Ne_vect;
MapFilling_Aspirated.Alpha2.y = Pman_vect;
MapFilling_Aspirated.Alpha2.z = Alpha2;
MapFilling_Aspirated.Alpha3.x = Ne_vect;
MapFilling_Aspirated.Alpha3.y = Pman_vect;
MapFilling_Aspirated.Alpha3.z = Alpha3;
MapFilling_Aspirated.OF.x = VVTCA_list;
MapFilling_Aspirated.OF.y = VVTCE_list;
MapFilling_Aspirated.OF.z = OF2;
MapFilling_Aspirated.R = R;
MapFilling_Aspirated.delta_ivc.x = Ne_vect;
MapFilling_Aspirated.delta_ivc.y = delta_angle_ivc;
MapFilling_Aspirated.delta_evc.x = Ne_vect;
MapFilling_Aspirated.delta_evc.y = delta_angle_evc;
MapFilling_Aspirated.IVC = IVC_ref;
MapFilling_Aspirated.EVC = EVC_ref;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To do: define output file name and path
save('MapFilling_Aspirated_0518_2_DataBase_all','MapFilling_Aspirated')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

