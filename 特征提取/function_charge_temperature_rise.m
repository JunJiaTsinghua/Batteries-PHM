function [Calculation_results,flags]= function_charge_temperature_rise(data,flags,work_folder_file_folder,Calculation_results)
%function_charge_temperature_rise 充电过程温升
global data_struct
data_struct=data;
output_figs=flags.output_figs;
charge_progress_X_axis=flags.charge_progress_X_axis;

%%
%调试的时候打开本节
% Calculation_results={};
% output_figs=1;
% work_folder_file_folder='C:\MATLAB_APP\functions\test';
% data_struct=importdata('data_struct.mat');
% charge_index=importdata('cycle_index.mat');

%%
%没有这个字段的话，是要现场算的
if ~isfield(flags,'charge_index')
    charge_index=get_charge_index(data_struct,flags);
    flags.charge_index=charge_index;
else
    charge_index=flags.charge_index;
end
% flags=importdata('flags1.mat');
% index=1:size(data_struct.temperature_all,1);
 total_milage=data_struct.total_milage;
%%
%各个层级都会出一个结果和图，每个层级的子结构也会出一个结果和图。
this_function_figs='';
this_function_records='';
try
    for o=flags.analyze_object
        %子层级是什么
        switch char(o)
            case 'CELL'
                Tem_data=data_struct.temperature_all;
            case 'MOD'
                 if isfield(flags,'all_tem')
                      if isfield(flags.all_tem,'MOD')
                          Tem_data=flags.all_tem.MOD;
                      else
                          Tem_data=all_tem_compute(data_struct.temperature_all,char(o),flags);
                          flags.all_tem.MOD=Tem_data;
                      end
                 else
                     flags.all_tem={};
                     Tem_data=all_tem_compute(data_struct.temperature_all,char(o),flags);
                      flags.all_tem.MOD=Tem_data;
                 end
                 
            case 'CASE'
                 if isfield(flags,'all_tem')
                      if isfield(flags.all_tem,'CASE')
                          Tem_data=flags.all_tem.CASE;
                      else
                          Tem_data=all_tem_compute(flags.all_tem.MOD,char(o),flags);
                          flags.all_tem.CASE=Tem_data;
                      end
                 else
                     flags.all_tem={};
                     Tem_data=all_tem_compute(flags.all_tem.MOD,char(o),flags);
                      flags.all_tem.CASE=Tem_data;
                 end
            case 'CABIN'
                  if isfield(flags,'all_tem')
                      if isfield(flags.all_tem,'CABIN')
                          Tem_data=flags.all_tem.CABIN;
                      else
                          Tem_data=all_tem_compute(flags.all_tem.CASE,char(o),flags);
                          flags.all_tem.CABIN=Tem_data;
                      end
                 else
                     flags.all_tem={};
                     Tem_data=all_tem_compute(flags.all_tem.CASE,char(o),flags);
                      flags.all_tem.CABIN=Tem_data;
                 end
        end
       
        %%
        %如果成功的话，会接着提取摘要，绘图和输出报告
        %报告内容计算
             charge_tem_rise=zeros(length(charge_index),size(Tem_data,2));
             mileage_axis=zeros(length(charge_index),1);
            for i =1:length(charge_index)
                this_cycle=charge_index(i).cycle_index;
                 this_mileage= total_milage(this_cycle(1):this_cycle(2));
                 mileage_axis(i)=this_mileage(end);
                 this_Tem=Tem_data(this_cycle(1):this_cycle(2),:);
                max_Tem=max(this_Tem,[],1);
                this_Tem_start=this_Tem(1,:);
                tem_rise=max_Tem-this_Tem_start;
                charge_tem_rise(i,:)=tem_rise;
                [max_Tem_rise,probe]=max(tem_rise);
                if size(Tem_data,2)==1
                    this_requipment_num='';
                else
                    this_requipment_num=int2str(probe);
                end
                this_function_records=[this_function_records, '循环',int2str(i),'最大温升是',char(o),this_requipment_num,':',num2str( roundn(max_Tem_rise,-2) ),'℃   '];
            end
  
        %图片绘制-分开还是hold on
        if output_figs
            plot_way=flags.plot_split;
            if size(charge_tem_rise,2)==1
                plot_way='一起画';
            end
       switch plot_way
           case '分开画'
               for k=1:size(charge_tem_rise,2)
                   h_fig= figure('name',[char(o),int2str(k),'充电最大温升变化曲线'],'NumberTitle','off','Visible','off');
                   switch charge_progress_X_axis
                       case '次数'
                           plot(charge_tem_rise(:,k))
                       case '里程'
                           plot(mileage_axis,charge_tem_rise(:,k))
                   end
                   xlabel(charge_progress_X_axis);
                   ylabel('温升(℃)');
                   title([char(o),int2str(k),'充电最大温升变化曲线'])
                   set(h_fig,'Visible','on')
                   saveas(h_fig,[work_folder_file_folder,'\',[char(o),int2str(k),'充电最大温升变化曲线'],'.fig'])
                   close(h_fig)
                   this_function_figs=[this_function_figs,work_folder_file_folder,'\',char(o),int2str(k),'充电最大温升变化曲线','.fig' ,  10  ...
                ];
               end
               
           case '一起画'
               h_fig= figure('name',[char(o),'充电最大温升变化曲线'],'NumberTitle','off','Visible','off');
               switch charge_progress_X_axis
                   case '次数'
                       plot(charge_tem_rise)
                   case '里程'
                       plot(mileage_axis,charge_tem_rise)
               end
               legend_cell={};
               for k=1:size(charge_tem_rise,2)
                   legend_cell=[legend_cell,int2str(k)];
               end
               xlabel(charge_progress_X_axis);
               ylabel('温升(℃)');
               title([char(o),'充电最大温升变化曲线'])
               if length(legend_cell)>1
                 legend(legend_cell)
               end
               set(h_fig,'Visible','on')
               saveas(h_fig,[work_folder_file_folder,'\',[char(o),'充电最大温升变化曲线'],'.fig'])
               close(h_fig)
               this_function_figs=[this_function_figs,work_folder_file_folder,'\',char(o),'充电最大温升变化曲线','.fig' ,  10  ...
                   ];
       end
   
        end
        
    end
    %%
    %输出报告
    % 功能点
    Calculation_results(size(Calculation_results,2)+1).name = '充电过程最大温升';
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
    Calculation_results(size(Calculation_results,2)+1).name = '充电过程最大温升';
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