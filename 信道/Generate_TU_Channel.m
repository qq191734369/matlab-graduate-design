%% 函数功能：
% 产生信道TDL-A
%% 输入参数
% BlockInd：数据包索引
%% 输出参数
% H：信道矩阵（列数为采样点个数+MAX_DELAY）
%% Modify history
% 2018/1/18 created by Liu Chunhua 
%% code

function [H] = Generate_TU_Channel(BlockInd)
%%%%%%%%%%%%%%%%% 产生信道（一个一个数据包产生）%%%%%%%%%%%%%%%%%%%%%
global UE_ANT_NUM;
global NB_ANT_NUM;
global SUBCARRIER_SPACE;
global IFFT_SIZE; 
global UE_SPEED;
global CARRIER_FREQUENCY;

global MUL_PATH;
global MAX_DELAY;
global Am;
% 一个子slot的持续时间(s)
period=1*10^(-3)/(SUBCARRIER_SPACE/15);
% 产生信道的采样周期
Ts=1*10^(-3)/SUBCARRIER_SPACE/IFFT_SIZE;  
%% 生成信道
for u=1:UE_ANT_NUM
    for s=1:NB_ANT_NUM
        %%%%%%%%%%%%%%产生信道%%%%%%%%%%%%%%%
        ChannelState=rand(1,MUL_PATH)*sum(100*clock);
%         t=[(BlockInd-1)*period:Ts:BlockInd*period-Ts];
        t=(BlockInd-1)*period:Ts:(BlockInd*period-Ts+MAX_DELAY*Ts);
        NumSam = length(t);
        for n=1:MUL_PATH
            channel=Jakes_gen(UE_SPEED,CARRIER_FREQUENCY,t,ChannelState(n));
%             channel=Jakes_gen_ruili(UE_SPEED,CARRIER_FREQUENCY,Ts);
%             H(u,s,n,:) = Am(n)*filter(channel,ones(1,NumSam));
            h_I=real(channel);
            h_Q=imag(channel);
            tempH=h_I+1i*h_Q;
            H(u,s,n,:)=tempH*Am(n);
        end
    end
end
end