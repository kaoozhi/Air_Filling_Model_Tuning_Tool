
Ne_vect  = MapFilling_Aspirated.Alpha1.x;
Pman_vect = MapFilling_Aspirated.Alpha1.y ;
Alpha1 = MapFilling_Aspirated.Alpha1.z ;
Ne_vect=MapFilling_Aspirated.Alpha2.x ;
Pman_vect=MapFilling_Aspirated.Alpha2.y; 
Alpha2= MapFilling_Aspirated.Alpha2.z;
Ne_vect = MapFilling_Aspirated.Alpha3.x;
Pman_vect=MapFilling_Aspirated.Alpha3.y; 
Alpha3= MapFilling_Aspirated.Alpha3.z ;
VVTCA_list=MapFilling_Aspirated.OF.x;
VVTCE_list=MapFilling_Aspirated.OF.y;
OF=MapFilling_Aspirated.OF.z;

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


figure, surf(VVTCA_list,VVTCE_list,OF)
xlabel('VVTCA (deg)','fontsize',ftsz)
ylabel('VVTCE (deg)','fontsize',ftsz)
zlabel('OF','fontsize',ftsz)
set(gcf,'PaperPositionMode','Auto');
colormap jet
shading interp
view(3)
title('OF')