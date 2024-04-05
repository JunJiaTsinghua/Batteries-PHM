%��ÿ������������ؼ�ֵ�Ĵ���������ͳ�ƣ�����Ե�����Ͻ�һ����λ
clear;clc

%%
%��Щ����
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
if_sampEn=0;%%��һ����Ҫ��Ҫ�����������㣬1���ã��õĻ��ǳ���---�ѵõ�֤ʵ���������ظ���
for days =1:length(date_days)
this_day=char(date_days(days))
load(['C:\��������\3_A��6��\seconddata2019',this_day,case_name,'.mat'])
%%
%������ȡ���ݵ�ģʽ
still_or_run=1;%0ֻҪ��ֹ�ģ�1ֻҪ���еģ�������ȫҪ
[ still_index ] = still_index_get( data.I,data.max_min_position.VolMin.value );%�ҳ���ֹ��index
num_data_points=length(data.I);
skip_index=[];
switch still_or_run
    case 1
        skip_index=still_index;%�Ǿ�������ֹ��
    case 0
        skip_index= setdiff((1:1:length(data.I)),still_index);%�������е�
end



load(['C:\�ֿ�����\���_�����뽡��\MIT��ʣ������Ԥ��\MIT\����\huairou_d_deltaQ_temp\vol_tem_features_huairou\Cabin_3_A_Case_06\',this_day,'_',case_name,'_','case_tem_feature_data.mat'])
%����ģ�����������¶ȡ���С�¶Ⱥ��²����mods��struct���档����ģ���ڣ��²�ļ���λ�ü�¼
mods_max_data=case_tem_feature_data.maxmin.mods_max_data;
mods_min_data=case_tem_feature_data.maxmin.mods_min_data;
%�����ص�����¶ȡ���С�¶ȣ��Լ�ÿ��ģ���ڳ��ֹ���ֵ�ļ�¼
[case_max_value,~]=max_min_inside_mod(mods_max_data);%���ֵ��������ֵ�϶��������ص����ֵ
[~,case_min_value]=max_min_inside_mod(mods_min_data);%��Сֵ��������ֵ�϶��������ص���Сֵ
[ case_maxmin_position_count ] = case_max_min_reocrd( data.Tem_mods,case_max_value,case_min_value );
case_tem_feature_data.maxmin.case_maxmin_position_count=case_maxmin_position_count;
save([this_day,'_',case_name,'_','case_tem_feature_data.mat'],'case_tem_feature_data','-v7.3')

load(['C:\�ֿ�����\���_�����뽡��\MIT��ʣ������Ԥ��\MIT\����\huairou_d_deltaQ_temp\vol_tem_features_huairou\Cabin_3_A_Case_06\',this_day,'_',case_name,'_','case_vol_feature_data.mat'])
%��ѹ��ص�������ȡ
%��ѹ�ģ�������struct��ʽ��֮ǰ�Ǵ��ȫ�����壬û�а�ģ������
num_target_objects=12;
target_field1_str='Mod';
target_field2_str='V';
[ Vol_mods_struct ] = object_to_struct(data.Vol_cells,num_target_objects,target_field1_str,target_field2_str);
%�Դ����������ģ�飬�ֱ������ģ����ֹ����ٴμ�ֵ�������ø��Ǹ��������õ��Ľ�����
case_max_value=data.max_min_position.VolMax.value;
case_min_value=data.max_min_position.VolMin.value;
index_to_use=setdiff((1:1:num_data_points),skip_index);
[ case_maxmin_position_count ] = case_max_min_reocrd( Vol_mods_struct,case_max_value(index_to_use),case_min_value(index_to_use) );
case_vol_feature_data.maxmin.case_maxmin_position_count=case_maxmin_position_count;
save([this_day,'_',case_name,'_','case_vol_feature_data.mat'],'case_vol_feature_data','-v7.3')
end

