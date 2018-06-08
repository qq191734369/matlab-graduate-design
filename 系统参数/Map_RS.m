function [ RSMapMatrix ] = Map_RS( RBNum,DMRS_FREQUENCY,DMRS_TIME )
%% 函数功能：
% 构造参考信号的资源映射矩阵，矩阵每行代表频域上对应的1个子载波，每列代表时域上对应的1个符号，对应矩阵元素 1: 数据, 2: DMRS,
%% 输入参数：
% RBNum ：仿真所考虑RB数量
% DMRS_FREQUENCY：DMRS所在的频域位置，1个RB内
% DMRS_TIME：DMRS所在的时域位置，1个RB内
%% 输出参数：
% RSMapMatrix：资源映射矩阵
%% Modify history
% 2017/10/28 created by Liu Chunhua 
%% code

RSMapMatrix = [];
global SUBCARRIER_PER_RB;
global SYMBOL_PER_SUBFRAME;
global PDCCH_LENTH;
% RE映射
RSMapMatrixRB = ones(SUBCARRIER_PER_RB,SYMBOL_PER_SUBFRAME);
% 控制资源映射
RSMapMatrixRB(:,1:PDCCH_LENTH)=0;
% 参考信号映射
for i=1:length(DMRS_TIME)
    RSMapMatrixRB(DMRS_FREQUENCY,DMRS_TIME(i))=2;
end
% 将RB组合起来
for ii=1:RBNum
    RSMapMatrix=[RSMapMatrix;RSMapMatrixRB];
end

end

