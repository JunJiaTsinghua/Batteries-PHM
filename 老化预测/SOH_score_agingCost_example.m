retire_SOH=0.8;

%% Soh用一号电池。评分假设一个波动剧烈的，方便展示效果。
plot_SOH=importdata('plot_SOH.mat');
SOH_list=plot_SOH(1).SOH_excel;
Score_list=[100 98.5 97.3 99 50 65 100 95.5 96.5 100 100 95 100 100 100 100];
%% 初始成本，单个电池，估一个，集成成本估一个
price_Wh=2.2;
huilv=6;
huishou_ratio=0.5;
price_bat=3.7*50*price_Wh/huilv;
price_bat=price_bat*(1-huishou_ratio);
Remaining_value_list=zeros(1,length(SOH_list));
for i =1:length(SOH_list)
    Remaining_value_list(i)=price_bat*(SOH_list(i)-retire_SOH)/(1-retire_SOH)*Score_list(i)*0.01;
    
end
figure(1)
subplot(411)
plot(SOH_list*100','.-','MarkerSize',11,'lineWidth',1.3)
set(gca,'FontName','Times New Roman','FontSize',14)
ylabel('SOH(%)','FontSize',15')
ylim([0.95*min(SOH_list)*100 1.05*max(SOH_list)*100])
grid on
subplot(412)
plot(Score_list','.-','MarkerSize',11,'lineWidth',1.3)
set(gca,'FontName','Times New Roman','FontSize',14)
ylabel('Score','FontSize',15')
set(gca,'yaxislocation','right');
ylim([0.95*min(Score_list) 1.05*max(Score_list)])
grid on
subplot(413)
plot(Remaining_value_list','.-','MarkerSize',11,'lineWidth',1.3)
set(gca,'FontName','Times New Roman','FontSize',14)
ylabel('Remaining Value ($)','FontSize',15')
ylim([0.95*min(Remaining_value_list) 1.05*max(Remaining_value_list)])
grid on

subplot(414)
aging_cost=Remaining_value_list(2:end)-Remaining_value_list(1:end-1);
aging_cost(aging_cost>0)=0;
aging_cost=[0,abs(aging_cost)];
plot(aging_cost','.-','MarkerSize',11,'lineWidth',1.3)
set(gca,'FontName','Times New Roman','FontSize',14)
ylabel('Aging Cost ($)','FontSize',15')
set(gca,'yaxislocation','right');
ylim([0.95*min(aging_cost) 1.05*max(aging_cost)])
xlabel('Test Number','FontSize',15')
grid on
saveas(gcf, '每两个循环的老化成本示意图.tif');