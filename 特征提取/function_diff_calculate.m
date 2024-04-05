function [result_data] = function_diff_calculate(VT_data,index,object,flags)
%FUNCTION_DIFF_CALCULATE ��������Դ�Ĳ�ͬ�����㼫ֵ�������.VT�����ѹ���¶����ݣ���������ô��
%   �˴���ʾ��ϸ˵��
switch flags.data_source_choosed
    case 'changan_EV_data'
        %%
        %�������ݣ���Ҫ���սṹ�����½��й����Ļ���
        %��ֵȷ��
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
        %ȷ�ϲ㼶
        switch object
            case 'CELL'
                num=0;
            case 'MOD'
                num=mod_num_of_case;
            case 'CASE'
                num=case_num_of_cabin;
                index=1:size(VT_data,1);%ֻ��CELL��MOD���õ�ԭʼ����ȥ������
            case 'CABIN'
                num=1;
                index=1:size(VT_data,1);%�����������Ѿ��Ƕ��μ������ݣ��Ѿ��׹������˵�
        end
        VT=VT_data(index,:);
        result_data=main_changAn(VT,num);
end
end
%%
%�������ݵļ��㡣Ҳ��������Ҳһ��
function results=main_changAn(VT,num)
sub_num=size(VT,2)/num;
results={};
switch sub_num
    %���ֻ��һ��������һ��ģ��ֻ��һ��̽��
    case 1
    results.sum=VT;
    results.mean=VT;
    results.max='�Ӷ������һ��������';
    results.min='�Ӷ������һ��������';
    results.max_index='�Ӷ������һ��������';
    results.min_index='�Ӷ������һ��������';
    results.diff='�Ӷ������һ��������';
    
    %��inf��ʾ��������ǰѵ�����ͨ�˿�
    case inf
        MAX=max(VT,[],2);
        results.max=MAX;
        %�ӵ���һ��ȥ��Ȼ��ȽϺ������һ�к͵�һ��һ����˵���������ж�Ӧ�ĵ�س�������ֵ��
        %һ�ο��Գ��ֺܶ����ֵ�������������嶼���Ǹ�ģ�����ߵ�ѹ��
         VT_and_max=[MAX,VT];
        max_index=arrayfun(@(x)find(VT_and_max(x,1)==VT_and_max(x,2:end)),1:size(VT_and_max,1),'un',0);
%         max_index=cell2mat(max_index);%�����Ȳ�Ū����Ȼû�����ȥ�̶��ĳ���
        results.max_index=max_index';
        %��Сֵ
        MIN=min(VT,[],2);
        results.min=MIN;
        VT_and_min=[MIN,VT];
        min_index=arrayfun(@(x)find(VT_and_min(x,1)==VT_and_min(x,2:end)),1:size(VT_and_min,1),'un',0);
%         min_index=cell2mat(min_index);%�����Ȳ�Ū����Ȼû�����ȥ�̶��ĳ���
        results.min_index=min_index';
        %��ֵ
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
        %���
        MAX=max(this_sub_sys,[],2);
        results.max(:,i)=MAX;
        VT_and_max=[MAX,this_sub_sys];
        max_index=arrayfun(@(x)find(VT_and_max(x,1)==VT_and_max(x,2:end))+(i-1)*sub_num,1:size(VT_and_max,1),'un',0);
%         max_index=cell2mat(max_index);%�����Ȳ�Ū����Ȼû�����ȥ�̶��ĳ���
        results.max_index(:,i)=max_index;
        %��С
        MIN=min(this_sub_sys,[],2);
        results.min(:,i)=MIN;
        VT_and_min=[MIN,this_sub_sys];
        min_index=arrayfun(@(x)find(VT_and_min(x,1)==VT_and_min(x,2:end))+(i-1)*sub_num,1:size(VT_and_min,1),'un',0);
%         min_index=cell2mat(min_index);%�����Ȳ�Ū����Ȼû�����ȥ�̶��ĳ���
        results.min_index(:,i)=min_index;
        MEAN=mean(this_sub_sys,2);
        results.mean(:,i)=MEAN;
        DIFF=MAX-MIN;
        results.diff(:,i)=DIFF;
    end

end

end
