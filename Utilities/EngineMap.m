function EngineMap(Ne, Pman,Masp_est,Masp,tt)

% Engine speed breakpoints
Ne_vect = [600 750 1000,1250,1500,1750,2100,2500,3000,3500,4000,4500,5000,5500,6000 6500];
% Ne_vect = [1000,1250,1500,1750,2100,2500,3000,3500,4000,4500,5000,5500];

% Intake manifold pressure breakpoints
Pman_vect = [12.0 24.0 36.0 48.0 66.0 84.0 102.0 120.0 144.0 168.0 192.0 216.0 240.0 264.0 288.0 312.0];
err = -100*(Masp-Masp_est)./Masp;

[Pman_V,Ne_V]=meshgrid(Pman_vect,Ne_vect);


[Ne_q,Pman_q] = ndgrid(Ne_vect,Pman_vect);
F = scatteredInterpolant([Ne,Pman],err);
% F = griddedInterpolant(xq,yq,e');
% [a,b] = ndgrid(m,n);
err_q = griddata(Ne,Pman,err,Ne_q,Pman_q,'linear');



% err_V = gridfit(Ne,Pman,err,Ne_vect,Pman_vect,'interp','triangle');
% err_V = interp2(Ne,Pman,err,Ne_V,Pman_V);


% F = griddedInterpolant(Ne,Pman,err);
% Evaluate the interpolant at query locations ( $xq$,  $yq$).
str = string(round(err,1));
% ti = -2:.25:2;
% [xq,yq] = meshgrid(ti,ti);
% err_V = F(Ne_V,Pman_V);

tri = delaunay(Ne,Pman);
% tricontour(tri,Ne,Pman,err,-10:1:10);
% % clabel(C,h);
% trisurfc(Ne,Pman,err,-10:1:10)
% contourf(Ne_V,Pman_V,err_V)
% surfc(Ne_q,Pman_q,err_q)

colormap(turbo)
% colormap spring
grid on;
% figure
hold on;

scatter(Ne,Pman,20,round(err,1),'filled');
xlim([0, 7000])
% plot3(Ne,Pman,round(err,1),'.','MarkerSize',10);
try
textscatter(Ne,Pman,str,'TextDensityPercentage',100);
catch
scattertext(Ne,Pman,round(err,1));
% scattertext(Ne,Pman,round(err,1),str,'colormap',turbo);
end

% scattertext(Ne,Pman,round(err,1),'clim',caxis);
hold off
caxis([-5 5])

% plot3(Ne, Pman, err,'bo','linewidth',1);

% set(gca,'CameraPosition',[0 0 700])
% err_grid = gridfit(Ne,Pman,err,Ne_vect,Pman_vect);

% figure;
% contourf(Ne_vect,Pman_vect, err_grid);
% hold on
% plot3(Ne, Pman, err,'ro','linewidth',1);

colorbar

xlabel('Engine Speed[rpm]')
ylabel('Pman[kPa]')
title([tt '- Relative error[%]'])
xlim([500 6500])

end