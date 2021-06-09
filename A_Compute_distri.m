clear
close all
clc
addpath(genpath(cd))

%% Figure properties
ftsz = 14;
pos = [100 100 1000 600];
lw = 3;
C = {[0 0.447 0.741]...
     [0.85 0.325 0.098]};

%% Compute valves lifts
angle = 0:.1:720;
Valve_lift_reference = .7; % mm

%% Intake and exhaust valve cross section data import 
[FileName_param,PathName_param,FilterIndex_param] = uigetfile('.xlsx','Select cross section law file.xlsx');

[Se_int text_input all_input]=xlsread([PathName_param '\' FileName_param],1);
[Se_exh text_input all_input]=xlsread([PathName_param '\' FileName_param],2);

Area_int.x = [0;Se_int(:,1)];
Area_int.y = [0;Se_int(:,2)];

Area_exh.x = [0;Se_exh(:,1)];
Area_exh.y = [0;Se_exh(:,2)];

% load Data_distri/Seff_HR12VDV
% Area_int.x = [0;Seff_adm.Lift_mm];
% Area_int.y = [0;Seff_adm.Seff_cm2];



%% Intake and exhaust lift law data import
[FileName_param,PathName_param,FilterIndex_param] = uigetfile('.xlsx','Select lift law file.xlsx');

[Lift_int text_input all_input]=xlsread([PathName_param '\' FileName_param],1);
[Lift_exh text_input all_input]=xlsread([PathName_param '\' FileName_param],2);
Lint.x = Lift_int(:,1);
Lint.y = Lift_int(:,2);
Lexh.x = Lift_exh(:,1);
Lexh.y = Lift_exh(:,2);

sel_IVO_sup = find(Lint.y > Valve_lift_reference,1,'first');
sel_IVO_inf = sel_IVO_sup-1;
tab = [sel_IVO_inf sel_IVO_sup];
[a b] = min([abs(Lint.y(sel_IVO_inf)-Valve_lift_reference) abs(Lint.y(sel_IVO_sup)-Valve_lift_reference)]);
sel_IVO = tab(b);
angle_IVO = Lint.x(sel_IVO);

sel_EVC_sup = find(Lexh.y > Valve_lift_reference,1,'last');
sel_EVC_inf = sel_EVC_sup+1;
tab = [sel_EVC_inf sel_EVC_sup];
[a b] = min([abs(Lexh.y(sel_EVC_inf)-Valve_lift_reference) abs(Lexh.y(sel_EVC_sup)-Valve_lift_reference)]);
sel_EVC = tab(b);
angle_EVC = Lexh.x(sel_EVC);


%% Plot volume and valve lift profiles
Volume = Volume_HR12(angle);

VVTint = [0 60];
VVTexh = [0 60];

figure
ax(1) = subplot(211);
hold on, grid
plot(angle,interp1(Lint.x-VVTint(1),Lint.y,angle),'color',C{1},'linewidth',lw)
plot(angle,interp1(Lint.x-VVTint(2),Lint.y,angle),'--','color',C{1},'linewidth',lw-1)
plot(angle,interp1(Lexh.x+VVTexh(1),Lexh.y,angle),'color',C{2},'linewidth',lw)
plot(angle,interp1(Lexh.x+VVTexh(2),Lexh.y,angle),'--','color',C{2},'linewidth',lw-1)
xlim([min(angle) max(angle)])
xlabel('angle (deg)','fontsize',ftsz)
ylabel('Lift (mm)','fontsize',ftsz)
lg = legend(['Intake (VVT ',num2str(VVTint(1)),')'],['Intake (VVT ',num2str(VVTint(2)),')'],['Exhaust (VVT ',num2str(VVTexh(1)),')'],['Exhaust (VVT ',num2str(VVTexh(2)),')']);
set(lg,'fontsize',ftsz)
ax(2) = subplot(212);
hold on, grid
plot(angle,Volume.*1e3,'linewidth',lw)
xlim([min(angle) max(angle)])
xlabel('angle (deg)','fontsize',ftsz)
ylabel('Volume (l)','fontsize',ftsz)
linkaxes(ax,'x')
set(gcf,'position',pos,'PaperPositionMode','auto')
print(gcf,'-r400','-dpng','Data_distri\Figure_distri')

%% Compute OF
VVTint_vect = -10:61;
VVTexh_vect = -10:61;

for i = 1:length(VVTint_vect)
    for j = 1:length(VVTexh_vect)
        
        angle_IVO = angle(find(interp1(Lint.x-VVTint_vect(i),Lint.y,angle) > Valve_lift_reference,1,'first'));
        angle_EVC = angle(find(interp1(Lexh.x+VVTexh_vect(j),Lexh.y,angle) > Valve_lift_reference,1,'last'));
        angle_overlap = angle_IVO:.1:angle_EVC;
        
        
        Area_int_overlap = interp1(Area_int.x,Area_int.y,interp1(Lint.x-VVTint_vect(i),Lint.y,angle_overlap),'linear','extrap');
        Area_exh_overlap = interp1(Area_exh.x,Area_exh.y,interp1(Lexh.x+VVTexh_vect(j),Lexh.y,angle_overlap));
        
        Area_overlap = min(Area_int_overlap,Area_exh_overlap);
        
%         figure
%         plot(angle_overlap,Area_int_overlap,'b-');hold on; plot(angle_overlap,Area_exh_overlap,'r-');
%         plot(angle_overlap,Area_overlap,'k')

        OFint_map(i,j) = trapz(Area_int_overlap)*1e-6;
        OFexh_map(i,j) = trapz(Area_exh_overlap)*1e-6;
        OF_map(i,j) = trapz(Area_overlap)*1e-6;

    end
end
Overlap.x = VVTint_vect;
Overlap.y = VVTexh_vect;
Overlap.z = OF_map';
figure
surf(Overlap.x,Overlap.y,Overlap.z)
xlabel('VVTint (deg)','fontsize',ftsz)
ylabel('VVTexh (deg)','fontsize',ftsz)
zlabel('Overlap Factor (m2.deg)','fontsize',ftsz)
view([52 24])

%% Save data
MAP_Distri.OF_map = Overlap;
MAP_Distri.IVC_ref = round(angle(find(interp1(Lint.x,Lint.y,angle) > Valve_lift_reference,1,'last')));
MAP_Distri.EVC_ref = round(angle(find(interp1(Lexh.x,Lexh.y,angle) > Valve_lift_reference,1,'last')));

save('Data_distri/MAP_Distri','-struct','MAP_Distri')