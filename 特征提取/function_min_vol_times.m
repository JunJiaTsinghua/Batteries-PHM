function  [Calculation_results,flags]  = function_min_vol_times(data,flags,work_folder_file_folder,Calculation_results)
%function_min_vol_times ��ѡʱ�䷶Χ�ڣ���ѹ������Сֵ��ͳ�ƴ���
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
        if isfield(flags.(char(o)),'Vol')
            if isfield(flags.(char(o)).Vol,'Diff')
                M_data=flags.(char(o)).Vol.Diff.min_index;
                %û���������Ҫ�ֳ��㡣
            else
                flags.(char(o)).Vol.Diff={};
                %��ȡ���ڼ���ı�������
                switch char(o)
                    case 'CELL'
                        data_to_use=data_struct.cell_voltage;
                    case 'MOD'
                        data_to_use=data_struct.cell_voltage;
                    case 'CASE'
                        data_to_use=flags.MOD.Vol.Diff.sum;
                    case 'CABIN'
                        data_to_use=flags.CASE.Vol.Diff.sum;
                end
                %���м��㣬���浽flags����
                result_data=function_diff_calculate(data_to_use,index,char(o),flags);
                flags.(char(o)).Vol.Diff=result_data;%��������ٷ�Diff��Incon��һ�㣬���ǣ����ص�ֵû��ֱ�Ӹ���Vol��Vol��������
                M_data=result_data.min_index;
            end
            
        else
            %û����������������ݶ�û�����������Ҫ�ֳ��㡣
            flags.(char(o)).Vol={};
            flags.(char(o)).Vol.Diff={};
              %��ȡ���ڼ���ı�������
                switch char(o)
                    case 'CELL'
                        data_to_use=data_struct.cell_voltage;
                    case 'MOD'
                        data_to_use=data_struct.cell_voltage;
                    case 'CASE'
                        data_to_use=flags.MOD.Vol.Diff.sum;
                    case 'CABIN'
                        data_to_use=flags.CASE.Vol.Diff.sum;
                end
                %���м��㣬���浽flags����
            result_data=function_diff_calculate(data_to_use,index,char(o),flags);
            flags.(char(o)).Vol.Diff=result_data;
            M_data=result_data.min_index;
        end
        %%
        %����ɹ��Ļ����������ȡժҪ����ͼ���������
        %�������ݼ���
        if isa(M_data,'char')
            report_content=M_data;
            this_function_records=[this_function_records, flags.data_part,char(o),'��͵�ѹ:',report_content,'  '];
        else
            frequency={};
            for f=1:size(M_data,2)
                 f_num=int2str(f);
                this_f=['O',f_num];
                
                min_vol_times=tabulate(cell2mat(M_data(:,f)'));%ÿ��ģ��/��/����Сֵ�������Сֵ������ֻ�����һ��
                frequency.(this_f)=min_vol_times;
                [MIN_times,MIN_INDEXs]=maxk(min_vol_times(:,2),3);
                cells=min_vol_times(:,1);
                MIN_cells=cells(MIN_INDEXs);
                probability=min_vol_times(:,3);
                MIN_probability=roundn(probability(MIN_INDEXs),-2);
                report_content='';
                report_content=[report_content,'   ��͵�ѹ������������',sub_layer,':',mat2str(MIN_cells)];
                report_content=[report_content,'   ����:',mat2str(MIN_probability)];
                report_content=[report_content,'   ����:',mat2str(MIN_times)];
                if size(M_data,2)==1
                    f_num='';
                end
                this_function_records=[this_function_records, flags.data_part,char(o),f_num,'��͵�ѹ:',report_content ,  10  ];
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
               
               for k=1:length(f_s)
                   h_fig= figure('name',[char(o),int2str(k),'�и�',sub_layer,'������͵�ѹ�Ĵ���'],'NumberTitle','off','Visible','off');
                   min_vol_times=frequency.(['O',int2str(k)]);
                   bar(min_vol_times(:,1),min_vol_times(:,2))
                   xlabel([sub_layer,'���']);
                   ylabel('��͵�ѹ(��)');
                   title([char(o),int2str(k),'�и�',sub_layer,'������͵�ѹ�Ĵ���'])
                   set(h_fig,'Visible','on')
                   saveas(h_fig,[work_folder_file_folder,'\',[char(o),int2str(k),'�и�',sub_layer,'������͵�ѹ�Ĵ���'],'.fig'])
                   close(h_fig)
                   this_function_figs=[this_function_figs,work_folder_file_folder,'\',char(o),int2str(k),'�и�',sub_layer,'������͵�ѹ�Ĵ���','.fig' ,  10  ...
                ];
               end
               
           case 'һ��'
               h_fig= figure('name',[char(o),'�и�',sub_layer,'������͵�ѹ�Ĵ���'],'NumberTitle','off','Visible','off');
               
               legend_cell={};
               for k=1:length(f_s)
                  min_vol_times=frequency.(['O',int2str(k)]);
                   bar(min_vol_times(:,1),min_vol_times(:,2))
                   hold on
                   legend_cell=[legend_cell,int2str(k)];
               end
               xlabel([sub_layer,'���']);
               ylabel('��͵�ѹ(��)');
               title([char(o),'�и�',sub_layer,'������͵�ѹ�Ĵ���'])
               if length(legend_cell)>1
                 legend(legend_cell)
               end
               set(h_fig,'Visible','on')
               saveas(h_fig,[work_folder_file_folder,'\',[char(o),'�и�',sub_layer,'������͵�ѹ�Ĵ���'],'.fig'])
               close(h_fig)
               this_function_figs=[this_function_figs,work_folder_file_folder,'\',char(o),'�и�',sub_layer,'������͵�ѹ�Ĵ���','.fig' ,  10  ...
                   ];
       end
        
          
        end
        
    end
    %%
    %�������
    % ���ܵ�
    Calculation_results(size(Calculation_results,2)+1).name = '��͵�ѹ';
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
    Calculation_results(size(Calculation_results,2)+1).name = '��͵�ѹ';
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
