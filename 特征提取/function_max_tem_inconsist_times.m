function  [Calculation_results,flags]  = function_max_tem_inconsist_times(data,flags,work_folder_file_folder,Calculation_results)
%function_max_tem_inconsist_times ��ѡʱ�䷶Χ�ڣ���ѹ��һ������������ĳ������Ĵ���
global data_struct
data_struct=data;
output_figs=flags.output_figs;
inconsist_method=flags.inconsist_method;
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
% analyze_object(strcmp(analyze_object,'CABIN'))=[];%������û�ò�һ������ȥ��һ�㼶�ٱȽϵ�˵��
try
    for o=analyze_object
        %���㼶��ʲô
        switch char(o)
            case 'CELL'
                 father_layer='̽��';
            case 'MOD'
                father_layer='��';
            case 'CASE'
                father_layer='��';
            case 'CABIN'
                father_layer='ϵͳ';
        end
        %���ŶԸ����㼶�Ķ�����з���������Ѿ�����ˣ���ֱ��������
        if isfield(flags.(char(o)),'Tem')
            if isfield(flags.(char(o)).Tem,'Incon')
                In_data=flags.(char(o)).Tem.Incon;
                %û���������Ҫ�ֳ��㡣
            else
                flags.(char(o)).Tem.Incon={};
                %��ȡ���ڼ���ı�������
                switch char(o)
                    case 'CELL'
                        data_to_use=data_struct.temperature_all;
                    case 'MOD'
                        data_to_use=data_struct.temperature_all;
                   case 'CASE'%��Ҫģ��ĵ�ѹ,�о���,û�о���
%                         if isfield(flags.MOD.Tem,'Diff')%��Ȼ��Tem��һ�㼶���϶�����ΪDiff������
                            data_to_use=flags.MOD.Tem.Diff.mean;
%                         else
%                             data_to_use_pre=data_struct.temperature_all;
%                             flags.MOD.Tem.Diff=function_diff_calculate(data_to_use_pre,index,'MOD',flags);
%                             data_to_use=flags.MOD.Tem.Diff.mean;
%                         end
                    case 'CABIN'%ͬ��
%                          if isfield(flags.CASE.Tem,'Diff')
                            data_to_use=flags.CASE.Tem.Diff.mean;
%                         else
%                             data_to_use_pre=flags.MOD.Tem.Diff.mean;
%                             flags.CASE.Tem.Diff=function_diff_calculate(data_to_use_pre,index,'CASE',flags);
%                             data_to_use=flags.CASE.Tem.Diff.mean;
%                         end
                end
                %���м��㣬���浽flags����
                result_data=function_incon_calculate(data_to_use,index,char(o),flags);
                flags.(char(o)).Tem.Incon=result_data;%��������ٷ�Diff��Incon��һ�㣬���ǣ����ص�ֵû��ֱ�Ӹ���Tem��Tem��������
                In_data=result_data;
            end
            
        else
            %û����������������ݶ�û�����������Ҫ�ֳ��㡣
            flags.(char(o)).Tem={};
            flags.(char(o)).Tem.Incon={};
              %��ȡ���ڼ���ı�������
                switch char(o)
                    case 'CELL'
                        data_to_use=data_struct.temperature_all;
                    case 'MOD'
                        data_to_use=data_struct.temperature_all;
                    case 'CASE'%��Ҫģ��ĵ�ѹ,�о���,û�о���
%                         if isfield(flags.MOD.Tem,'Diff')%��Ȼ��Tem��û�У��ǿ϶�û��Diff
%                             data_to_use=flags.MOD.Tem.Diff.mean;
%                         else
                            flags.(char(o)).Tem.Diff={};
                            data_to_use_pre=data_struct.temperature_all;
                            results=function_diff_calculate(data_to_use_pre,index,'MOD',flags);
                            flags.MOD.Tem.Diff=results;
                            data_to_use=results.mean;
%                         end
                    case 'CABIN'%ͬ��
%                          if isfield(flags.CASE.Tem,'Diff')
%                             data_to_use=flags.CASE.Tem.Diff.mean;
%                         else
                            data_to_use_pre=flags.MOD.Tem.Diff.mean;
                            results=function_diff_calculate(data_to_use_pre,index,'CASE',flags);
                            flags.CASE.Tem.Diff=results;
                            data_to_use=results.mean;
%                         end
                end
                %���м��㣬���浽flags����
            result_data=function_incon_calculate(data_to_use,index,char(o),flags);
            flags.(char(o)).Tem.Incon=result_data;
            In_data=result_data;
        end
        %%
        %����ɹ��Ļ����������ȡժҪ����ͼ���������
        %�������ݼ���
        if isa(In_data,'char') || size(In_data,2)==1
            report_content=['  ',father_layer,'�¶�',inconsist_method,'����һ�������,�޷����������������'];
        else
            %�������ֵ��������������������ֵ��Ƶ��
            max_inconst_every_point=max(In_data,[],2);%����ÿ����粻һ���Ե����ֵ
            In_data_and_MAX=[max_inconst_every_point,In_data];
            MAX_index=arrayfun(@(x)find(In_data_and_MAX(x,1)==In_data_and_MAX(x,2:end)),1:size(In_data_and_MAX,1),'un',0);
            max_diff_vol_times=tabulate(cell2mat(MAX_index));
            [MAX_times,MAX_INDEXs]=maxk(max_diff_vol_times(:,2),3);
            probes=max_diff_vol_times(:,1);
            MAX_probes=probes(MAX_INDEXs);
            probability=max_diff_vol_times(:,3);
            MAX_probability=roundn(probability(MAX_INDEXs),-2);
            report_content='';
            report_content=[report_content,'   ',father_layer,'�¶�',inconsist_method,'����������������',char(o),':',mat2str(MAX_probes)];
            report_content=[report_content,'   ����(%):',mat2str(MAX_probability)];
            report_content=[report_content,'   ����:',mat2str(MAX_times)];  
        end
         this_function_records=[this_function_records, flags.data_part,report_content , 10 ];
        %ͼƬ����-�ֿ�����hold on
        if output_figs && ~isa(In_data,'char') && size(In_data,2)>1
            h_fig= figure('name',[father_layer,'�¶�',inconsist_method,'�и�',char(o),'������߲�һ���ԵĴ���'],'NumberTitle','off','Visible','off');
            
            bar(max_diff_vol_times(:,1),max_diff_vol_times(:,2))
            xlabel([char(o),'���']);
            ylabel('��߲�һ���Դ���');
            title([father_layer,'�¶�',inconsist_method,'�и�',char(o),'������߲�һ���ԵĴ���'])
            set(h_fig,'Visible','on')
            saveas(h_fig,[work_folder_file_folder,'\',[father_layer,'�¶�',inconsist_method,'�и�',char(o),'������߲�һ���ԵĴ���'],'.fig'])
            close(h_fig)
            this_function_figs=[this_function_figs,work_folder_file_folder,'\',[father_layer,'�¶�',inconsist_method,'�и�',char(o),'������߲�һ���ԵĴ���'] ,  10  ...
                ];
        end
        
    end
    %%
    %�������
    % ���ܵ�
    Calculation_results(size(Calculation_results,2)+1).name = '����¶Ȳ�һ���Դ���ͳ��';
    %���ժҪ
    Calculation_results(size(Calculation_results,2)).meanmary =this_function_records;
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
    Calculation_results(size(Calculation_results,2)+1).name = '����¶Ȳ�һ���Դ���ͳ��';
    % ���ժҪ
    Calculation_results(size(Calculation_results,2)).meanmary = '�����쳣';
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
