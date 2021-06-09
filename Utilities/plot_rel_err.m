function plot_rel_err(est,ref,filename,x,y,tt)      

      subplot(1,4,1)
      analysis_plot(est,ref,filename,1);
      legend('MDL\_IFP','Location','Southeast')


    
%     EngineMap(Data.N, Data.P_A_COL/10,Masp_RSA,Masp,'MDL\_RSA');
%     
%     subplot(2,4,4)
%     histerr(Masp, Masp_RSA, 'MDL\_RSA')
%     
%        tt = 'MDL\_IFP: MAF';
%     subplot(2,4,[6,7])
      subplot(1,4,[2,3])
%       EngineMap(Data.Vxx_avg_eng_spd_XETK_1, Data.Vxx_intk_mfld_prs_XETK_1,Vxx_cyl_pump_flow_sim,Vxx_cyl_pump_flow_sw,'MDL\_IFP- impact Pdif');
      EngineMap(x, y,est,ref,tt);
      
      subplot(1,4,4)
      histerr(ref, est, tt);
end