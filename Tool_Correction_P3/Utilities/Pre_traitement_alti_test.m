Tqi_list =  [30 45 60 75 90 105 120 135 150 165 180 195 210 235];
%% Variable selection filter
Tqi_var_thd = 0.05; %mbar: minimum value for valid Pman measurement
Dir_path=uigetdir('Select SDS Data Folder:');
foldernames = dir(Dir_path);
filenames=dir([Dir_path '\**\*.mat']);

% varname_Ne = 'Vxx_avg_eng_spd_XETK_1';
% varname_Tqi = 'Vxx_tqi_sp_XETK_1';
% varname_inj_ena = 'Vbx_inj_ena_XETK_1';
varname_Ne = 'Vxx_avg_eng_spd';
varname_Tqi = 'Vxx_tqi_sp';
varname_inj_ena = 'Vbx_inj_ena';
for ifile=1:length(filenames)
    Data=load([filenames(ifile).folder '\' filenames(ifile).name]);
    
    Data_all_var=[];
    var_in = fieldnames(Data);
    for j=1:length(var_in)
        Data_all_var=[Data_all_var,Data.(var_in{j})];
    end
    
    ival_Ne=Data.(varname_Ne)>1000 & Data.(varname_Ne)<4800;
    ival_Pman = false(size(Data.(varname_Tqi)));
    for i=1:length(Tqi_list)
        ival_Pman=ival_Pman | abs(Data.(varname_Tqi)-Tqi_list(i))<=Tqi_var_thd;
    end
%     ival = ival_Ne & ival_Pman & Data.(varname_inj_ena);
    ival = ival_Ne & ~((Data.(varname_inj_ena))<1);

    Data_all_new = Data_all_var(ival,:);
    %     end
    
    for k=1:length(var_in)
    Data_all.(var_in{k})=Data_all_new(:,k);
    end
    save([filenames(1).folder '\' filenames(ifile).name(1:end-4) '_filtered.mat'],'-struct','Data_all')
    
end
