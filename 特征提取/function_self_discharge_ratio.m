function [Calculation_results,flags]= function_self_discharge_ratio(data,flags,work_folder_file_folder,Calculation_results)
%function_self_discharge_ratio 静置时期产生的自放电
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
threshold_names={'C_rate_standard_current'};
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
if ~isfield(flags,'still_index')
    still_index=get_still_index(data_struct,flags);
    flags.still_index=still_index;
else
    still_index=flags.still_index;
end
%%
% 计算，并对结果进行处理
try
   %%
    %如果成功的话，会接着提取摘要，绘图和输出报告
    this_function_figs='';
    this_function_records=['自放电量采用安时积分法，结果仅供参考',  10] ;
   
    self_dis_Q=[];
    self_dis_ratio=[];
    time_stamp=data_struct.time_stamp;
    bus_current=data_struct.bus_current;
    soc=data_struct.soc;
    for i =1:length(still_index)
        this_cycle=still_index(i).cycle_index;
        %这次充电的安时积分法
        time_range=time_stamp(this_cycle(1):this_cycle(2));
        current=bus_current(this_cycle(1):this_cycle(2));
        error_index=abs(current)>2*mean(current);
        this_soc=soc(this_cycle(1):this_cycle(2));
        if sum(error_index)>length(error_index)*0.1 || this_soc(end)>this_soc(1) || this_soc(end)<this_soc(1)-10
            %错误数据太多，
             this_function_records=[this_function_records, '循环',int2str(i),',数据有误   '];
            continue
        end
        current(error_index)=[];
        time_range(error_index)=[];
        Q_this_time=compute_Ah_Q(current,time_range);
        self_dis_Q=[self_dis_Q;Q_this_time];
        self_dis_ratio_this_time=Q_this_time/C_rate_standard_current/((time_range(end)-time_range(1))/3600);
        self_dis_ratio=[self_dis_ratio;self_dis_ratio_this_time];
        this_function_records=[this_function_records, '循环',int2str(i),', 自放电量(Ah):',num2str( Q_this_time ),'   '];
    end
    if output_figs 
        h_fig= figure('name',['自放电率变化'],'NumberTitle','off','Visible','off');

        yyaxis left;
        bar(self_dis_Q);
        xlabel('次数');
        ylabel('自放电量(Ah)');
         yyaxis right;
        plot(self_dis_ratio,'lineWidth',2);
        ylabel('自放电率(%/小时)');
        title('自放电率变化')
        set(h_fig,'Visible','on')
        saveas(h_fig,[work_folder_file_folder,'\','自放电率变化','.fig'])
        this_function_figs=[this_function_figs,work_folder_file_folder,'\','自放电率变化','.fig' ,  10  ...
            ];
        close(h_fig)
    end
    %输出报告
    % 功能点
    Calculation_results(size(Calculation_results,2)+1).name = '自放电率变化';
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
    Calculation_results(size(Calculation_results,2)+1).name = '自放电率变化';
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

