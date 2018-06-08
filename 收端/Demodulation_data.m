%% 函数功能：
% 对输入的数据进行特定模式的解星座点调制，可选的模式有1：BPSK；2：QPSK；4：16QAM；6：64QAM
%% 输入参数：
% data_in：输入的数据流
% SnrLinearMMSE：信道均衡得到的数据信道处线性信噪比
%% 输出参数
% DeQamOut：解制后的数据流
%% Modify history
% 2017/6/5 created by Mao Zhendong
% 2017/10/30 modified by Liu Chunhua
%% code
function  DeQamOut = Demodulation_data(data_in, SnrLinearMMSE)   
    global MODULATION;
    len_input=length(data_in);
    h = ones(1,len_input);
    switch (MODULATION)                            % 1：BPSK；2：QPSK；4：16QAM；6：64QAM
   %% QPSK
    case 2                                       
        n_power=1./SnrLinearMMSE;       
       
        temp_1=real(data_in)>0;
        temp_2=2*temp_1-1;                % 计算低位的LLR信息
        s0_L=(temp_2+1i)*sqrt(2)/2;
        s1_L=(temp_2-1i)*sqrt(2)/2;
       
        d0_L=abs(data_in-s0_L);           % 计算信号点与标准信号星座点之间的距离
        d1_L=abs(data_in-s1_L);
        
        llr_L=1.*(d1_L.^2-d0_L.^2)./(n_power.*(1./((abs(h)).^2)));  % 计算似然比信息llr
        
        temp_1=imag(data_in)>0;
        temp_2=2*temp_1-1;                % 计算高位的LLR信息
        s0_H=(1+1i*temp_2)*sqrt(2)/2;
        s1_H=(-1+1i*temp_2)*sqrt(2)/2;
        
       d0_H=abs(data_in-s0_H);           % 计算信号点与标准信号星座点之间的距离
       d1_H=abs(data_in-s1_H);      
       
       llr_H=1.*(d1_H.^2-d0_H.^2)./(n_power.*(1./((abs(h)).^2)));     % 计算似然比信息llr
   
       DeQamOut = zeros(1,2*len_input);
       for I=1:len_input
           DeQamOut(2*I-1:2*I)=[-llr_L(I),-llr_H(I)];                  % 将高低位排序，输出解调结果的似然比序列 
       end
   %% 16QAM
    case 4                                            
        const_16qam=4;               %16qam符号对应的二进制比特数
        %以二进制比特数来表示所有16qam符号
        %计算16qam相应符号位0或1到相应符号位为1或0的符号的距离，所采用的表（三个比特位）
        const_num=[1 2 3 4 5 6 7 8];
        %计算1/2/3/4位比特时，相对于被解调星座位置的偏差（十进制表示）
        const_num_1=[8 8 8 8 8 8 8 8 ;4 4 4 4 8 8 8 8;2 2 4 4 6 6 8 8;1 2 3 4 5 6 7 8];
        %星座图表
        constel_diagram=[sqrt(2)/2+1i*sqrt(2)/2, 1i*1.5*sqrt(2)+sqrt(2)/2, 1i*sqrt(2)/2+1.5*sqrt(2), 1.5*sqrt(2)+1i*1.5*sqrt(2),...       % 第一象限
                         sqrt(2)/2-1i*sqrt(2)/2, -1i*1.5*sqrt(2)+sqrt(2)/2, -1i*sqrt(2)/2+1.5*sqrt(2), 1.5*sqrt(2)-1i*1.5*sqrt(2),...     % 第四象限
                        -sqrt(2)/2+1i*sqrt(2)/2,-sqrt(2)/2+1i*1.5*sqrt(2),-1.5*sqrt(2)+1i*sqrt(2)/2,-1.5*sqrt(2)+1i*1.5*sqrt(2),...       % 第二象限
                        -sqrt(2)/2-1i*sqrt(2)/2,-sqrt(2)/2-1i*1.5*sqrt(2),-1.5*sqrt(2)-1i*sqrt(2)/2,-1.5*sqrt(2)-1i*1.5*sqrt(2)]/sqrt(5); % 第三象限
        
        h_square=abs(h).^2;                                                  % 得到信道估计值的平方
        DeQamOut=zeros(1,const_16qam*len_input);                             % 存储似然比信息
        %计算信号到各个星座点的映射距离
        temp=[abs(data_in-constel_diagram(1)),abs(data_in-constel_diagram(2)),abs(data_in-constel_diagram(3)),abs(data_in-constel_diagram(4)),abs(data_in-constel_diagram(5)),abs(data_in-constel_diagram(6)),...
            abs(data_in-constel_diagram(7)),abs(data_in-constel_diagram(8)),abs(data_in-constel_diagram(9)),abs(data_in-constel_diagram(10)),abs(data_in-constel_diagram(11)),abs(data_in-constel_diagram(12)),...
            abs(data_in-constel_diagram(13)),abs(data_in-constel_diagram(14)),abs(data_in-constel_diagram(15)),abs(data_in-constel_diagram(16))].^2;
        % 下面是计算各个信息比特的似然比信息llr
        for m=1:len_input
            temp2=temp(m:len_input:2^const_16qam*len_input);
            for n=1:const_16qam               
                pad_num_1=const_num+const_num_1(n,:);
                dist_square_1=min(temp2(pad_num_1));                        %计算第n位比特为1的星座图到被解调星座的最小距离
                
                pad_num_0=const_num+const_num_1(n,:)-2^(const_16qam-n);     % 计算第n位比特为0的星座图到被解调星座的最小距离
                dist_square_0=min(temp2(pad_num_0));
                DeQamOut(const_16qam*(m-1)+n)=h_square(m)*(dist_square_1-dist_square_0)*SnrLinearMMSE(m);  % 得到释然比信息
            end
        end
   %% 64QAM
    case 6                                
        SN_MMSE_dB=10*log10(SnrLinearMMSE);
            for I_deqam=1:len_input
                DeQamOut((6*I_deqam-5):6*I_deqam)=deqam64(real(data_in(I_deqam)),imag(data_in(I_deqam)),real(h(I_deqam)),imag(h(I_deqam)), SN_MMSE_dB(I_deqam));
            end 
    otherwise
        disp('Error! Please input again');        
    end
end