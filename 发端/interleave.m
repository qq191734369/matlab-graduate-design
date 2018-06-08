function [ data_interleaved ] = interleave( data, L)
%INTERLEAVE 此处显示有关此函数的摘要
%   此处显示详细说明
global G;

a_G = [];
A = length(data);

i_SFN = [A-7,A-6,A-5,A-4];
i_HRF = A-3;
i_SSB = [A-2,A-1,A];

j_SFN = 1;
j_HRF = 11;
j_SSB = 12;
j_other = 15;

for i = 1:A
    if ~isempty(find(i_SFN == i))
        a_G(i) = G(j_SFN)+1;
        j_SFN = j_SFN + 1;
    elseif i == i_HRF
        a_G(i) = G(i_HRF) + 1;
    elseif i >= A-2 && i <= A
        a_G(i) = G(i_SSB) + 1;
        i_SSB = i_SSB +1;
    else
        a_G(i) = G(j_other) + 1;
        j_other = j_other + 1;
    end
end
end

