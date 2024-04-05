%哪些单体（探针）最容易出现最大值、最小值
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
data_type='vol';
feature_type='min';
if_draw=1;
pic_num = 0;
max_cell_this_feature=[];dates={};ratio_matrix=[];
for days =1:length(date_days)
this_day=char(date_days(days))
data=importdata(['D:\程序\电池_数据与健康\MIT的剩余寿命预测\MIT\怀柔\huairou_d_deltaQ_temp\vol_tem_features_huairou\cells_3_A_06\',this_day,'_',case_name,'_','case_',data_type,'_feature_data.mat']);
field_str=[feature_type,'_cells'];
min_cells=data.maxmin.case_maxmin_position_count.(field_str);

[m,index]=max(min_cells);
max_cell_this_feature=[max_cell_this_feature;index];
dates=[dates;this_day];
pic_num=pic_num+1;
if if_draw==1
    draw_gif(pic_num,max_cell_this_feature,case_name);
end
%画静态变化图
a=tabulate(max_cell_this_feature);
ratio_matrix(pic_num,1:230)=0;
for i =1:size(a,1)
    ratio_matrix(pic_num,i)=a(i,3);       
end

end
if if_draw==1
    h_fig2= figure(2);
    % set(h_fig2,'Visible','off');
    ax2=gca(h_fig2);
    for i =1:size(ratio_matrix,2)
        figure(h_fig2)
        plot(ratio_matrix(:,i))

        hold on 
    end

    xlabel('计算次数')
    ylabel('模组方差最大的概率')
    saveas(h_fig2,[case_name,'10.fig'])
end
max_cell_this_feature