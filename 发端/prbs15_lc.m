%这个模块利用prbs码模拟原始数据
function [inf_bits_length,inf_bits]=prbs15_lc(packetlength)
h1=[1,1,1,1,1,1,1,1,0,1,1,0,1,1,0];
for i=1:packetlength
h2(i)=h1(15);
a=xor(h1(15),h1(14));
h1(2:15)=h1(1:14);
h1(1)=a;
end
% ret=tx_crc24(h2);
% inf_bits=[h2 ret];
inf_bits=h2;
inf_bits_length=length(inf_bits);
end
