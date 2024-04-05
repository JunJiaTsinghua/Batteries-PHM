function [Calculation_results,flags]= function_Ah_intergal_wide_SOC(data,flags,work_folder_file_folder,Calculation_results)
%function_Ah_intergal_wide_SOC ��ΧSOC�İ�ʱ���ַ�
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
threshold_names={'C_rate_standard_current','time_interval','C_rate_jump_limit'};
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
if ~isfield(flags,'charge_index')
    charge_index=get_charge_index(data_struct,flags);
    flags.charge_index=charge_index;
else
    charge_index=flags.charge_index;
end
%%
% ���㣬���Խ�����д���
try
   %%
    %����ɹ��Ļ����������ȡժҪ����ͼ���������
    this_function_figs='';
    this_function_records=['�������ð�ʱ���ַ�,��������ο�,    ����(Ah):',  10] ;
    Cap=[];
    time_stamp=data_struct.time_stamp;
    bus_current=data_struct.bus_current;
    soc=data_struct.soc;
    for i =1:length(charge_index)
        this_cycle=charge_index(i).cycle_index;
        %��γ��İ�ʱ���ַ�
        time_range=time_stamp(this_cycle(1):this_cycle(2));
        current=bus_current(this_cycle(1):this_cycle(2));
        A_rate=C_rate_compute(current);
        C_rate=A_rate/C_rate_standard_current;
        this_soc_start=soc(this_cycle(1));
        this_soc_end=soc(this_cycle(2));
        if this_soc_start>flags.SOC_min || this_soc_end<flags.SOC_max || time_interval>flags.data_quality_min...
                || C_rate >flags.C_rate_max || this_soc_end<this_soc_start
            %��������̫�࣬
             this_function_records=[this_function_records, 'ѭ��',int2str(i),',��   '];
            continue
        end
        Q_this_cycle=compute_Ah_Q(current,time_range);
        Cap_this_cycle=100*roundn(Q_this_cycle/(this_soc_end-this_soc_start),-4);
        Cap=[Cap;Cap_this_cycle];
        this_function_records=[this_function_records, 'ѭ��',int2str(i),': ',num2str( Cap_this_cycle ),'   '];
    end
    if output_figs 
        h_fig= figure('name',['�����仯'],'NumberTitle','off','Visible','off');
        bar(Cap);
        xlabel('����');
        ylabel('����(Ah)');
        title('�����仯')
        set(h_fig,'Visible','on')
        saveas(h_fig,[work_folder_file_folder,'\','�����仯','.fig'])
        this_function_figs=[this_function_figs,work_folder_file_folder,'\','�����仯','.fig' ,  10  ...
            ];
        close(h_fig)
    end
    %�������
    % ���ܵ�
    Calculation_results(size(Calculation_results,2)+1).name = '�����仯';
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
    Calculation_results(size(Calculation_results,2)+1).name = '�����仯';
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

%%
%���б��ʵ���ȡ
function  C_rate=C_rate_compute(I_this_cycle)
global C_rate_jump_limit
length_all=length(I_this_cycle);
I_to_use=I_this_cycle(ceil(length_all*0.1):ceil(length_all*0.9));%��ͷȥβ������ܸտ�ʼ�ͽ���ʱ�������Ӱ��
for i =1:length(I_to_use)-1
    if abs(I_to_use(i+1)-I_to_use(i))/abs(I_to_use(i))>C_rate_jump_limit
        end_index=i;
        break
    else
        end_index=length(I_to_use);
    end
end
C_rate_pre=abs(mean(I_to_use(1:end_index)));
C_rate=roundn(C_rate_pre,-1);
end

