function [ cn ] = Cn( init , L)
%CN 此处显示有关此函数的摘要
%   此处显示详细说明
%  输入 init 为38.211中5.2.1定义的Cinit，是一个整数
%  L 是需要的序列长度
if init < 0
    error('Cn模块输入不正确')
else
   Nc = 1600;
   arr = dec2bin(init) - '0';
   len  = length(arr);
   derlen = 31 - len;
   x1_reg = [zeros(1,30) 1];
   x2_reg = [zeros(1,derlen) arr];
   x1_gen = [1 zeros(1,27) 1 0 0 1];
   x2_gen = [1 zeros(1,27) 1 1 1 1];
   out1 = 0;
   out2 = 0;
   for i = 1:Nc
       x1 = mod(x1_reg(31)+x1_reg(28),2);
       x1_reg = [x1 x1_reg(:,1:30)];
       x2 = mod(x2_reg(31)+x2_reg(30)+x2_reg(29)+x2_reg(28),2);
       x2_reg = [x2 x2_reg(:,1:30)];
   end
   
   for j = 0:L
       out1 = x1_reg(31);
       x1 = mod(x1_reg(31)+x1_reg(28),2);
       x1_reg = [x1 x1_reg(:,1:30)];
       out2 = x2_reg(31);
       x2 = mod(x2_reg(31)+x2_reg(30)+x2_reg(29)+x2_reg(28),2);
       x2_reg = [x2 x2_reg(:,1:30)];
   end
   cn = mod(out1+out2,2);
end
end

