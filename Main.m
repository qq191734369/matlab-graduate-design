%====================发端一帧一帧发送=================%
%====================每一帧有10个子帧=================%
%====================BLOCK_NUM=10=================%
clear all;
close all;
clc;
addpath(genpath(pwd));
global_parameters;
config_global_parameters();
Snr = [-7,-6,-5,-4,-3,-2,-1,0,1,2];
% Snr = [5,6];
Rx_CFO = [(2*rand(1, 1)-1)*0.1 (2*rand(1, 1)-1)*5];
%% General parameters
nid_1 = 200;
nid_2 = 0;
NID = 3*nid_1 + nid_2;
BW = 5;         %MHz
CFO_per_ppm = 4; %kHz
TTIs=20;      %各点运行的最大传输次数
PerNum = 1;
BloPer = 1;
% 同步序列时频起始位置
k0_pss = NUM_USED_SUBCARRIER/2-PSS_ALLOCATED_LENGTH/2;
l_pss = 3;
k0_sss = NUM_USED_SUBCARRIER/2-PSS_ALLOCATED_LENGTH/2;
l_sss = l_pss+2;
sss_pss_distance = 2*(CP_LENGTH_SHORT+IFFT_SIZE);
% Rx parameters
N = 1;                    %下采样点数
% 用于调试、测试平台
PSS_first_position = SUBFRAME_LEN/2 - (IFFT_SIZE+CP_LENGTH_SHORT)*4 -IFFT_SIZE + 1;

right_detect_normal = [];
right_detect_normal_large_cfo = [];
right_pbch_arr = [];
pbch_trans_arr = [];
BER = [];
%% PBCH数据生成
RS_MAP_MATRIX = get_DMRS_MATRIX(NID);
DATA_NUM = sum(sum(RS_MAP_MATRIX==1));                 % DCI RE数
DMRSNum = sum(sum(RS_MAP_MATRIX==2));                 % DMRS RE数
[DMRS_LOCATION,DATA_LOCATION] = getDMRS_DATA_location();
pbch_len = 8;
rateMatch_len = 864;
% pbch_data = prbs15_lc(pbch_len);
crcLen = 24;
DLUL = 1;
L=8; %搜索树宽度
[crcEncObj, crcDecObj] = getCRCObj(crcLen);
PolarParam = PC_Construction(rateMatch_len,pbch_len+crcLen, DLUL);
channelIntlv = getChannelIntlv(rateMatch_len,DLUL,PolarParam);
[UCIData, PolarOut] = Polar_Encode(pbch_len,rateMatch_len,crcLen,PolarParam,channelIntlv,crcEncObj); %经过速率匹配输出的编码结果一共864个bit
pbchData = qpsk(PolarOut); %经过调制，864个bit映射为432个复数，之后要进行资源映射
%将pbch数据分块并添加DMRS
[ pbchData1,pbchData21,pbchData22,pbchData3 ] = genPBCHBlock( pbchData,NID );

%% 信道部分
TU_channel_EPA_genetate_hou
% 计算RHH和RDH并保存下来
R_hh_dh_viena_DMRS;
% waitbar函数的句柄，显示程序运行进度条
% hwait = waitbar(0,'请等待>>>>>>>>'); 
% snr_array_length = length(Snr);
% step=snr_array_length/100;
for SnrInd = 1:length(Snr)
    % 同步成功数量初始化
    right_detect1 = 0;
    right_detect2 = 0;
    right_pbch = 0;
    pbch_trans = 0;
    err_bit = 0;
    %% 进度条
%      if snr_array_length-SnrInd<=0
%          waitbar(SnrInd/snr_array_length,hwait,'即将完成');
%          pause(0.05);
%      else
%          PerStr=fix(SnrInd/step);                % fix是向0靠拢取整函数，函数运行百分比
%          str=['正在运行： ',num2str(PerStr),'%'];   % 把1到BlockNum的数换算到1到100内，计算程序运行进度百分比 
%          waitbar(SnrInd/snr_array_length, hwait, str);
%          pause(0.05);
%      end
for I = 1:TTIs
    %% DL data generate and Mapping
    initialdata = round(rand(1,NUM_BITS_PER_FRAME));                   %initial data for DL(Physical channel, after channel coding and scrambling);
    [modout] = qpsk(initialdata);                                  %modulation
    data = reshape(modout,NUM_USED_SUBCARRIER,NUM_OFDM_PER_FRAME);
    %% PSS/SSS generate
    % add your codes here(PSS/SSS generate): 
    
    PSS1 = PSS(nid_2);% pss生成
    SSS1 = SSS(nid_1,nid_2);
    pss_length = length(PSS1);
    sss_length = length(SSS1);
    PSS_tx = [zeros(1,ceil((NUM_USED_SUBCARRIER-pss_length)/2)) PSS1 zeros(1,floor((NUM_USED_SUBCARRIER-pss_length)/2))];
    SSS_tx = [zeros(1,ceil((NUM_USED_SUBCARRIER-sss_length)/2)) SSS1 zeros(1,floor((NUM_USED_SUBCARRIER-sss_length)/2))];
    %% PSS/SSS mapping
    for i = 1:1                                                                       %PSS mapping
        data([1:NUM_USED_SUBCARRIER],l_pss+14*(i-1)) = PSS_tx;            %the frequency resource here is for PSS
        data([1:NUM_USED_SUBCARRIER],l_pss+14*(i-1)+1) = pbchData1;
        data([1:NUM_USED_SUBCARRIER],l_pss+14*(i-1)+3) = pbchData3;
        data([1:NUM_USED_SUBCARRIER],l_sss+14*(i-1)) = SSS_tx;          %the frequency resource here is for SSS0
        data([1:48],l_sss+14*(i-1)) = pbchData21;
        data([NUM_USED_SUBCARRIER-47:NUM_USED_SUBCARRIER],l_sss+14*(i-1)) = pbchData22;
%         data([1:NUM_USED_SUBCARRIER],NUM_OFDM_PER_FRAME/2+l_pss+14*(i-1)) = PSS_tx;            %the frequency resource here is for PSS
%         data([1:NUM_USED_SUBCARRIER],NUM_OFDM_PER_FRAME/2+l_sss+14*(i-1)) = SSS_tx;          %the frequency resource here is for SSS0 
    end
    %% OFDM modulation
    [ofdm_out1]=ofdm_mod(data,IFFT_SIZE,NUM_OFDM_SLOT,CP_LENGTH_LONG,CP_LENGTH_SHORT);  
    %% add TRP frequency offset ±0.05ppm均匀分布
    CFO_TRP = (2*rand(1, 1)-1)*0.05;                                                  %ppm
    ofdm_out = ofdm_out1; %.*exp(j*2*pi*CFO_TRP*CFO_per_ppm*1e3*([0:length(ofdm_out1)-1])*Ts); 
    
%     %初始化前快干扰
%     PreInterfere=zeros(1,SUBFRAME_LEN);
%     channel_out = [];
%     fft_size_minus = IFFT_SIZE-1;
%     train_ofdm_out=[zeros(1,CP_LENGTH_LONG), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), ...
%                     zeros(1,CP_LENGTH_LONG), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus), zeros(1,CP_LENGTH_SHORT), 1, zeros(1,fft_size_minus)];                                     
%     train_ofdm_temp = train_ofdm_out;
       %% 信道 EPA
%     if Ind == 1
%             PreviousTrain=zeros(UE_ANT_NUM*NB_ANT_NUM,T);
%             TrainInterfere=zeros(UE_ANT_NUM*NB_ANT_NUM,T);
%     end

        %% 计算相关矩阵
    channel_out = [];
    for block_index = 1:BLOCK_NUM
        if block_index == 1
            PreInterfere=zeros(UE_ANT_NUM*NB_ANT_NUM,T);
        end
        % 读取离线信道文件
        [H, delay_out, mul_path ] = TU_channel_EPA_from_file(block_index);
        % 过TDL-A信道 
        [channel_out_end,SignalInterfere]=TU_channel_new(ofdm_out(:,SUBFRAME_LEN*(block_index-1)+1:SUBFRAME_LEN*block_index),PreInterfere,H,delay_out,mul_path);
%         [channel_out_train,TrainInterfere] = TU_channel_new(train_ofdm_temp, PreviousTrain, H, delay_out, mul_path);  
        % 更新前块干扰td_pss_tx
        PreInterfere = SignalInterfere;
%         PreviousTrain = TrainInterfere; 
        channel_out = [channel_out, channel_out_end];
    end
    % 对每个信噪比点单独分别进行一下步骤
    % 过AWGN信道
    SnrLinear = 10^(Snr(SnrInd)/10);     
    NoiseVec = Awgn_Gen(channel_out, SnrLinear);               
    DataAwgn = channel_out + NoiseVec;  

     %pss测试后加的
    CFO_Rx = (2*rand(1, 1)-1)*0.1;                                                       %ppm ±0.1ppm均匀分布
    data_Rx1 = DataAwgn;%.*exp(j*2*pi*CFO_Rx*CFO_per_ppm*1e3*([0:length(ofdm_out1)-1])*Ts);

   %% 小区搜索  0.1/0.05ppm 
    [ceil_id2, Pss_location, CFO] = PSS_detect(data_Rx1, IFFT_SIZE, N, 10000 ,CP_LENGTH_SHORT,1);
    Pss_location
    data_Rx1=data_Rx1;%.*exp(-1*j*2*pi*CFO*([0:length(ofdm_out1)-1])*Ts);
    rx_pss = data_Rx1(Pss_location:Pss_location+IFFT_SIZE-1);
    %利用pss进行sss的信道估计
    channel_ls = ChannelEstmate_SSS( rx_pss, IFFT_SIZE, ceil_id2 );
    %分离SSS
    rx_sss = data_Rx1(Pss_location+sss_pss_distance:Pss_location+sss_pss_distance+IFFT_SIZE-1);
    
    % 获取RHH和RDH矩阵
    R_dh0_DMRS = Rdh(:,:,1);
    R_hh0_DMRS = Rhh(:,:,1);
    R_hh0_PSS = R_hh_PSS(:,:,1);
    %频域SSS检测 ------- 这个性能很重要，需要优化   
    channel_sss = channelEst_SSS_MMSE( channel_ls, R_hh0_PSS, SnrLinear );
    [id1,  max_corr] = SSS_detect(rx_sss, nid_2, channel_sss.', IFFT_SIZE);
    %% PBCH解调部分
    %计算nid
%     rx_nid = id1*3 + ceil_id2;
    rx_nid = 600;
    %分离含有pbch的符号，去cp
    PBCHSymbols = data_Rx1(Pss_location+IFFT_SIZE:Pss_location+IFFT_SIZE+3*(IFFT_SIZE+CP_LENGTH_SHORT)-1);
    PBCHSymbols = reshape(PBCHSymbols,IFFT_SIZE+CP_LENGTH_SHORT,3);
    PBCHSymbols(1:CP_LENGTH_SHORT,:) = [];
    %解ofdm
    rx_PBCHDataAndSSS = [];
    for i=1:3
    rx_PBCHDataAndSSS = [rx_PBCHDataAndSSS deofdm(PBCHSymbols(:,i).',NUM_USED_SUBCARRIER,IFFT_SIZE)];
    end
    
%     [H_Ideal, HPilott, HPSSt] = CE_LS(channel_out_train,3,600);
%     
    %分理出pbch数据
    [rx_PBCHDataToDeqpsk,rx_dmrs] = getPBCHData( rx_PBCHDataAndSSS,rx_nid );
    h_dmrs = rx_dmrs./DMRS;  % LS估计导频处信道
    
    
    % 实际信道估计
    H_est = Channel_estimation(h_dmrs, R_dh0_DMRS,R_hh0_DMRS, SnrLinear);               
    % MMSE检测
    [ MMSEOut, MMSESinr ] = MMSE_detector_MIMO( rx_PBCHDataToDeqpsk,H_est, SnrLinear,NB_ANT_NUM);
    %解qpsk
    rx_PBCHDataToDePolar = Demodulation_data(MMSEOut, MMSESinr);
    %解Polar
    rx_PBCHData = Polar_Decode(rx_PBCHDataToDePolar,rateMatch_len,crcLen,PolarParam,L,channelIntlv,crcDecObj);
    bit_right = rx_PBCHData(1:8).' == UCIData
    if(isempty(find(bit_right==0)))
        right_pbch = right_pbch+1;
    end
    err_bit = err_bit + sum(bit_right == 0);
    % 判断是否检测成功
    if(id1==nid_1 && ceil_id2==nid_2 && abs(Pss_location-PSS_first_position)<=CP_LENGTH_SHORT/2)
        right_detect1 = right_detect1 + 1;
        
        pbch_trans = pbch_trans +1;
    end
end

right_detect_normal = [right_detect_normal right_detect1];
right_pbch_arr = [right_pbch_arr right_pbch];
pbch_trans_arr = [pbch_trans_arr pbch_trans];
BER = [BER err_bit/(8*TTIs)];
end
right_pbch_arr
pbch_trans_arr
% close(hwait);          % 关闭进度条
right_detect_normal = right_detect_normal./TTIs;
figure(10)
plot(Snr,right_detect_normal,'--+b')
title('联合检测成功率')
xlabel('信噪比（dB）')
ylabel('一次检测PSS/SSS联合检测成功率')
% h = legend(['优化算法'],['传统算法'],['低精度量化'],'location','best');
% h = legend(['传统算法'],'location','best');
h = legend(['0.05/0.1ppm 3km/h'],'best');
set(h,'Box','off');
set(gca,'YTick',0.4:0.1:1);

BLER = (TTIs-right_pbch_arr)./TTIs;
figure(1)
plot(Snr,BLER,'--+b')
hold on;
plot(Snr,BER,'--*r')
title('PBCH误块率')
xlabel('信噪比（dB）')
ylabel('概率')
h = legend(['本文BLER'],['本文BER'],'best');
set(h,'Box','off');
% set(gca,'YTick',[0,0.001,0.01,0.1,1]);