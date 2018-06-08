%该程序用来完成对输入信号进行OFDM解调
function [y]=deofdm(x,sub_carrier_num,ifft_length)

%对每个符号进行FFT运算
fre_domain_x=fft(x)*sqrt(sub_carrier_num)/ifft_length;
%去除调制时添加的零点
y=[fre_domain_x([ifft_length-sub_carrier_num/2+1:end]) fre_domain_x([2:sub_carrier_num/2+1])];