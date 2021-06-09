function [delta_angle_ivc, delta_angle_evc] = update_divc(...
    delta_angle_ivc, delta_angle_evc, ...
    Ne_vect, Ne_window,...
    alpha1, alpha2, alpha3,...
    IVC, EVC,...
    Masp, Ne, Pman, R, Tman, OF)

warning off all

for i = 1:length(Ne_vect)
    sel = find(abs(Ne-Ne_vect(i)) < Ne_window);
    if length(sel) > 10
        try
            x0 = [delta_angle_ivc(i)];
            xm = [-Inf];
            xM = [Inf];
            F = @(x) 100*nanmean(abs(1-(alpha1(sel).*Pman(sel).*Volume_HR12(IVC(sel)-x(1))./(R*Tman(sel)) - alpha2(sel).*OF(sel).*1e6./Ne(sel)  - alpha3(sel).*Volume_HR12(EVC(sel)))./Masp(sel)));
            opts1=  optimset('display','off');
            x = lsqnonlin(F,x0,xm,xM,opts1);
            
            Masp_est = (alpha1(sel).*Pman(sel).*Volume_HR12(IVC(sel)-delta_angle_ivc(i))./(R*Tman(sel)) - alpha2(sel).*OF(sel).*1e6./Ne(sel)  - alpha3(sel).*Volume_HR12(EVC(sel)));
            err_old = 100*nanmean(abs((Masp(sel)-Masp_est)./Masp(sel)));
            
            Masp_est = (alpha1(sel).*Pman(sel).*Volume_HR12(IVC(sel)-x(1))./(R*Tman(sel)) - alpha2(sel).*OF(sel).*1e6./Ne(sel)  - alpha3(sel).*Volume_HR12(EVC(sel)));
            err_new = 100*nanmean(abs((Masp(sel)-Masp_est)./Masp(sel)));

            %- Update ONLY if improving
            if err_new < err_old || isnan(err_old)
                delta_angle_ivc(i) = x(1);
            end
        catch
        end
    end
end