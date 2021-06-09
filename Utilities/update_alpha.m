function [Alpha1, Alpha2, Alpha3] = update_alpha(...
                                Alpha1, Alpha2, Alpha3,...
                                Ne_vect, Pman_vect,...
                                Ne_window, Pman_window, VVTvar_min,...
                                VVTint, VVTexh,...
                                Masp, Ne, Pman, Vivc, R, Tman, OF, Vevc)

warning off all

for i = 1:length(Ne_vect)
    for j = 1:length(Pman_vect)
        sel = find(abs(Ne-Ne_vect(i)) < Ne_window & abs(Pman-Pman_vect(j)) < Pman_window);
        uniqueVVT = unique([round(VVTint(sel)) round(VVTexh(sel))],'rows');
        if (length(uniqueVVT) >= VVTvar_min) % condition for fitting
            Alpha = [Pman(sel).*Vivc(sel)./(R*Tman(sel)) -OF(sel).*1e6./Ne(sel) -Vevc(sel)];
            Y = Masp(sel);
            X_hat = Alpha\Y;
            
            Masp_est = (Alpha1(i,j).*Pman(sel).*Vivc(sel)./(R*Tman(sel)) - Alpha2(i,j).*OF(sel).*1e6./Ne(sel)  - Alpha3(i,j).*Vevc(sel));
            err_old = 100*nanmean(abs((Masp(sel)-Masp_est)./Masp(sel)));
            
            Masp_est = Alpha*X_hat;
            err_new = 100*nanmean(abs((Masp(sel)-Masp_est)./Masp(sel)));

            %- Update ONLY if improving
            if err_new < err_old || isnan(err_old)
                Alpha1(i,j) = X_hat(1);
                Alpha2(i,j) = X_hat(2);
                Alpha3(i,j) = X_hat(3);
            end
        end
    end
end