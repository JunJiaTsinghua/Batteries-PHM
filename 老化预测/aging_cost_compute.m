function [results,aging_cost] = aging_cost_compute(results,period_num)
retire_SOH=0.8;
price_Wh=2.2;
huilv=6;
huishou_ratio=0.5;
price_bat=3.7*50*price_Wh/huilv;
price_bat=price_bat*(1-huishou_ratio);
%% 取本次的SOH和评分

SOH_list=results(period_num).SOH_list;
Remaining_value_list_last_period=results(period_num-1).Remaining_value_list;
Score_list=results(period_num).Score_list;
Remaining_value_list=zeros(1,length(SOH_list));
for i =1:length(SOH_list)
    Remaining_value_list(i)=price_bat*(SOH_list(i)-retire_SOH)/(1-retire_SOH)*Score_list(i)*0.01;
end
 %两轮的差距就是老化成本
aging_cost_list=Remaining_value_list-Remaining_value_list_last_period;
aging_cost_list(aging_cost_list<0)=0; %老化成本小于0的要置为0
aging_cost=sum(aging_cost_list);
results(period_num).Remaining_value_list=Remaining_value_list;
end

