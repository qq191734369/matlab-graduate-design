function [ channel ] = ChannelEstmate_SSS( pss_rx, ifft_size, nid2 )
%CHANNELESTMATE_SSS 此处显示有关此函数的摘要
%   此处显示详细说明
global PSS_ALLOCATED_LENGTH;
pss=PSS(nid2);
len = length(pss);
pss_rx_fre = deofdm(pss_rx,PSS_ALLOCATED_LENGTH,ifft_size); %144个点
pss_fre = real(pss_rx_fre(ceil((PSS_ALLOCATED_LENGTH-len)/2)+1:ceil((PSS_ALLOCATED_LENGTH-len)/2)+len));
channel = pss_fre./pss;
end

