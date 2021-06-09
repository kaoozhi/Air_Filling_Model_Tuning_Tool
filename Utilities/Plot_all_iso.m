Mest = [];
Mref =[];
for i=1:length(Masp_vect)
Mest = [Mest; Masp_vect(i).est];
Mref = [Mref; Masp_vect(i).mes];

end
% Mest_SDS = Mest;
% Mref_SDS = Mref;


% Mest_0 = Mest;
% Mref_0 = Mref;

Mest_auto = Mest;
Mref_auto = Mref;
figure
subplot(1,3,1)
analysis_plot(Mest_SDS,Mref_SDS,'SDS',1);
subplot(1,3,2)
analysis_plot(Mest_0,Mref_0,'VVT0',1);
subplot(1,3,3)
analysis_plot(Mest_auto,Mref_auto,'VVTauto',1);
legend('MDL\_IFP','Location','Southeast')
% subplot(1,2,2)
% histerr(Mest, Mref,'MDL\_IFP');