%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To do: choose calibration file to load
Cal = load('Cal_cor_alti_0531.mat');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cal_name=fieldnames(Cal);
for i=1:length(cal_name)

    if contains(cal_name{i},'Cxm')
        Cal_tr.(cal_name{i})=Cal.(cal_name{i})';
    else
        Cal_tr.(cal_name{i})=Cal.(cal_name{i});
    end

end

conv2mfile(Cal_tr,'Cal_cor_alti_inca');