function [result_data] = function_incon_calculate(VT_data,index,object,flags)
%FUNCTION_DIFF_CALCULATE 根据数据源的不同，计算极值相关数据.VT代表电压和温度数据，都可以这么算
%   此处显示详细说明
inconsist_method=flags.inconsist_method;
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
        result_data=main_changAn(VT,num,inconsist_method);
end
end
%%
%长安数据的计算。也许其他的也一样
function results=main_changAn(VT,num,inconsist_method)
sub_num=size(VT,2)/num;
%%
%用方差算
if strcmp(inconsist_method,'方差')
% results={};
switch sub_num
    %如果只有一个，比如一个模组只有一个探针
    case 1
        results='子对象仅有一个传感器';
        
        %用inf表示，这里的是把单体拉通了看
    case inf
        s=std(VT,0,2);
        results=s.^2;
        
    otherwise
        results=zeros(size(VT,1),num);
        for i=1:num
            this_sub_sys=VT(:,((i-1)*sub_num+1):i*sub_num);
            s=std(this_sub_sys,0,2);
            VAR=s.^2;
            results(:,i)=VAR;
        end  
end
end
%%
%用熵算
if strcmp(inconsist_method,'样本熵')
% results={};
switch sub_num
    %如果只有一个，比如一个模组只有一个探针
    case 1
        results='子对象仅有一个传感器';
        
        %用inf表示，这里的是把单体拉通了看
    case inf
        results=zeros(size(VT,1),1);
        num_intervals=size(VT,2);
        for j=1:size(VT,1)
            results(j)=SampEn(VT(j,:),num_intervals);
        end
        
    otherwise
        results=zeros(size(VT,1),num);
        num_intervals=size(VT,2);
        for i=1:num
            this_sub_sys=VT(:,((i-1)*sub_num+1):i*sub_num);
             result=zeros(size(VT,1),1);
            for j=1:size(VT,1)
                result(j)=SampEn(this_sub_sys(j,:),num_intervals);
            end
            results(:,i)=result;
        end  
end
end
end

function SampEn=SampEn(y,num_intervals)
%不以原信号为参考的时间域的信号熵
%输入：maxf:原信号的能量谱中能量最大的点
%y:待求信息熵的序列
%Hx:y的信息熵
%将序列按num_intervals数等分，如果num_intervals=10,就将序列分为10等份
x_min=min(y);
x_max=max(y);
maxf(1)=abs(x_max-x_min);
maxf(2)=x_min;
interval_t=1.0/num_intervals;
interval=maxf(1)*interval_t;
% for i=1:10
% pnum(i)=length(find((y_p>=(i-1)*jiange)&(y_p<i*jiange)));
% end

pnum(1)=length(find(y<maxf(2)+interval));
for i=2:num_intervals-1
    pnum(i)=length(find((y>=maxf(2)+(i-1)*interval)&(y<maxf(2)+i*interval)));
end
pnum(num_intervals)=length(find(y>=maxf(2)+(num_intervals-1)*interval));
%sum(pnum)
pro_pnum=pnum/sum(pnum);%每段出现的概率
%sum(ppnum)
SampEn=0;
for i=1:num_intervals
    if pro_pnum(i)==0
        SampEn_i=0;
    else
        SampEn_i=-pro_pnum(i)*log2(pro_pnum(i));
    end
    SampEn=SampEn+SampEn_i;
end
end
