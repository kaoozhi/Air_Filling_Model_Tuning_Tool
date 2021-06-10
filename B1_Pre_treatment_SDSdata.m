clear
close all
clc
addpath(genpath(cd))

Dir_path=uigetdir('Select SDS Data Folder:');
foldernames = dir(Dir_path);
filenames=dir([Dir_path '\**\*.mat']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To do: define label name for intake manifold pressure and breakpoints ran on SDS test
varname_Pman='P_A_COL';
Pman_brkp =10*[12.0 24.0 36.0 48.0 66.0 84.0 102.0 120.0 144.0 168.0 180 192.0 216.0 240.0 264.0 288.0 312.0];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To do: define input variable labels to read
var_in={'N','MAP','MAT','VVTCA','VVTCE','P_AVT','QAMGC_P1','T_AVT','RICONDIA','P_A_COL','VVTCA_SP','VVTCE_SP','KS','QE','VLVT','QA','TCO'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To do: define output variable labels to write
var_out={'N','MAP','MAT','VVTCA','VVTCE','P_AVT','QAMGC','T_AVT','RICONDIA','P_A_COL','VVTCA_SP','VVTCE_SP','KS','QE','VLVT','QA','TCO'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Variable selection filter
Pman_min = 300; %mbar: minimum value for valid Pman measurement
Pman_var_thd = 10; %mbar: variation threshold for selection
VVTint_var_thd=1; %degCA: VVTCA-variation threshold for selection
VVTexh_var_thd=1; %degCA: VVTCE-variation threshold for selection

%% Delay finder
Data_all_file=[];
for ifile=1:length(filenames)
    %     length(filenames)
    
    Data=load([filenames(ifile).folder '\' filenames(ifile).name]);
    
    %% Delay finder -> hysteris reduction
    xx = Data.(varname_Pman);
    %     yy = Data.QAMGC./Data.RICONDIA;
    yy = Data.QAMGC;
    % Sweep delay
    max_delay = 60; %
    freq_Hz = 10;
    R2 = nan(max_delay+1,1);
    dt = nan(max_delay+1,1);
    
    % Set up fittype and options.
    ft = fittype( 'poly5' );
    for i = 0:1:max_delay
        x_new = xx(1:end-i);
        y_new = yy(1+i:end);
        [xData, yData] = prepareCurveData( x_new, y_new );
        [fitresult, gof] = fit( xData, yData, ft);
        R2(i+1,1) = gof.rsquare;
        dt(i+1,1) = i/freq_Hz;
    end
    % Best delay and fitting coefficient
    [B,max_idx] = max(R2);
    R2_store = B;
    dt_store = dt(max_idx);
    shift_idx = dt_store*10;
    
    
    %     x_new = xx(1:end-shift_idx);
    %     y_new = yy(1+shift_idx:end);
    %     z_new = zz(1:end-shift_idx);
    %
    
    figure(1)
    %     plotbrowser('on')
    %     hold on
    %     i = dt(max_idx)*10;
    x_new = [nan(shift_idx,1);xx];
    y_new = [yy; nan(shift_idx,1)];
    plot(xx,yy,'linewidth',2)
    hold on
    plot(x_new,y_new,'linewidth',2)
    hold off
    grid on
    xlabel('Pman [mbar]')
    ylabel('QAMGC [mg]')
    legend('before','after','Location','Southeast')
    %     hold off
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% To do: VVT correction if needed, modify the following codes
    %     Cxp_vvt_ex_angl_n_cor = [-0.275000005960464 -0.324999988079071 -0.375 -0.5 -0.600000023841858 -0.699999988079071 -0.850000023841858 -0.899999976158142 -1 -1.14999997615814 -1.25 -1.39999997615814 -1.60000002384186 -1.79999995231628 -2.09999990463257 -2.40000009536743 -2.54999995231628 -2.65000009536743 -2.70000004768372 -3];
    %     Cxb_vvt_ex_angl_n_cor_bkp = [550 650 750 1000 1200 1400 1700 1800 2000 2300 2500 2800 3200 3600 4200 4800 5100 5300 5400 6000];
    %     Cxp_vvt_intk_angl_n_cor = [0.137500002980232 0.162499994039535 0.1875 0.25 0.300000011920929 0.349999994039536 0.425000011920929 0.449999988079071 0.5 0.574999988079071 0.625 0.699999988079071 0.800000011920929 0.899999976158142 1.04999995231628 1.20000004768372 1.27499997615814 1.32500004768372 1.35000002384186 1.5];
    %     Cxb_vvt_intk_angl_n_cor_bkp = [550 650 750 1000 1200 1400 1700 1800 2000 2300 2500 2800 3200 3600 4200 4800 5100 5300 5400 6000];
    %     Orange
    %         Data.VVTCE = Data.VVTCE-2;
    %         Data.VVTCA = Data.VVTCA + 7;
    %     Grey
    %         Data.VVTCA = Data.VVTCA_SP;
    %
    %         Data.VVTCE = Data.VVTCE + interp1(Cxb_vvt_ex_angl_n_cor_bkp,Cxp_vvt_ex_angl_n_cor, min(6000,Data.N));
    %         Data.VVTCA = Data.VVTCA + interp1(Cxb_vvt_intk_angl_n_cor_bkp,Cxp_vvt_intk_angl_n_cor, min(6000,Data.N));
    %     Yellow: no correction
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %% Averaging sample points by Pman breakpoint with delayed Pman data
    % Selection conditions
    ival_VVTint=abs(Data.VVTCA(1:end-shift_idx)-mean(Data.VVTCA(1:end-shift_idx)))<=VVTint_var_thd;
    ival_VVTexh=abs(Data.VVTCE(1:end-shift_idx)-mean(Data.VVTCE(1:end-shift_idx)))<=VVTexh_var_thd;
    ival=ival_VVTint & ival_VVTexh & Data.QAMGC(1+shift_idx:end)<1e6;
    Data.QA(Data.QA>1e6) = Data.QAMGC(Data.QA>1e6).*Data.N(Data.QA>1e6)*3/120/1000*3.6;
    
    
    % Application of delay
    Data_all_var=[];
    
    for i=1:length(var_in)
        if strcmp(var_in{i},'QAMGC')
            Data_all_var=[Data_all_var,Data.(var_in{i})(1+shift_idx:end)];
        else
            Data_all_var=[Data_all_var,Data.(var_in{i})(1:end-shift_idx)];
        end
    end
    
    
    % Averaging sample points on each Pman breakpoint
    idx_varname_Pman = find(contains(var_in,varname_Pman));
    Data_all_fil_Pman=[];
    for i=1:length(Pman_brkp)
        ival_Pman=abs(Data_all_var(:,idx_varname_Pman)-Pman_brkp(i))<=Pman_var_thd & Data_all_var(:,idx_varname_Pman)>=Pman_min;
        Data_fil_Pman=mean(Data_all_var(ival&ival_Pman,:),1);
        Data_fil_Pman(idx_varname_Pman)=Pman_brkp(i);% Force Pman brkp value as mean value
        if isnan(Data_fil_Pman(1))|| sum(ival&ival_Pman)<10
            Data_fil_Pman=[];
        end
        Data_all_fil_Pman=[Data_all_fil_Pman;Data_fil_Pman];
    end
    
    %Appending
    Data_all_file=[Data_all_file;Data_all_fil_Pman];
    
end

for i=1:length(var_out)
    Data_all.(var_out{i})=Data_all_file(:,i);
end
Data=Data_all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To do: choose unit for intake manifold pressure
% if P_A_COL selected (mbar)
Data.MAP = Data.(varname_Pman)/10;
% if MAP selected (kPa)
% Data.MAP = Data.(varname_Pman);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To do: define path and name for output file
save('.\SDS_calib_all.mat','-struct','Data');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
