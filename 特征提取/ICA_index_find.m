function [index ] = ICA_index_find( cycle )
%UNTITLED4 此处显示有关此函数的摘要
%   此处显示详细说明
    %挨着判断长度
   ICA_index=[];
for i =1:length(cycle)-1
    cycle_len=length(cycle(i).t);
    cycle_len1=length(cycle(i+1).t);
    if cycle_len1-cycle_len>0.2*cycle_len  %如果后一个比前面一个长很多，那么这个就是ICA测试在的地方
        ICA_index=[ICA_index;i+1];%记录下ICA所在的循环
    end
    
end
index=ICA_index(end:-1:1);%已经反转过了 

end

