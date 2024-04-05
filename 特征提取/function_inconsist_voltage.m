function  [Calculation_results,flags]  = function_inconsist_voltage(data,flags,work_folder_file_folder,Calculation_results)
%function_inconsist_voltage 所选时间范围内，电压不一致性计算
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
        if isfield(flags.(char(o)),'Vol')
            if isfield(flags.(char(o)).Vol,'Incon')
                In_data=flags.(char(o)).Vol.Incon;
                %没有算过，就要现场算。
            else
                flags.(char(o)).Vol.Incon={};
                %拉取用于计算的本层数据
                switch char(o)
                    case 'CELL'
                        data_to_use=data_struct.cell_voltage;
                    case 'MOD'
                        data_to_use=data_struct.cell_voltage;
                   case 'CASE'%需要模组的电压,有就用,没有就算
%                         if isfield(flags.MOD.Vol,'Diff')%既然有Vol这一层级，肯定是因为Diff创建过
                            data_to_use=flags.MOD.Vol.Diff.sum;
%                         else
%                             data_to_use_pre=data_struct.cell_voltage;
%                             flags.MOD.Vol.Diff=function_diff_calculate(data_to_use_pre,index,'MOD',flags);
%                             data_to_use=flags.MOD.Vol.Diff.sum;
%                         end
                    case 'CABIN'%同理
%                          if isfield(flags.CASE.Vol,'Diff')
                            data_to_use=flags.CASE.Vol.Diff.sum;
%                         else
%                             data_to_use_pre=flags.MOD.Vol.Diff.sum;
%                             flags.CASE.Vol.Diff=function_diff_calculate(data_to_use_pre,index,'CASE',flags);
%                             data_to_use=flags.CASE.Vol.Diff.sum;
%                         end
                end
                %进行计算，并存到flags里面
                result_data=function_incon_calculate(data_to_use,index,char(o),flags);
                flags.(char(o)).Vol.Incon=result_data;%有想过不再分Diff和Incon这一层，但是，返回的值没法直接赋给Vol或Vol，不方便
                In_data=result_data;
            end
            
        else
            %没有算过（连这种数据都没有算过），就要现场算。
            flags.(char(o)).Vol={};
            flags.(char(o)).Vol.Incon={};
              %拉取用于计算的本层数据
                switch char(o)
                    case 'CELL'
                        data_to_use=data_struct.cell_voltage;
                    case 'MOD'
                        data_to_use=data_struct.cell_voltage;
                    case 'CASE'%需要模组的电压,有就用,没有就算
%                         if isfield(flags.MOD.Vol,'Diff')%既然连Vol都没有，那肯定没有Diff
%                             data_to_use=flags.MOD.Vol.Diff.sum;
%                         else
                            flags.(char(o)).Vol.Diff={};
                            data_to_use_pre=data_struct.cell_voltage;
                            results=function_diff_calculate(data_to_use_pre,index,'MOD',flags);
                            flags.MOD.Vol.Diff=results;
                            data_to_use=results.sum;
%                         end
                    case 'CABIN'%同理
%                          if isfield(flags.CASE.Vol,'Diff')
%                             data_to_use=flags.CASE.Vol.Diff.sum;
%                         else
                            data_to_use_pre=flags.MOD.Vol.Diff.sum;
                            results=function_diff_calculate(data_to_use_pre,index,'CASE',flags);
                            flags.CASE.Vol.Diff=results;
                            data_to_use=results.sum;
%                         end
                end
                %进行计算，并存到flags里面
            result_data=function_incon_calculate(data_to_use,index,char(o),flags);
            flags.(char(o)).Vol.Incon=result_data;
            In_data=result_data;
        end
        %%
        %如果成功的话，会接着提取摘要，绘图和输出报告
        %报告内容计算
        if isa(In_data,'char')
            report_content=In_data;
        else
            max_Incon_Vol=max(In_data,[],1);%每个模组/簇/舱电压不一致性里面的最大值，报告只输出这一个
            report_content=mat2str(roundn(max_Incon_Vol,-2));
        end
         this_function_records=[this_function_records, flags.data_part,char(o),'中各',sub_layer,'的最大电压',inconsist_method,':',report_content ,'     '];
        %图片绘制-分开还是hold on
        if output_figs && ~isa(In_data,'char')
            plot_way=flags.plot_split;
            if size(In_data,2)==1
                plot_way='一起画';
            end
       switch plot_way
           case '分开画'
               for k=1:size(In_data,2)
                   h_fig= figure('name',[char(o),int2str(k),'中各',sub_layer,'的最大电压',inconsist_method,'曲线'],'NumberTitle','off','Visible','off');
                   plot(In_data(:,k))
                   xlabel('数据采集点');
                   ylabel(inconsist_method);
                   title([char(o),int2str(k),'中各',sub_layer,'的最大电压',inconsist_method,'曲线'])
                   set(h_fig,'Visible','on')
                   saveas(h_fig,[work_folder_file_folder,'\',[char(o),int2str(k),'中各',sub_layer,'的最大电压',inconsist_method,'曲线'],'.fig'])
                   close(h_fig)
                   this_function_figs=[this_function_figs,work_folder_file_folder,'\',char(o),int2str(k),'中各',sub_layer,'的最大电压',inconsist_method,'曲线','.fig' ,  10  ...
                ];
               end
               
           case '一起画'
               h_fig= figure('name',[char(o),'中各',sub_layer,'的最大电压',inconsist_method,'曲线'],'NumberTitle','off','Visible','off');
               plot(In_data)
               legend_cell={};
               for k=1:size(In_data,2)
                   legend_cell=[legend_cell,int2str(k)];
               end
               xlabel('数据采集点');
               ylabel(inconsist_method);
               title([char(o),'中各',sub_layer,'的最大电压',inconsist_method,'曲线'])
               if length(legend_cell)>1
                 legend(legend_cell)
               end
               set(h_fig,'Visible','on')
               saveas(h_fig,[work_folder_file_folder,'\',[char(o),'中各',sub_layer,'的最大电压',inconsist_method,'曲线'],'.fig'])
               close(h_fig)
               this_function_figs=[this_function_figs,work_folder_file_folder,'\',char(o),'中各',sub_layer,'的最大电压',inconsist_method,'曲线','.fig' ,  10  ...
                   ];
       end
        
          
        end
        
    end
    %%
    %输出报告
    % 功能点
    Calculation_results(size(Calculation_results,2)+1).name =[ '电压',inconsist_method,'变化'];
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
    Calculation_results(size(Calculation_results,2)+1).name =[ '电压',inconsist_method,'变化'];
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
