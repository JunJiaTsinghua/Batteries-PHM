function [ maxmin_position_count_record ] = case_max_min_reocrd( mods_struct,max_data,min_data )
%max_min_position_count 对簇里面的模组分别看它出现过多少次极值
%   此处显示详细说明
mod_fields=fieldnames(mods_struct);
maxmin_position_count_record={};
n_objects_one_mod=length(fieldnames(mods_struct.Mod1));
max_cells=zeros(1,length(mod_fields)*n_objects_one_mod);
min_cells=zeros(1,length(mod_fields)*n_objects_one_mod);
% max_data_to_use=max_data(index_to_use);
% min_data_to_use=min_data(index_to_use);
max_records=zeros(1,length(mod_fields)); 
   min_records=zeros(1,length(mod_fields));
for i=1:length(mod_fields)
    this_mod_field=char(mod_fields(i));
    %直接调用对单个模组的查找方法，返回各个单体的累计次数
    this_mod_data= mods_struct.(this_mod_field);
  [ max_min_num_record ] = mod_max_min_reocrd(this_mod_data,max_data,min_data );
  %对其结果求和
  
    max_sum=sum(max_min_num_record.max_record);
    min_sum=sum(max_min_num_record.min_record);
    
max_records(i)=max_sum;
min_records(i)=min_sum;
 max_cells(((i-1)*n_objects_one_mod+1):(i*n_objects_one_mod))=max_min_num_record.max_record;
min_cells(((i-1)*n_objects_one_mod+1):(i*n_objects_one_mod))=max_min_num_record.min_record;
end
maxmin_position_count_record.max_record=max_records;
  maxmin_position_count_record.min_record=min_records;
maxmin_position_count_record.min_cells=min_cells;
maxmin_position_count_record.max_cells=max_cells;
end

