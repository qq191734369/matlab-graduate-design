function [ data, dmrs ] = getPBCHData( PBCHSymbols, nid)
%GETPBCHDATA 此处显示有关此函数的摘要
%  ssBlock是一个时域信号，是一个矩阵，没一行代表子载波，每一列代表一个符号
DMRS_v = mod(nid,4);
len = length(PBCHSymbols);
data = [PBCHSymbols(1:288) PBCHSymbols(len-288+1:len)];

%计算DMRS位置
DMRS_index = [1:4:576] + DMRS_v;
dmrs = data(DMRS_index);
data(DMRS_index) = [];
end

