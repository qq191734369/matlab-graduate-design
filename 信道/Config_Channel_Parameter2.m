function Config_Channel_Parameter2(CHANNEL_MODE)
%% 函数功能：
% 配置信道参数相关全局变量
%% Modify history
% 2018/1/18 created by Liu Chunhua 
%% code
global SUBCARRIER_SPACE;
global IFFT_SIZE; 
global UE_SPEED;
global CARRIER_FREQUENCY;

global DELAY_OUT;
global MAX_DELAY;

global MUL_PATH;
global DELAY_TIME;
global Am;
global DELAY_SPREAD;
%% 初始化参数
%移动终端的速度
% UE_SPEED=9*3.6/3.6;
UE_SPEED=3/3.6;
%载波频率
CARRIER_FREQUENCY=4*1e9;
% 时延扩展
DELAY_SPREAD=100*(1e-9);
if strcmp(CHANNEL_MODE,'TDL-A')==1
    %多径的数目
    MUL_PATH=23;
    %各径的延迟时间
    NormalizedDelay=[0.0000,0.3819,0.4025,0.5868,0.4610,0.5375,0.6708,0.5750,0.7618,1.5375,1.8978,2.2242,2.1718,2.4942,2.5119,3.0582,4.0810,4.4579,4.5695,4.7966,5.0066,5.3043,9.6586];
    %各径的功率
    RelativePower=[-13.4,0,-2.2,-4,-6,-8.2,-9.9,-10.5,-7.5,-15.9,-6.6,-16.7,-12.4,-15.2,-10.8,-11.3,-12.7,-16.2,-18.3,-18.9,-16.6,-19.9,-29.7];
elseif strcmp(CHANNEL_MODE,'TDL-B')==1
    MUL_PATH=23;
    NormalizedDelay=[0.0000,0.1072,0.2155,0.2095,0.2870,0.2986,0.3752,0.5055,0.3681,0.3697,0.5700,0.5283,1.1021,1.2756,1.5474,1.7842,2.0169,2.8294,3.0219,3.6187,4.1067,4.2790,4.7834];
    RelativePower=[0,-2.2,-4,-3.2,-9.8,-1.2,-3.4,-5.2,-7.6,-3,-8.9,-9,-4.8,-5.7,-7.5,-1.9,-7.6,-12.2,-9.8,-11.4,-14.9,-9.2,-11.3];
elseif strcmp(CHANNEL_MODE,'TDL-C')==1
    MUL_PATH=24;
    NormalizedDelay=[0.0000,0.2099,0.2219,0.2329,0.2176,0.6366,0.6448,0.6560,0.6584,0.7935,0.8213,0.9336,1.2285,1.3083,2.1704,2.7105,4.2589,4.6003,5.4902,5.6077,6.3065,6.6374,7.0427,8.6523];
    RelativePower=[-4.4,-1.2,-3.5,-5.2,-2.5,0,-2.2,-3.9,-7.4,-7.1,-10.7,-11.1,-5.1,-6.8,-8.7,-13.2,-13.9,-13.9,-15.8,-17.1,-16,-15.7,-21.6,-22.8];
end
%normal:功率是否归一化的标志，normal＝1，则relative_power为归一化功率，否则为实际通过此径的信号功率
Normal=1;
%% 中间变量
% 产生信道的采样周期
Ts=1*10^(-3)/SUBCARRIER_SPACE/IFFT_SIZE;   
% 计算各径延时
DELAY_TIME=DELAY_SPREAD*NormalizedDelay;
% 各径的延迟点数
DELAY_OUT=round(DELAY_TIME/Ts);
% 所有径中最大的延迟点数
MAX_DELAY=max(DELAY_OUT);
%信号通过信道时的相对幅度值
Am=sqrt(10.^(0.1*RelativePower));
%判断功率是否归一化
if Normal==1
    Am=Am./sqrt(sum(Am.^2));
end
end