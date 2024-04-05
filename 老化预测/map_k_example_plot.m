%% 作3D图，各个特征跟C 和 DOD相关的特征变化图


%% Ro相关特征画图
plot_Ro=importdata('plot_Ro.mat');
figure('Position', [200, 200, 800, 600])
grid on
hold on
[feature_k,x,y,z]=feature_k_ratio(plot_Ro,'Ro_excel',1.1*10^-3);
surf(x,y, z);
view([26 21])
% legend({'a','b','c'})
set(gca,'FontName','Times New Roman','FontSize',14)
xlabel('C','FontSize',15')
ylabel('DOD(%)','FontSize',15')
zlabel('ΔR(Ω/100Ah)','FontSize',15')
saveas(gcf, '某个Ro的斜率map图.emf');
%% Rp相关特征画图
plot_Rp=importdata('plot_Rp.mat');
figure('Position', [200, 200, 800, 600])
grid on
hold on
[feature_k,x,y,z]=feature_k_ratio(plot_Rp,'Rp_excel',7.8*10^-4);
surf(x,y, z);
view([26 21])
% legend({'a','b','c'})
set(gca,'FontName','Times New Roman','FontSize',14)
xlabel('C','FontSize',15')
ylabel('DOD(%)','FontSize',15')
zlabel('ΔR(Ω/100Ah)','FontSize',15')
saveas(gcf, '某个Rp的斜率map图.emf');
%% ICA峰值画图
plot_ICA_peak=importdata('plot_ICA_peak.mat');
figure('Position', [200, 200, 800, 600])
% set(gca)
grid on
hold on

[feature_k,x,y,z]=feature_k_ratio(plot_ICA_peak,'ICA_peak',125);
surf(x,y, z);
% view([-30 30])
% view([45 25])
% view([50 20])
view([26 21])
set(gca,'FontName','Times New Roman','FontSize',14)
xlabel('C','FontSize',15')
ylabel('DOD(%)','FontSize',15')
zlabel('ΔPeak(Ah*V^-^1/100Ah)','FontSize',15')
saveas(gcf, '某个IC峰值的斜率map图.emf');
%% ICA相关特征画图
plot_ICA_Area=importdata('plot_ICA_Area.mat');
figure('Position', [200, 200, 800, 600])
% set(gca)
grid on

[feature_k,x,y,z]=feature_k_ratio(plot_ICA_Area,'ICA_area',20);
surf(x,y, z);
% view([-30 30])
% view([45 25])
% view([50 20])
view([26 21])

% legend({'a','b','c'})
set(gca,'FontName','Times New Roman','FontSize',14)
xlabel('C','FontSize',15')
ylabel('DOD(%)','FontSize',15')
zlabel('ΔArea(Ah/100Ah)','FontSize',15')
saveas(gcf, '某个IC面积的斜率map图.emf');
%% VAR特征全部的拟合图
plot_VAR=importdata('plot_VAR.mat');
figure
subplot(2,1,1)
set(gca,'FontName','Times New Roman','FontSize',14)
hold on
box on
for i =1:length(plot_VAR)
    plot(plot_VAR(i).Ah_list,plot_VAR(i).VAR)
end

ylabel('VAR','FontSize',15')

% set(gca,'xtick','','xticklabel','')
grid on
subplot(2,1,2)
set(gca,'FontName','Times New Roman','FontSize',14)
hold on
box on
for i =1:length(plot_VAR)
    plot(plot_VAR(i).Ah_list_fit,plot_VAR(i).VAR_fit)
end

xlabel('Total Q (Ah)','FontSize',15')
ylabel('VAR','FontSize',15')
grid on
saveas(gcf, '所有VAR的绘图.tif');

%% VAR特征平均值的示意图
plot_VAR=importdata('plot_VAR.mat');
figure
hold on
box on
HF='VAR';
HF_fit=[HF ,'_fit'];
HF_polyval=[HF ,'_polyval'];
points=[];
point_y=0.5;
legends={};
route=0;
curve_legend={};
for i=[1,5,7,15]
    max_Ah_to_compute=max(plot_VAR(i).Ah_list_fit(end),plot_VAR(i+1).Ah_list_fit(end));
    new_Ah_list_fit=0:1000:max_Ah_to_compute;
    y_new_1=polyval(plot_VAR(i).(HF_polyval),new_Ah_list_fit);
    y_new_2=polyval(plot_VAR(i+1).(HF_polyval),new_Ah_list_fit);
    y_miu=0.5*(y_new_2+y_new_1);
    eval(['P',int2str(route),'=plot(new_Ah_list_fit,y_miu)']);
    curve_legend=[curve_legend,['P',int2str(route)]];
    [~,index]=find(y_miu>point_y,1);
    points=[points;[new_Ah_list_fit(index),y_miu(index)]];
    route=route+1;
    legends=[legends,['Route ',int2str(route)]];
end

plot(plot_VAR(1).Ah_list_fit,ones(size(plot_VAR(1).Ah_list_fit))*point_y,'.-');

for p =1:size(points,1)
    scatter(points(p,1),points(p,2))
end
legend(curve_legend,legends)
set(gca,'FontName','Times New Roman','FontSize',14)
xlabel('Total Q (Ah)','FontSize',15')
ylabel('VAR','FontSize',15')
grid on
saveas(gcf, '多条VAR的斜率取点图.tif');
%% VAR特征示意图
figure('Position', [200, 200, 800, 600])
% set(gca)
grid on
hold on
for i =[0.5 0.6 0.7]
[feature_k,x,y,z]=feature_k_ratio(plot_VAR,'VAR',i);
S=surf(x,y, z);
% S.FaceAlpha = 0.5;
end
% view([-30 30])
% view([45 25])
% view([50 20])
view([26 21])
set(gca,'FontName','Times New Roman','FontSize',14)
xlabel('C','FontSize',15')
ylabel('DOD(%)','FontSize',15')
zlabel('ΔVAR(VAR/100Ah)','FontSize',15')
saveas(gcf, '很多个VAR的斜率map图.emf');
%% VAR特征示意图
figure('Position', [200, 200, 800, 600])
% set(gca)
grid on
hold on

[feature_k,x,y,z]=feature_k_ratio(plot_VAR,'VAR',0.5);
S=surf(x,y, z);
S.FaceAlpha = 0.5;
x=[feature_k.C];
y=[feature_k.DOD];
z=[feature_k.k];
scatter3(x(1:2:end),y(1:2:end),z(1:2:end),'filled','blue')
scatter3(x(28),y(28),z(28),'filled','blue')
view([26 21])
set(gca,'FontName','Times New Roman','FontSize',14)
xlabel('C','FontSize',15')
ylabel('DOD(%)','FontSize',15')
zlabel('ΔVAR(VAR/100Ah)','FontSize',15')
saveas(gcf, '某个VAR的斜率map图带散点.emf');