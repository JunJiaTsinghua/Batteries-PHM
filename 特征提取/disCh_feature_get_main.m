clear;clc
load('cell_1_4_5_10_100.mat')
cycles_to_compute=[1,4,5,10,100];
%%
%一些想画图验证一下的特征
end_life_list=[];
diff_Q_100_10=[];
var_100_10_list=[];
diff_Q_5_4=[];
var_5_4_list=[];
life_Per5_list=[];
Vdlin=cells(1).Vdlin;
 
%%
%挨个电池提取各种特征

for i=1:length(cells)
    fprintf(['正在计算第',int2str(i),'个电池','\n'])
    features(i).life=cells(i).life;
     %%
    %%%%%%%美化过程
    flag=0;
    diff=cells(i).Qdlin100-cells(i).Qdlin10;
    %是否有跳变
        for j=1:length(diff)-1
            if abs(diff(i+1)-diff(i))>0.06
                flag=1;
            end
        end
        
%       有的话就不要这个循环
    if  min(diff)<-0.1354 || flag==1
        continue
    end
    if   cells(i).life<200%按照原文所述，最短命的是要被去掉的
        continue
    end
    %%%%美化过程
    %%
    %100-10的方差
    diff_10_100=cells(i).Qdlin100-cells(i).Qdlin10;
    features(i).min_diffQ_10_100=min(diff_10_100);
    var_10_100=variance(diff_10_100);
  
    features(i).var_10_100=var_10_100;
    %5-4的方差
    diff_4_5=cells(i).Qdlin5-cells(i).Qdlin4;
    var_4_5=variance(diff_4_5);
    features(i).var_4_5=var_4_5;
    %5-1的方差
     diff_1_5=cells(i).Qdlin5-cells(i).Qdlin1;
    var_1_5=variance(diff_1_5);
    features(i).var_1_5=var_1_5;
    %%
    %100-10的kurtosis【峰度，反映峰部的尖度。集中在最大值附近的程度】
    kur_10_100=kurtosis(diff_10_100);
    features(i).kur_10_100=kur_10_100;
    %100-10的skewness【偏度，反映远离正态分布的程度，数据是否集中在某一边，不对称】
    skew_10_100=skewness(diff_10_100);
    features(i).skew_10_100=skew_10_100;
    %100-10的均值
      mean_10_100=mean(diff_10_100);
    features(i).mean_10_100=mean_10_100;
    %%
    %各个循环放电IC曲线的峰值和峰位置
    for j =cycles_to_compute
        field_to_read=strcat('discharge_dQdV',int2str(j));
        [ica_peak_value,index]=min(cells(i).(field_to_read)(1:800));%有的IC曲线后面半截有误差
        ica_peak_voltage=cells(i).Vdlin(index);
        peak_to_save_str=strcat('ica_peak_value_',int2str(j));
         ica_data.(peak_to_save_str)=ica_peak_value;
         peakVoltage_to_save_str=strcat('ica_peak_voltage_',int2str(j));
         ica_data.(peakVoltage_to_save_str)=ica_peak_voltage;
    end
     features(i).ica_features=ica_data;
    clear ica_data ;
    %%
    %各个循环时，温度的最大值、平均值、最小值，在summary都有，把第一个为0的剔除就行
    for j =cycles_to_compute
        %各个循环时候，温度的积分
        field_to_read=strcat('Tdlin',int2str(j));
        T_list=cells(i).(field_to_read);
        T_sum=sum(T_list);
        Tsum_to_save_str=strcat('T_Sum_',int2str(j));
        T_data.(Tsum_to_save_str)=T_sum;
        %最大、平均值
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

          %第2个循环的容量，其实是这里记录的第1个.！！！【这里纠错，不能去找Qdlin里面的最后一个数，那是按电压范围截断了的】
         if cap_list(1)==0
            cap_cycle2=cap_list(2);
         else
             cap_cycle2=cap_list(1);
         end
         features(i).cap_cycle2=cap_cycle2;
         features(i).cap_diff_2_100=cap_list(100)-cap_cycle2;
         %第2个循环容量和最大容量的差值
    %【和上面不一定相关，因为最大值一般不会是1.1Ah。这个实验的最大值出现在运行一段时间后，不会是1.1Ah】
    %注意数据如果有错误（比1.1还大），要去求第二大
        [cap_max,index]=max(cap_list);
        if cap_max<1.1
            cap_max_real=cap_max;
        else
            cap_list(index)=cap_list(index-1);%不能置为0，会影响后面的工作
             cap_max_real=max(cap_list);
        end
        features(i).cap_max_real=cap_max_real;
         features(i).cap_diff_2_max=cap_max_real-cap_cycle2;
         %%
         %衰减到95%时候的循环数。summary里面的放电;相对值是针对放电实际里面的最大值；绝对值是针对1.1Ah
         %部分的cpa_list是波动的，做一些前处理【smooth就省了。会引入额外误差。主要是把跳变给搞掉】
         for k =1:length(cap_list)-1
          if (cap_list(k+1)-cap_list(k))/cap_list(k) < inf && abs((cap_list(k+1)-cap_list(k))/cap_list(k))>0.01
                 cap_list(k+1)=cap_list(k);
          end
         end
         %找绝对衰减对应的循环
         for k =1:length(cap_list)-1
             if cap_list(k+1)<1.1*0.95 && cap_list(k)>=1.1*0.95
                 cycle_life_Per95_absolute=k;
                 break
             end
         end
         %找相对衰减对应的循环
        for k =1:length(cap_list)-1
             if cap_list(k+1)<cap_max_real*0.95 && cap_list(k)>=cap_max_real*0.95
                 cycle_life_Per95_relative=k;
                 break
             end
         end
         features(i).cycle_life_Per95_absolute=cycle_life_Per95_absolute;
         features(i).cycle_life_Per95_relative=cycle_life_Per95_relative;
%%
%   %调试用
%     if i==3
%         break
%     end
    
end

save('feature.mat','features','-v7.3')