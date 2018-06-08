function [data,IntlvBit] = Polar_Encode(K,N,crcLen,PolarParam,channelIntlv,CRCEncObj)
%% 函数功能：
% 生成随机数据流，添加CRC，并进行Polar编码及相应的速率匹配
%% 输入参数：
% K:生成信息位长度
% N:编码比特速率匹配输出长度
% DLUL:上下行标志，1表示下行，0表示上行
% crcLen:CRC长度
% PolarParam:Polar码参数
% channelIntlv：信道交织参数
%% 输出参数：
% data:原始信息比特
% IntlvBit:编码输出
%% Modify history
% 2018/1/31 created by Sharon Sha 
%% code
repSeq          = PolarParam.repSeq;
N0              = PolarParam.N_mother;
dcrcIntlv       = PolarParam.dcrcIntlv;
DLUL            = PolarParam.DLUL;

% data = randi([0,1], 1, K);
[data_len,data] = prbs15_lc(K);
    if DLUL==1
        
        ones_data = [ones(24,1); data(:)];
        ones_data_CRCAttached = step(CRCEncObj, ones_data);
        dataCRCAttached = ones_data_CRCAttached(25:end);
        dataIntlv = dataCRCAttached(dcrcIntlv);
        IntlvBit = Polar_Encoder(dataIntlv,N0,K,PolarParam,N, repSeq);
        else
        if isfield(PolarParam,'Seg')
            data = randi([0,1], 1, PolarParam.Seg_originK-crcLen);    
            if mod(PolarParam.Seg_originK-crcLen,2) == 1
                data0 = data(1:PolarParam.Seg_K-crcLen-1);
                data1 = data(end-(PolarParam.Seg_K-crcLen)+1:end);
                data0 = [0 data0]; % padding zero
            else
                data0 = data(1:PolarParam.Seg_K-crcLen);
                data1 = data(end-(PolarParam.Seg_K-crcLen)+1:end);
            end

            
            dataIntlv0 = step(CRCEncObj, data0.').';
            EncodedBit0 = Polar_Encoder(dataIntlv0,N0,K,PolarParam,N/2, repSeq);
            IntlvBit0 = EncodedBit0(channelIntlv);
            dataIntlv1 = step(CRCEncObj, data1.').';
            EncodedBit1 = Polar_Encoder(dataIntlv1,N0,K,PolarParam,N/2, repSeq);
            IntlvBit1 = EncodedBit1(channelIntlv);
            
            IntlvBit = [IntlvBit0 IntlvBit1]; % combine x
        else
            dataIntlv = step(CRCEncObj, data.').';
            EncodedBit = Polar_Encoder(dataIntlv,N0,K,PolarParam,N, repSeq);
            IntlvBit = EncodedBit(channelIntlv);
        end
    end
end

