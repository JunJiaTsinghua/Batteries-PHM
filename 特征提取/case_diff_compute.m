function [ mods_maxmin_position_count,mods_max_data, mods_min_data,mods_diff_data, max_diff_value,min_diff_value] =case_diff_compute(case_struct)
%CASE_DIFF_COMPUTE �����ṹ��ļ�ֵ�������Ǵز㼶
%   �˴���ʾ��ϸ˵��
fields=fieldnames(case_struct); 
mods_diff_data={};
mods_max_data={};
mods_min_data={};
mods_maxmin_position_count={};
global skip_index num_data_points
index_to_use=setdiff((1:1:num_data_points),skip_index);
for i =1:length(fields)
    %����ģ���ڣ��Լ��ļ�ֵ����¼
    this_mod=char(fields(i));
    this_mod_data=case_struct.(this_mod);
    [mod_max_value,mod_min_value]=max_min_inside_mod(this_mod_data);%����ƺ�û��Ҫ����
     [ max_min_num_record ] = mod_max_min_reocrd( this_mod_data,mod_max_value(index_to_use),mod_min_value(index_to_use));%�����ÿ��ģ������ļ�ֵͳ������
    mods_maxmin_position_count.(this_mod)=max_min_num_record;
    diff_value=mod_max_value-mod_min_value;
    mods_diff_data.(this_mod)=diff_value(index_to_use);
    mods_max_data.(this_mod)=mod_max_value(index_to_use);
    mods_min_data.(this_mod)=mod_min_value(index_to_use);
end
 [max_diff_value,min_diff_value]=max_min_inside_mod(mods_diff_data);
end

