function [ESS_curves] = function_condition_generate(paras_bat)
PV_data_struct=importdata('PV_data_struct.mat');
load_data_struct=importdata('load_data_struct.mat');
this_season=char(paras_bat.season);
% 插值成86400
PV_this_season=k_PV*PV_data_struct.(this_season);
PV_this_season=spline(1:length(PV_this_season),PV_this_season ,1:(length(PV_this_season)-1)/(24*60*60):(length(PV_this_season)));
PV_this_season(PV_this_season<0)=0;
load_this_season=k_grid*load_data_struct.(this_season);
load_this_season=spline(1:length(load_this_season),load_this_season ,1:(length(load_this_season)-1)/(24*60*60):(length(load_this_season)));

% 有光伏的时候，优先光伏出力。如有光伏多余，则储能充电。如电网超限且光伏不够，则储能补充。
shave_ratio=0.8;
grid_and_ESS=load_this_season-PV_this_season;% 光伏先给

ESS_need_cha1=grid_and_ESS;
ESS_need_cha1(grid_and_ESS>0)=0; % 储能充电部分

load_need_shave=grid_and_ESS-10000*shave_ratio; % 还需要削峰的
ESS_need_dis_1=load_need_shave;% 重载是一定要解决的
ESS_need_dis_1(ESS_need_dis_1<0)=0; % 储能放电部分1

grid_to_response=grid_and_ESS-ESS_need_dis_1; % 进一步做响应的
response_base_line=ones(size(grid_and_ESS))*5000;
time_response_label=zeros(size(grid_and_ESS));
time_response_label(19.5*60*60:21.5*60*60)=1; % 这个时段不超过这么多，有奖励
ESS_need_dis_2=grid_to_response-response_base_line;
ESS_need_dis_2=ESS_need_dis_2.*time_response_label;

ESS_need_dis=ESS_need_dis_2+ESS_need_dis_1;


kWh_ESS_cha_from_grid=trapz(ESS_need_dis)-trapz(ESS_need_cha1);

ESS_need_cha2=zeros(size(grid_and_ESS));
ESS_need_cha2(1:6*60*60)=-kWh_ESS_cha_from_grid/(6*60*60);
ESS_curves.(this_season)=ESS_need_dis+ESS_need_cha1+ESS_need_cha2;

end

