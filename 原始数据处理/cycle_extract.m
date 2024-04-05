function [ cell ] = cycle_extract( batch,cycle_to_choose,data_to_save )
%CYCLE_EXTRACT 此处显示有关此函数的摘要
%   此处显示详细说明
% %加载数据
% clc;clear;
% load('batch1_1_10.mat');
%% 
%判断每个循环的长度，找出ICA测试在的地方，给提出来。
cell_num=length(batch);
for n=1:cell_num
    clear ICA_cycle
cycle=batch(n).cycles;%每个cell的循环
  %剔除第一个空的循环
    if isempty(cycle(1).t)
        cycle(1)=[];
    end
ICA_index=ICA_index_find(cycle);
%记录下ICA的数据
%空的就为空，太多了，说明那些并不是因为ICA产生的，是实验本身有了问题
if  isempty( ICA_index )
    ICA_cycle=[];
end

if length(ICA_index)<=3 
    for k=1:length(ICA_index)
    ICA_cycle(k).data=cycle(ICA_index(k));
    ICA_cycle(k).icacylce=ICA_index(k);
    cycle(ICA_index(k))=[];%把ICA所在的循环置为空
    end
else
 ICA_cycle=['problem'];
end

%提取指定的循环。
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

