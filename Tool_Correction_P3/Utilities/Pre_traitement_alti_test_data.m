close all
clear
[FileName,PathName,FilterIndex] = uigetfile('.mat','MultiSelect','off','Choose data file: .mat');
Data = load([PathName FileName]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To do: Define slicing index of sections to be removed
slicing_idx = {[1,101],	[937,1098],	[1975,2301],	[2860,3117],	[3760,3920],	[4647,4750],	[5540,5558],	[6432,6465],	[7317,7348],	[8253,8321],	[9146,9299],	[10042,10211],	[10941,11103],	[11832,11999]...
    ,	[12700,12869],	[13594,13807],	[14521,14801],	[15417,15691],	[16316,16621]}; % 2500m valid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

varname_inj_ena = 'Vbx_inj_ena';
varname_inj_ena_inca = 'Vbx_inj_ena_XETK_1';
try
    idx_inj_on = Data.(varname_inj_ena)==1;
catch
    idx_inj_on = Data.(varname_inj_ena_inca)==1;
end


varnames = fieldnames(Data);
Data_all_var = [];
for i=1:length(varnames)
    
    Data_all_var=[Data_all_var,Data.(varnames{i})];
    
end

idx = true(size(Data_all_var,1),1);
for j=1:length(slicing_idx)
    
    idx(slicing_idx{j}(1):slicing_idx{j}(2))=false;
end
idx = idx & idx_inj_on;

Data_all_new = Data_all_var(idx,:);
for k=1:length(varnames )
    Data_all.(varnames{k})=Data_all_new(:,k);
end
save([PathName strrep(FileName,'.mat','') '_filtered.mat'],'-struct','Data_all')