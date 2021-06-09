function histerr(Masp_est, Masp, tt)

    err_mean = 100*nanmean(abs((Masp-Masp_est)./Masp));
    x = -20:20;
    histogram(-100*(Masp-Masp_est)./Masp,x)
    grid on;
    xlim([x(1) x(end)])
    xlabel('Relative error [%]')
    ylabel(['Number of points (total = ',num2str(sum(~isnan(Masp_est))) ')']);
    title([tt ' - Mean absolute error: ',num2str(err_mean),' %']);
%     set(tt,'fontsize',ftsz);
%     set(gcf,'PaperPositionMode','Auto');
    
end