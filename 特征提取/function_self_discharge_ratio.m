function [Calculation_results,flags]= function_self_discharge_ratio(data,flags,work_folder_file_folder,Calculation_results)
%function_self_discharge_ratio ����ʱ�ڲ������Էŵ�
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
% flags=importdata('flags1.mat');
% still_index=importdata('cycle_index.mat');
% flags={};
%%
%��ֵȷ��
threshold=flags.threshold;
threshold_names={'C_rate_standard_current'};
threshold_names_str='';
for i =threshold_names
    threshold_names_str=[threshold_names_str,' ',char(i)];
end
eval(['global ',threshold_names_str]);
thresholds=threshold.('thresholds');
threshold_value=threshold.('value');
for i=1:length(thresholds)
    if ismember(char(thresholds(i)), threshold_names)
        value= cell2mat(threshold_value(i));
        eval([char(thresholds(i)),'=',num2str(value),';'])
    end
end
% C_rate_standard_current=30;
%%
%û������ֶεĻ�����Ҫ�ֳ����
if ~isfield(flags,'still_index')
    still_index=get_still_index(data_struct,flags);
    flags.still_index=still_index;
else
    still_index=flags.still_index;
end
%%
% ���㣬���Խ�����д���
try
   %%
    %����ɹ��Ļ����������ȡժҪ����ͼ���������
    this_function_figs='';
    this_function_records=['�Էŵ������ð�ʱ���ַ�����������ο�',  10] ;
   
    self_dis_Q=[];
    self_dis_ratio=[];
    time_stamp=data_struct.time_stamp;
    bus_current=data_struct.bus_current;
    soc=data_struct.soc;
    for i =1:length(still_index)
        this_cycle=still_index(i).cycle_index;
        %��γ��İ�ʱ���ַ�
        time_range=time_stamp(this_cycle(1):this_cycle(2));
        current=bus_current(this_cycle(1):this_cycle(2));
        error_index=abs(current)>2*mean(current);
        this_soc=soc(this_cycle(1):this_cycle(2));
        if sum(error_index)>length(error_index)*0.1 || this_soc(end)>this_soc(1) || this_soc(end)<this_soc(1)-10
            %��������̫�࣬
             this_function_records=[this_function_records, 'ѭ��',int2str(i),',��������   '];
            continue
        end
        current(error_index)=[];
        time_range(error_index)=[];
        Q_this_time=compute_Ah_Q(current,time_range);
        self_dis_Q=[self_dis_Q;Q_this_time];
        self_dis_ratio_this_time=Q_this_time/C_rate_standard_current/((time_range(end)-time_range(1))/3600);
        self_dis_ratio=[self_dis_ratio;self_dis_ratio_this_time];
        this_function_records=[this_function_records, 'ѭ��',int2str(i),', �Էŵ���(Ah):',num2str( Q_this_time ),'   '];
    end
    if output_figs 
        h_fig= figure('name',['�Էŵ��ʱ仯'],'NumberTitle','off','Visible','off');

        yyaxis left;
        bar(self_dis_Q);
        xlabel('����');
        ylabel('�Էŵ���(Ah)');
         yyaxis right;
        plot(self_dis_ratio,'lineWidth',2);
        ylabel('�Էŵ���(%/Сʱ)');
        title('�Էŵ��ʱ仯')
        set(h_fig,'Visible','on')
        saveas(h_fig,[work_folder_file_folder,'\','�Էŵ��ʱ仯','.fig'])
        this_function_figs=[this_function_figs,work_folder_file_folder,'\','�Էŵ��ʱ仯','.fig' ,  10  ...
            ];
        close(h_fig)
    end
    %�������
    % ���ܵ�
    Calculation_results(size(Calculation_results,2)+1).name = '�Էŵ��ʱ仯';
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
    Calculation_results(size(Calculation_results,2)+1).name = '�Էŵ��ʱ仯';
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

