% ************************************************************************
% Copyright: Huawei Technologies Co., Ltd. 2017 All rights reserved.
% File name: Polar_Encoder.m
% Author: CT HangZhou Alg
% Description:  PC Polar Code Encoding
% History: Dec 8th, 2017 Cleaned
%*************************************************************************
function EncodedBit = Polar_Encoder(data,N0,K,PolarParam,codeBitLength, repSeq)

    Frozen_Set_Id   = PolarParam.Frozen_Set_Id;
    Info_Set_Id     = PolarParam.Info_Set_Id;
    Chk_Set_Id      = PolarParam.Chk_Set_Id;
    q               = PolarParam.q;
    
    u(Frozen_Set_Id) = 0;
    u(Info_Set_Id) = data;
    % PC encoding
    PRIME = 5;
    cc_reg = zeros(1,PRIME);
    for j = 1:N0
        if Info_Set_Id(j) && u(j)==1
            cc_reg(mod(j-1,PRIME)+1) = ~cc_reg(mod(j-1,PRIME)+1);
        elseif Chk_Set_Id(j)
            u(j) = cc_reg(mod(j-1,PRIME)+1);
        end
    end
    % Arikan encoding
    m = log2(length(Info_Set_Id));
    for ii=1:m
        u =reshape(u,2.^ii,2.^(m-ii));
        u(1:2.^(ii-1),:) =  u(1:2.^(ii-1),:)+ u(2.^(ii-1)+1:2.^ii,:);
        u = reshape(u,2.^m,1);
    end
    xp = mod(u,2)';
    % circular buffer
    xp = xp(repSeq);
    % rate matching
    if N0 < codeBitLength
        % repetition
        x_tmp = repmat(xp, 1, ceil(codeBitLength/N0));
        x = x_tmp(1:codeBitLength);
    else
        % remove puncture/shorten bits
        x = xp(q(repSeq));
    end
    EncodedBit = x;
    
end