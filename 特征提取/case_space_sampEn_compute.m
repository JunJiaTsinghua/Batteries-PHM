function [mods_space_sampEn,max_sampEn_data,min_sampEn_data]=case_space_sampEn_compute(mods_struct)
%��ռ������ء������¶ȵ���ͬһʱ���ڿռ��ϵĲ�һ��
mod_fields=fieldnames(mods_struct);

mods_space_sampEn={};

for i=1:length(mod_fields)
  disp(['��',num2str(i),'��ģ��']) 
    this_mod_field=char(mod_fields(i));
    
     [ tem_space_sampEn_list ] = space_scale_sampEn( mods_struct.(this_mod_field) );
     mods_space_sampEn.(this_mod_field)=tem_space_sampEn_list;
    
end 
     
   [max_sampEn_data,min_sampEn_data]=max_min_inside_mod(mods_space_sampEn);


end