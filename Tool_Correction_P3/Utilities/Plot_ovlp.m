ftsz = 10;
figure;
nb_col = 1;
Vxx_cyl_pump_flow = Vxx_cyl_pump_flow_sim;
Vxx_cyl_pump_flow_nomi = (mivc_bas - movlp_bas_nomi -mevc_bas_nomi).*(3.*Vxx_avg_eng_spd/120/1000);
set(gcf,'position',[0 0 1600 900],'PaperPositionMode','auto');

ax(1) = subplot(5,nb_col,1);
hold on; grid
p = plot(Vxx_cyl_pump_flow,'o','linewidth',1);
C = get(p,'color');
plot(Vxx_cyl_pump_flow_nomi,'o','linewidth',1);
plot(Vxx_intk_air_flow,'x','linewidth',1);
ylabel('MAF [g/s]','fontsize',ftsz)
xlim([1 length(Masp)])
lg = legend('model w/ cor','model w/o cor','HFM','Location','Best');
title('MAF - Comparaison [g/s]')

ax(2) = subplot(5,nb_col,2);
hold on; grid
% plot(movlp_bas_nomi,'*','Markersize',8)
% plot(movlp_bas,'o','Markersize',8)
plot(movlp_bas)
plot(movlp_bas_nomi)

grid on
hold off
legend('m''_{ovlp} w/ cor','m''_{ovlp} w/o cor')
title('Overlap mass [mg/str]')
ylabel('[mg/str]','fontsize',ftsz)


ax(3) = subplot(5,nb_col,3);
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
ylabel('Relative error [-]','fontsize',ftsz)
title('MAF relative error [-]')
linkaxes([ax(1),ax(2),ax(3)],'x')

ax(4) = subplot(5,nb_col,[4 5]);
%     temp_y = Vxx_intk_air_flow./(Vxx_intk_air_flow+1);
EngineMap_notext(Vxx_avg_eng_spd,Vxx_intk_mfld_prs+prs_diff,Vxx_cyl_pump_flow,Vxx_intk_air_flow,'MODEL W/ COR');



