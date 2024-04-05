function  [Calculation_results,flags]  = function_max_temperature(data,flags,work_folder_file_folder,Calculation_results)
%function_max_temperature ��ѡʱ�䷶Χ�ڣ��¶����ֵ
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
% index=1:length(data_struct.bus_current);
% flags=importdata('flags.mat');
%%
%�����㼶�����һ�������ͼ��ÿ���㼶���ӽṹҲ���һ�������ͼ��
this_function_figs='';
this_function_records='';
try
    for o=flags.analyze_object
        %���ŶԸ����㼶�Ķ�����з���������Ѿ�����ˣ���ֱ��������
        if isfield(flags.(char(o)),'Tem')
            if isfield(flags.(char(o)).Tem,'Diff')
                M_data=flags.(char(o)).Tem.Diff.max;
                %û���������Ҫ�ֳ��㡣
            else
                flags.(char(o)).Tem.Diff={};
                %��ȡ���ڼ���ı�������
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
                %���м��㣬���浽flags����
                result_data=function_diff_calculate(data_to_use,index,char(o),flags);
                flags.(char(o)).Tem.Diff=result_data;%��������ٷ�Diff��Incon��һ�㣬���ǣ����ص�ֵû��ֱ�Ӹ���Tem��Vol��������
                M_data=result_data.max;
            end
            
        else
            %û����������������ݶ�û�����������Ҫ�ֳ��㡣
            flags.(char(o)).Tem={};
            flags.(char(o)).Tem.Diff={};
              %��ȡ���ڼ���ı�������
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
                %���м��㣬���浽flags����
            result_data=function_diff_calculate(data_to_use,index,char(o),flags);
            flags.(char(o)).Tem.Diff=result_data;
            M_data=result_data.max;
        end
        %%
        %����ɹ��Ļ����������ȡժҪ����ͼ���������
        %�������ݼ���
        if isa(M_data,'char')
            report_content=M_data;
        else
            max_max_tem=max(M_data,[],1);%ÿ��ģ��/��/�����ֵ��������ֵ������ֻ�����һ��
            report_content=mat2str(roundn(max_max_tem,-2));
        end
         this_function_records=[this_function_records, flags.data_part,char(o),'����¶�:',report_content ,'     '];
        %ͼƬ����-�ֿ�����hold on
        if output_figs && ~isa(M_data,'char')
            plot_way=flags.plot_split;
            if size(M_data,2)==1
                plot_way='һ��';
            end
       switch plot_way
           case '�ֿ���'
               for k=1:size(M_data,2)
                   h_fig= figure('name',[char(o),int2str(k),'����¶�����'],'NumberTitle','off','Visible','off');
                   plot(M_data(:,k))
                   xlabel('���ݲɼ���');
                   ylabel('����¶�(��)');
                   title([char(o),int2str(k),'����¶�����'])
                   set(h_fig,'Visible','on')
                   saveas(h_fig,[work_folder_file_folder,'\',[char(o),int2str(k),'����¶�����'],'.fig'])
                   close(h_fig)
                   this_function_figs=[this_function_figs,work_folder_file_folder,'\',char(o),int2str(k),'����¶�����','.fig' ,  10  ...
                ];
               end
               
           case 'һ��'
               h_fig= figure('name',[char(o),'����¶�����'],'NumberTitle','off','Visible','off');
               plot(M_data)
               legend_cell={};
               for k=1:size(M_data,2)
                   legend_cell=[legend_cell,int2str(k)];
               end
               xlabel('���ݲɼ���');
               ylabel('����¶�(��)');
               title([char(o),'����¶�����'])
               if length(legend_cell)>1
                 legend(legend_cell)
               end
               set(h_fig,'Visible','on')
               saveas(h_fig,[work_folder_file_folder,'\',[char(o),'����¶�����'],'.fig'])
               close(h_fig)
               this_function_figs=[this_function_figs,work_folder_file_folder,'\',char(o),'����¶�����','.fig' ,  10  ...
                   ];
       end
        
          
        end
        
    end
    %%
    %�������
    % ���ܵ�
    Calculation_results(size(Calculation_results,2)+1).name = '����¶�';
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
    Calculation_results(size(Calculation_results,2)+1).name = '����¶�';
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
