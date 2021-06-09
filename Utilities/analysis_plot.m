function analysis_plot(Masp_mdl_IFP,Masp,name,ifig)

% figure;
% ax(1) = subplot(211);
% hold on; grid
% % plot(Masp_mdl_RSA./Masp,'x','color',[255 215 0]/255,'linewidth',2)
% plot(Masp_mdl_IFP./Masp,'x','color',[100 149 237]/255,'linewidth',2)
% plot(Masp_mdl_RSA./Masp,'x','color',[46 139 87]/255,'linewidth',2)
%
% plot(Masp*0+0.95,'k--')
% plot(Masp*0+1.05,'k--')
% xlim([1 length(Masp)])
% ylim([0.8 1.2])
% xlabel('Point number')
% ylabel('[-]')
% % legend('MDL\_RSA','MDL\_IFP','MDL\_NN','Location','Southeast')
% title(' Relative error comparison')

% err_RSA = abs((Masp-Masp_mdl_RSA)./Masp)*100;
err_IFP = abs((Masp-Masp_mdl_IFP)./Masp)*100;
% err_RSA = abs((Masp-Masp_mdl_RSA)./Masp)*100;
count_totp = length(Masp);
% count_tot = sum(~isnan(Masp_est));
thld3=3;
% count_b5pct = [sum(err_RSA<5),sum(err_IFP<5)]/count_totp;
% count_b3pct = [sum(err_RSA<thld3),sum(err_IFP<thld3)]/count_totp;

count_b5pct = sum(err_IFP<5)/count_totp;
count_b3pct = sum(err_IFP<thld3)/count_totp;
%
% ax(2) = subplot(212);
ftsz = 6;
dataSample= [count_b5pct*100;count_b3pct*100]';
% b=bar([count_b5pct*100;count_b3pct*100]);
% text(1:length(Y),Y,num2str(Y'),'vert','bottom','horiz','center'); 

catStrArray = {'<5%','<3%'};
catArray = categorical(catStrArray);       
catArray = reordercats(catArray,catStrArray);
b=bar(catArray,dataSample',0.8);
nModel = size(dataSample,1);
nCat = size(dataSample,2);
xPosAmpl = 0.3682626-0.3298725*exp(-0.407004*(nModel-1)); % position amplitude
xPosInc = 2*xPosAmpl/(nModel-1);
% modelNames = [];
for idxModel=1:nModel
    bar_xPos = 1:nCat;
    if nModel~=1
        bar_xPos = bar_xPos-xPosAmpl+(idxModel-1)*xPosInc;
    end
%     text(bar_xPos,dataSample(idxModel,:),num2str(dataSample(idxModel,:)',...
%        '%0.1f'),'vert','bottom','horiz','center');  
    text(bar_xPos,dataSample(idxModel,:),num2str(dataSample(idxModel,:)',...
        '%0.1f'),'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize', ftsz); 
%     modelNames{idxModel}=sprintf('model%d',idxModel);
end
% legend(modelNames)

% text(1:length(Y), Y', num2str(Y','%0.1f'),'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize', ftsz)

% dt = datatip(b,'DataIndex',7);

% datatip(b(1),'DataIndex',1,'Location','southeast','FontSize', ftsz);
% datatip(b(1),'DataIndex',2,'Location','southeast','FontSize', ftsz);
% datatip(b(2),'DataIndex',1,'Location','southeast','FontSize', ftsz);
% datatip(b(2),'DataIndex',2,'Location','southeast','FontSize', ftsz);
% 
% for ii = 1:length(b)
%     dtRow= b(ii).DataTipTemplate;
%     dtRow.DataTipRows(1)=[];
%     dtRow.DataTipRows(1).('Label')='';
%     dtRow.DataTipRows(1).('Format')='%.1f';
% end
% datatip(b(3),'DataIndex',1,'Location','southeast');
% datatip(b(3),'DataIndex',2,'Location','southeast');

b(1).FaceColor=[100 149 237]/255;
% b(1).FaceColor=[255 215 0]/255;
% b(2).FaceColor=[46 139 87]/255;
set(gca,'xticklabel',{'<5%',['<' num2str(thld3) '%']},'FontSize', ftsz+2)
title([strrep(name,'_','\_') ' (' num2str(length(Masp)) 'pts)'],'FontSize', ftsz+2)
% legend('MDL\_IFP','MDL\_RSA','Location','Southeast')
if ifig==1
ylabel('[%]')

else
set(gca,'YTick',[])

end
ylim([0 105])



end