function [Calculation_results,flags]= function_Ah_intergal_wide_SOC(data,flags,work_folder_file_folder,Calculation_results)
%function_Ah_intergal_wide_SOC 宽范围SOC的安时积分法
global data_struct
data_struct=data;
output_figs=flags.output_figs;
% charge_Index_get=flags.charge_Index_get
%%
%调试的时候打开本节
% Calculation_results={};
% output_figs=1;
% work_folder_file_folder='C:\MATLAB_APP\functions\test';
% data_struct=importdata('data_struct.mat');
% flags=importdata('flags1.mat');
% still_index=importdata('cycle_index.mat');
% flags={};
%%
%阈值确定
threshold=flags.threshold;
threshold_names={'C_rate_standard_current','time_interval','C_rate_jump_limit'};
threshold_names_str='';
for i =threshold_names
    threshold_names_str=[threshold_names_str,' ',char(i)];
end
eval(['global ',threshold_names_str]);
thresholds=threshold.('thresholds');
threshold_value=threshold.('value');
for i=1:length(thresholds)
    if ismember(char(thresholds(i)), threshold_names)
        value= cell2mat(threshold_value(i));
        eval([char(thresholds(i)),'=',num2str(value),';'])
    end
end
% C_rate_standard_current=30;
%%
%没有这个字段的话，是要现场算的
if ~isfield(flags,'charge_index')
    charge_index=get_charge_index(data_struct,flags);
    flags.charge_index=charge_index;
else
    charge_index=flags.charge_index;
end
%%
% 计算，并对结果进行处理
try
   %%
    %如果成功的话，会接着提取摘要，绘图和输出报告
    this_function_figs='';
    this_function_records=['电量采用安时积分法,结果仅供参考,    电量(Ah):',  10] ;
    Cap=[];
    time_stamp=data_struct.time_stamp;
    bus_current=data_struct.bus_current;
    soc=data_struct.soc;
    for i =1:length(charge_index)
        this_cycle=charge_index(i).cycle_index;
        %这次充电的安时积分法
        time_range=time_stamp(this_cycle(1):this_cycle(2));
        current=bus_current(this_cycle(1):this_cycle(2));
        A_rate=C_rate_compute(current);
        C_rate=A_rate/C_rate_standard_current;
        this_soc_start=soc(this_cycle(1));
        this_soc_end=soc(this_cycle(2));
        if this_soc_start>flags.SOC_min || this_soc_end<flags.SOC_max || time_interval>flags.data_quality_min...
                || C_rate >flags.C_rate_max || this_soc_end<this_soc_start
            %错误数据太多，
             this_function_records=[this_function_records, '循环',int2str(i),',无   '];
            continue
        end
        Q_this_cycle=compute_Ah_Q(current,time_range);
        Cap_this_cycle=100*roundn(Q_this_cycle/(this_soc_end-this_soc_start),-4);
        Cap=[Cap;Cap_this_cycle];
        this_function_records=[this_function_records, '循环',int2str(i),': ',num2str( Cap_this_cycle ),'   '];
    end
    if output_figs 
        h_fig= figure('name',['容量变化'],'NumberTitle','off','Visible','off');
        bar(Cap);
        xlabel('次数');
        ylabel('电量(Ah)');
        title('容量变化')
        set(h_fig,'Visible','on')
        saveas(h_fig,[work_folder_file_folder,'\','容量变化','.fig'])
        this_function_figs=[this_function_figs,work_folder_file_folder,'\','容量变化','.fig' ,  10  ...
            ];
        close(h_fig)
    end
    %输出报告
    % 功能点
    Calculation_results(size(Calculation_results,2)+1).name = '容量变化';
    %结果摘要
    Calculation_results(size(Calculation_results,2)).summary =this_function_records;
    %文件路径
    if output_figs
        Calculation_results(size(Calculation_results,2)).figs_path =this_function_figs;    % 本文件提供struct2str的函数
    else
        Calculation_results(size(Calculation_results,2)).figs_path ='用户未选择图片输出';
    end
    % 备注
    Calculation_results(size(Calculation_results,2)).remark = '无' ;
    
%%
catch ErrorInfo
    
    % 功能点
    Calculation_results(size(Calculation_results,2)+1).name = '容量变化';
    % 结果摘要
    Calculation_results(size(Calculation_results,2)).summary = '数据异常';
    % 文件路径
    Calculation_results(size(Calculation_results,2)).figs_path =  '数据异常';
    % 备注
    if strcmp("'cell' 类型的输入参数无效。输入必须为结构体或者 Java 或 COM 对象。", ErrorInfo.message)
        message='数据量太少';
    else
        message= ErrorInfo.message;
    end
    Calculation_results(size(Calculation_results,2)).remark = message;
    
end

end

%%
%进行倍率的提取
function  C_rate=C_rate_compute(I_this_cycle)
global C_rate_jump_limit
length_all=length(I_this_cycle);
I_to_use=I_this_cycle(ceil(length_all*0.1):ceil(length_all*0.9));%掐头去尾，免得受刚开始和结束时候的跳变影响
for i =1:length(I_to_use)-1
    if abs(I_to_use(i+1)-I_to_use(i))/abs(I_to_use(i))>C_rate_jump_limit
        end_index=i;
        break
    else
        end_index=length(I_to_use);
    end
end
C_rate_pre=abs(mean(I_to_use(1:end_index)));
C_rate=roundn(C_rate_pre,-1);
end

