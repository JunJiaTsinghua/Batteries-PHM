function  [Calculation_results,flags]  = function_max_diff_vol_times(data,flags,work_folder_file_folder,Calculation_results)
%function_max_temperature ��ѡʱ�䷶Χ�ڣ���ѹ��ֵ��������ĳ������Ĵ���
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
% flags=importdata('flags1.mat');
%%
%�����㼶�����һ�������ͼ��ÿ���㼶���ӽṹҲ���һ�������ͼ��
this_function_figs='';
this_function_records='';
analyze_object=flags.analyze_object;
% analyze_object(strcmp(analyze_object,'CELL'))=[];
% analyze_object(strcmp(analyze_object,'CABIN'))=[];%������û�ò�ֵ��ȥ��һ�㼶�ٱȽϵ�˵��
try
    for o=analyze_object
        %���㼶��ʲô
        switch char(o)
            case 'CELL'
                 father_layer='����';
            case 'MOD'
                father_layer='��';
            case 'CASE'
                father_layer='��';
            case 'CABIN'
                father_layer='ϵͳ';
                 
        end
        %���ŶԸ����㼶�Ķ�����з���������Ѿ�����ˣ���ֱ��������
        if isfield(flags.(char(o)),'Vol')
            if isfield(flags.(char(o)).Vol,'Diff')
                M_data=flags.(char(o)).Vol.Diff.diff;
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
                flags.(char(o)).Vol.Diff=result_data;%��������ٷ�Diff��Incon��һ�㣬���ǣ����ص�ֵû��ֱ�Ӹ���Tem��Vol��������
                M_data=result_data.diff;
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
            M_data=result_data.diff;
        end
        %%
        %����ɹ��Ļ����������ȡժҪ����ͼ���������
        %�������ݼ���
        if isa(M_data,'char') || size(M_data,2)==1
            report_content=['  ',father_layer,'����һ�������,�޷����������������'];
        else
            %�������ֵ��������������������ֵ��Ƶ��
            max_diff_every_point=max(M_data,[],2);%����ÿ�����ѹ������ֵ
            M_data_and_MAX=[max_diff_every_point,M_data];
            MAX_index=arrayfun(@(x)find(M_data_and_MAX(x,1)==M_data_and_MAX(x,2:end)),1:size(M_data_and_MAX,1),'un',0);
            max_diff_vol_times=tabulate(cell2mat(MAX_index));
            [MAX_times,MAX_INDEXs]=maxk(max_diff_vol_times(:,2),3);
            cells=max_diff_vol_times(:,1);
            MAX_probes=cells(MAX_INDEXs);
            probability=max_diff_vol_times(:,3);
            MAX_probability=roundn(probability(MAX_INDEXs),-2);
            report_content='';
            report_content=[report_content,'   ',father_layer,'����������������',char(o),':',mat2str(MAX_probes)];
            report_content=[report_content,'   ����(%):',mat2str(MAX_probability)];
            report_content=[report_content,'   ����:',mat2str(MAX_times)];  
        end
         this_function_records=[this_function_records, flags.data_part,report_content , 10 ];
        %ͼƬ����-�ֿ�����hold on
        if output_figs && ~isa(M_data,'char') && size(M_data,2)>1
            h_fig= figure('name',[father_layer,'�и�',char(o),'�������ѹ��Ĵ���'],'NumberTitle','off','Visible','off');
            
            bar(max_diff_vol_times(:,1),max_diff_vol_times(:,2))
            xlabel([char(o),'���']);
            ylabel('����');
            title([father_layer,'�и�',char(o),'�������ѹ��Ĵ���'])
            set(h_fig,'Visible','on')
            saveas(h_fig,[work_folder_file_folder,'\',[father_layer,'�и�',char(o),'�������ѹ��Ĵ���'],'.fig'])
            close(h_fig)
            this_function_figs=[this_function_figs,work_folder_file_folder,'\',[father_layer,'�и�',char(o),'�������ѹ��Ĵ���'] ,  10  ...
                ];
        end
        
    end
    %%
    %�������
    % ���ܵ�
    Calculation_results(size(Calculation_results,2)+1).name = '���ѹ�����ͳ��';
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
    Calculation_results(size(Calculation_results,2)+1).name = '���ѹ�����ͳ��';
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
