clear
close all
clc
addpath(genpath(cd))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% To do:  select SDS data path to be loaded
Data=load('Input_data\DataBase\SDS\2757\SDS_calib_all.mat');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%
% index=(~(abs(Data.VVTCA-7)<=2)) & (~abs(Data.VVTCA-30)<=2);
Vcyl = 0.00119900004938245; % m3
R = 287;%J/Kg
Ne_SDS = Data.N(index); %rpm
Masp_SDS = Data.QAMGC(index); %kg

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% To do: choose right unit for intake manifold pressure
% Pman_SDS = Data.MAP*1e2; %Pa
Pman_SDS = Data.P_A_COL(index)*1e2; %Pa
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
Tman_SDS = Data.MAT(index); %K
Tco_SDS = Data.TCO(index);
Texh_SDS = Data.T_AVT(index); %K
VVTint_SDS = Data.VVTCA(index); %?V
VVTexh_SDS = Data.VVTCE(index); %?V

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% To do: define VVT positions ran on SDS tests
VVTCA_list=[0 2 8 23 31 38 53 60];
VVTCE_list=[0 13 29 43 58];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
Ne_list=unique(round(Ne_SDS,-1));
Pman_list = unique(round(Pman_SDS,-1));
eta_SDS = Masp_SDS*1e-6./(Pman_SDS*Vcyl/3./(R*(Tman_SDS+273.15)));
VVTint_SDS = interp1(VVTCA_list,VVTCA_list,VVTint_SDS,'nearest','extrap');
VVTexh_SDS = interp1(VVTCE_list,VVTCE_list,VVTexh_SDS,'nearest','extrap');
Ne_SDS = interp1(Ne_list,Ne_list,Ne_SDS,'nearest','extrap');
Pman_SDS = interp1(Pman_list,Pman_list,Pman_SDS,'nearest','extrap');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% To do: Define Engne speed and intake manifold pressure breakpoints
Ne_vect = [600,750,1000,1250,1500,1750,2100,2500,3000,3500,4000,4500,5000,5500,6000,6500]; %rpm
Pman_vect = 1e3*[12.0 24.0 36.0 48.0 66.0 84.0 102.0 120.0 144.0 168.0 192.0 216.0 240.0 264.0 288.0 312.0]; %Pa
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%% Extrapolate Masp SDS data
VVTint_vect = unique(VVTint_SDS);
VVTexh_vect = unique(VVTexh_SDS);
%% Extrapolate Masp = f(Ne,Pman) for each VVTCE/VVTCA pair
dFF = fullfact([numel(Ne_vect),numel(Pman_vect)]);
Ne_all = [];
Pman_all =[];
for i=1:length(dFF)
    Ne_all = [Ne_all; Ne_vect(dFF(i,1))];
    Pman_all = [Pman_all; Pman_vect(dFF(i,2))];
end


Masp_maps = [];
eta_maps = [];
ii = 1;
eta_min = min(eta_SDS);
eta_max = max(eta_SDS);

%% Extrapolate Masp=f(Pman) for each N, VVTCA/VVTCE pair;
for ica = 1:length(VVTint_vect)
    
    for ice = 1:length(VVTexh_vect)
        %         eta_extrap = [];
        %         Pman_extrap = [];
        %         Masp_extrap = [];
        %         Ne_extrap = [];
        %         Tman_extrap = [];
        idx_sel = (VVTint_SDS == VVTint_vect(ica))&(VVTexh_SDS == VVTexh_vect(ice));
        if sum(idx_sel)<=20
            continue
        else
            
            % Extrapolation for engine speeds hor range along each Pman
            Pman_extrap_pre1 =[];
            Ne_extrap_pre1=[];
            %             Masp_extrap_pre1 =[];
            eta_extrap_pre1 =[];
            Pman_sel = Pman_SDS(idx_sel);
            Ne_sel = Ne_SDS(idx_sel);
            eta_sel = eta_SDS(idx_sel);
            
            Pman_vect_pre = Pman_vect(ismember(Pman_vect,Pman_sel));
            %             x_new = Ne_vect(Ne_vect<min(Ne_sel)| Ne_vect>max(Ne_sel))';
            x_new = Ne_vect(Ne_vect<min(Ne_sel)& Ne_vect<min(Ne_SDS))';
            
            %             x_new = Ne_vect(~ismember(Ne_vect,Ne_sel))';
            min_n_pt = 10;
            for kk=1:length(Pman_vect_pre)
                
                yy = eta_sel(Pman_sel==Pman_vect_pre(kk));
                if length(yy) >=min_n_pt
                    xx = Ne_sel(Pman_sel==Pman_vect_pre(kk));
                    p = polyfit(xx,yy,2);
                    %                     y_new = polyval(p,x_new);
                    if ~all(diff(sort(xx)))
                        
                        [xx,ia,ic] = unique(xx);
                        yy = yy(ia);
                    end
                    y_new1 = interp1(xx,yy,x_new,'nearest','extrap');
                    y_new2 = polyval(p,x_new);
                    alpha = 0.9;
                    y_new = y_new1*alpha+y_new2*(1-alpha);
%                     y_new(y_new>eta_max)= eta_max*1.05;
%                     y_new(y_new<eta_min)=eta_min*0.95;
                    y_new = min(y_new, eta_max*1.05);
                    y_new = max(y_new, eta_min*0.95);
                    
                    eta_extrap_pre1 =[eta_extrap_pre1;y_new];
                    Ne_extrap_pre1 = [Ne_extrap_pre1; x_new];
                    Pman_extrap_pre1 =[Pman_extrap_pre1; Pman_vect_pre(kk)*ones(size(x_new))];
                end
            end
            
            Tman_extrap_pre1 = mean(Tman_SDS(idx_sel))*ones(size(Ne_extrap_pre1));
            Masp_extrap_pre1 = eta_extrap_pre1.*(Pman_extrap_pre1*Vcyl/3./(R*(Tman_extrap_pre1+273.15)))*1e+6;
            
            
            % Extrapolation for Pman hor range along each engine speed%
            Pman_extrap_pre2 =[];
            Ne_extrap_pre2=[];
            Masp_extrap_pre2 =[];
            eta_extrap_pre2 =[];
            Tman_extrap_pre2 = [];
            Ne_vect_pre = Ne_vect(ismember(Ne_vect,Ne_sel));
            %             x_new = Pman_vect(Pman_vect>max(Pman_SDS)| Pman_vect<min(Pman_SDS))';
            x_new = Pman_vect(Pman_vect>max(Pman_SDS))';
            %             x_new = Pman_vect(~ismember(Pman_vect,Pman_sel))';
            for kk=1:length(Ne_vect_pre)
                %                 if Ne_vect_pre(kk) >=min(Ne_SDS)
                yy = eta_sel(Ne_sel==Ne_vect_pre(kk));
                if length(yy) >=min_n_pt
                    xx = Pman_sel(Ne_sel==Ne_vect_pre(kk));
                    p = polyfit(xx,yy,2);
                    if ~all(diff(sort(xx)))                    
                        [xx,ia,ic] = unique(xx);
                        yy = yy(ia);
                    end
                    y_new1 = interp1(xx,yy,x_new,'nearest','extrap');
                    y_new2 = polyval(p,x_new);
                    beta = 1;
                    y_new = y_new1*beta+y_new2*(1-beta);
%                     y_new(y_new>eta_max)= eta_max*1.05;
%                     y_new(y_new<eta_min)= eta_min*0.95;
                    y_new = min(y_new, eta_max*1.05);
                    y_new = max(y_new, eta_min*0.95);
                    eta_extrap_pre2 =[eta_extrap_pre2;y_new];
                    Ne_extrap_pre2 = [Ne_extrap_pre2; Ne_vect_pre(kk)*ones(size(x_new))];
                    Pman_extrap_pre2 =[Pman_extrap_pre2; x_new];
                end
                %                 end
            end
            Tman_extrap_pre2 = mean(Tman_SDS(idx_sel))*ones(size(Ne_extrap_pre2));
            Masp_extrap_pre2 = eta_extrap_pre2.*(Pman_extrap_pre2*Vcyl/3./(R*(Tman_extrap_pre2+273.15)))*1e+6;
%             

            
            eta_extrap_pre = [eta_extrap_pre1;eta_extrap_pre2];
            Pman_extrap_pre = [Pman_extrap_pre1;Pman_extrap_pre2];
            Masp_extrap_pre = [Masp_extrap_pre1; Masp_extrap_pre2];
            Ne_extrap_pre = [Ne_extrap_pre1; Ne_extrap_pre2];
            Tman_extrap_pre = [Tman_extrap_pre1; Tman_extrap_pre2];
            
            
            %             eta_extrap = [eta_extrap;eta_extrap_pre];
            %             Pman_extrap = [Pman_extrap;Pman_extrap_pre];
            %             Masp_extrap = [Masp_extrap; Masp_extrap_pre];
            %             Ne_extrap = [Ne_extrap; Ne_extrap_pre];
            %             Tman_extrap = [Tman_extrap; Tman_extrap_pre];
            
            
            %% Extrapolate with gridfit
            
%             idx_extrap_1st = Pman_all >= min(Pman_SDS(idx_sel)) & Pman_all <= max(Pman_SDS(idx_sel)) & Ne_all> max(Ne_SDS(idx_sel));
%             idx_extrap_2nd = Ne_all >= min(Ne_SDS(idx_sel)) & Pman_all < min(Pman_SDS(idx_sel));
%             ide_extrap_3rd = Ne_all < min(Ne_SDS(idx_sel)) & Pman_all < min(Pman_SDS(idx_sel));
            idx_extrap_1st = Pman_all >= min(Pman_SDS(idx_sel)) & Pman_all <= max(Pman_SDS(idx_sel)) & Ne_all> max(Ne_SDS);
            idx_extrap_2nd = Ne_all >= min(Ne_SDS(idx_sel)) & Pman_all < min(Pman_SDS);
            ide_extrap_3rd = Ne_all < min(Ne_SDS) & Pman_all < min(Pman_SDS);
            
            %             idx_extrap_1st = Ne_all < min(Ne_SDS(idx_sel)) & Pman_all < min(Pman_SDS(idx_sel));
            %             idx_extrap_2nd = Ne_all > max(Ne_SDS(idx_sel)) & Pman_all < min(Pman_SDS(idx_sel));
            
            idx_extrap_fit = idx_extrap_1st | idx_extrap_2nd | ide_extrap_3rd;
            
            Ne_extrap_fit = Ne_all(idx_extrap_fit);
            Pman_extrap_fit = Pman_all(idx_extrap_fit);
            extrap_mode = 'solver';
            extrap_opt = 'normal';
%             extrap_mode = 'regularizer';
%             extrap_opt = 'gradient';
            %             eta_map=gridfit(Ne_SDS(idx_sel),Pman_SDS(idx_sel),eta_SDS(idx_sel),Ne_vect,Pman_vect,extrap_mode, extrap_opt);
            eta_map=gridfit([Ne_SDS(idx_sel);Ne_extrap_pre],[Pman_SDS(idx_sel);Pman_extrap_pre],[eta_SDS(idx_sel);eta_extrap_pre],Ne_vect,Pman_vect,extrap_mode, extrap_opt);
            
            %             eta_max =max(eta_SDS(idx_sel));
            eta_extrap_fit=min(eta_max*1.05,interp2(Ne_vect,Pman_vect,eta_map,Ne_extrap_fit,Pman_extrap_fit));
            
%             eta_extrap_fit(eta_extrap_fit<eta_min)=eta_min*0.95;
            eta_extrap_fit = max(eta_extrap_fit,eta_min*0.95);
            Tman_extrap_fit = mean(Tman_SDS(idx_sel))*ones(size(Ne_extrap_fit));
            Masp_extrap_fit = eta_extrap_fit.*(Pman_extrap_fit*Vcyl/3./(R*(Tman_extrap_fit+273.15)))*1e+6;
            
            
            %             Masp_map = gridfit([Ne_SDS(idx_sel);Ne_extrap],[Pman_SDS(idx_sel);Pman_extrap],[Masp_SDS(idx_sel);Masp_extrap],Ne_vect,Pman_vect);
            
            Ne_vect_sel = Ne_vect(ismember(Ne_vect,Ne_SDS(idx_sel)));
            Pman_vect_sel = Pman_vect(ismember(Pman_vect, Pman_SDS(idx_sel)));
            Masp_map_sel = gridfit(Ne_SDS(idx_sel),Pman_SDS(idx_sel),Masp_SDS(idx_sel),Ne_vect_sel,Pman_vect_sel);
            eta_map_sel = gridfit(Ne_SDS(idx_sel),Pman_SDS(idx_sel),eta_SDS(idx_sel),Ne_vect_sel,Pman_vect_sel);
            
            
            %             eta_new = [eta_SDS(idx_sel);eta_extrap];
            %             Pman_new = [Pman_SDS(idx_sel);Pman_extrap];
            %             Ne_new = [Ne_SDS(idx_sel);Ne_extrap];
            %             Masp_new = [Masp_SDS(idx_sel); Masp_extrap];
            %% Append surface fitted data to extrapolated data
            eta_extrap = [eta_extrap_pre;eta_extrap_fit];
            Pman_extrap = [Pman_extrap_pre;Pman_extrap_fit];
            Ne_extrap = [Ne_extrap_pre; Ne_extrap_fit];
            Masp_extrap = [Masp_extrap_pre;Masp_extrap_fit];
            Tman_extrap = [Tman_extrap_pre; Tman_extrap_fit];
            %% Remove data where the Masp is not realistic
            ind_Masp = Masp_extrap > 50 & Masp_extrap < 1200;
            
            eta_extrap = eta_extrap(ind_Masp);
            Pman_extrap = Pman_extrap(ind_Masp);
            Ne_extrap = Ne_extrap(ind_Masp);
            Masp_extrap = Masp_extrap(ind_Masp);
            Tman_extrap = Tman_extrap(ind_Masp);
            
            
            figure;
            set(gcf,'position',[20 50 1600 600],'PaperPositionMode','auto');
            
            subplot(121)
            %             surf(Ne_vect,Pman_vect*1e-3,eta_map,'FaceAlpha',0.5);
            surf(Ne_vect_sel,Pman_vect_sel*1e-3, eta_map_sel,'FaceAlpha',0.5);
            hold on
            plot3(Ne_SDS(idx_sel),Pman_SDS(idx_sel)*1e-3,eta_SDS(idx_sel),'bo','linewidth',2)
            plot3(Ne_extrap,Pman_extrap*1e-3,eta_extrap,'r*','linewidth',2);
            hold off
            title(['\eta_{cyl} @ VVTCA=' num2str(VVTint_vect(ica)) 'deg, VVTCE=' num2str(VVTexh_vect(ice)) 'deg'])
            
            ylabel('Pman[kPa]')
            xlabel('Ne[rpm]')
            zlabel('[-]')
            subplot(122)
            %             surf(Ne_vect,Pman_vect*1e-3,Masp_map,'FaceAlpha',0.5);
            surf(Ne_vect_sel,Pman_vect_sel*1e-3, Masp_map_sel,'FaceAlpha',0.5);
            
            hold on
            %         surf(Ne_vect_extrap,Pman_vect_extrap*1e3,Masp_grid_extrap);
            plot3(Ne_SDS(idx_sel),Pman_SDS(idx_sel)*1e-3,Masp_SDS(idx_sel),'bo','linewidth',2)
            plot3(Ne_extrap,Pman_extrap*1e-3,Masp_extrap,'r*','linewidth',2);
            hold off
            title(['M_{asp} @ VVTCA=' num2str(VVTint_vect(ica)) 'deg, VVTCE=' num2str(VVTexh_vect(ice)) 'deg'])
            
            ylabel('Pman[kPa]')
            xlabel('Ne[rpm]')
            zlabel('[mg/str]')
            
            %         Data_extrap(ii).eta=eta_extrap;

            Data_extrap(ii).MAT=Tman_extrap;
            Data_extrap(ii).QAMGC=Masp_extrap;
            %         Data_extrap(ii).eta_map=eta_map;
            %         Data_extrap(ii).Masp_map=Masp_map;
            Data_extrap(ii).N=Ne_extrap;
            Data_extrap(ii).P_A_COL=Pman_extrap/100;
            Data_extrap(ii).MAP=Pman_extrap/1000;
            Data_extrap(ii).VVTCA=VVTint_vect(ica)*ones(size(Ne_extrap));
            Data_extrap(ii).VVTCE=VVTexh_vect(ice)*ones(size(Ne_extrap));
            Data_extrap(ii).T_AVT=mean(Texh_SDS(idx_sel))*ones(size(Ne_extrap));
            Data_extrap(ii).QA = Masp_extrap.*Ne_extrap*3/120/1000*3.6;
            Data_extrap(ii).TCO = mean(Tco_SDS(idx_sel))*ones(size(Ne_extrap));
            
            ii = ii+1;
        end
        
        
        
        
        
    end
    
end

%% Save data
var_name_Data = fieldnames(Data);
var_save = var_name_Data(ismember(var_name_Data,fieldnames(Data_extrap)));
Data_all =[];
for i = 1:length(Data_extrap)
    Data_temp = [];
    for j = 1:length(var_save)
        Data_temp = [Data_temp, Data_extrap(i).(var_save{j})];
    end
    Data_all =[Data_all; Data_temp];
end

for i = 1:length(var_save)
    Data_save.(var_save{i}) = Data_all(:,i);
end
Data_SDS = Data;
Data = Data_save;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To do: define output file path
save('Input_data/SDS_calib_all_extrap','-struct','Data');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 