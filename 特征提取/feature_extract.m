%% 计算特征--真实的特征
% bat_files={'C1DOD70_2','C1DOD70_1','C1DOD30_2','C1DOD30_1','C1.5DOD70_2','C1.5DOD70_1','C1.2DOD70_2','C1.2DOD70_1'};
bat_files={'C1DOD30_1'};
features={};
for bat =1:length(bat_files)
ALL_data=importdata([char(bat_files(bat)),'.mat']);
features(bat).battery=char(bat_files(bat));
%% 读取每个定容工况文件，确定每次定容的真实值
files_all=fieldnames(ALL_data);
SOH_Ah=[];
Q_total=[];
Q=0;
effiency=[];
ICA_data={};
V_80SOC0=0;
HPPC_80SOC={};
for i =1:length(files_all)
    
    %% 统计每个文件的Ah吞吐量。算SOH，算能量效率。
    Q_datas=ALL_data(3).(char(files_all(i)));
    Q=Q+sum(Q_datas);
    if contains(char(files_all(i)), '120C')   
        SOH_Ah=[SOH_Ah,Q_datas(end)];
        Q_total=[Q_total,Q];
        Wh_datas=ALL_data(4).(char(files_all(i)));
        effiency=[effiency,Wh_datas(end)/Wh_datas(end-1)];
    end
    
    
    %% 把ICA拉出来
    if contains(char(files_all(i)), '120C') 
        I_ICA=ALL_data(1).(char(files_all(i)));
        V_ICA=ALL_data(2).(char(files_all(i)));
        diff_ICA=I_ICA(2:end)-I_ICA(1:end-1);
        index_start=find(diff_ICA<-4 & diff_ICA>-10);
        ICA_data(length(ICA_data)+1).V= V_ICA(index_start:end);
        dV=0.002;
        [dV_list,dQdV]=function_ICA_compute(I_ICA(index_start:end),V_ICA(index_start:end),dV);
        ICA_data(length(ICA_data)).dQdV=dQdV;
        ICA_data(length(ICA_data)).dV_list=dV_list;
        dV=0.01;
        [dV_list1,dQdV1]=function_ICA_compute(I_ICA(index_start:end),V_ICA(index_start:end),dV);
        ICA_data(length(ICA_data)).dQdV1=dQdV1;
        ICA_data(length(ICA_data)).dV_list1=dV_list1;

    end
    
    %% 把HPPC拉出来,先只看80SOC的
    if contains(char(files_all(i)), '80SOC') 
        V_80SOC=ALL_data(2).(char(files_all(i)));
        if V_80SOC0==0 % 好像实验不是用V来标定SOC的，导致后面会挪位。需要给他们对其
            V_80SOC0=V_80SOC;
        else
            V_80SOC=V_80SOC-(V_80SOC(1)-V_80SOC0(1));
            
        end
        I_80SOC=ALL_data(1).(char(files_all(i)));
        HPPC_80SOC(length(HPPC_80SOC)+1).I_80SOC= I_80SOC;
        HPPC_80SOC(length(HPPC_80SOC)).V_80SOC= V_80SOC;
%         x=1:length(I_80SOC);
%         plot(x,I_80SOC)
    end
    %也看看20SOC
    if contains(char(files_all(i)), '20SOC') 
        V_20SOC=ALL_data(2).(char(files_all(i)));
        if V_20SOC0==0 % 好像实验不是用V来标定SOC的，导致后面会挪位。需要给他们对其
            V_20SOC0=V_20SOC;
        else
            V_20SOC=V_20SOC-(V_20SOC(1)-V_20SOC0(1));
            
        end
        I_20SOC=ALL_data(1).(char(files_all(i)));
        HPPC_20SOC(length(HPPC_20SOC)+1).I_20SOC= I_20SOC;
        HPPC_20SOC(length(HPPC_20SOC)).V_20SOC= V_20SOC;
%         x=1:length(I_80SOC);
%         plot(x,I_80SOC)
    end
end


  %%  存起来
  features(bat).Q_total=Q_total;
  features(bat).SOH_Ah=SOH_Ah;
  features(bat).effiency=effiency;
  features(bat).ICA_data=ICA_data;
  features(bat).HPPC_80SOC=HPPC_80SOC;
  features(bat).HPPC_20SOC=HPPC_20SOC;
  SOH=SOH_Ah/SOH_Ah(1);
  features(bat).SOH=SOH;


end
save('features.mat','features')