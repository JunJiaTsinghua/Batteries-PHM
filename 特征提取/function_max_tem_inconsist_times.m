function  [Calculation_results,flags]  = function_max_tem_inconsist_times(data,flags,work_folder_file_folder,Calculation_results)
%function_max_tem_inconsist_times 所选时间范围内，电压不一致性最大出现在某个对象的次数
global data_struct
data_struct=data;
output_figs=flags.output_figs;
inconsist_method=flags.inconsist_method;
%%
%调试的时候打开本节
% Calculation_results={};
% output_figs=1;
% work_folder_file_folder='C:\MATLAB_APP\functions\test';
% data_struct=importdata('data_struct.mat');
% index=1:length(data_struct.bus_current);
% flags=importdata('flags1.mat');

%%
%各个层级都会出一个结果和图，每个层级的子结构也会出一个结果和图。
this_function_figs='';
this_function_records='';
analyze_object=flags.analyze_object;
% analyze_object(strcmp(analyze_object,'CELL'))=[];
% analyze_object(strcmp(analyze_object,'CABIN'))=[];%这两个没得不一致性拿去上一层级再比较的说法
try
    for o=analyze_object
        %父层级是什么
        switch char(o)
            case 'CELL'
                 father_layer='探针';
            case 'MOD'
                father_layer='簇';
            case 'CASE'
                father_layer='舱';
            case 'CABIN'
                father_layer='系统';
        end
        %挨着对各个层级的对象进行分析，如果已经算过了，就直接拿来用
        if isfield(flags.(char(o)),'Tem')
            if isfield(flags.(char(o)).Tem,'Incon')
                In_data=flags.(char(o)).Tem.Incon;
                %没有算过，就要现场算。
            else
                flags.(char(o)).Tem.Incon={};
                %拉取用于计算的本层数据
                switch char(o)
                    case 'CELL'
                        data_to_use=data_struct.temperature_all;
                    case 'MOD'
                        data_to_use=data_struct.temperature_all;
                   case 'CASE'%需要模组的电压,有就用,没有就算
%                         if isfield(flags.MOD.Tem,'Diff')%既然有Tem这一层级，肯定是因为Diff创建过
                            data_to_use=flags.MOD.Tem.Diff.mean;
%                         else
%                             data_to_use_pre=data_struct.temperature_all;
%                             flags.MOD.Tem.Diff=function_diff_calculate(data_to_use_pre,index,'MOD',flags);
%                             data_to_use=flags.MOD.Tem.Diff.mean;
%                         end
                    case 'CABIN'%同理
%                          if isfield(flags.CASE.Tem,'Diff')
                            data_to_use=flags.CASE.Tem.Diff.mean;
%                         else
%                             data_to_use_pre=flags.MOD.Tem.Diff.mean;
%                             flags.CASE.Tem.Diff=function_diff_calculate(data_to_use_pre,index,'CASE',flags);
%                             data_to_use=flags.CASE.Tem.Diff.mean;
%                         end
                end
                %进行计算，并存到flags里面
                result_data=function_incon_calculate(data_to_use,index,char(o),flags);
                flags.(char(o)).Tem.Incon=result_data;%有想过不再分Diff和Incon这一层，但是，返回的值没法直接赋给Tem或Tem，不方便
                In_data=result_data;
            end
            
        else
            %没有算过（连这种数据都没有算过），就要现场算。
            flags.(char(o)).Tem={};
            flags.(char(o)).Tem.Incon={};
              %拉取用于计算的本层数据
                switch char(o)
                    case 'CELL'
                        data_to_use=data_struct.temperature_all;
                    case 'MOD'
                        data_to_use=data_struct.temperature_all;
                    case 'CASE'%需要模组的电压,有就用,没有就算
%                         if isfield(flags.MOD.Tem,'Diff')%既然连Tem都没有，那肯定没有Diff
%                             data_to_use=flags.MOD.Tem.Diff.mean;
%                         else
                            flags.(char(o)).Tem.Diff={};
                            data_to_use_pre=data_struct.temperature_all;
                            results=function_diff_calculate(data_to_use_pre,index,'MOD',flags);
                            flags.MOD.Tem.Diff=results;
                            data_to_use=results.mean;
%                         end
                    case 'CABIN'%同理
%                          if isfield(flags.CASE.Tem,'Diff')
%                             data_to_use=flags.CASE.Tem.Diff.mean;
%                         else
                            data_to_use_pre=flags.MOD.Tem.Diff.mean;
                            results=function_diff_calculate(data_to_use_pre,index,'CASE',flags);
                            flags.CASE.Tem.Diff=results;
                            data_to_use=results.mean;
%                         end
                end
                %进行计算，并存到flags里面
            result_data=function_incon_calculate(data_to_use,index,char(o),flags);
            flags.(char(o)).Tem.Incon=result_data;
            In_data=result_data;
        end
        %%
        %如果成功的话，会接着提取摘要，绘图和输出报告
        %报告内容计算
        if isa(In_data,'char') || size(In_data,2)==1
            report_content=['  ',father_layer,'温度',inconsist_method,'仅有一组计算结果,无法计算差异性特征量'];
        else
            %计算最大值，并看各个对象出现最大值的频次
            max_inconst_every_point=max(In_data,[],2);%计算每个点电不一致性的最大值
            In_data_and_MAX=[max_inconst_every_point,In_data];
            MAX_index=arrayfun(@(x)find(In_data_and_MAX(x,1)==In_data_and_MAX(x,2:end)),1:size(In_data_and_MAX,1),'un',0);
            max_diff_vol_times=tabulate(cell2mat(MAX_index));
            [MAX_times,MAX_INDEXs]=maxk(max_diff_vol_times(:,2),3);
            probes=max_diff_vol_times(:,1);
            MAX_probes=probes(MAX_INDEXs);
            probability=max_diff_vol_times(:,3);
            MAX_probability=roundn(probability(MAX_INDEXs),-2);
            report_content='';
            report_content=[report_content,'   ',father_layer,'温度',inconsist_method,'中最大次数最多的三个',char(o),':',mat2str(MAX_probes)];
            report_content=[report_content,'   比例(%):',mat2str(MAX_probability)];
            report_content=[report_content,'   次数:',mat2str(MAX_times)];  
        end
         this_function_records=[this_function_records, flags.data_part,report_content , 10 ];
        %图片绘制-分开还是hold on
        if output_figs && ~isa(In_data,'char') && size(In_data,2)>1
            h_fig= figure('name',[father_layer,'温度',inconsist_method,'中各',char(o),'出现最高不一致性的次数'],'NumberTitle','off','Visible','off');
            
            bar(max_diff_vol_times(:,1),max_diff_vol_times(:,2))
            xlabel([char(o),'编号']);
            ylabel('最高不一致性次数');
            title([father_layer,'温度',inconsist_method,'中各',char(o),'出现最高不一致性的次数'])
            set(h_fig,'Visible','on')
            saveas(h_fig,[work_folder_file_folder,'\',[father_layer,'温度',inconsist_method,'中各',char(o),'出现最高不一致性的次数'],'.fig'])
            close(h_fig)
            this_function_figs=[this_function_figs,work_folder_file_folder,'\',[father_layer,'温度',inconsist_method,'中各',char(o),'出现最高不一致性的次数'] ,  10  ...
                ];
        end
        
    end
    %%
    %输出报告
    % 功能点
    Calculation_results(size(Calculation_results,2)+1).name = '最大温度不一致性次数统计';
    %结果摘要
    Calculation_results(size(Calculation_results,2)).meanmary =this_function_records;
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
    Calculation_results(size(Calculation_results,2)+1).name = '最大温度不一致性次数统计';
    % 结果摘要
    Calculation_results(size(Calculation_results,2)).meanmary = '数据异常';
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
