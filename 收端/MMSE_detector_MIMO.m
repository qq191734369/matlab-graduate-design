%% 函数功能
% MMSE联合检测
%% 输入参数
% DataSymOut:接收到的数据流 NumRec*Len
% HEst：估计出的信道 NumRec* （NumTra*Len）
% SnrLinear：信噪比线性值
% NumTra：发送端天线数
%% 输入参数
% MMSEOut：检测出的数据流
% MMSESinr：检测出的信干噪比
%% Modify history
% 2017/6/6 created by Bu Shuqing
%% code
function [ MMSEOut, MMSESinr ] = MMSE_detector_MIMO( DataSymOut, HEst, SnrLinear, NumTra)
n_power=1/SnrLinear;                          % 噪声方差
Len = size(DataSymOut,2);
Ir=eye(NumTra);
MMSEOut = zeros(NumTra,Len);                  % 检测出的数据流
MMSESinr = zeros(NumTra,Len);                 % 检测出的信干噪比
    for I_s = 1 : Len
        H = HEst(:,(I_s:Len:NumTra*Len));     % NumRec* NumTra
        MMSEMat=pinv(H'*H+n_power*Ir)*H';
        NorMat = zeros(NumTra,NumTra);
        for TraInd = 1:NumTra
            NorMat(TraInd,TraInd) = 1 / (MMSEMat(TraInd,:) * H(:,TraInd));    
        end            
        NorMMSEMat = NorMat * MMSEMat;            
        MMSEOut(:,I_s) = NorMMSEMat * DataSymOut(:,I_s); 
        % 检测SINR
        temp_u = zeros(NumTra,NumTra);         %分子
        temp_dl = zeros(NumTra,NumTra);        %左侧分母
        temp_dr = zeros(NumTra,NumTra);        %右侧分母
        for TraInd = 1:NumTra
           temp_u(TraInd)=(MMSEMat(TraInd,:)*H(:,TraInd)) * (MMSEMat(TraInd,:)*H(:,TraInd))';
           temp_dl(TraInd) = (MMSEMat(TraInd,:) * H) * (MMSEMat(TraInd,:) * H)'-temp_u(TraInd); 
           temp_dr(TraInd) = MMSEMat(TraInd,:)*MMSEMat(TraInd,:)'*n_power; 
           MMSESinr(TraInd ,I_s) = temp_u(TraInd)/(temp_dl(TraInd)+temp_dr(TraInd));                
        end        
    end
end

