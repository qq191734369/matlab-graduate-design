function [DMRS_location,data_location] = getDMRS_DATA_location
%GETPOSITION 此处显示有关此函数的摘要
%   此处显示详细说明
global RS_MAP_MATRIX;
[fre,time] = size(RS_MAP_MATRIX);
DMRS_fre = 1;
data_fre = 1;
DMRS_location = [];
data_location = [];
DMRS_index = 1;
data_index = 1;
for i = 1:time
    for j = 1:fre
        if(RS_MAP_MATRIX(j,i) == 2)
            DMRS_location(1,DMRS_index) = j;
            DMRS_location(2,DMRS_index) = i;
            DMRS_index = DMRS_index+1;
        elseif(RS_MAP_MATRIX(j,i) == 1)
            data_location(1,data_index) = j;
            data_location(2,data_index) = i;
            data_index = data_index+1;
        end
    end
    DMRS_fre = 1;
    data_fre = 1;
end
end

