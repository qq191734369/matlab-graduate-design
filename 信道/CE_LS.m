%% 函数功能：
%function used by R_hh_dh_calculation_viena
%% 输入参数：
% DataOfdmIn：待解调的数据流
%% 输出参数
% DataSymOut：解调及解资源映射后的数据流
% PilotSymOut：解调及解资源映射后的DMRS
%% Modify history
% 2017/6/18 created by Bu Shuqing
% 2017/10/30 modified by Liu Chunhua
%% code
function [ HData, HPilot, HPSS] = CE_LS(DataOfdmIn,PBCHBeginOFDMIndex,nid)

global IFFT_SIZE;
global LONG_CP_PERIOD;
global CP_LENGTH_LONG;
global CP_LENGTH_SHORT;

ReFreNum = 240;
ReTimeNum = 7;
DataSymMatrix = zeros(ReFreNum, ReTimeNum);                                 % 系统时频资源块

PosInd =0;
%% 解OFDM调制
for TimeInd=1:ReTimeNum                                                     % 判断CP类型
    if mod(TimeInd,LONG_CP_PERIOD) == 1                                                             
        temp_Cp_length = CP_LENGTH_LONG;
    else 
        temp_Cp_length = CP_LENGTH_SHORT;
    end
    PosInd = PosInd + temp_Cp_length;
    data_to_FFT = DataOfdmIn(PosInd + (1: IFFT_SIZE));                        % 去除CP，提取数据部分
    post_FFT=fft(data_to_FFT);                                              % 输入为训练数据，不用除FFT点数
    DataSymMatrix((1:(ReFreNum/2)), TimeInd)=post_FFT((IFFT_SIZE-ReFreNum/2+1) : IFFT_SIZE);  %negative part
    DataSymMatrix(((ReFreNum/2+1):ReFreNum), TimeInd)=post_FFT(2:(ReFreNum/2)+1);         %positive part
    PosInd = PosInd + IFFT_SIZE;
end
%% 分离出PSS
PSSData = DataSymMatrix(:,PBCHBeginOFDMIndex).';
PSSData = PSSData(ceil((ReFreNum-127)/2)+1:ceil((ReFreNum-127)/2)+127);
%% 分离出有PBCH的符号
PBCHData = DataSymMatrix(:,PBCHBeginOFDMIndex+1:PBCHBeginOFDMIndex+3); %一共3个符号
[row,col] = size(PBCHData);
PBCHData = reshape(PBCHData,1,row*col);
%% 分离出PBCH
[DataSymOut,PilotSymOut] = getPBCHData( PBCHData, nid);
   HData = DataSymOut.';
   HPilot = PilotSymOut.';
   HPSS = PSSData.';
end

