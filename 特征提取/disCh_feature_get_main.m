clear;clc
load('cell_1_4_5_10_100.mat')
cycles_to_compute=[1,4,5,10,100];
%%
%һЩ�뻭ͼ��֤һ�µ�����
end_life_list=[];
diff_Q_100_10=[];
var_100_10_list=[];
diff_Q_5_4=[];
var_5_4_list=[];
life_Per5_list=[];
Vdlin=cells(1).Vdlin;
 
%%
%���������ȡ��������

for i=1:length(cells)
    fprintf(['���ڼ����',int2str(i),'�����','\n'])
    features(i).life=cells(i).life;
     %%
    %%%%%%%��������
    flag=0;
    diff=cells(i).Qdlin100-cells(i).Qdlin10;
    %�Ƿ�������
        for j=1:length(diff)-1
            if abs(diff(i+1)-diff(i))>0.06
                flag=1;
            end
        end
        
%       �еĻ��Ͳ�Ҫ���ѭ��
    if  min(diff)<-0.1354 || flag==1
        continue
    end
    if   cells(i).life<200%����ԭ�����������������Ҫ��ȥ����
        continue
    end
    %%%%��������
    %%
    %100-10�ķ���
    diff_10_100=cells(i).Qdlin100-cells(i).Qdlin10;
    features(i).min_diffQ_10_100=min(diff_10_100);
    var_10_100=variance(diff_10_100);
  
    features(i).var_10_100=var_10_100;
    %5-4�ķ���
    diff_4_5=cells(i).Qdlin5-cells(i).Qdlin4;
    var_4_5=variance(diff_4_5);
    features(i).var_4_5=var_4_5;
    %5-1�ķ���
     diff_1_5=cells(i).Qdlin5-cells(i).Qdlin1;
    var_1_5=variance(diff_1_5);
    features(i).var_1_5=var_1_5;
    %%
    %100-10��kurtosis����ȣ���ӳ�岿�ļ�ȡ����������ֵ�����ĳ̶ȡ�
    kur_10_100=kurtosis(diff_10_100);
    features(i).kur_10_100=kur_10_100;
    %100-10��skewness��ƫ�ȣ���ӳԶ����̬�ֲ��ĳ̶ȣ������Ƿ�����ĳһ�ߣ����Գơ�
    skew_10_100=skewness(diff_10_100);
    features(i).skew_10_100=skew_10_100;
    %100-10�ľ�ֵ
      mean_10_100=mean(diff_10_100);
    features(i).mean_10_100=mean_10_100;
    %%
    %����ѭ���ŵ�IC���ߵķ�ֵ�ͷ�λ��
    for j =cycles_to_compute
        field_to_read=strcat('discharge_dQdV',int2str(j));
        [ica_peak_value,index]=min(cells(i).(field_to_read)(1:800));%�е�IC���ߺ����������
        ica_peak_voltage=cells(i).Vdlin(index);
        peak_to_save_str=strcat('ica_peak_value_',int2str(j));
         ica_data.(peak_to_save_str)=ica_peak_value;
         peakVoltage_to_save_str=strcat('ica_peak_voltage_',int2str(j));
         ica_data.(peakVoltage_to_save_str)=ica_peak_voltage;
    end
     features(i).ica_features=ica_data;
    clear ica_data ;
    %%
    %����ѭ��ʱ���¶ȵ����ֵ��ƽ��ֵ����Сֵ����summary���У��ѵ�һ��Ϊ0���޳�����
    for j =cycles_to_compute
        %����ѭ��ʱ���¶ȵĻ���
        field_to_read=strcat('Tdlin',int2str(j));
        T_list=cells(i).(field_to_read);
        T_sum=sum(T_list);
        Tsum_to_save_str=strcat('T_Sum_',int2str(j));
        T_data.(Tsum_to_save_str)=T_sum;
        %���ƽ��ֵ
        for k={'Tmax','Tavg'}
            T_list=cells(i).summary.(k{1,1});
            cycle_add_flag=0;
            if T_list(1)==0
                cycle_add_flag=1;
            end
            index=j+cycle_add_flag;
            T_data_to_save=T_list(index);
            Tdata_to_save_str=strcat(k,'_',int2str(j));
            T_data.(Tdata_to_save_str{1,1})=T_data_to_save;
        end
    end
    features(i).T_features=T_data;
  T_data={};
    %%
         cap_list=cells(i).summary.QDischarge;
         cycle_list=cells(i).summary.cycle;

          %��2��ѭ������������ʵ�������¼�ĵ�1��.�������������������ȥ��Qdlin��������һ���������ǰ���ѹ��Χ�ض��˵ġ�
         if cap_list(1)==0
            cap_cycle2=cap_list(2);
         else
             cap_cycle2=cap_list(1);
         end
         features(i).cap_cycle2=cap_cycle2;
         features(i).cap_diff_2_100=cap_list(100)-cap_cycle2;
         %��2��ѭ����������������Ĳ�ֵ
    %�������治һ����أ���Ϊ���ֵһ�㲻����1.1Ah�����ʵ������ֵ����������һ��ʱ��󣬲�����1.1Ah��
    %ע����������д��󣨱�1.1���󣩣�Ҫȥ��ڶ���
        [cap_max,index]=max(cap_list);
        if cap_max<1.1
            cap_max_real=cap_max;
        else
            cap_list(index)=cap_list(index-1);%������Ϊ0����Ӱ�����Ĺ���
             cap_max_real=max(cap_list);
        end
        features(i).cap_max_real=cap_max_real;
         features(i).cap_diff_2_max=cap_max_real-cap_cycle2;
         %%
         %˥����95%ʱ���ѭ������summary����ķŵ�;���ֵ����Էŵ�ʵ����������ֵ������ֵ�����1.1Ah
         %���ֵ�cpa_list�ǲ����ģ���һЩǰ����smooth��ʡ�ˡ��������������Ҫ�ǰ�����������
         for k =1:length(cap_list)-1
          if (cap_list(k+1)-cap_list(k))/cap_list(k) < inf && abs((cap_list(k+1)-cap_list(k))/cap_list(k))>0.01
                 cap_list(k+1)=cap_list(k);
          end
         end
         %�Ҿ���˥����Ӧ��ѭ��
         for k =1:length(cap_list)-1
             if cap_list(k+1)<1.1*0.95 && cap_list(k)>=1.1*0.95
                 cycle_life_Per95_absolute=k;
                 break
             end
         end
         %�����˥����Ӧ��ѭ��
        for k =1:length(cap_list)-1
             if cap_list(k+1)<cap_max_real*0.95 && cap_list(k)>=cap_max_real*0.95
                 cycle_life_Per95_relative=k;
                 break
             end
         end
         features(i).cycle_life_Per95_absolute=cycle_life_Per95_absolute;
         features(i).cycle_life_Per95_relative=cycle_life_Per95_relative;
%%
%   %������
%     if i==3
%         break
%     end
    
end

save('feature.mat','features','-v7.3')