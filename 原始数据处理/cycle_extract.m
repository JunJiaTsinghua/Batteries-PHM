function [ cell ] = cycle_extract( batch,cycle_to_choose,data_to_save )
%CYCLE_EXTRACT �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
% %��������
% clc;clear;
% load('batch1_1_10.mat');
%% 
%�ж�ÿ��ѭ���ĳ��ȣ��ҳ�ICA�����ڵĵط������������
cell_num=length(batch);
for n=1:cell_num
    clear ICA_cycle
cycle=batch(n).cycles;%ÿ��cell��ѭ��
  %�޳���һ���յ�ѭ��
    if isempty(cycle(1).t)
        cycle(1)=[];
    end
ICA_index=ICA_index_find(cycle);
%��¼��ICA������
%�յľ�Ϊ�գ�̫���ˣ�˵����Щ��������ΪICA�����ģ���ʵ�鱾����������
if  isempty( ICA_index )
    ICA_cycle=[];
end

if length(ICA_index)<=3 
    for k=1:length(ICA_index)
    ICA_cycle(k).data=cycle(ICA_index(k));
    ICA_cycle(k).icacylce=ICA_index(k);
    cycle(ICA_index(k))=[];%��ICA���ڵ�ѭ����Ϊ��
    end
else
 ICA_cycle=['problem'];
end

%��ȡָ����ѭ����
for i =1:length(cycle_to_choose)
    str_cycle=int2str(cycle_to_choose(i));
    for j =1:length(data_to_save)
        str_data=data_to_save(j);
        field=strcat(str_data,str_cycle);
        cell(n).(field{1,1})=cycle(cycle_to_choose(i)).( str_data{1,1});     
    end
end
cell(n).life=batch(n).cycle_life;
cell(n).policy=batch(n).policy_readable;
cell(n).Vdlin=batch(n).Vdlin;
cell(n).summary=batch(n).summary;
cell(n).ICA=ICA_cycle;
end

end

