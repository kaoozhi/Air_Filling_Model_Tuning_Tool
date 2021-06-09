function Masp = Filling_Model_ref(Ne,Pman,Tman,VVTint,VVTexh,MapFilling_Aspirated)
    %% Input:
    % N [rpm]
    % Pman [Pa]
    % Tman [K]
    % VVTint [degCA]
    % VVTexh [degCA]
    % Model calibration: MapFilling_Aspirated
    %% Output:
    % Masp [mg/str]
    
    Cxb_cyl_fill_mdl_ex_vlv_cls_angl_cyl_vol=[310.0000000 316.0000000 322.0000000 328.0000000 334.0000000 340.0000000 346.0000000 352.0000000 358.0000000 364.0000000 370.0000000 376.0000000 382.0000000 388.0000000 394.0000000 400.0000000 ];
    Cxb_cyl_fill_mdl_intk_vlv_cls_angl_cyl_vol=[430.0000000 438.6666667 447.3333333 456.0000000 464.6666667 473.3333333 482.0000000 490.6666667 499.3333333 508.0000000 516.6666667 525.3333333 534.0000000 542.6666667 551.3333333 560.0000000 ];
    Cxp_cyl_fill_mdl_ex_vlv_cls_angl_cyl_vol = Volume_HR12(Cxb_cyl_fill_mdl_ex_vlv_cls_angl_cyl_vol);
    Cxp_cyl_fill_mdl_intk_vlv_cls_angl_cyl_vol = Volume_HR12(Cxb_cyl_fill_mdl_intk_vlv_cls_angl_cyl_vol);
    IVC = MapFilling_Aspirated.IVC-VVTint;
    EVC = MapFilling_Aspirated.EVC+VVTexh;
    Ne = min(6500,Ne);
    
    delta_IVC = interp1(MapFilling_Aspirated.delta_ivc.x,MapFilling_Aspirated.delta_ivc.y,Ne);
    Vivc = interp1(Cxb_cyl_fill_mdl_intk_vlv_cls_angl_cyl_vol,Cxp_cyl_fill_mdl_intk_vlv_cls_angl_cyl_vol,IVC-delta_IVC);
    Vevc = interp1(Cxb_cyl_fill_mdl_ex_vlv_cls_angl_cyl_vol,Cxp_cyl_fill_mdl_ex_vlv_cls_angl_cyl_vol,EVC);

    VVTint = min(60,VVTint);
    VVTint = max(0,VVTint);
    VVTexh = min(60,VVTexh);
    VVTexh = max(0,VVTexh);
    
    
    alpha1 = interp2(MapFilling_Aspirated.Alpha1.x,MapFilling_Aspirated.Alpha1.y,MapFilling_Aspirated.Alpha1.z',Ne,Pman);
    alpha2 = interp2(MapFilling_Aspirated.Alpha2.x,MapFilling_Aspirated.Alpha2.y,MapFilling_Aspirated.Alpha2.z',Ne,Pman);
    alpha3 = interp2(MapFilling_Aspirated.Alpha3.x,MapFilling_Aspirated.Alpha3.y,MapFilling_Aspirated.Alpha3.z',Ne,Pman);
    OF = interp2(MapFilling_Aspirated.OF.x,MapFilling_Aspirated.OF.y,MapFilling_Aspirated.OF.z,VVTint,VVTexh);

    R = 287;
    
    Masp = (alpha1.*Pman.*Vivc./(R*Tman) - alpha2.*OF.*1e6./Ne  - max(0,alpha3.*Vevc)).*1e6;
%     Migr = max(0,(alpha2.*OF.*1e6./Ne  + max(0,alpha3.*Vevc)).*1e6.*Tman./Texh);
%     IGR = Migr_est.*Tman./Texh./(Migr_est.*Tman./Texh+Masp_est);