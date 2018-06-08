function [ rm ] = dmrs(m, issb, nid, nhf )
%DMRS 生成PBCH用到的DM-RS
%   38.211  第五节
    issb_ = 4*issb + nhf;
    c_init = 2^11*(issb_ +1)*(floor(nid/4)+1)+2^6*(issb_ + 1)+(rem(nid,4));
    
    rm = 1/sqrt(2)*(1-2*Cn(c_init,2*m)) + i*1/sqrt(2)*(1-2*Cn(c_init,2*m+1));
end

