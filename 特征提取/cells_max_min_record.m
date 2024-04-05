%对每个单体出现整簇极值的次数进行了统计，方便对单体故障进一步定位
clear;clc

%%
%哪些日子
date_days={};
for i=8:8
    date_days=[date_days,['07',num2str(i,'%02d')]];
end
for i=1:27 
    date_days=[date_days,['08',num2str(i,'%02d')]];
end
case_name='Cabin_3_A_Case_06';
%%
global skip_index num_data_points if_sampEn
if_sampEn=0;%%不一致性要不要用样本熵来算，1是用，用的话非常慢---已得到证实，就是用熵更好
for days =1:length(date_days)
this_day=char(date_days(days))
load(['C:\怀柔数据\3_A舱6簇\seconddata2019',this_day,case_name,'.mat'])
%%
%定义提取数据的模式
still_or_run=1;%0只要静止的，1只要运行的，其他是全要
[ still_index ] = still_index_get( data.I,data.max_min_position.VolMin.value );%找出静止的index
num_data_points=length(data.I);
skip_index=[];
switch still_or_run
    case 1
        skip_index=still_index;%那就跳过静止的
    case 0
        skip_index= setdiff((1:1:length(data.I)),still_index);%跳过运行的
end



load(['C:\贾俊资料\电池_数据与健康\MIT的剩余寿命预测\MIT\怀柔\huairou_d_deltaQ_temp\vol_tem_features_huairou\Cabin_3_A_Case_06\',this_day,'_',case_name,'_','case_tem_feature_data.mat'])
%各个模组里面的最大温度、最小温度和温差，按照mods的struct来存。单个模组内，温差的极限位置记录
mods_max_data=case_tem_feature_data.maxmin.mods_max_data;
mods_min_data=case_tem_feature_data.maxmin.mods_min_data;
%整个簇的最大温度、最小温度，以及每个模组内出现过极值的记录
[case_max_value,~]=max_min_inside_mod(mods_max_data);%最大值里面的最大值肯定是整个簇的最大值
[~,case_min_value]=max_min_inside_mod(mods_min_data);%最小值里面的最大值肯定是整个簇的最小值
[ case_maxmin_position_count ] = case_max_min_reocrd( data.Tem_mods,case_max_value,case_min_value );
case_tem_feature_data.maxmin.case_maxmin_position_count=case_maxmin_position_count;
save([this_day,'_',case_name,'_','case_tem_feature_data.mat'],'case_tem_feature_data','-v7.3')

load(['C:\贾俊资料\电池_数据与健康\MIT的剩余寿命预测\MIT\怀柔\huairou_d_deltaQ_temp\vol_tem_features_huairou\Cabin_3_A_Case_06\',this_day,'_',case_name,'_','case_vol_feature_data.mat'])
%电压相关的特征提取
%电压的，先做成struct形式。之前是存的全部单体，没有按模组来存
num_target_objects=12;
target_field1_str='Mod';
target_field2_str='V';
[ Vol_mods_struct ] = object_to_struct(data.Vol_cells,num_target_objects,target_field1_str,target_field2_str);
%对簇里面的所有模组，分别找这个模组出现过多少次极值，可以用刚那个函数，得到的结果求和
case_max_value=data.max_min_position.VolMax.value;
case_min_value=data.max_min_position.VolMin.value;
index_to_use=setdiff((1:1:num_data_points),skip_index);
[ case_maxmin_position_count ] = case_max_min_reocrd( Vol_mods_struct,case_max_value(index_to_use),case_min_value(index_to_use) );
case_vol_feature_data.maxmin.case_maxmin_position_count=case_maxmin_position_count;
save([this_day,'_',case_name,'_','case_vol_feature_data.mat'],'case_vol_feature_data','-v7.3')
end

