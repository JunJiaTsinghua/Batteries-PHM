function [index ] = ICA_index_find( cycle )
%UNTITLED4 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
    %�����жϳ���
   ICA_index=[];
for i =1:length(cycle)-1
    cycle_len=length(cycle(i).t);
    cycle_len1=length(cycle(i+1).t);
    if cycle_len1-cycle_len>0.2*cycle_len  %�����һ����ǰ��һ�����ܶ࣬��ô�������ICA�����ڵĵط�
        ICA_index=[ICA_index;i+1];%��¼��ICA���ڵ�ѭ��
    end
    
end
index=ICA_index(end:-1:1);%�Ѿ���ת���� 

end

