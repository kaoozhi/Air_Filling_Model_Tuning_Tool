
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To do: choose calibration file
load MapFilling_Aspirated_0318_2_DataBase_all

%% To do: define breakpoints
% Engine speed
Cxb_cyl_fill_eng_spd=[600 800	1000	1250	1500	1750	2100	2500	3000	3500	4000	4500	5000	5500	6000 6500];
% Intake manifold pressure
Cxb_cyl_fill_intk_mfld_prs=[12.0 24.0 36.0 48.0 66.0 84.0 102.0 120.0 144.0 168.0 192.0 216.0 240.0 264.0 288.0 312.0];
% VVT position breakpoints for OF
Cxb_cyl_fill_mdl_vvt_intk_angl_ovlp_fac=[0 2 8 23 31 38 53 60];
Cxb_cyl_fill_mdl_vvt_ex_angl_ovlp_fac=[0 7 10 13 29 43 58 60];
% IVC and EVC breakpoints for volume law
Cxb_cyl_fill_mdl_ex_vlv_cls_angl_cyl_vol=[310.0000000 316.0000000 322.0000000 328.0000000 334.0000000 340.0000000 346.0000000 352.0000000 358.0000000 364.0000000 370.0000000 376.0000000 382.0000000 388.0000000 394.0000000 400.0000000 ];
Cxb_cyl_fill_mdl_intk_vlv_cls_angl_cyl_vol=[430.0000000 438.6666667 447.3333333 456.0000000 464.6666667 473.3333333 482.0000000 490.6666667 499.3333333 508.0000000 516.6666667 525.3333333 534.0000000 542.6666667 551.3333333 560.0000000 ];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[Cxb_prs_V,Cxb_n_V]=meshgrid(Cxb_cyl_fill_intk_mfld_prs,Cxb_cyl_fill_eng_spd);
Cal=[];

%% Conversion Mdl IFP
list_ifp_2d={'Alpha1','Alpha1','Alpha2','Alpha2','Alpha3','Alpha3'};
list_mdl_AEMS={'Cxm_cyl_fill_mdl_cor_1'
    'Cxm_cyl_fill_mdl_cor_1_vvl_intk_l_lift'
    'Cxm_cyl_fill_mdl_cor_2'
    'Cxm_cyl_fill_mdl_cor_2_vvl_intk_l_lift'
    'Cxm_cyl_fill_mdl_cor_3'
    'Cxm_cyl_fill_mdl_cor_3_vvl_intk_l_lift'};


Cal_IFP=MapFilling_Aspirated;
[ifp_prs_V,ifp_n_V]=meshgrid(Cal_IFP.Alpha1.y/1000,Cal_IFP.Alpha1.x);
for i=1:length(list_ifp_2d)
    
    Cmx_temp=Cal_IFP.(list_ifp_2d{i}).z;
    Cal.(list_mdl_AEMS{i})=griddata(ifp_n_V,ifp_prs_V,Cmx_temp,Cxb_n_V,Cxb_prs_V);
    map_smooth=gridfit(ifp_n_V(:),ifp_prs_V(:),Cmx_temp,Cxb_cyl_fill_eng_spd,Cxb_cyl_fill_intk_mfld_prs)';
    Cal.(list_mdl_AEMS{i})(isnan(Cal.(list_mdl_AEMS{i})))=map_smooth(isnan(Cal.(list_mdl_AEMS{i})));
end

Cal.Cxb_cyl_fill_mdl_vvt_intk_angl_ovlp_fac=Cxb_cyl_fill_mdl_vvt_intk_angl_ovlp_fac;
Cal.Cxb_cyl_fill_mdl_vvt_ex_angl_ovlp_fac=Cxb_cyl_fill_mdl_vvt_ex_angl_ovlp_fac;
[CxbOF_YV,CxbOF_XV]=meshgrid(Cal.Cxb_cyl_fill_mdl_vvt_ex_angl_ovlp_fac,Cal.Cxb_cyl_fill_mdl_vvt_intk_angl_ovlp_fac);
[OF_YV,OF_XV]=meshgrid(Cal_IFP.OF.y,Cal_IFP.OF.x);
Cal.Cxm_cyl_fill_mdl_vvt_intk_ex_angl_ovlp_fac=griddata(OF_XV,OF_YV,Cal_IFP.OF.z',CxbOF_XV,CxbOF_YV);
map_smooth=gridfit(OF_XV(:),OF_YV(:),Cal_IFP.OF.z',Cal.Cxb_cyl_fill_mdl_vvt_intk_angl_ovlp_fac,Cal.Cxb_cyl_fill_mdl_vvt_ex_angl_ovlp_fac)';
Cal.Cxm_cyl_fill_mdl_vvt_intk_ex_angl_ovlp_fac(isnan(Cal.Cxm_cyl_fill_mdl_vvt_intk_ex_angl_ovlp_fac))=map_smooth(isnan(Cal.Cxm_cyl_fill_mdl_vvt_intk_ex_angl_ovlp_fac));
Cal.Cxm_cyl_fill_mdl_vvt_intk_ex_angl_ovlp_fac_vvl_intk_l_lift=Cal.Cxm_cyl_fill_mdl_vvt_intk_ex_angl_ovlp_fac;
Cal.Cxp_cyl_fill_mdl_intk_vlv_cls_angl_cor=interp1(MapFilling_Aspirated.delta_ivc.x,MapFilling_Aspirated.delta_ivc.y,Cxb_cyl_fill_eng_spd);
Cal.Cxp_cyl_fill_mdl_intk_vlv_cls_angl_cor_vvl_intk_l_lift=Cal.Cxp_cyl_fill_mdl_intk_vlv_cls_angl_cor;


Cal.Cxb_cyl_fill_mdl_ex_vlv_cls_angl_cyl_vol=Cxb_cyl_fill_mdl_ex_vlv_cls_angl_cyl_vol;
Cal.Cxb_cyl_fill_mdl_intk_vlv_cls_angl_cyl_vol=Cxb_cyl_fill_mdl_intk_vlv_cls_angl_cyl_vol;
Cal.Cxp_cyl_fill_mdl_ex_vlv_cls_angl_cyl_vol = Volume_HR12(Cal.Cxb_cyl_fill_mdl_ex_vlv_cls_angl_cyl_vol);
Cal.Cxp_cyl_fill_mdl_intk_vlv_cls_angl_cyl_vol = Volume_HR12(Cal.Cxb_cyl_fill_mdl_intk_vlv_cls_angl_cyl_vol);

Cal.Cxb_cyl_fill_eng_spd=Cxb_cyl_fill_eng_spd;
Cal.Cxb_cyl_fill_intk_mfld_prs=Cxb_cyl_fill_intk_mfld_prs;


cal_name=fieldnames(Cal);
for i=1:length(cal_name)

    if contains(cal_name{i},'Cxm')
        Cal_tr.(cal_name{i})=Cal.(cal_name{i})';
    else
        Cal_tr.(cal_name{i})=Cal.(cal_name{i});
    end

end

prompt = 'Generate calibration for: [1]Simulink [2]INCA [3]Both: ? \n';
result = input(prompt);

if result ==1
    conv2mfile(Cal,'Cal_sim');
else
    if result==2
        conv2mfile(Cal_tr,'Cal_inca');
        
    else
        if result==3
            conv2mfile(Cal,'Cal_sim');
            conv2mfile(Cal_tr,'Cal_inca');
        else
            msgbox('Wrong number entered, try again');
        end
    end
    
end


