% ************************************************************************
% Copyright: Huawei Technologies Co., Ltd. 2017 All rights reserved.
% File name: PC_Construction.m
% Author: CT HangZhou Alg
% Description:  Polar Code Construction, and Rate Matching initialization
% History: Dec 8th, 2017 Cleaned
%*************************************************************************
function    [PolarParam] = PC_Construction(N,K,DLUL)
% N: coded block size
% K: info block size, including CRC
% DLUL: 1 for DL, 0 for UL
PolarParam.Seg_originK = K;
PolarParam.Seg_originN = N;

if N-(K-3)>192
    F = 1;
else
    F = 0;
end

% impose mother code length
% parameters: from RAN1_90 WA R1-1715000 option 2
beta = 1+ 1/8;
Rrepthr = 9/16;
Rmin = 1/8;

if (DLUL==0)
    % segmentation
    if ((K-11)>=360) && (N>=1088)
        if mod(N,2)==1
            error('Odd N in segmentation is NOT supported.')
        end
        K = ceil((K-11)/2)+11;
        N = ceil(N/2);
        PolarParam.Seg = true;
        PolarParam.Seg_N = N;
    end
end

% determine mother code length
N_DM = 2^ceil(log2(N));
if (N<=beta*N_DM/2) && (K/N<Rrepthr)
    N_M = N_DM/2;
else
    N_M = N_DM;
end
N_R = 2^ceil(log2(K/Rmin));

if (DLUL==1)
    N_max = 512;
elseif (DLUL==0)
    N_max = 1024;
end

N_mother = min([N_M,N_R,N_max]);

if N>N_mother
    N = N_mother;
end

%% repetition pattern
N0 = 2^ceil(log2(N));
numG = 32;
sizeG = N0/numG;
qSeq = [0 1 2 4 3 5 6 7 8 16 9 17 10 18 11 19 12 20 13 21 14 22 15 23 24 25 26 28 27 29 30 31] + 1;
repSeq = [];
for ii=1:numG
    repSeq = [repSeq (qSeq(ii)-1)*sizeG+1:qSeq(ii)*sizeG];
end

%%
if (DLUL==1)
    %% rate matching
    [B,q,~] = rate_matching(N0,N,K);
    if max(q) == 2
        LLR_PUNCTURE = -10E4;
    else
        LLR_PUNCTURE = 0;
    end
    %% 1-pass construction
    Info_Set_Id = false(1,N0);
    Info_Index = B(max(1,end-K+1):end);
    Info_Set_Id(Info_Index) = true;
    Froz_Set_Id = ~Info_Set_Id;
    DynFroz_Set_Id = false(1,N0);
    % D-CRC interleaver
    dcrcIntlvMax = getDCRCIntlv;
    deltaK = length(dcrcIntlvMax)-K;
    dcrcIntlv = dcrcIntlvMax(dcrcIntlvMax>deltaK);
    dcrcIntlv = dcrcIntlv - min(dcrcIntlv)+1;
    
elseif (DLUL==0)
    if ((K-6)<=19 && (K-6)>=12)
        %% rate matching
        [B,q,~] = rate_matching(N0,N,K);
        if max(q) == 2
            LLR_PUNCTURE = -10E4;
        else
            LLR_PUNCTURE = 0;
        end
        %% 1-pass construction
        weights = 2.^(sum(de2bi(0:(N0-1)),2)');
        Sub_Set_Id_wmin = B(max(1,end-K+1):end);% K is with CRC
        Sub_Set_Id_all = B(max(1,end-K-3+1):end);% K + CRC +numPC
        w_min = min(weights(Sub_Set_Id_wmin));
        Froz_Set_Id = false(1,N0);
        % pw_min = min(reliaPower(B(max(1,end-K+1):end)));
        Info_Set_Id = false(1,N0);
        DynFroz_Set_Id = false(1,N0);
        FF = 0;
        % for w_min PC
        for i = N0:-1:1
            j=B(i);
            if sum(Info_Set_Id)==K
                Froz_Set_Id(j)=true;
                % shorten/punctured + least reliable
            elseif q(j)
                Froz_Set_Id(j)=true;
                % information bits
            elseif weights(j)== w_min && FF<F
                DynFroz_Set_Id(j)=true;
                FF = FF + 1;
            else
                Info_Set_Id(j)=true;
            end
        end
        % for less realiable PC
        for j = Sub_Set_Id_all(1:3-F)
            DynFroz_Set_Id(j)=true;
        end
        
    elseif ((K-11)>19)
        %% rate matching
        [B,q,~] = rate_matching(N0,N,K);
        if max(q) == 2
            LLR_PUNCTURE = -10E4;
        else
            LLR_PUNCTURE = 0;
        end
        % 1-pass construction
        Info_Set_Id = false(1,N0);
        Info_Index = B(max(1,end-K+1):end);
        Info_Set_Id(Info_Index) = true;
        Froz_Set_Id = ~Info_Set_Id;
        DynFroz_Set_Id = false(1,N0);
    else
        error('NOT Supported UL payload size');
    end
    dcrcIntlv = 1:K;
end
%% sanity check
if N==K
    Info_Set_Id = true(1,N0) & (~q);
    Froz_Set_Id = false(1,N0) | q;
    DynFroz_Set_Id = false(1,N0);
end

if sum(Info_Set_Id)~=K
    error('number of info bits incorrect: %d -> %d',K,sum(Info_Set_Id));
end
if sum(~q)~=N
    error('number of code bits incorrect: %d -> %d',N,sum(~q));
end

PolarParam.Info_Set_Id      =Info_Set_Id;
PolarParam.Frozen_Set_Id    =Froz_Set_Id;
PolarParam.q                =~q;
PolarParam.Chk_Set_Id       =DynFroz_Set_Id;
PolarParam.repSeq           = repSeq;
PolarParam.Seg_K            = K;
PolarParam.N_mother         = N_mother;
PolarParam.LLR_PUNCTURE     = LLR_PUNCTURE;
PolarParam.DLUL             = DLUL;
PolarParam.dcrcIntlv        = dcrcIntlv;
PolarParam.dcrcDeIntlv(dcrcIntlv)   = 1:length(dcrcIntlv);
end

function [B,q,reliaPower] = rate_matching(N0,N,K)
% step 1: determine puncture/shorten patterns
q = get_pattern(N0,N,K);
% step 2: load the sequence
load('HW90.mat','Seq_Q'); % HW-seq in RAN1_90
Seq_Q = Seq_Q - min(Seq_Q);
% Z sequence
reliaPower(Seq_Q+1) = 0:length(Seq_Q)-1;
reliaPower = reliaPower(1:N0);
% bit pre-freezing
puncture_index = logical(q);
reliaPower(puncture_index) = 0;
F_Set = [];
if q(1) % puncture
    if N>=3/4*N0
        F_Set = [0:ceil(3*N0/4 - N/2)-1] + 1;
    else
        F_Set = [0:ceil(9*N0/16 - N/4)-1] + 1;
    end
end
reliaPower(F_Set) = 0;
% step 3: sort bit index sequence by ascending reliability
[~,B]=sort(reliaPower,'ascend');
end


function q = get_pattern(N0,N,K)
% step 1: determine puncture/shorten patterns
q = zeros(1,N0);
P = N0-N;
numG = 32;
qSeq = [0 1 2 4 3 5 6 7 8 16 9 17 10 18 11 19 12 20 13 21 14 22 15 23 24 25 26 28 27 29 30 31] + 1;
sizeG = N0/numG;
intQ = floor(P/sizeG);
fraQ = mod(P,sizeG);
for ii=1:intQ
    q((qSeq(ii)-1)*sizeG+1:qSeq(ii)*sizeG) = 1;
end
q((qSeq(intQ+1)-1)*sizeG+1:(qSeq(intQ+1)-1)*sizeG+fraQ) = 1;
% step 2: separately process for puncture and shorten
Rpsthr = 7/16; % from RAN1_90 WA R1-1715000 option 2
if K/N > Rpsthr % for shorten
    q = 2*fliplr(q);
else% for puncture
    q = 1*q;
end
end

function dcrcIntlvMax = getDCRCIntlv
dcrcIntlvMax = 1+[0,2,4,7,9,14,19,20,24,25,26,28,31,34,42,45,49,50,51,53,54,56,58,59,61,62,65,66,67,69,70,71,72,76,77,81,82,83,87,88,89,91,93,95,98,101,104,106,108,110,111,113,115,118,119,120,122,123,126,127,129,132,134,138,139,140,1,3,5,8,10,15,21,27,29,32,35,43,46,52,55,57,60,63,68,73,78,84,90,92,94,96,99,102,105,107,109,112,114,116,121,124,128,130,133,135,141,6,11,16,22,30,33,36,44,47,64,74,79,85,97,100,103,117,125,131,136,142,12,17,23,37,48,75,80,86,137,143,13,18,38,144,39,145,40,146,41,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163];
end