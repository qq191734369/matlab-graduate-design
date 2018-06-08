function [h]=Jakes_gen_ruili(v,fc,Ts)
%函数[h]=myjakesmodel(v,t,fc,k)，
%该程序利用改进的jakes模型来产生单径的平坦型瑞利衰落信道
%Yahong R.Zheng and Chengshan Xiao "Improved Models for
%the Generation of Multiple Uncorrelated Rayleigh Fading Waveforms"
%IEEE Commu letters, Vol.6, NO.6, JUNE 2002
%输入变量说明：
%  fc：载波频率 单位Hz
%  v:移动台速度  单位m/s
%  t :信道持续时间  单位s
%  seed: 产生衰落的随机数种子
%  h为输出的瑞利信道函数，是一个时间函数复序列
%作者：娄文科   日期：05.3.13
%电磁波传播速度即光速
c=3*10^8;
%最大多普勒频移
wm=fc*v/c;
h = rayleighchan(Ts,wm);