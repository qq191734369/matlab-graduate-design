function [ data , sinr] = MMSE_detector( indata, H )
%MMSE_DETECTOR 此处显示有关此函数的摘要
%   此处显示详细说明
    sinr = 20;
    data = indata./H;

end

