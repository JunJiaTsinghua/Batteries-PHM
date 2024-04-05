%%
load('life_score.mat')
% ���� figure
figure1 = figure;

% ���� subplot
subplot1 = subplot(2,1,1,'Parent',figure1);
hold(subplot1,'on');
X1=1:30;
Y1=life_score.life_list;
Y2=life_score.score_list;
% ���� plot
plot(X1,Y1,'ZDataSource','','Parent',subplot1,...
    'LineWidth',1.5,...
    'Color',[0 0 0]);
set(gca, 'FontSize', 16,'FontName','Times New Roman')
% ���� ylabel
ylabel({'Total Q (Ah*10^5)'});
box(subplot1,'on');
% ������������������
set(subplot1,'FontSize',16,'XAxisLocation','top','XColor',[0 0 0],'XGrid',...
    'on','XTickLabel',{'','','','','','',''},'YAxisLocation','left','YColor',...
    [0 0 0],'YGrid','on',...
    'ZColor',[0 0 0]);
% % ���� legend
% legend1 = legend(subplot1,'show');
% set(legend1,'FontSize',12);

% ���� axes
axes1 = axes('Parent',figure1,...
    'Position',[0.13 0.24302247073851 0.775 0.341162790697674]);
hold(axes1,'on');

% ���� plot
plot(X1,Y2,'Parent',axes1,'DisplayName','Score','LineWidth',1.5,...
    'Color',[1 0 0]);
set(gca, 'FontSize', 16,'FontName','Times New Roman')
% ���� xlabel
xlabel('Battery Number');

% ���� ylabel
ylabel('Score');

% ȡ�������е�ע���Ա���������� Y ��Χ
% ylim(axes1,[0.2 1.2]);
box(axes1,'on');
axis(axes1,'ij');
set(axes1,'FontSize',16,'XGrid','on','YAxisLocation','right','YGrid','on','YTick',[30 45 60 75 90],...
    'YTickLabel',{'30','45','60','75','90'});
% set(subplot1,'XAxisLocation','top','XColor',[0 0 0],'XGrid','on',...
%     'XTickLabel','','YAxisLocation','right','YColor',[0 0 0],'YGrid','on',...
%     'ZColor',[0 0 0]);
% ���� legend
% legend2 = legend(axes1,'show');
% set(legend2,...
%     'Position',[0.151552768478856 0.51670200029239 0.1656151389474 0.0489236778359123],...
%     'FontSize',12);
saveas(gcf, '���ֺ�SOH����Ժܸ�.tif');
