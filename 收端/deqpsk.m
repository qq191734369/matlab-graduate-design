function [ outdata ] = deqpsk( indata )
%DEQPSK 收端进行qpsk解调的模块
%   输入一个复数数组，每个点对应两个二进制比特，输出数组长度是输入的二倍
    realdata = real(indata);
    imagdata = imag(indata);
    outdata = [];
%     figure(1)
%     plot(realdata,imagdata,'ro');
%     axis([-1.5 1.5 -1.5 1.5]);
%     grid on;
    
    len = length(indata);
    for i = 1:len
        if realdata(i)>0 && imagdata(i)>0
            outdata = [outdata,[0 0]];
        elseif realdata(i)>0 && imagdata(i)<0
            outdata = [outdata, [0 1]];
        elseif realdata(i) <0 && imagdata(i)<0
            outdata = [outdata, [1 1]];
        else
            outdata = [outdata, [1 0]];
        end
    end
end

