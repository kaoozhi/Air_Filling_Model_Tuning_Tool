function OF2 = update_OF(...
                OF2,OF,...
                VVTCA_list, VVTCE_list,...
                VVT_config, VVTint, VVTexh,...
                alpha1, alpha2, alpha3,...
                Masp, Ne, Pman, Vivc, R, Tman, Vevc)

for i = 1:length(VVT_config)
    sel = find(round(VVTint) == VVT_config(i,1) & round(VVTexh) == VVT_config(i,2));
    if length(sel) > 5
        OF_p = -(Masp(sel) + (alpha3(sel)).*Vevc(sel) - alpha1(sel).*Pman(sel).*Vivc(sel)./(R*Tman(sel)))./alpha2(sel)./1e6.*Ne(sel);
        OF_row = find(VVTCE_list == VVT_config(i,2));
        OF_col = find(VVTCA_list == VVT_config(i,1));

        OF_new = nanmedian(OF_p);
        OF_new = 0.95*nanmedian(OF(sel)) + 0.05*nanmedian(OF_p);
        
        
        %% Saturation of OF
        OF_new(OF_new<0)=0;
        
        Masp_est = (alpha1(sel).*Pman(sel).*Vivc(sel)./(R*Tman(sel)) - alpha2(sel).*OF2(OF_row,OF_col).*1e6./Ne(sel)  - alpha3(sel).*Vevc(sel));
        err_old = 100*nanmean(abs((Masp(sel)-Masp_est)./Masp(sel)));

        Masp_est = (alpha1(sel).*Pman(sel).*Vivc(sel)./(R*Tman(sel)) - alpha2(sel).*OF_new.*1e6./Ne(sel)  - alpha3(sel).*Vevc(sel));
        err_new = 100*nanmean(abs((Masp(sel)-Masp_est)./Masp(sel)));

        %- Update ONLY if improving
        if err_new < err_old || isnan(err_old)
            OF2(OF_row,OF_col) = OF_new;
        end
    end
end

OF2(OF2<0)=0;