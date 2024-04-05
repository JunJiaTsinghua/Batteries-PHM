function [Calculation_results,flags]= funct_charge_mean_temperature(data,flags,work_folder_file_folder,Calculation_results)
%funct_charge_mean_temperature ������ƽ���¶�
global data_struct
data_struct=data;
output_figs=flags.output_figs;
% charge_Index_get=flags.charge_Index_get
%%
%���Ե�ʱ��򿪱���
% Calculation_results={};
% output_figs=1;
% work_folder_file_folder='C:\MATLAB_APP\functions\test';
% data_struct=importdata('data_struct.mat');
% charge_index=importdata('cycle_index.mat');
charge_progress_X_axis=flags.charge_progress_X_axis;
%%
%û������ֶεĻ�����Ҫ�ֳ����
% if ~isfield(flags,'charge_index')
%     charge_index=get_charge_index(data_struct,flags);
%     flags.charge_index=charge_index;
% else
%     charge_index=flags.charge_index;
% end
flags=importdata('flags1.mat');
index=1:size(data_struct.temperature_all,1);
 total_milage=data_struct.total_milage;
%%
%�����㼶�����һ�������ͼ��ÿ���㼶���ӽṹҲ���һ�������ͼ��
this_function_figs='';
this_function_records='';
try
    for o=flags.analyze_object
        %�Ӳ㼶��ʲô
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
        %����ɹ��Ļ����������ȡժҪ����ͼ���������
        %�������ݼ���
             charge_tem_mean=zeros(length(charge_index),size(Tem_data,2));
             mileage_axis=zeros(length(charge_index),1);
            for i =1:length(charge_index)
                this_cycle=charge_index(i).cycle_index;
                 this_mileage= total_milage(this_cycle(1):this_cycle(2));
                 mileage_axis(i)=this_mileage(end);
                 this_Tem=Tem_data(this_cycle(1):this_cycle(2),:);
                mean_Tem=mean(this_Tem,1);
                charge_tem_mean(i,:)=mean_Tem;
                [max_Tem_mean,probe]=max(mean_Tem);
                if size(Tem_data,2)==1
                    this_requipment_num='';
                else
                    this_requipment_num=int2str(probe);
                end
                this_function_records=[this_function_records, 'ѭ��',int2str(i),'���ƽ���¶���',char(o),this_requipment_num,':',num2str( roundn(max_Tem_mean,-2) ),'��   '];
            end
  
        %ͼƬ����-�ֿ�����hold on
        if output_figs
            plot_way=flags.plot_split;
            if size(charge_tem_mean,2)==1
                plot_way='һ��';
            end
       switch plot_way
           case '�ֿ���'
               for k=1:size(charge_tem_mean,2)
                   h_fig= figure('name',[char(o),int2str(k),'���ƽ���¶ȱ仯����'],'NumberTitle','off','Visible','off');
                   switch charge_progress_X_axis
                       case '����'
                           plot(charge_tem_mean(:,k))
                       case '���'
                           plot(mileage_axis,charge_tem_mean(:,k))
                   end
                   xlabel(charge_progress_X_axis);
                   ylabel('ƽ���¶�(��)');
                   title([char(o),int2str(k),'���ƽ���¶ȱ仯����'])
                   set(h_fig,'Visible','on')
                   saveas(h_fig,[work_folder_file_folder,'\',[char(o),int2str(k),'���ƽ���¶ȱ仯����'],'.fig'])
                   close(h_fig)
                   this_function_figs=[this_function_figs,work_folder_file_folder,'\',char(o),int2str(k),'���ƽ���¶ȱ仯����','.fig' ,  10  ...
                ];
               end
               
           case 'һ��'
               h_fig= figure('name',[char(o),'���ƽ���¶ȱ仯����'],'NumberTitle','off','Visible','off');
               switch charge_progress_X_axis
                   case '����'
                       plot(charge_tem_mean)
                   case '���'
                       plot(mileage_axis,charge_tem_mean)
               end
               legend_cell={};
               for k=1:size(charge_tem_mean,2)
                   legend_cell=[legend_cell,int2str(k)];
               end
               xlabel(charge_progress_X_axis);
               ylabel('ƽ���¶�(��)');
               title([char(o),'���ƽ���¶ȱ仯����'])
               if length(legend_cell)>1
                 legend(legend_cell)
               end
               set(h_fig,'Visible','on')
               saveas(h_fig,[work_folder_file_folder,'\',[char(o),'���ƽ���¶ȱ仯����'],'.fig'])
               close(h_fig)
               this_function_figs=[this_function_figs,work_folder_file_folder,'\',char(o),'���ƽ���¶ȱ仯����','.fig' ,  10  ...
                   ];
       end
   
        end
        
    end
    %%
    %�������
    % ���ܵ�
    Calculation_results(size(Calculation_results,2)+1).name = '������ƽ���¶�';
    %���ժҪ
    Calculation_results(size(Calculation_results,2)).summary =this_function_records;
    %�ļ�·��
    if output_figs
        Calculation_results(size(Calculation_results,2)).figs_path =this_function_figs;    % ���ļ��ṩstruct2str�ĺ���
    else
        Calculation_results(size(Calculation_results,2)).figs_path ='�û�δѡ��ͼƬ���';
    end
    % ��ע
    Calculation_results(size(Calculation_results,2)).remark = '��' ;
    
    %%
catch ErrorInfo
    
    % ���ܵ�
    Calculation_results(size(Calculation_results,2)+1).name = '������ƽ���¶�';
    % ���ժҪ
    Calculation_results(size(Calculation_results,2)).summary = '�����쳣';
    % �ļ�·��
    Calculation_results(size(Calculation_results,2)).figs_path =  '�����쳣';
    % ��ע
    if strcmp("'cell' ���͵����������Ч���������Ϊ�ṹ����� Java �� COM ����", ErrorInfo.message)
        message='������̫��';
    else
        message= ErrorInfo.message;
    end
    Calculation_results(size(Calculation_results,2)).remark = message;
    
end

end