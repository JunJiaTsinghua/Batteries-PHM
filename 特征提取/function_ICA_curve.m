function   [Calculation_results,flags]=function_ICA_curve(data,flags,work_folder_file_folder,Calculation_results)
%用于计算ICA曲线,每种数据源有可能不一样，也有可能仅仅改阈值就可以。
% Calculation_results={};
global data_struct
data_struct=data;
% data_struct=importdata('data_struct.mat');
% threshold=this_configuration;
% flags=importdata('flags1.mat');
% Calculation_results={};
% work_folder_file_folder='C:\MATLAB_APP\functions\test';
%阈值确定
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


% %可配置参数
% C_rate_jump_limit=1/5;%充电时候倍率跳变百分比限制，太大就不再算恒流
% time_charge_limit=300;%至少充电多少分钟才算有价值的循环，太短没有必要算ICA
% peak_area_v_range=0.1;%计算峰面积的时候，想积分峰左右多宽电压的范围。
% %（因为实车基本上很难能碰到旁边的谷,这个比例是指的充电电压的多大范围，30V就积分3V，左右各1.5V）
% IC_peak_min_SOC=50;%该车辆电池类型的平台期不会超过的SOC范围，例如给的样本，其峰位置不会再50%SOC之后


output_figs=flags.output_figs;

try
    switch flags.data_source_choosed
        case 'changan_EV_data'
            ICA_results=ICA_main_changAn(flags);
    end
    %如果成功的话，会接着提取摘要，绘图和输出报告
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
            this_function_records=[this_function_records, '倍率:',this_rate,',时间:',occur_time,',特征值:',struct2str(curve_features) ,'   ',  10  ...
                ];
            hold on
        end
        if output_figs
            xlabel('曲线数量');
            ylabel('电压(V)');
            zlabel('电量增量(Ah/V)')
            title('ICA曲线平滑对比')
            legend(labels);
            set(h_fig,'Visible','on')
            saveas(h_fig,[work_folder_file_folder,'\','ICA_',this_rate,'.fig'])
            this_function_figs=[this_function_figs,work_folder_file_folder,'\','ICA_',this_rate,'.fig' ,  10  ...
                ];
            
            close(h_fig)
        end
    end
    %%
    %输出报告
    % 功能点
    Calculation_results(size(Calculation_results,2)+1).name = 'ICA曲线';
    %结果摘要
    Calculation_results(size(Calculation_results,2)).summary =this_function_records;
    %文件路径
    if output_figs
        Calculation_results(size(Calculation_results,2)).figs_path =this_function_figs;    % 本文件提供struct2str的函数
    else
        Calculation_results(size(Calculation_results,2)).figs_path ='用户未选择图片输出';
    end
    % 备注
    Calculation_results(size(Calculation_results,2)).remark = '无' ;
    
catch ErrorInfo
    
    % 功能点
    Calculation_results(size(Calculation_results,2)+1).name = 'ICA曲线';
    % 结果摘要
    Calculation_results(size(Calculation_results,2)).summary = '数据长度不满足分析需求';
    % 文件路径
    Calculation_results(size(Calculation_results,2)).figs_path =  '数据异常';
     % 备注
    if strcmp("'cell' 类型的输入参数无效。输入必须为结构体或者 Java 或 COM 对象。", ErrorInfo.message)
        message='数据量太少';
    else
        message= ErrorInfo.message;
    end
    Calculation_results(size(Calculation_results,2)).remark = message;
    
end
end

function ICA_results=ICA_main_changAn(flags)
% clear
%一些初始化参数
global  num_interp data_struct     
%不同的倍率，插值和平滑的窗口值不同，能达到不同的平滑效果。下面是基准值，凭借实际数据，要
%在这个基准值上改变比例
% interp_window_size_base=0.1;
% filter_window_size_base=0.05;
% window_size_SOC_base=90;


%获取能算ICA的充电循环索引
% cycles_index=cycles_index_get();%ICA自己有一个原始的索引获取方法，是最开始写的
% cycles_index=get_charge_index(data_struct,flags);%这个外面的单独写了一个函数，两个差球不多。但是外面这个的阈值可以单独设置
if ~isfield(flags,'charge_index')
    charge_index=get_charge_index(data_struct,flags);
    flags.charge_index=charge_index;
else
    charge_index=flags.charge_index;
end
%对每一个循环进行ICA计算。
bus_voltage=data_struct.bus_voltage;
bus_current=data_struct.bus_current;
soc=data_struct.soc;
terminal_time=data_struct.terminal_time;
ICA_results={};
for cycle_num =1:length(charge_index)
    %拿到当前循环的所需数据
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
    %进行插值、平滑、曲线计算
    num_interp=length(V_this_cycle);
    [V_IC,dQdV,SOC_smooth]=ICA_compute(V_this_cycle,I_this_cycle,SOC_this_cycle);
    %特征提取
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
%特征提取计算
function curve_features=IC_feature_compute(V_IC,dQdV,SOC_smooth,V_IC_interval)
%PEAKAREA 计算IC的峰值面积
%%
%找到峰值对应的索引;
global peak_area_v_range IC_peak_min_SOC
if SOC_smooth(1)>IC_peak_min_SOC%起始点SOC太高，不用算了
    curve_features={};
    curve_features.Area='SOC范围太窄';
    curve_features.peak='SOC范围太窄';
    curve_features.positon='SOC范围太窄';
else
    [max_dQdV,index]=max(dQdV);%max就是峰值了
    i=index;j=index;
    lowV=V_IC(index)-0.5*peak_area_v_range*(V_IC(end)-V_IC(1));
    upV=V_IC(index)+0.5*peak_area_v_range*(V_IC(end)-V_IC(1));
    lowIndex=0;upIndex=0;Area=0;
    %找下界限
    while i>0
        if V_IC(i)<=lowV && V_IC(i+1)>=lowV
            lowIndex=i;break
        else
            i=i-1;
        end
    end
    %找上界线
    while j<length(V_IC)
        if V_IC(j)<=upV && V_IC(j+1)>=upV
            upIndex=j;break
        else
            j=j+1;
        end
    end
    
    % upIndex=length(V_IC);lowIndex=1;%如果全部积分的话，就是充入电量
    %%
    %算面积
    if upIndex==0 || lowIndex==0
        %     fprintf('这个循环没法积面积')
        Area='面积积分条件不满足';
    else
        %用数值积分
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
%进行倍率的提取
function  C_rate=C_rate_compute(I_this_cycle)
global C_rate_jump_limit
length_all=length(I_this_cycle);
I_to_use=I_this_cycle(ceil(length_all*0.1):ceil(length_all*0.9));%掐头去尾，免得受刚开始和结束时候的跳变影响
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
%计算ICA曲线
function [V_IC,dQdV_smooth,SOC_smooth]=ICA_compute(V_this_cycle,I_this_cycle,SOC_this_cycle)
%%
%用安时积分法算容量，用于计算真正的dQdV
global time_interval num_interp  interp_window_size_base filter_window_size_base window_size_SOC_base
Q_list=[0];
for i =1:length(I_this_cycle)-1
    this_interval_current_average=abs((I_this_cycle(i+1)+I_this_cycle(i))/2)/3600;
    sum_Q=this_interval_current_average*time_interval+Q_list(end);
    Q_list=[Q_list;sum_Q];
    
end

%%
%SOC只采到小数点后一位，这里给插值，就当Q来用了。[而后没有采用这个方案]
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
% xlabel('SOC（%）');
% ylabel('电压（V）');
% title('Ah-V曲线平滑对比')
% legend('平滑','未平滑');

%%
%直接拿dQ去比上dV。其面积积分（没平滑的时候），就是SOC【换成Q_list之后，就是Q】
Q_list_smooth=smooth(Q_list,interp_window_size,'sgolay');%其实后面应该是Q_list.刚开始用SOC试了懒得换回来
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
% xlabel('电压(V)');
% ylabel('电量增量(Ah/V)');
% title('ICA曲线平滑对比')
% legend('平滑','未平滑');

end

%%
%提取充电循环
function cycles_index=cycles_index_get()
%%
%初始化
global data_miss_tolrance data_struct time_interval   time_charge_limit 
data_miss_tolrance = 1.5;  %# 时间间隔超过标准值的1.5倍，认为是丢失
c_miss_num_limit = 30; % # 充电时候丢失数据点的极限
flag_C_begin_threshold = 3; % # 几个连续点说明开始充电了
flag_C_end_threshold = 3;  %# 几个连续点说明结束充电了
bus_current=data_struct.bus_current;


%%
%提取充放电循环的相关标志位。vehicle_mode=2；running_mode=1；为恒流充电。同时再用电流为负并且不间断去判断

vehicle_mode=data_struct.vehicle_mode;
running_mode=data_struct.running_mode;
bus_current=data_struct.bus_current;
soc=data_struct.soc;
charge_mode=data_struct.charge_mode;
time_stamp=data_struct.time_stamp;
terminal_time=data_struct.terminal_time;
%bus_voltage用单体的电压求和，得出来的很平滑。
bus_voltage=zeros(size(data_struct.cell_voltage,1),1);
for i =1:size(data_struct.cell_voltage,1)
    bus_voltage(i)=sum(data_struct.cell_voltage(i,:));
end
%%
%挨着索引，把可能是恒流充电的片段索引拿出来。后面进一步判断的时候再删除。
cycles_index=[];%存成一个结构体，后面的cell串联即可
index_this_cycle=[];%检测到的这个循环的index记录
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
    %# 发现开始充电了：三次出现充电的特征
    if flag_C_begin < flag_C_begin_threshold && charge_mode(i)==1 &&vehicle_mode(i)==2&&running_mode(i)==1 && bus_current(i)<0
        flag_C_begin =flag_C_begin+ 1;
        if flag_C_begin >= flag_C_begin_threshold
            begin_index = i -2;
        end
    end
    
    % # 在充电持续记录的时候，出现了不是充电的特征三次
    if flag_C_begin >=flag_C_begin_threshold && ( charge_mode(i)~=1 ||  bus_current(i)>0)
        if i > last_record_index+ 1%#如果判断出来满足条件的不是相连的，不能把两个隔很久的作为判断条件
            flag_C_end = 0;last_record_index=i;%fprintf('中途出现错误数据或充电中断');
        else
            flag_C_end =flag_C_end+ 1;last_record_index = i;
        end
        if flag_C_end >= flag_C_end_threshold
            end_index = i - 3;
            last_record_index=inf;
            flag_C_end = 0;
            flag_C_begin = 0;
            data_miss = missDataRecord(begin_index, soc(begin_index:end_index),bus_voltage(begin_index:end_index), time_stamp(begin_index:end_index));
            
            %# 进行数据质量的判断。
            if data_miss.num_miss> c_miss_num_limit || end_index-begin_index<time_charge_limit/time_interval
                % # print("丢失过多，舍弃")
                continue
            else
                cycle_C_index.cycle_index = [begin_index, end_index];
                cycle_C_index.num_miss=  data_miss.num_miss;
                cycle_C_index.miss_place=  data_miss.miss_place;
                %                 sum_C_miss = sum_C_miss + data_miss.num_miss;%总共丢失了多少。
                cycles_index=[cycles_index;cycle_C_index];
            end
            
        end
    end
end

end

%%
%记录下来那些丢失数据的地方【重复删除应该在最开始就弄了，这里不管】
function data_miss=missDataRecord(begin_index, soc, voltage, time)
data_miss = {};
miss_num_this_cycle = 0;
miss_place = {};
global data_miss_tolrance time_interval
for i =1: length(soc)-1
    if soc(i)== 0 || voltage(i) == 0 || time(i+1)-time(i)>data_miss_tolrance*time_interval
         num_miss = max(1,ceil(( time(i+1)-time(i)) / time_interval)) ; %# 实际的时间差值，减去理应有的10，再除以10，是那些被丢了的
        miss_num_this_cycle = miss_num_this_cycle + num_miss;
        miss_place.(['Index_',int2str(i + begin_index-1)]) =num_miss;
        
    end
    data_miss.num_miss = miss_num_this_cycle;
    data_miss.miss_place = miss_place;
end

end