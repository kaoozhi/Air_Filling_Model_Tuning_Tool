function conv2mfile_value(Cal,filename)
[file,path] = uiputfile([filename '.m'],'Convert calibration to (.m)');

calname = sprintf('%s', [path file]);
fileID = fopen(calname,'wt');
list_name=sort(fieldnames(Cal));
for j=1:length(list_name)
    
    formatCxp1 = [list_name{j} '.Value=['];
    formatCxp2 = '%.7f ';
    formatCxp3 = '];\n\n';
    formatCxx1 = [list_name{j} '.Value='];
    formatCxx2 = '%.4f ';
    formatCxx3 = ';\n\n';
    formatoth1 = [list_name{j} '.Value='];
    formatoth2 = '%.4f ';
    formatoth3 = ';\n\n';
    if ~startsWith(list_name{j},'Cx') && ~startsWith(list_name{j},'Cb') && ~startsWith(list_name{j},'Cn')
        fprintf(fileID,formatoth1);
        fprintf(fileID,formatoth2,Cal.(list_name{j}));
        fprintf(fileID,formatoth3);
    else
        
        if numel(Cal.(list_name{j}))<=1
            fprintf(fileID,formatCxx1);
            fprintf(fileID,formatCxx2,Cal.(list_name{j}));
            fprintf(fileID,formatCxx3);
        else
            fprintf(fileID,formatCxp1);
            %         fprintf(fileID,formatCxp2, Cal.(list_name{j}));
            if size(Cal.(list_name{j}),1)==1 || size(Cal.(list_name{j}),2)==1
                fprintf(fileID,formatCxp2, Cal.(list_name{j}));
            else
                [nbrow,~]=size(Cal.(list_name{j}));
                for irow=1:nbrow
                    formatCmp='%.7f ';
                    fprintf(fileID,formatCmp, Cal.(list_name{j})(irow,:));
                    if irow~=nbrow
                        formatCmp=';\n';
                        fprintf(fileID,formatCmp);
                    end
                end
            end
            fprintf(fileID,formatCxp3);
        end
    end
    
    
end
fclose(fileID);
end