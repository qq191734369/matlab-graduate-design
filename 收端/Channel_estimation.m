%% 函数功能：
% 进行信道估计
%% 输入参数：
% PilotSymOut：参考信号
% R_dh：数据与导频子载波间的互相关矩阵
% R_hh：导频子载波间的自相关矩阵
% SnrLinear：信噪比线性值
%% 输出参数
% HDataMMSE：估计出的数据位置处信道
%% Modify history
% 2017/6/5 created by Mao Zhendong
% 2017/10/30 modified by Liu Chunhua
%% code
function HDataMMSE = Channel_estimation(PilotSymOut, R_dh,R_hh,SnrLinear)

    %计算beita
    %计算方法 beita=(星座点的平方的均值)*(星座点倒数的平方的均值)
    %即beita=(sum(abs(constel_diagram).^2)/64)*(sum(abs(1./constel_diagram).^2)/64)
%     global MODULATION;
%     switch (MODULATION)
%         case {2}                               % QPSK为2
%             beita=1;
%         case {4}                               % 16QAM为4
%             beita=17/9;
%         case {6}                               % 64QAM为6
%             beita=2.6854;            
%     end
%     R_hh_pilot = R_hh / (R_hh+beita/SnrLinear*eye(length(R_hh)));
    R_hh_data = R_dh / (R_hh+1/SnrLinear*eye(length(R_hh)));

    HLS = PilotSymOut.';                       % LS估计出的DMRS处信道
%     HPilotMMSE = R_hh_pilot * HLS;             % LMMSE估计出的DMRS处信道
    HDataMMSE = (R_hh_data * HLS).';    % LMMSE估计出的数据位置处信道
    
    
