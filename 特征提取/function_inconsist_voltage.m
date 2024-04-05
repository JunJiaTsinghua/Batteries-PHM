function  [Calculation_results,flags]  = function_inconsist_voltage(data,flags,work_folder_file_folder,Calculation_results)
%function_inconsist_voltage ��ѡʱ�䷶Χ�ڣ���ѹ��һ���Լ���
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
            if isfield(flags.(char(o)).Vol,'Incon')
                In_data=flags.(char(o)).Vol.Incon;
                %û���������Ҫ�ֳ��㡣
            else
                flags.(char(o)).Vol.Incon={};
                %��ȡ���ڼ���ı�������
                switch char(o)
                    case 'CELL'
                        data_to_use=data_struct.cell_voltage;
                    case 'MOD'
                        data_to_use=data_struct.cell_voltage;
                   case 'CASE'%��Ҫģ��ĵ�ѹ,�о���,û�о���
%                         if isfield(flags.MOD.Vol,'Diff')%��Ȼ��Vol��һ�㼶���϶�����ΪDiff������
                            data_to_use=flags.MOD.Vol.Diff.sum;
%                         else
%                             data_to_use_pre=data_struct.cell_voltage;
%                             flags.MOD.Vol.Diff=function_diff_calculate(data_to_use_pre,index,'MOD',flags);
%                             data_to_use=flags.MOD.Vol.Diff.sum;
%                         end
                    case 'CABIN'%ͬ��
%                          if isfield(flags.CASE.Vol,'Diff')
                            data_to_use=flags.CASE.Vol.Diff.sum;
%                         else
%                             data_to_use_pre=flags.MOD.Vol.Diff.sum;
%                             flags.CASE.Vol.Diff=function_diff_calculate(data_to_use_pre,index,'CASE',flags);
%                             data_to_use=flags.CASE.Vol.Diff.sum;
%                         end
                end
                %���м��㣬���浽flags����
                result_data=function_incon_calculate(data_to_use,index,char(o),flags);
                flags.(char(o)).Vol.Incon=result_data;%��������ٷ�Diff��Incon��һ�㣬���ǣ����ص�ֵû��ֱ�Ӹ���Vol��Vol��������
                In_data=result_data;
            end
            
        else
            %û����������������ݶ�û�����������Ҫ�ֳ��㡣
            flags.(char(o)).Vol={};
            flags.(char(o)).Vol.Incon={};
              %��ȡ���ڼ���ı�������
                switch char(o)
                    case 'CELL'
                        data_to_use=data_struct.cell_voltage;
                    case 'MOD'
                        data_to_use=data_struct.cell_voltage;
                    case 'CASE'%��Ҫģ��ĵ�ѹ,�о���,û�о���
%                         if isfield(flags.MOD.Vol,'Diff')%��Ȼ��Vol��û�У��ǿ϶�û��Diff
%                             data_to_use=flags.MOD.Vol.Diff.sum;
%                         else
                            flags.(char(o)).Vol.Diff={};
                            data_to_use_pre=data_struct.cell_voltage;
                            results=function_diff_calculate(data_to_use_pre,index,'MOD',flags);
                            flags.MOD.Vol.Diff=results;
                            data_to_use=results.sum;
%                         end
                    case 'CABIN'%ͬ��
%                          if isfield(flags.CASE.Vol,'Diff')
%                             data_to_use=flags.CASE.Vol.Diff.sum;
%                         else
                            data_to_use_pre=flags.MOD.Vol.Diff.sum;
                            results=function_diff_calculate(data_to_use_pre,index,'CASE',flags);
                            flags.CASE.Vol.Diff=results;
                            data_to_use=results.sum;
%                         end
                end
                %���м��㣬���浽flags����
            result_data=function_incon_calculate(data_to_use,index,char(o),flags);
            flags.(char(o)).Vol.Incon=result_data;
            In_data=result_data;
        end
        %%
        %����ɹ��Ļ����������ȡժҪ����ͼ���������
        %�������ݼ���
        if isa(In_data,'char')
            report_content=In_data;
        else
            max_Incon_Vol=max(In_data,[],1);%ÿ��ģ��/��/�յ�ѹ��һ������������ֵ������ֻ�����һ��
            report_content=mat2str(roundn(max_Incon_Vol,-2));
        end
         this_function_records=[this_function_records, flags.data_part,char(o),'�и�',sub_layer,'������ѹ',inconsist_method,':',report_content ,'     '];
        %ͼƬ����-�ֿ�����hold on
        if output_figs && ~isa(In_data,'char')
            plot_way=flags.plot_split;
            if size(In_data,2)==1
                plot_way='һ��';
            end
       switch plot_way
           case '�ֿ���'
               for k=1:size(In_data,2)
                   h_fig= figure('name',[char(o),int2str(k),'�и�',sub_layer,'������ѹ',inconsist_method,'����'],'NumberTitle','off','Visible','off');
                   plot(In_data(:,k))
                   xlabel('���ݲɼ���');
                   ylabel(inconsist_method);
                   title([char(o),int2str(k),'�и�',sub_layer,'������ѹ',inconsist_method,'����'])
                   set(h_fig,'Visible','on')
                   saveas(h_fig,[work_folder_file_folder,'\',[char(o),int2str(k),'�и�',sub_layer,'������ѹ',inconsist_method,'����'],'.fig'])
                   close(h_fig)
                   this_function_figs=[this_function_figs,work_folder_file_folder,'\',char(o),int2str(k),'�и�',sub_layer,'������ѹ',inconsist_method,'����','.fig' ,  10  ...
                ];
               end
               
           case 'һ��'
               h_fig= figure('name',[char(o),'�и�',sub_layer,'������ѹ',inconsist_method,'����'],'NumberTitle','off','Visible','off');
               plot(In_data)
               legend_cell={};
               for k=1:size(In_data,2)
                   legend_cell=[legend_cell,int2str(k)];
               end
               xlabel('���ݲɼ���');
               ylabel(inconsist_method);
               title([char(o),'�и�',sub_layer,'������ѹ',inconsist_method,'����'])
               if length(legend_cell)>1
                 legend(legend_cell)
               end
               set(h_fig,'Visible','on')
               saveas(h_fig,[work_folder_file_folder,'\',[char(o),'�и�',sub_layer,'������ѹ',inconsist_method,'����'],'.fig'])
               close(h_fig)
               this_function_figs=[this_function_figs,work_folder_file_folder,'\',char(o),'�и�',sub_layer,'������ѹ',inconsist_method,'����','.fig' ,  10  ...
                   ];
       end
        
          
        end
        
    end
    %%
    %�������
    % ���ܵ�
    Calculation_results(size(Calculation_results,2)+1).name =[ '��ѹ',inconsist_method,'�仯'];
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
    Calculation_results(size(Calculation_results,2)+1).name =[ '��ѹ',inconsist_method,'�仯'];
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
