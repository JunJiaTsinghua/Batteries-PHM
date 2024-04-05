function   [Calculation_results,flags]=function_ICA_curve(data,flags,work_folder_file_folder,Calculation_results)
%���ڼ���ICA����,ÿ������Դ�п��ܲ�һ����Ҳ�п��ܽ�������ֵ�Ϳ��ԡ�
% Calculation_results={};
global data_struct
data_struct=data;
% data_struct=importdata('data_struct.mat');
% threshold=this_configuration;
% flags=importdata('flags1.mat');
% Calculation_results={};
% work_folder_file_folder='C:\MATLAB_APP\functions\test';
%��ֵȷ��
threshold=flags.threshold;
threshold_names={'time_interval' ,'C_rate_jump_limit', 'time_charge_limit', 'peak_area_v_range', 'IC_peak_min_SOC'...
    ,'interp_window_size_base','filter_window_size_base','window_size_SOC_base'};

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


% %�����ò���
% C_rate_jump_limit=1/5;%���ʱ��������ٷֱ����ƣ�̫��Ͳ��������
% time_charge_limit=300;%���ٳ����ٷ��Ӳ����м�ֵ��ѭ����̫��û�б�Ҫ��ICA
% peak_area_v_range=0.1;%����������ʱ������ַ����Ҷ���ѹ�ķ�Χ��
% %����Ϊʵ�������Ϻ����������ԱߵĹ�,���������ָ�ĳ���ѹ�Ķ��Χ��30V�ͻ���3V�����Ҹ�1.5V��
% IC_peak_min_SOC=50;%�ó���������͵�ƽ̨�ڲ��ᳬ����SOC��Χ������������������λ�ò�����50%SOC֮��


output_figs=flags.output_figs;

try
    switch flags.data_source_choosed
        case 'changan_EV_data'
            ICA_results=ICA_main_changAn(flags);
    end
    %����ɹ��Ļ����������ȡժҪ����ͼ���������
    C_rates=fieldnames(ICA_results);
    this_function_records='';
    this_function_figs='';
    for i =1:length(C_rates)
        this_rate=char(C_rates(i));
        if output_figs
            h_fig= figure('name',['ICA_',this_rate],'NumberTitle','off','Visible','off');
            labels=[];
        end
        for j =1:length(ICA_results.(this_rate))
            if output_figs
                V_IC=ICA_results.(this_rate)(j).V_IC;
                dQdV=ICA_results.(this_rate)(j).dQdV;
                plot3(ones(size(V_IC,2),1)* j,V_IC,dQdV);
                labels=[labels;ICA_results.(this_rate)(j).occur_time];
            end
            %             peak_area=ICA_results.(this_rate)(j).peak_area;
            %             peak_value=ICA_results.(this_rate)(j).peak_value;
            %             peak_position=ICA_results.(this_rate)(j).peak_position;
            occur_time=ICA_results.(this_rate)(j).occur_time;
            curve_features=ICA_results.(this_rate)(j).curve_features;
            this_function_records=[this_function_records, '����:',this_rate,',ʱ��:',occur_time,',����ֵ:',struct2str(curve_features) ,'   ',  10  ...
                ];
            hold on
        end
        if output_figs
            xlabel('��������');
            ylabel('��ѹ(V)');
            zlabel('��������(Ah/V)')
            title('ICA����ƽ���Ա�')
            legend(labels);
            set(h_fig,'Visible','on')
            saveas(h_fig,[work_folder_file_folder,'\','ICA_',this_rate,'.fig'])
            this_function_figs=[this_function_figs,work_folder_file_folder,'\','ICA_',this_rate,'.fig' ,  10  ...
                ];
            
            close(h_fig)
        end
    end
    %%
    %�������
    % ���ܵ�
    Calculation_results(size(Calculation_results,2)+1).name = 'ICA����';
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
    
catch ErrorInfo
    
    % ���ܵ�
    Calculation_results(size(Calculation_results,2)+1).name = 'ICA����';
    % ���ժҪ
    Calculation_results(size(Calculation_results,2)).summary = '���ݳ��Ȳ������������';
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

function ICA_results=ICA_main_changAn(flags)
% clear
%һЩ��ʼ������
global  num_interp data_struct     
%��ͬ�ı��ʣ���ֵ��ƽ���Ĵ���ֵ��ͬ���ܴﵽ��ͬ��ƽ��Ч���������ǻ�׼ֵ��ƾ��ʵ�����ݣ�Ҫ
%�������׼ֵ�ϸı����
% interp_window_size_base=0.1;
% filter_window_size_base=0.05;
% window_size_SOC_base=90;


%��ȡ����ICA�ĳ��ѭ������
% cycles_index=cycles_index_get();%ICA�Լ���һ��ԭʼ��������ȡ���������ʼд��
% cycles_index=get_charge_index(data_struct,flags);%�������ĵ���д��һ���������������򲻶ࡣ���������������ֵ���Ե�������
if ~isfield(flags,'charge_index')
    charge_index=get_charge_index(data_struct,flags);
    flags.charge_index=charge_index;
else
    charge_index=flags.charge_index;
end
%��ÿһ��ѭ������ICA���㡣
bus_voltage=data_struct.bus_voltage;
bus_current=data_struct.bus_current;
soc=data_struct.soc;
terminal_time=data_struct.terminal_time;
ICA_results={};
for cycle_num =1:length(charge_index)
    %�õ���ǰѭ������������
    cycle_index=charge_index(cycle_num).cycle_index;
    V_this_cycle=bus_voltage(cycle_index(1):cycle_index(2));
    I_this_cycle=bus_current(cycle_index(1):cycle_index(2));
    C_rate=C_rate_compute(I_this_cycle);
    this_C_rate=['C',strrep(num2str(C_rate),'.','_')];
    if isfield(ICA_results,this_C_rate)~=1
        ICA_results.(this_C_rate)={};
    end
    time_this_cylce=terminal_time(cycle_index(1):cycle_index(2));
    occure_date=datestr(time_this_cylce(1),'yyyy-mm-dd');
    SOC_this_cycle=soc(cycle_index(1):cycle_index(2));
    %���в�ֵ��ƽ�������߼���
    num_interp=length(V_this_cycle);
    [V_IC,dQdV,SOC_smooth]=ICA_compute(V_this_cycle,I_this_cycle,SOC_this_cycle);
    %������ȡ
    V_IC_interval=(V_this_cycle(end)-V_this_cycle(1))/(num_interp-1);
    curve_features=IC_feature_compute(V_IC,dQdV,SOC_smooth,V_IC_interval);
    ICA_results.(this_C_rate)(size(ICA_results.(this_C_rate),2)+1).occur_time=occure_date;
    ICA_results.(this_C_rate)(size(ICA_results.(this_C_rate),2)).SOC_range=[SOC_this_cycle(1),SOC_this_cycle(end)];
    ICA_results.(this_C_rate)(size(ICA_results.(this_C_rate),2)).dQdV=dQdV;
    ICA_results.(this_C_rate)(size(ICA_results.(this_C_rate),2)).V_IC=V_IC;
    ICA_results.(this_C_rate)(size(ICA_results.(this_C_rate),2)).SOC=SOC_smooth;
    ICA_results.(this_C_rate)(size(ICA_results.(this_C_rate),2)).curve_features=curve_features;
    ICA_results.(this_C_rate)(size(ICA_results.(this_C_rate),2)).peak_area=curve_features.Area;
    ICA_results.(this_C_rate)(size(ICA_results.(this_C_rate),2)).peak_value=curve_features.peak;
    ICA_results.(this_C_rate)(size(ICA_results.(this_C_rate),2)).peak_position=curve_features.positon;
    %      ICA_results.(this_C_rate)=ICA_data;
end
end
%%
%������ȡ����
function curve_features=IC_feature_compute(V_IC,dQdV,SOC_smooth,V_IC_interval)
%PEAKAREA ����IC�ķ�ֵ���
%%
%�ҵ���ֵ��Ӧ������;
global peak_area_v_range IC_peak_min_SOC
if SOC_smooth(1)>IC_peak_min_SOC%��ʼ��SOC̫�ߣ���������
    curve_features={};
    curve_features.Area='SOC��Χ̫խ';
    curve_features.peak='SOC��Χ̫խ';
    curve_features.positon='SOC��Χ̫խ';
else
    [max_dQdV,index]=max(dQdV);%max���Ƿ�ֵ��
    i=index;j=index;
    lowV=V_IC(index)-0.5*peak_area_v_range*(V_IC(end)-V_IC(1));
    upV=V_IC(index)+0.5*peak_area_v_range*(V_IC(end)-V_IC(1));
    lowIndex=0;upIndex=0;Area=0;
    %���½���
    while i>0
        if V_IC(i)<=lowV && V_IC(i+1)>=lowV
            lowIndex=i;break
        else
            i=i-1;
        end
    end
    %���Ͻ���
    while j<length(V_IC)
        if V_IC(j)<=upV && V_IC(j+1)>=upV
            upIndex=j;break
        else
            j=j+1;
        end
    end
    
    % upIndex=length(V_IC);lowIndex=1;%���ȫ�����ֵĻ������ǳ������
    %%
    %�����
    if upIndex==0 || lowIndex==0
        %     fprintf('���ѭ��û�������')
        Area='�����������������';
    else
        %����ֵ����
        for i=lowIndex:upIndex-1
            dx=V_IC_interval;
            fx=0.5*(dQdV(i+1)+dQdV(i));
            dArea=dx*fx;
            Area=Area+dArea;
        end
    end
    curve_features={};
    curve_features.Area=Area;
    curve_features.peak=max_dQdV;
    curve_features.positon=V_IC(index);
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
%%
%����ICA����
function [V_IC,dQdV_smooth,SOC_smooth]=ICA_compute(V_this_cycle,I_this_cycle,SOC_this_cycle)
%%
%�ð�ʱ���ַ������������ڼ���������dQdV
global time_interval num_interp  interp_window_size_base filter_window_size_base window_size_SOC_base
Q_list=[0];
for i =1:length(I_this_cycle)-1
    this_interval_current_average=abs((I_this_cycle(i+1)+I_this_cycle(i))/2)/3600;
    sum_Q=this_interval_current_average*time_interval+Q_list(end);
    Q_list=[Q_list;sum_Q];
    
end

%%
%SOCֻ�ɵ�С�����һλ���������ֵ���͵�Q�����ˡ�[����û�в����������]
% for j =1:length(V_this_cycle)-1
%
%     if V_this_cycle(j+1)-V_this_cycle(j)<=0
%         V_this_cycle(j+1)=V_this_cycle(j)
%     end
% end
%%

interp_window_size=interp_window_size_base*window_size_SOC_base/(SOC_this_cycle(end)-SOC_this_cycle(1));
SOC_smooth=smooth(SOC_this_cycle,interp_window_size,'sgolay');
V_smooth=smooth(V_this_cycle,interp_window_size,'sgolay');
%%
% figure(1)
% plot(SOC_smooth,V_smooth,'b','LineWidth',1.5)
% hold on
% plot(SOC_this_cycle,V_this_cycle,'r-','LineWidth',1)
% xlabel('SOC��%��');
% ylabel('��ѹ��V��');
% title('Ah-V����ƽ���Ա�')
% legend('ƽ��','δƽ��');

%%
%ֱ����dQȥ����dV����������֣�ûƽ����ʱ�򣩣�����SOC������Q_list֮�󣬾���Q��
Q_list_smooth=smooth(Q_list,interp_window_size,'sgolay');%��ʵ����Ӧ����Q_list.�տ�ʼ��SOC�������û�����
d_V_list=V_this_cycle(1):(V_this_cycle(end)-V_this_cycle(1))/(num_interp-1):V_this_cycle(end);
SOC_list=spline(V_smooth,Q_list_smooth ,d_V_list);
dQdV=[];
for i =1:length(d_V_list)-1
    dQdV=[dQdV,(SOC_list(i+1)-SOC_list(i))/((V_this_cycle(end)-V_this_cycle(1))/(num_interp-1))];
end
filter_window_size=filter_window_size_base*window_size_SOC_base/(SOC_this_cycle(end)-SOC_this_cycle(1));

dQdV_smooth=smooth(dQdV,filter_window_size,'sgolay');
V_IC=d_V_list(1:(num_interp-1));

% %%
% figure(2)
% plot(d_V_list(1:(num_interp-1)),dQdV_smooth,'b','LineWidth',2)
% hold on
% plot(d_V_list(1:(num_interp-1)),dQdV,'r-','LineWidth',1)
% xlabel('��ѹ(V)');
% ylabel('��������(Ah/V)');
% title('ICA����ƽ���Ա�')
% legend('ƽ��','δƽ��');

end

%%
%��ȡ���ѭ��
function cycles_index=cycles_index_get()
%%
%��ʼ��
global data_miss_tolrance data_struct time_interval   time_charge_limit 
data_miss_tolrance = 1.5;  %# ʱ����������׼ֵ��1.5������Ϊ�Ƕ�ʧ
c_miss_num_limit = 30; % # ���ʱ��ʧ���ݵ�ļ���
flag_C_begin_threshold = 3; % # ����������˵����ʼ�����
flag_C_end_threshold = 3;  %# ����������˵�����������
bus_current=data_struct.bus_current;


%%
%��ȡ��ŵ�ѭ������ر�־λ��vehicle_mode=2��running_mode=1��Ϊ������硣ͬʱ���õ���Ϊ�����Ҳ����ȥ�ж�

vehicle_mode=data_struct.vehicle_mode;
running_mode=data_struct.running_mode;
bus_current=data_struct.bus_current;
soc=data_struct.soc;
charge_mode=data_struct.charge_mode;
time_stamp=data_struct.time_stamp;
terminal_time=data_struct.terminal_time;
%bus_voltage�õ���ĵ�ѹ��ͣ��ó����ĺ�ƽ����
bus_voltage=zeros(size(data_struct.cell_voltage,1),1);
for i =1:size(data_struct.cell_voltage,1)
    bus_voltage(i)=sum(data_struct.cell_voltage(i,:));
end
%%
%�����������ѿ����Ǻ�������Ƭ�������ó����������һ���жϵ�ʱ����ɾ����
cycles_index=[];%���һ���ṹ�壬�����cell��������
index_this_cycle=[];%��⵽�����ѭ����index��¼
flag_C_begin = 0;
flag_C_end = 0;
sum_C_miss = 0;
last_record_index =inf;
cycle_C_index = {};
cycle = 0;
begin_index = 0;
%%
for i =1:length(bus_current)
    cycle={};
    %# ���ֿ�ʼ����ˣ����γ��ֳ�������
    if flag_C_begin < flag_C_begin_threshold && charge_mode(i)==1 &&vehicle_mode(i)==2&&running_mode(i)==1 && bus_current(i)<0
        flag_C_begin =flag_C_begin+ 1;
        if flag_C_begin >= flag_C_begin_threshold
            begin_index = i -2;
        end
    end
    
    % # �ڳ�������¼��ʱ�򣬳����˲��ǳ�����������
    if flag_C_begin >=flag_C_begin_threshold && ( charge_mode(i)~=1 ||  bus_current(i)>0)
        if i > last_record_index+ 1%#����жϳ������������Ĳ��������ģ����ܰ��������ܾõ���Ϊ�ж�����
            flag_C_end = 0;last_record_index=i;%fprintf('��;���ִ������ݻ����ж�');
        else
            flag_C_end =flag_C_end+ 1;last_record_index = i;
        end
        if flag_C_end >= flag_C_end_threshold
            end_index = i - 3;
            last_record_index=inf;
            flag_C_end = 0;
            flag_C_begin = 0;
            data_miss = missDataRecord(begin_index, soc(begin_index:end_index),bus_voltage(begin_index:end_index), time_stamp(begin_index:end_index));
            
            %# ���������������жϡ�
            if data_miss.num_miss> c_miss_num_limit || end_index-begin_index<time_charge_limit/time_interval
                % # print("��ʧ���࣬����")
                continue
            else
                cycle_C_index.cycle_index = [begin_index, end_index];
                cycle_C_index.num_miss=  data_miss.num_miss;
                cycle_C_index.miss_place=  data_miss.miss_place;
                %                 sum_C_miss = sum_C_miss + data_miss.num_miss;%�ܹ���ʧ�˶��١�
                cycles_index=[cycles_index;cycle_C_index];
            end
            
        end
    end
end

end

%%
%��¼������Щ��ʧ���ݵĵط����ظ�ɾ��Ӧ�����ʼ��Ū�ˣ����ﲻ�ܡ�
function data_miss=missDataRecord(begin_index, soc, voltage, time)
data_miss = {};
miss_num_this_cycle = 0;
miss_place = {};
global data_miss_tolrance time_interval
for i =1: length(soc)-1
    if soc(i)== 0 || voltage(i) == 0 || time(i+1)-time(i)>data_miss_tolrance*time_interval
         num_miss = max(1,ceil(( time(i+1)-time(i)) / time_interval)) ; %# ʵ�ʵ�ʱ���ֵ����ȥ��Ӧ�е�10���ٳ���10������Щ�����˵�
        miss_num_this_cycle = miss_num_this_cycle + num_miss;
        miss_place.(['Index_',int2str(i + begin_index-1)]) =num_miss;
        
    end
    data_miss.num_miss = miss_num_this_cycle;
    data_miss.miss_place = miss_place;
end

end