%% 程序功能：
% 离线生成 2D_viena 信道估计所用的信道相关信息：R_hh，导频元素自相关矩阵；R_dh，数据与导频元素互相关矩阵 

% 计算信道相关矩阵
for PerInd = 1 : PerNum
    R_hh_temp = 0;
    R_dh_temp = 0;
    R_hh_PSS_temp = 0;
    for Ind = 1:BloPer
        BlockIndex = (PerInd-1)*BloPer+Ind;
        %% 训练序列
        fft_size_minus = IFFT_SIZE-1;
        train_ofdm_out=[zeros(1,CP_LENGTH_LONG), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), ...
                        zeros(1,CP_LENGTH_LONG), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus)];                                     
        train_ofdm_temp = train_ofdm_out;
       %% 信道 EPA
        if Ind == 1
                PreviousTrain=zeros(UE_ANT_NUM*NB_ANT_NUM,T);
        end
        [H, delay_out, mul_path ] = TU_channel_EPA_from_file(BlockIndex);   %读取离线信道文件
        [channel_out_train,TrainInterfere] = TU_channel_new(train_ofdm_temp, PreviousTrain, H, delay_out, mul_path);  
        PreviousTrain = TrainInterfere; 
        %% 计算相关矩阵
         [HData, HPilot, HPSS] = CE_LS(channel_out_train,l_pss,NID);
         R_hh_temp = R_hh_temp + HPilot * HPilot';
         R_dh_temp = R_dh_temp + HData * HPilot';   
         R_hh_PSS_temp = R_hh_PSS_temp + HPSS*HPSS';
    end
    R_hh_temp = R_hh_temp/BloPer;
    R_dh_temp = R_dh_temp/BloPer;
    R_hh_PSS_temp = R_hh_PSS_temp/BloPer;
    R_hh(:,:,PerInd) = R_hh_temp;
    R_dh(:,:,PerInd) = R_dh_temp;
    R_hh_PSS(:,:,PerInd) = R_hh_PSS_temp;

    %% 计算时域相关性
    % Slot的长度
    period=1*10^(-3)/(SUBCARRIER_SPACE/15);  
    % 最大多普勒频偏，频率Hz,速度m/s，单位要归一化
    fDmax = UE_SPEED*CARRIER_FREQUENCY/3e8;
    % 计算每个符号的时间长度，包括CP
    SymbolDuration = period/SYMBOL_PER_SUBFRAME;
    DeltaT = (0:(SYMBOL_PER_SUBFRAME-1))*SymbolDuration;
    Rtt = besselj(0,2*pi*fDmax*DeltaT);

    %% 只设置频域插值
    % lenRtt = length(Rtt);
    % Rtt = ones(1,lenRtt);
    %% 计算频域相关性
    % 计算延迟功率谱
    for n = 1:(MAX_DELAY+1)
        index = find((DELAY_OUT+1)==n);
        PDP(n) = sum(Am(index).^2);
    end
    Rf = fft(PDP,IFFT_SIZE);%/sqrt(IFFT_SIZE);
    Rff = Rf.';

    %% 计算时频域信道相关矩阵
    RffRtt = Rff*Rtt;
    %% 计算插值矩阵
    DMRSLen = size(DMRS_LOCATION,2);
    DataLen = size(DATA_LOCATION,2);
    PortNum = size(DMRS_LOCATION,3);

    Rhh = zeros(DMRSLen,DMRSLen,PortNum);
    Rdh = zeros(DataLen,DMRSLen,PortNum);
    % 计算导频自相关矩阵
    for PortInd = 1:PortNum
        for DMRSInd1 = 1:DMRSLen
            for DMRSInd2 = 1:DMRSLen
                DeltaF = abs(DMRS_LOCATION(1,DMRSInd2,PortInd) - DMRS_LOCATION(1,DMRSInd1,PortInd))+1;
                DeltaT = abs(DMRS_LOCATION(2,DMRSInd2,PortInd) - DMRS_LOCATION(2,DMRSInd1,PortInd))+1;
                    if DMRS_LOCATION(1,DMRSInd1,PortInd) >= DMRS_LOCATION(1,DMRSInd2,PortInd)
                        Rhh(DMRSInd1,DMRSInd2,PortInd) = RffRtt(DeltaF,DeltaT);
                    else
                        Rhh(DMRSInd1,DMRSInd2,PortInd) = RffRtt(DeltaF,DeltaT)';
                    end
            end
        end
    end
    % 计算导频和数据间的互相关矩阵
    for PortInd = 1:PortNum
        for DataInd = 1:DataLen
            for DMRSInd = 1:DMRSLen
                DeltaF = abs(DATA_LOCATION(1,DataInd,PortInd) - DMRS_LOCATION(1,DMRSInd,PortInd))+1;
                DeltaT = abs(DATA_LOCATION(2,DataInd,PortInd) - DMRS_LOCATION(2,DMRSInd,PortInd))+1;
                    if DATA_LOCATION(1,DataInd,PortInd) >= DMRS_LOCATION(1,DMRSInd,PortInd)
                        Rdh(DataInd,DMRSInd,PortInd) = RffRtt(DeltaF,DeltaT);
                    else
                        Rdh(DataInd,DMRSInd,PortInd) = RffRtt(DeltaF,DeltaT)';
                    end
            end
        end
    end
end

save('R_hh_dh_viena_DMRS_frontloaded2RB.mat', 'Rhh', 'Rdh','R_hh_PSS');