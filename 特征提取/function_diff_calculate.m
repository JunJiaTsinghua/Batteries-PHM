function [result_data] = function_diff_calculate(VT_data,index,object,flags)
%FUNCTION_DIFF_CALCULATE 根据数据源的不同，计算极值相关数据.VT代表电压和温度数据，都可以这么算
%   此处显示详细说明
switch flags.data_source_choosed
    case 'changan_EV_data'
        %%
        %长安数据，需要按照结构，重新进行归属的划分
        %阈值确定
        threshold=flags.threshold;
        threshold_names={'case_num_of_cabin','mod_num_of_case'};
        thresholds=threshold.('thresholds');
        threshold_value=threshold.('value');
        for i=1:length(thresholds)
            if ismember(char(thresholds(i)), threshold_names)
                value= cell2mat(threshold_value(i));
                eval([char(thresholds(i)),'=',num2str(value),';'])
            end
        end
        %确认层级
        switch object
            case 'CELL'
                num=0;
            case 'MOD'
                num=mod_num_of_case;
            case 'CASE'
                num=case_num_of_cabin;
                index=1:size(VT_data,1);%只有CELL和MOD是用的原始数据去套索引
            case 'CABIN'
                num=1;
                index=1:size(VT_data,1);%这俩的数据已经是二次计算数据，已经套过索引了的
        end
        VT=VT_data(index,:);
        result_data=main_changAn(VT,num);
end
end
%%
%长安数据的计算。也许其他的也一样
function results=main_changAn(VT,num)
sub_num=size(VT,2)/num;
results={};
switch sub_num
    %如果只有一个，比如一个模组只有一个探针
    case 1
    results.sum=VT;
    results.mean=VT;
    results.max='子对象仅有一个传感器';
    results.min='子对象仅有一个传感器';
    results.max_index='子对象仅有一个传感器';
    results.min_index='子对象仅有一个传感器';
    results.diff='子对象仅有一个传感器';
    
    %用inf表示，这里的是把单体拉通了看
    case inf
        MAX=max(VT,[],2);
        results.max=MAX;
        %加到第一列去，然后比较后面的哪一列和第一列一样，说明后面那列对应的电池出现了最值。
        %一次可以出现很多次最值，（比如多个单体都是那个模组的最高电压）
         VT_and_max=[MAX,VT];
        max_index=arrayfun(@(x)find(VT_and_max(x,1)==VT_and_max(x,2:end)),1:size(VT_and_max,1),'un',0);
%         max_index=cell2mat(max_index);%这里先不弄，不然没法存进去固定的长度
        results.max_index=max_index';
        %最小值
        MIN=min(VT,[],2);
        results.min=MIN;
        VT_and_min=[MIN,VT];
        min_index=arrayfun(@(x)find(VT_and_min(x,1)==VT_and_min(x,2:end)),1:size(VT_and_min,1),'un',0);
%         min_index=cell2mat(min_index);%这里先不弄，不然没法存进去固定的长度
        results.min_index=min_index';
        %差值
        DIFF=MAX-MIN;
        results.diff=DIFF;
    
    
    otherwise
    results.sum=zeros(size(VT,1),num);
    results.max=zeros(size(VT,1),num);
    results.min=zeros(size(VT,1),num);
    results.max_index=cell(size(VT,1),num);
    results.min_index=cell(size(VT,1),num);
    results.diff=zeros(size(VT,1),num);
    results.mean=zeros(size(VT,1),num);
    for i=1:num
        this_sub_sys=VT(:,((i-1)*sub_num+1):i*sub_num);
        SUM=sum(this_sub_sys,2);
        results.sum(:,i)=SUM;
        %最大
        MAX=max(this_sub_sys,[],2);
        results.max(:,i)=MAX;
        VT_and_max=[MAX,this_sub_sys];
        max_index=arrayfun(@(x)find(VT_and_max(x,1)==VT_and_max(x,2:end))+(i-1)*sub_num,1:size(VT_and_max,1),'un',0);
%         max_index=cell2mat(max_index);%这里先不弄，不然没法存进去固定的长度
        results.max_index(:,i)=max_index;
        %最小
        MIN=min(this_sub_sys,[],2);
        results.min(:,i)=MIN;
        VT_and_min=[MIN,this_sub_sys];
        min_index=arrayfun(@(x)find(VT_and_min(x,1)==VT_and_min(x,2:end))+(i-1)*sub_num,1:size(VT_and_min,1),'un',0);
%         min_index=cell2mat(min_index);%这里先不弄，不然没法存进去固定的长度
        results.min_index(:,i)=min_index;
        MEAN=mean(this_sub_sys,2);
        results.mean(:,i)=MEAN;
        DIFF=MAX-MIN;
        results.diff(:,i)=DIFF;
    end

end

end
