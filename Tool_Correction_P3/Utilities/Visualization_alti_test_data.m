close all
clear
[FileName,PathName,FilterIndex] = uigetfile('.mat','MultiSelect','off','Choose data file: .mat');
Data = load([PathName FileName]);
var_names= fieldnames(Data);
for i=1:length(var_names)
    temp_var_name = strrep(var_names{i},'_XETK_1','');
    Data_rep.(temp_var_name) = Data.(var_names{i});
end

err_rel_maf = Data_rep.Vxx_cyl_pump_flow./Data_rep.Vxx_intk_air_flow-1;
figure
ax(1)= subplot(711);
hold on
plot(err_rel_maf);
plot(Data_rep.Vxx_intk_air_flow*0+0.95-1,'k--')
plot(Data_rep.Vxx_intk_air_flow*0+1.05-1,'k--')
hold off
% legend('model w/ cor','model w/o cor','Location','Best');
% xlim([1 length(Masp)])
ylim([0.8 1.2]-1)
title('MAF - Relative error')
ax(2)=subplot(712);
plot(Data_rep.Vxx_avg_eng_spd);
title('Vxx\_avg\_eng\_spd')

ax(3)=subplot(713);
plot(Data_rep.Vbx_inj_ena);
title('Vbx\_inj\_ena')

ax(4)=subplot(714);
plot(Data_rep.Vxx_intk_air_flow);
title('Vxx\_intk\_air\_flow')

ax(5)=subplot(715);
plot(Data_rep.Vxx_intk_mfld_prs);
title('Vxx\_intk\_mfld\_prs')

ax(6)=subplot(716);
plot(Data_rep.Vxx_vvt_intk_angl);
title('Vxx\_vvt\_intk\_angl')

ax(7)=subplot(717);
plot(Data_rep.Vxx_vvt_ex_angl);
title('Vxx\_vvt\_ex\_angl')

linkaxes(ax, 'x');

suplabel(strrep(FileName,'_','\_') ,'t');
