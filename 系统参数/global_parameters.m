%% 仿真参数
global SYS_BW;
global NB_ANT_NUM;
global UE_ANT_NUM;
global MODULATION;

global IFFT_SIZE;
global T;%一个子帧上的采样点数

global SUBCARRIER_SPACE;
global SYMBOL_PER_SUBFRAME;

global NL;%流数
global DATA_NUM;%可用RE个数
global BLOCK_NUM;


%% DMRS图样
global DMRS_FREQUENCY;
global DMRS_TIME;
global RS_MAP_MATRIX;
global DMRS_LOCATION;
global DATA_LOCATION;
global DMRS;

%%
global INNER_INTERLEAVER_PARAMETERS;
global CB_CRC_POLYNOMIAL;
global TB_CRC_POLYNOMIAL;
%% PSS
global PSS_QUALIFY;
global PSS_NORMAL;
global PSS_LOW;
global PSS_ALLOCATED_LENGTH ;   
global SSS_ALLOCATED_LENGTH ; 
%% 帧参数
global NUM_SUBFRAME;
global SLOT_PERSUBFRAME ;
global NUM_OFDM_SLOT;
global NUM_RB;
global NUM_SUBCARRIER_PER_RB;
global MODU_MODE ;
global CP_LENGTH_SHORT;
global CP_LENGTH_LONG;
global LONG_CP_PERIOD;

global Ts;
global NUM_USED_SUBCARRIER;
global NUM_OFDM_PER_SUBFRAME ;
global NUM_OFDM_PER_FRAME ;
global NUM_BITS_PER_SUBFRAME ;
global NUM_BITS_PER_FRAME;
global SUBFRAME_LEN;
global FRAME_LEN;
global G; % PBCH payload交织

%% 信道
global MAX_DELAY;
global CHANNEL_MODE;
global MUL_PATH;
global DELAY_TIME;
global DELAY_OUT;
global UE_SPEED;
global CARRIER_FREQUENCY;
global Am;
