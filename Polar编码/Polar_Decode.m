function dataDecodedDeIntlv=Polar_Decode(LLR_full,codeBitLength,crcLen,PolarParam,T_size,channelIntlv,CRCDecObj)
%% 函数功能：
% 生成随机数据流，添加CRC，并进行Polar编码及相应的速率匹配
%% 输入参数：
% LLR_full:解调输出似然比信息
% codeBitLength:编码比特长度
% crcLen:CRC长度
% PolarParam:Polar码参数
% T_size:译码树宽度
%% 输出参数：
% dataDecodedDeIntlv:译码输出
%% Modify history
% 2018/1/31 created by Sharon Sha 
%% Code

Info_Set_Id     = PolarParam.Info_Set_Id;
Chk_Set_Id      = PolarParam.Chk_Set_Id;
q               = PolarParam.q;
repSeq          = PolarParam.repSeq;
N0              = PolarParam.N_mother;
LLR_PUNCTURE    = PolarParam.LLR_PUNCTURE;
dcrcDeIntlv     = PolarParam.dcrcDeIntlv;
DLUL            = PolarParam.DLUL;

channelDeIntlv(channelIntlv)  = 1:length(channelIntlv);
L_size=T_size;
for i=1:N0
    str = dec2bin(i);
    depth(i) = 1+length(str)-find(str=='1',1,'last');
end
depth(N0) = 1;

%%
    if DLUL==1
        if codeBitLength>N0
            LLR_buf = zeros(1, ceil(codeBitLength/N0)*N0);
            LLR_buf(1:codeBitLength) = LLR_full;
            LLR = sum(reshape(LLR_buf,N0,[]),2).';
        else
            LLR             = LLR_PUNCTURE*ones(1,N0);
            LLR(q(repSeq)) 	= LLR_full;
        end
        % circular buffer
        LLR(repSeq)     = LLR;
        [zz1,PM] = PolarDecoderPCCPub((N0),(-LLR),(L_size),single(Info_Set_Id),single(depth),single(Chk_Set_Id));
        [~,index] = sort(PM,'ascend');
        zz1 = zz1(index,:);
        for tt = 1:T_size
            z1 = zz1(tt, :);
            dataDecoded = z1(Info_Set_Id).';
            dataDecodedDeIntlv = dataDecoded(dcrcDeIntlv);
            [~,flag] = step(CRCDecObj,[ones(24,1); dataDecodedDeIntlv(:)]);
            if flag==0
                break
            end
        end
    else
        if isfield(PolarParam,'Seg')
            LLR_full0 = LLR_full(1:end-PolarParam.Seg_N);
            LLR_full1 = LLR_full(end-PolarParam.Seg_N+1:end);
            LLR_full0 = LLR_full0(channelDeIntlv);
            LLR_full1 = LLR_full1(channelDeIntlv);
            if codeBitLength/2>N0
                LLR_buf0 = zeros(1, ceil(codeBitLength/2/N0)*N0);
                LLR_buf0(1:codeBitLength/2) = LLR_full0;
                LLR0 = sum(reshape(LLR_buf0,N0,[]),2).';
                LLR_buf1 = zeros(1, ceil(codeBitLength/2/N0)*N0);
                LLR_buf1(1:codeBitLength/2) = LLR_full1;
                LLR1 = sum(reshape(LLR_buf1,N0,[]),2).';
            else
                LLR0             = LLR_PUNCTURE*ones(1,N0);
                LLR0(q(repSeq)) 	= LLR_full0;
                LLR1             = LLR_PUNCTURE*ones(1,N0);
                LLR1(q(repSeq)) 	= LLR_full1;
            end

            % circular buffer
            LLR0(repSeq)     = LLR0;
            [zz0,PM] = PolarDecoderPCCPub((N0),(-LLR0),(L_size),single(Info_Set_Id),single(depth),single(Chk_Set_Id));
            [~,index] = sort(PM,'ascend');
            zz0 = zz0(index,:);
            for tt = 1:T_size
                z0 = zz0(tt, :);
                dataDecodedDeIntlv0 = z0(Info_Set_Id).';
                [~,flag] = step(CRCDecObj,dataDecodedDeIntlv0(:));
                if flag==0
                    break
                end
            end
            if flag ==1 
                z0 = zz0(1, :);
                dataDecodedDeIntlv0 = z0(Info_Set_Id).';
            end
            if mod(PolarParam.Seg_originK-crcLen,2) == 1
                dataDecodedDeIntlv0 = dataDecodedDeIntlv0(2:end);
            end
            % circular buffer
            LLR1(repSeq)     = LLR1;
            [zz1,PM] = PolarDecoderPCCPub((N0),(-LLR1),(L_size),single(Info_Set_Id),single(depth),single(Chk_Set_Id));
            [~,index] = sort(PM,'ascend');
            zz1 = zz1(index,:);
            for tt = 1:T_size
                z1 = zz1(tt, :);
                dataDecodedDeIntlv1 = z1(Info_Set_Id).';
                [~,flag] = step(CRCDecObj,dataDecodedDeIntlv1(:));
                if flag==0
                    break
                end
            end
            if flag ==1 
                z1 = zz1(1, :);
                dataDecodedDeIntlv1 = z1(Info_Set_Id).';
            end
            dataDecodedDeIntlv = [dataDecodedDeIntlv0(1:end-crcLen);dataDecodedDeIntlv1];
        else
            LLR_full = LLR_full(channelDeIntlv);
            if codeBitLength>N0
                LLR_buf = zeros(1, ceil(codeBitLength/N0)*N0);
                LLR_buf(1:codeBitLength) = LLR_full;
                LLR = sum(reshape(LLR_buf,N0,[]),2).';
            else
                LLR             = LLR_PUNCTURE*ones(1,N0);
                LLR(q(repSeq)) 	= LLR_full;
            end
            % circular buffer
            LLR(repSeq)     = LLR;
            [zz1,PM] = PolarDecoderPCCPub((N0),(-LLR),(L_size),single(Info_Set_Id),single(depth),single(Chk_Set_Id));
            [~,index] = sort(PM,'ascend');
            zz1 = zz1(index,:);
            for tt = 1:T_size
                z1 = zz1(tt, :);
                dataDecodedDeIntlv = z1(Info_Set_Id).';
                [~,flag] = step(CRCDecObj,dataDecodedDeIntlv(:));
                if flag==0
                    break
                end
            end
        end
    end
    
end