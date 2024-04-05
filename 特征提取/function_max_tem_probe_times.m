function  [Calculation_results,flags]  = function_max_tem_probe_times(data,flags,work_folder_file_folder,Calculation_results)
%function_max_tem_probe_times ��ѡʱ�䷶Χ�ڣ��¶�̽��������ֵ��ͳ�ƴ���
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
         %�Ӳ㼶��ʲô
        switch char(o)
            case 'CELL'
                sub_layer='����';
            case 'MOD'
                 sub_layer='����';
            case 'CASE'
                 sub_layer='ģ��';
            case 'CABIN'
                 sub_layer='��';
        end
        %���ŶԸ����㼶�Ķ�����з���������Ѿ�����ˣ���ֱ��������
        if isfield(flags.(char(o)),'Tem')
            if isfield(flags.(char(o)).Tem,'Diff')
                M_data=flags.(char(o)).Tem.Diff.max_index;
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
                M_data=result_data.max_index;
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
            M_data=result_data.max_index;
        end
        %%
        %����ɹ��Ļ����������ȡժҪ����ͼ���������
        %�������ݼ���
        if isa(M_data,'char')
            report_content=M_data;
             this_function_records=[this_function_records, flags.data_part,char(o),'����¶�:',report_content ,'     '];
        else
            frequency={};%��ǰ�㼶�ж�����󣬾ͻ��ж���Ƶ�εĽ��������19��ģ���19��Ƶ����Ҫ��¼
            for f=1:size(M_data,2)
                 f_num=int2str(f);
                this_f=['O',f_num];
                
            max_tem_probe_times=tabulate(cell2mat(M_data(:,f)'));%ÿ��ģ��/��/�����ֵ��������ֵ������ֻ�����һ��
            frequency.(this_f)=max_tem_probe_times;
            [MAX_times,MAX_INDEXs]=maxk(max_tem_probe_times(:,2),3);
            probes=max_tem_probe_times(:,1);
            MAX_probes=probes(MAX_INDEXs);
            probability=max_tem_probe_times(:,3);
            MAX_probability=roundn(probability(MAX_INDEXs),-2);
            report_content='';
            report_content=[report_content,'   ��������������',sub_layer,':',mat2str(MAX_probes)];
            report_content=[report_content,'   ����:',mat2str(MAX_probability)];
            report_content=[report_content,'   ����:',mat2str(MAX_times)];
            if size(M_data,2)==1
                f_num='';
            end
            this_function_records=[this_function_records, flags.data_part,char(o),f_num,'����¶�:',report_content , 10 ];
            end
        end
        
        %ͼƬ����-�ֿ�����hold on
        if output_figs && ~isa(M_data,'char')
            f_s=fieldnames(frequency);
            plot_way=flags.plot_split;
            if length(f_s)==1
                plot_way='һ��';
            end
       switch plot_way
           case '�ֿ���'
               for  k=1:length(f_s)
                   h_fig= figure('name',[char(o),int2str(k),'�и�',sub_layer,'��������¶ȵĴ���'],'NumberTitle','off','Visible','off');
                  max_tem_probe_times=frequency.(['O',int2str(k)]);
                   bar(max_tem_probe_times(:,1),max_tem_probe_times(:,2))
                   xlabel([sub_layer,'���']);
                   ylabel('����¶�(��)');
                   title([char(o),int2str(k),'�и�',sub_layer,'��������¶ȵĴ���'])
                   set(h_fig,'Visible','on')
                   saveas(h_fig,[work_folder_file_folder,'\',[char(o),int2str(k),'�и�',sub_layer,'��������¶ȵĴ���'],'.fig'])
                   close(h_fig)
                   this_function_figs=[this_function_figs,work_folder_file_folder,'\',char(o),int2str(k),'�и�',sub_layer,'��������¶ȵĴ���','.fig' ,  10  ...
                ];
               end
               
           case 'һ��'
               h_fig= figure('name',[char(o),'�и�',sub_layer,'��������¶ȵĴ���'],'NumberTitle','off','Visible','off');

               legend_cell={};
               for k=length(f_s)
                    max_tem_probe_times=frequency.(['O',int2str(k)]);
                   bar(max_tem_probe_times(:,1),max_tem_probe_times(:,2))
                   hold on
                   legend_cell=[legend_cell,int2str(k)];
               end
               xlabel([sub_layer,'���']);
               ylabel('����¶�(��)');
               title([char(o),'�и�',sub_layer,'��������¶ȵĴ���'])
               if length(legend_cell)>1
                 legend(legend_cell)
               end
               set(h_fig,'Visible','on')
               saveas(h_fig,[work_folder_file_folder,'\',[char(o),'�и�',sub_layer,'��������¶ȵĴ���'],'.fig'])
               close(h_fig)
               this_function_figs=[this_function_figs,work_folder_file_folder,'\',char(o),'�и�',sub_layer,'��������¶ȵĴ���','.fig' ,  10  ...
                   ];
       end
        
          
        end
        
    end
    %%
    %�������
    % ���ܵ�
    Calculation_results(size(Calculation_results,2)+1).name = '����¶�̽����ִ���ͳ��';
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
    Calculation_results(size(Calculation_results,2)+1).name = '����¶�̽����ִ���ͳ��';
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
