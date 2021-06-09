% close all

mref = Masp;
masp_est= (mivc_bas - movlp_bas -mevc_bas);
delta_m = mref-masp_est;
names_var_in = fieldnames(Input);
for i=1:length(names_var_in)
    
    Input_resize.(names_var_in{i}) = Input.(names_var_in{i})(2:end);
end

% beta =  1- delta_m./mevc_bas;

beta =  delta_m./mevc_bas./(1-prs_ratio);
idx =(Vxx_intk_mfld_prs <84);
ind_sel = ~isnan(masp_est./mref);

x = Input_resize.N_rpm(ind_sel);
y = Input_resize.Pman_kPa(ind_sel)+prs_diff(ind_sel);
z = beta(ind_sel);
x_node = Cxb_cyl_fill_eng_spd;
y_node = Cxb_cyl_fill_intk_mfld_prs;
z_node = gridfit(x, y, z, x_node, y_node, 'interp', 'bilinear');

[Cxb_prs_V,Cxb_n_V]=meshgrid(Cxb_cyl_fill_intk_mfld_prs,Cxb_cyl_fill_eng_spd);
% idx1 = (Cxb_prs_V >=70);
% z_node(idx1')=1;

% new_z = interp2(x_node, y_node, z_node, x, y);
% z_node = gridfit(x, y, new_z, x_node, y_node,'smoothness',10);
% z_node = gridfit(x, y, new_z, x_node, y_node);

z_node(z_node<1)=1;
idx2 = (Cxb_prs_V >=84);
z_node(idx2')=1;

Cxm_cyl_fill_mdl_ex_mfld_prs_rat_cor_fac = z_node';
x_all = Input_resize.N_rpm;
new_z = interp2(x_node, y_node, z_node, x, y,'spline');
masp_est_new= mivc_bas - movlp_bas -max(0,mevc_bas.*((prs_ratio-1).*new_z+1));
% movlp_bas(movlp_bas_nomi>0) = movlp_bas_nomi(movlp_bas_nomi>0);
% masp_est_new= mivc_bas - movlp_bas -max(0,mevc_bas.*((prs_ratio-1).*new_z+1));

Launch_sim_cor_alti;
figure
surf(x_node,y_node,z_node)
zlabel('f')
xlabel('Engine speed(rpm)')
ylabel('Corrected Pman(kPa)')
title('MAP = f(N,P_{man\_cor})')

figure
hold on;

plot(err_cyl_flow_nomi,'x','linewidth',0.4)%,'*','linewidth',0.2
plot(err_cyl_flow_base,'x','linewidth',0.4)%,'*','linewidth',0.2
plot(err_cyl_flow_h,'x','linewidth',0.4)
plot(err_cyl_flow,'x','linewidth',0.4)
plot(Vxx_intk_air_flow*0+0.95-1,'k--')
plot(Vxx_intk_air_flow*0+1.05-1,'k--')
title('MAF - Relative error comparaison')
ylabel('Relative error (-)')
% ylim([0.8 1.2]-1)
hold off
legend('model w/o cor','model w/ cor: base','model w/ cor: base+h','model w/ cor: base+h+f','Location','Best');


suplabel(strrep(name_list{k},'_','\_') ,'t');
% figure;
% hold on
% plot(movlp_bas,'*','Markersize',8)
% plot(mevc_bas,'o','Markersize',8)
% grid on
% hold off
% legend('m''_{ovlp}','m''_{evc}')

% figure;
% set(gcf,'position',[0 0 1600 450],'PaperPositionMode','auto');
% 
% subplot(121)
% plot(Input_resize.N_rpm, beta,'*')
% title('Correction dependency of Engine speed')
% ylabel('Optimal coeficient')
% xlabel('Engine speed(rpm)')

% subplot(122)
% % plot(Data.Vxx_intk_mfld_prs_XETK_1, beta,'*')
% plot(y, beta,'*')
% title('Correction dependency of \DeltaP')
% ylabel('Optimal coeficient')
% % xlabel('Intake manifold pressure(kPa)')
% xlabel('Corrected intake manifold pressure(kPa)')

% figure(4)
% hold on
% % plot(Data.Vxx_avg_eng_spd_XETK_1(ind_sel), beta(ind_sel),'*')
% % plot(Data.Vxx_avg_eng_spd_XETK_1, beta_fit)
% plot(Input_resize.N_rpm(ind_sel), beta(ind_sel),'*')
% plot(Input_resize.N_rpm, beta_fit)
% hold off
% title('Correction dependency of Engine speed')
% ylabel('Optimal coeficient')
% xlabel('Engine speed(rpm)')
% legend('Target coefficient', 'Fitted coefficient')



% figure
% subplot(4, 1, [1 2])
% hold on
% plot(masp_est./mref ,' *','LineWidth',1.5)
% plot(masp_est_new./mref,'o','LineWidth',1.5)
% plot(mref*0+0.95,'r--','linewidth',2)
% plot(mref*0+1.05,'r--','linewidth',2)
% hold off
% % plot(masp_est_new, '-s', 'LineWidth',1.5)
% grid on
% 
% legend('Rel\_err - Mest', 'Rel\_err - Mest\_cor')
% title('Relative error [-]')
% subplot(4,1,3)
% plot(prs_diff,'*','LineWidth',1.5)
% title('\DeltaP')
% 
% subplot(4,1,4)
% plot(prs_ratio,'*','LineWidth',1.5)
% title('Pression ratio')


% figure(6)
% data_list = {'ISO_20degC_2500m'};
% set(gcf,'position',[0 0 1600 450],'PaperPositionMode','auto');
% tt = 'AFTER  - MDL\_IFP: MAF';
% % plot_rel_err(masp_est_new,mref,data_list{1},Data.Vxx_avg_eng_spd_XETK_1, Data.Vxx_intk_mfld_prs_XETK_1,tt)
% plot_rel_err(masp_est_new,mref,data_list{1},Input_resize.N_rpm, Input_resize.Pman_kPa,tt)

% figure(9)
% data_list = {'ISO_20degC_2500m'};
% set(gcf,'position',[0 0 1600 450],'PaperPositionMode','auto');
% tt = 'Before  - MDL\_IFP: MAF';
% % plot_rel_err(masp_est,mref,data_list{1},Data.Vxx_avg_eng_spd_XETK_1, Data.Vxx_intk_mfld_prs_XETK_1,tt)
% plot_rel_err(masp_est,mref,data_list{1},Input_resize.N_rpm, Input_resize.Pman_kPa,tt)


% figure;
% hold on
% plot(movlp_bas_nomi,'*','Markersize',8)
% plot(movlp_bas,'o','Markersize',8)
% grid on
% hold off
% legend('m''_{ovlp\_nomi}','m''_{ovlp}')
% 
% figure
% hold on
% plot(mevc_bas_nomi,'*','Markersize',8)
% plot(max(0,mevc_bas.*((prs_ratio-1).*new_z+1)),'o','Markersize',8)
% grid on
% hold off
% legend('m''_{evc\_nomi}','m''_{evc}')

% figure(10)
% tt = 'm''_{ovlp} (mg/str)';
% % HotMap(Data.Vxx_avg_eng_spd_XETK_1, Data.Vxx_intk_mfld_prs_XETK_1,movlp_bas,tt)
% HotMap(Input_resize.N_rpm, Input_resize.Pman_kPa,movlp_bas,tt)


% figure(11)
% tt = 'Interpolated values of f(N,P_{man\_cor})';
% HotMap(x, y,new_z,tt)

