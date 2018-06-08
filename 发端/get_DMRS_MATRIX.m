function [ RS_MAP_MATRIX ] = get_DMRS_MATRIX( NID )
%GET_DMRS_MATRIX 此处显示有关此函数的摘要
%   此处显示详细说明
    global RS_MAP_MATRIX;
    RS_MAP_MATRIX = zeros(240,7);
    out1 = zeros(1,240);
    out3 = zeros(1,240);
    out21 = zeros(1,48);
    out22 = zeros(1,48);
    DMRS_v = mod(NID,4);

    index_1_3 = [0:239] + 1; %用到的子载波下标
    index_2 = [0:47] + 1;

    DMRS_index1_3 = [0:4:236] + 1 + DMRS_v; %DMRS的子载波下标
    DMRS_index2 = [0:4:44] + 1 + DMRS_v;
    
   %计算PBCH数据部分子载波下标
   for i = 1:length(DMRS_index1_3)
       locate = find(index_1_3 == DMRS_index1_3(i));
       if(~isempty(locate))
           index_1_3(locate) = [];
       end
   end
   for i = 1:length(DMRS_index2)
       locate = find(index_2 == DMRS_index2(i));
       if(~isempty(locate))
           index_2(locate) = [];
       end
   end
   out1(index_1_3) = 1;
   out1(DMRS_index1_3) = 2;
   out21(index_2) = 1;
   out21(DMRS_index2) = 2;
   out22(index_2) = 1;
   out22(DMRS_index2) = 2;
   out3(index_1_3) = 1;
   out3(DMRS_index1_3) = 2;
   RS_MAP_MATRIX(:,4) = out1;
   RS_MAP_MATRIX(:,5) = [out21 zeros(1,144) out22];
   RS_MAP_MATRIX(:,6) = out3;
end

