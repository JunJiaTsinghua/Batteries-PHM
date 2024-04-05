function  [Calculation_results,flags]  = function_max_tem_probe_times(data,flags,work_folder_file_folder,Calculation_results)
%function_max_tem_probe_times 所选时间范围内，温度探针出现最大值的统计次数
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
% index=1:length(data_struct.bus_current);
% flags=importdata('flags.mat');
%%
%各个层级都会出一个结果和图，每个层级的子结构也会出一个结果和图。
this_function_figs='';
this_function_records='';
try
    for o=flags.analyze_object
         %子层级是什么
        switch char(o)
            case 'CELL'
                sub_layer='单体';
            case 'MOD'
                 sub_layer='单体';
            case 'CASE'
                 sub_layer='模组';
            case 'CABIN'
                 sub_layer='簇';
        end
        %挨着对各个层级的对象进行分析，如果已经算过了，就直接拿来用
        if isfield(flags.(char(o)),'Tem')
            if isfield(flags.(char(o)).Tem,'Diff')
                M_data=flags.(char(o)).Tem.Diff.max_index;
                %没有算过，就要现场算。
            else
                flags.(char(o)).Tem.Diff={};
                %拉取用于计算的本层数据
                switch char(o)
                    case 'CELL'
                        data_to_use=data_struct.temperature_all;
                    case 'MOD'
                        data_to_use=data_struct.temperature_all;
                    case 'CASE'
                        data_to_use=flags.MOD.Tem.Diff.mean;
                    case 'CABIN'
                        data_to_use=flags.CASE.Tem.Diff.mean;
                end
                %进行计算，并存到flags里面
                result_data=function_diff_calculate(data_to_use,index,char(o),flags);
                flags.(char(o)).Tem.Diff=result_data;%有想过不再分Diff和Incon这一层，但是，返回的值没法直接赋给Tem或Vol，不方便
                M_data=result_data.max_index;
            end
            
        else
            %没有算过（连这种数据都没有算过），就要现场算。
            flags.(char(o)).Tem={};
            flags.(char(o)).Tem.Diff={};
              %拉取用于计算的本层数据
                switch char(o)
                    case 'CELL'
                        data_to_use=data_struct.temperature_all;
                    case 'MOD'
                        data_to_use=data_struct.temperature_all;
                    case 'CASE'
                        data_to_use=flags.MOD.Tem.Diff.mean;
                    case 'CABIN'
                        data_to_use=flags.CASE.Tem.Diff.mean;
                end
                %进行计算，并存到flags里面
            result_data=function_diff_calculate(data_to_use,index,char(o),flags);
            flags.(char(o)).Tem.Diff=result_data;
            M_data=result_data.max_index;
        end
        %%
        %如果成功的话，会接着提取摘要，绘图和输出报告
        %报告内容计算
        if isa(M_data,'char')
            report_content=M_data;
             this_function_records=[this_function_records, flags.data_part,char(o),'最高温度:',report_content ,'     '];
        else
            frequency={};%当前层级有多个对象，就会有多少频次的结果，比如19个模组就19个频次需要记录
            for f=1:size(M_data,2)
                 f_num=int2str(f);
                this_f=['O',f_num];
                
            max_tem_probe_times=tabulate(cell2mat(M_data(:,f)'));%每个模组/簇/舱最大值里面的最大值，报告只输出这一个
            frequency.(this_f)=max_tem_probe_times;
            [MAX_times,MAX_INDEXs]=maxk(max_tem_probe_times(:,2),3);
            probes=max_tem_probe_times(:,1);
            MAX_probes=probes(MAX_INDEXs);
            probability=max_tem_probe_times(:,3);
            MAX_probability=roundn(probability(MAX_INDEXs),-2);
            report_content='';
            report_content=[report_content,'   最大次数最多的三个',sub_layer,':',mat2str(MAX_probes)];
            report_content=[report_content,'   比例:',mat2str(MAX_probability)];
            report_content=[report_content,'   次数:',mat2str(MAX_times)];
            if size(M_data,2)==1
                f_num='';
            end
            this_function_records=[this_function_records, flags.data_part,char(o),f_num,'最高温度:',report_content , 10 ];
            end
        end
        
        %图片绘制-分开还是hold on
        if output_figs && ~isa(M_data,'char')
            f_s=fieldnames(frequency);
            plot_way=flags.plot_split;
            if length(f_s)==1
                plot_way='一起画';
            end
       switch plot_way
           case '分开画'
               for  k=1:length(f_s)
                   h_fig= figure('name',[char(o),int2str(k),'中各',sub_layer,'出现最高温度的次数'],'NumberTitle','off','Visible','off');
                  max_tem_probe_times=frequency.(['O',int2str(k)]);
                   bar(max_tem_probe_times(:,1),max_tem_probe_times(:,2))
                   xlabel([sub_layer,'编号']);
                   ylabel('最高温度(℃)');
                   title([char(o),int2str(k),'中各',sub_layer,'出现最高温度的次数'])
                   set(h_fig,'Visible','on')
                   saveas(h_fig,[work_folder_file_folder,'\',[char(o),int2str(k),'中各',sub_layer,'出现最高温度的次数'],'.fig'])
                   close(h_fig)
                   this_function_figs=[this_function_figs,work_folder_file_folder,'\',char(o),int2str(k),'中各',sub_layer,'出现最高温度的次数','.fig' ,  10  ...
                ];
               end
               
           case '一起画'
               h_fig= figure('name',[char(o),'中各',sub_layer,'出现最高温度的次数'],'NumberTitle','off','Visible','off');

               legend_cell={};
               for k=length(f_s)
                    max_tem_probe_times=frequency.(['O',int2str(k)]);
                   bar(max_tem_probe_times(:,1),max_tem_probe_times(:,2))
                   hold on
                   legend_cell=[legend_cell,int2str(k)];
               end
               xlabel([sub_layer,'编号']);
               ylabel('最高温度(℃)');
               title([char(o),'中各',sub_layer,'出现最高温度的次数'])
               if length(legend_cell)>1
                 legend(legend_cell)
               end
               set(h_fig,'Visible','on')
               saveas(h_fig,[work_folder_file_folder,'\',[char(o),'中各',sub_layer,'出现最高温度的次数'],'.fig'])
               close(h_fig)
               this_function_figs=[this_function_figs,work_folder_file_folder,'\',char(o),'中各',sub_layer,'出现最高温度的次数','.fig' ,  10  ...
                   ];
       end
        
          
        end
        
    end
    %%
    %输出报告
    % 功能点
    Calculation_results(size(Calculation_results,2)+1).name = '最高温度探针出现次数统计';
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
    Calculation_results(size(Calculation_results,2)+1).name = '最高温度探针出现次数统计';
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
