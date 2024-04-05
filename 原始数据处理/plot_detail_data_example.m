%% 找两颗数据质量不错的，出图用到报告里面去。
ALL_data=importdata('C1DOD30_1.mat');
%% 取数据
files_all=fieldnames(ALL_data);
I_data_all=[];
V_data_all=[];
for i =1:length(files_all)
    I_data_all=[I_data_all;ALL_data(1).(char(files_all(i)))];
    V_data_all=[V_data_all;ALL_data(2).(char(files_all(i)))];
end
I_data_all(1920454:2016807)=[];
V_data_all(1920454:2016807)=[];
I_data_all(1:522552)=[];
V_data_all(1:522552)=[];
%% 画图，整体图
range1=1397908:2935579; %这个是取中间那段好看的
figure('Position', [500, 0, 500, 400]) %所有电流
plot(I_data_all(range1))
set(gca,'FontName','Times New Roman','FontSize',14)
% xlabel('\fontname{宋体}时间\fontname{times new roman}(s)','FontSize',15)
% ylabel('\fontname{宋体}电流\fontname{times new roman}(A)','FontSize',15')
xlabel('Time(s)','FontSize',15)
ylabel('Current(A)','FontSize',15')
grid on
saveas(gcf, '某电池多个循环的电流图.tif');

figure('Position', [1000, 0, 500, 400]) %所有电压
plot(V_data_all(range1))
set(gca,'FontName','Times New Roman','FontSize',14)
% xlabel('\fontname{宋体}时间\fontname{times new roman}(s)','FontSize',15)
% ylabel('\fontname{宋体}电压\fontname{times new roman}(V)','FontSize',15')
xlabel('Time(s)','FontSize',15)
ylabel('Voltage(V)','FontSize',15')
ylim([2.65 4.25])
grid on
saveas(gcf, '某电池多个循环的电压图.tif');
%% 局部图
I_data=I_data_all(range1);
V_data=V_data_all(range1);
range2=1:445633; %然后又再取这一段里面的第一次工况
figure('Position', [0, 0, 800, 600])
grid on
subplot(2,1,1)
plot(I_data(range2))
set(gca,'FontName','Times New Roman','FontSize',14)

% ylabel('\fontname{宋体}电流\fontname{times new roman}(A)','FontSize',15')
ylabel('Current(A)','FontSize',15')
xlim([1 4.5*10^5])
ylim([-105 105])
set(gca,'xtick','','xticklabel','')
breakxaxis([2*10^5 4*10^5])

grid on
subplot(2,1,2)
plot(V_data(range2))
set(gca,'FontName','Times New Roman','FontSize',14)
% xlabel('\fontname{宋体}时间\fontname{times new roman}(s)','FontSize',15)
% ylabel('\fontname{宋体}电压\fontname{times new roman}(V)','FontSize',15')
xlabel('Time(s)','FontSize',15)
ylabel('Voltage(V)','FontSize',15')
xlim([1 4.5*10^5])
ylim([2.65 4.25])
breakxaxis([2*10^5 4*10^5])

saveas(gcf, '某电池局部的电压图.tif');
%% 子工况
figure('Position', [0, 0, 800, 600])

subplot(2,3,1) %定容的工况
plot(V_data(1:16693))
set(gca,'FontName','Times New Roman','FontSize',14)
% ylabel('\fontname{宋体}电压\fontname{times new roman}(V)','FontSize',15')
ylabel('Voltage(V)','FontSize',15')
ylim([2.65 4.25])
grid on

subplot(2,3,2) %ICA的工况
plot(V_data(45044:120913))
set(gca,'FontName','Times New Roman','FontSize',14)
ylim([2.65 4.25])
grid on
subplot(2,3,3) % DST的工况
plot(V_data(120954:132419))
set(gca,'FontName','Times New Roman','FontSize',14)
ylim([3.2 4.25])
grid on
subplot(2,3,4) % FUDS的工况
plot(V_data(149998:161196))
set(gca,'FontName','Times New Roman','FontSize',14)
% xlabel('\fontname{宋体}时间\fontname{times new roman}(s)','FontSize',15)
% ylabel('\fontname{宋体}电压\fontname{times new roman}(V)','FontSize',15')
xlabel('Time(s)','FontSize',15)
ylabel('Voltage(V)','FontSize',15')
ylim([3.25 4.25])
grid on
subplot(2,3,5) % HPPC的工况
plot(V_data(175663:176991))
set(gca,'FontName','Times New Roman','FontSize',14)
xlabel('Time(s)','FontSize',15)
ylim([3.25 4.25])
grid on
subplot(2,3,6) % 循环的工况
plot(V_data(179733:185336))
set(gca,'FontName','Times New Roman','FontSize',14)
xlabel('Time(s)','FontSize',15)
ylim([3.2 4.25])

grid on

%% 另一个电池
ALL_data1=importdata('C1.2DOD70_1.mat');
files_all=fieldnames(ALL_data1);
I_data_all1=[];
V_data_all1=[];
for i =1:length(files_all)
    I_data_all1=[I_data_all1;ALL_data1(1).(char(files_all(i)))];
    V_data_all1=[V_data_all1;ALL_data1(2).(char(files_all(i)))];
end
%%
figure('Position', [0, 0, 800, 600])

subplot(2,3,1) %定容的工况

plot(V_data(1:16693))
hold on 
plot(V_data_all1(1451492:1469529))
set(gca,'FontName','Times New Roman','FontSize',14)
% ylabel('\fontname{宋体}电压\fontname{times new roman}(V)','FontSize',15')
ylabel('Voltage(V)','FontSize',15')
title('a')
legend({'NO.1','NO.13'})
ylim([2.65 4.25])
grid on
box on

subplot(2,3,2) %ICA的工况

plot(V_data(45044:120913))
hold on 
plot(V_data_all1(1500314:1579577))
set(gca,'FontName','Times New Roman','FontSize',14)
ylim([2.65 4.25])
grid on
title('b')
subplot(2,3,3) % DST的工况

plot(V_data(120954:132419))
hold on 
plot(V_data_all1(1579607:1591085))
set(gca,'FontName','Times New Roman','FontSize',14)
ylim([3.2 4.25])
grid on
title('c')
subplot(2,3,4) % FUDS的工况

plot(V_data(150208:161176))
hold on 
plot(V_data_all1(1608947:1619903))
set(gca,'FontName','Times New Roman','FontSize',14)
% xlabel('\fontname{宋体}时间\fontname{times new roman}(s)','FontSize',15)
% ylabel('\fontname{宋体}电压\fontname{times new roman}(V)','FontSize',15')
xlabel('Time(s)','FontSize',15)
ylabel('Voltage(V)','FontSize',15')
ylim([3.25 4.25])
grid on
title('d')
subplot(2,3,5) % HPPC的工况

plot(V_data(175663:176991))
hold on
plot(V_data_all1(1636197:1637550))
set(gca,'FontName','Times New Roman','FontSize',14)
xlabel('Time(s)','FontSize',15)
ylim([3.25 4.25])
grid on
title('e')
subplot(2,3,6) % 循环的工况

plot(V_data(179733:185336))
hold on 
plot(V_data_all1(3089174:3099679))
set(gca,'FontName','Times New Roman','FontSize',14)
xlabel('Time(s)','FontSize',15)
ylim([3.2 4.25])
title('f')
grid on


