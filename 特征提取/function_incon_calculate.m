function [result_data] = function_incon_calculate(VT_data,index,object,flags)
%FUNCTION_DIFF_CALCULATE ��������Դ�Ĳ�ͬ�����㼫ֵ�������.VT�����ѹ���¶����ݣ���������ô��
%   �˴���ʾ��ϸ˵��
inconsist_method=flags.inconsist_method;
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
        result_data=main_changAn(VT,num,inconsist_method);
end
end
%%
%�������ݵļ��㡣Ҳ��������Ҳһ��
function results=main_changAn(VT,num,inconsist_method)
sub_num=size(VT,2)/num;
%%
%�÷�����
if strcmp(inconsist_method,'����')
% results={};
switch sub_num
    %���ֻ��һ��������һ��ģ��ֻ��һ��̽��
    case 1
        results='�Ӷ������һ��������';
        
        %��inf��ʾ��������ǰѵ�����ͨ�˿�
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
%������
if strcmp(inconsist_method,'������')
% results={};
switch sub_num
    %���ֻ��һ��������һ��ģ��ֻ��һ��̽��
    case 1
        results='�Ӷ������һ��������';
        
        %��inf��ʾ��������ǰѵ�����ͨ�˿�
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
%����ԭ�ź�Ϊ�ο���ʱ������ź���
%���룺maxf:ԭ�źŵ����������������ĵ�
%y:������Ϣ�ص�����
%Hx:y����Ϣ��
%�����а�num_intervals���ȷ֣����num_intervals=10,�ͽ����з�Ϊ10�ȷ�
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
pro_pnum=pnum/sum(pnum);%ÿ�γ��ֵĸ���
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
