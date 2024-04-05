function [ESS_curves] = function_condition_generate(paras_bat)
PV_data_struct=importdata('PV_data_struct.mat');
load_data_struct=importdata('load_data_struct.mat');
this_season=char(paras_bat.season);
% ��ֵ��86400
PV_this_season=k_PV*PV_data_struct.(this_season);
PV_this_season=spline(1:length(PV_this_season),PV_this_season ,1:(length(PV_this_season)-1)/(24*60*60):(length(PV_this_season)));
PV_this_season(PV_this_season<0)=0;
load_this_season=k_grid*load_data_struct.(this_season);
load_this_season=spline(1:length(load_this_season),load_this_season ,1:(length(load_this_season)-1)/(24*60*60):(length(load_this_season)));

% �й����ʱ�����ȹ�����������й�����࣬���ܳ�硣����������ҹ�����������ܲ��䡣
shave_ratio=0.8;
grid_and_ESS=load_this_season-PV_this_season;% ����ȸ�

ESS_need_cha1=grid_and_ESS;
ESS_need_cha1(grid_and_ESS>0)=0; % ���ܳ�粿��

load_need_shave=grid_and_ESS-10000*shave_ratio; % ����Ҫ�����
ESS_need_dis_1=load_need_shave;% ������һ��Ҫ�����
ESS_need_dis_1(ESS_need_dis_1<0)=0; % ���ܷŵ粿��1

grid_to_response=grid_and_ESS-ESS_need_dis_1; % ��һ������Ӧ��
response_base_line=ones(size(grid_and_ESS))*5000;
time_response_label=zeros(size(grid_and_ESS));
time_response_label(19.5*60*60:21.5*60*60)=1; % ���ʱ�β�������ô�࣬�н���
ESS_need_dis_2=grid_to_response-response_base_line;
ESS_need_dis_2=ESS_need_dis_2.*time_response_label;

ESS_need_dis=ESS_need_dis_2+ESS_need_dis_1;


kWh_ESS_cha_from_grid=trapz(ESS_need_dis)-trapz(ESS_need_cha1);

ESS_need_cha2=zeros(size(grid_and_ESS));
ESS_need_cha2(1:6*60*60)=-kWh_ESS_cha_from_grid/(6*60*60);
ESS_curves.(this_season)=ESS_need_dis+ESS_need_cha1+ESS_need_cha2;

end

