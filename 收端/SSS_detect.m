function [ID1, max_corr] = SSS_detect(sss, nid_2, channel,ifft_size)
global SSS_ALLOCATED_LENGTH

len = 127;
sss_rx_freq = deofdm(sss,SSS_ALLOCATED_LENGTH,ifft_size); %144¸öµã
sss_freq = sss_rx_freq(ceil((SSS_ALLOCATED_LENGTH-len)/2)+1:ceil((SSS_ALLOCATED_LENGTH-len)/2)+len);
sss_after_estmate = real(sss_freq./channel);

max_corr = 0;

for nid_1 = 1:336
        local_sss = SSS(nid_1,nid_2);;
        corr = abs(local_sss * sss_after_estmate');
        if max_corr < corr
            max_corr = corr;
            cell_id1 = nid_1;
        end
end
ID1 = cell_id1;

