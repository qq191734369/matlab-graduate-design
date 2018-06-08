%% 函数功能：
% 数据过信道
%% 输入参数
% SignalIn：输入数据
% PreInterfere：来自上一个数据包的前块干扰
% H：信道矩阵
%% 输出参数
% SignalOut：输出数据
% SignalInterfere：对下一个数据包的前块干扰
%% Modify history
% 2018/1/18 created by Liu Chunhua 
%% code
function [SignalOut, SignalInterfere] = Pass_Channel(SignalIn,PreInterfere,H)
global UE_ANT_NUM;
global NB_ANT_NUM;
global DELAY_OUT;
global MAX_DELAY;

MulPath  = size(H,3);
% 采样点个数
N = size(SignalIn,2);
% 前块干扰点数
PreSeqNum = min(MAX_DELAY,size(PreInterfere,2));
%% 信号过信道
SignalTemp = zeros(UE_ANT_NUM*NB_ANT_NUM,N+MAX_DELAY);
for u=1:UE_ANT_NUM %注意这是接收端天线
    for s=1:NB_ANT_NUM %发送天线
        for n=1:MulPath
            DelayAdd = DELAY_OUT(n);
            HTemp=H(u,s,n,:);
%             SignalTemp((u-1)*NB_ANT_NUM+s,(DelayAdd+1):(DelayAdd+N)) = SignalTemp((u-1)*NB_ANT_NUM+s,(DelayAdd+1):(DelayAdd+N)) ...
%                 +SignalIn(s,:).*HTemp;
            SignalTemp((u-1)*NB_ANT_NUM+s,(DelayAdd+1):(DelayAdd+N)) = SignalTemp((u-1)*NB_ANT_NUM+s,(DelayAdd+1):((DelayAdd+N))) ...
                +SignalIn(s,:).*HTemp(1,(DelayAdd+1):(DelayAdd+N));
        end
    end
end
%% 整合前块干扰
for PathInd = 1:UE_ANT_NUM*NB_ANT_NUM
    SignalTemp(PathInd,1:PreSeqNum) = SignalTemp(PathInd,1:PreSeqNum)+PreInterfere(PathInd,1:PreSeqNum);
end
%% 输出信号
SignalOut = SignalTemp(:,1:N);
SignalInterfere = SignalTemp(:,N+1:N+PreSeqNum);
end
