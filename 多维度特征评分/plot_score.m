 %%
%%作图
%累计评分
h_fig1= figure(1);
ax1=gca(h_fig1);
legend_cell={};
score_sum=zeros(1,19);
for i =1:size(ratio_matrix,2)
    score_sum(i)=sum(ratio_matrix(:,i))
     legend_cell=[legend_cell;num2str(i)]; 
end
h_fig1=plot(score_sum,'-ro','linewidth',1.5)
xlabel('模组编号','FontSize',14,'FontName','宋体')
ylabel('累计评分','FontSize',14,'FontName','宋体')

%%
%所有的综合评分
h_fig2= figure(2); 
ax2=gca(h_fig2);
% set(h_fig2,'Visible','off');
legend_cell={};
for i =1:size(ratio_matrix,2)
    h_fig2(i)=plot(ratio_matrix(:,i),'linewidth',1.2);
     legend_cell=[legend_cell;num2str(i)];
    hold on 
end

maker_idx = 1:3:30;
 interest = [1 2 3 4 5 6 7 8 9 10 11 14]; %需要改变线型的模组
 markers= {'o';'*';'+';'.';'x';'s';'d';'^';'v';'>';'p';'h'}; %指定标记
  set(h_fig2(interest),{'Marker'},markers,'MarkerIndices',maker_idx);
  
 iLine0 = {'-.';'--';'--';':';'-.';'--';'--'}; %指定线型
 interest0=[13 14 15 16 17 18 19];
 markers= {'o';'*';'+';'.';'x';'s';'d'};
 set(h_fig2(interest0),{'LineStyle'},iLine0);
 set(h_fig2(interest0),{'Marker'},markers,'MarkerIndices',maker_idx);
 set(gca,'FontName','Times New Roman','FontSize',14)
legend(ax2,legend_cell,'FontSize',14);
columnlegend(6, legend_cell);
xlim([0 28])

xlabel('循环数','FontSize',14,'FontName','宋体')
ylabel('综合评分','FontSize',14,'FontName','宋体')
ylim([0,102])
%%
%综合评分，用3D图画
h_fig4= figure(1);
ax4=gca(h_fig4);
labels=[];legend_cell={};
for j =1:19
    if j==2
    h_fig4(j)=plot3(ones(size(ratio_matrix,1),1)* j ,1:size(ratio_matrix,1),  ratio_matrix(:,j),'lineWidth',1.8);
    else
        h_fig4(j)=plot3(ones(size(ratio_matrix,1),1)* j ,1:size(ratio_matrix,1),  ratio_matrix(:,j),'lineWidth',1.2);
    end
    legend_cell=[legend_cell;num2str(j)];
    hold on
end
maker_idx = 1:3:30;
 interest = [1 2 3 4 5 6 7 8 9 10 11 14]; %需要改变线型的模组
 markers= {'o';'*';'+';'.';'x';'s';'d';'^';'v';'>';'p';'h'}; %指定标记
  set(h_fig4(interest),{'Marker'},markers,'MarkerIndices',maker_idx);
  
 iLine0 = {'-.';'--';'--';':';'-.';'--';'--'}; %指定线型
 interest0=[13 14 15 16 17 18 19];
 markers= {'o';'*';'+';'.';'x';'s';'d'};
 set(h_fig4(interest0),{'LineStyle'},iLine0);
 set(h_fig4(interest0),{'Marker'},markers,'MarkerIndices',maker_idx);
 set(gca,'FontName','Times New Roman','FontSize',14)
legend(ax4,legend_cell,'FontSize',12);
ylim([0 28])
zlim([0,102])
ylabel('循环数','FontSize',14,'FontName','宋体')
zlabel('综合评分','FontSize',14,'FontName','宋体')

box on
%%
%某天的评分
h_fig3= figure(1);
ax3=gca(h_fig3);
legend_cell={};


h_fig3=plot(ratio_matrix(27,:),'-ro','linewidth',1.5);
xlabel('模组编号','FontSize',14,'FontName','宋体')
ylabel('综合评分','FontSize',14,'FontName','宋体')
