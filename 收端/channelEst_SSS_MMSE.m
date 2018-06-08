function [ ch_MMSE ] = channelEst_SSS_MMSE( ch_LS, R_hh, SnrLinear )
%CHANNELEST_SSS_MMSE 此处显示有关此函数的摘要
%   此处显示详细说明
    %计算beita
    %计算方法 beita=(星座点的平方的均值)*(星座点倒数的平方的均值)
    %即beita=(sum(abs(constel_diagram).^2)/64)*(sum(abs(1./constel_diagram).^2)/64)
    global MODULATION;
    switch (MODULATION)
        case {2}                               % QPSK为2
            beita=1;
        case {4}                               % 16QAM为4
            beita=17/9;
        case {6}                               % 64QAM为6
            beita=2.6854;            
    end
    R_hh_pilot = R_hh / (R_hh+beita/SnrLinear*eye(length(R_hh)));

    ch_MMSE = R_hh_pilot*ch_LS.';

end

