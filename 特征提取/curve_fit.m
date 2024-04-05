%% 拟合曲线用，把散点图变成光滑的多项式拟合曲线
%%
function features_new=curve_fit(features_new,feature_name)
for bat =1:length(features_new)%-1:length(bats)
    if strcmp('C1-DOD50-1',features_new(bat).battery) || strcmp('C2-DOD70-2',features_new(bat).battery)
        continue
    end
    x=features_new(bat).Ah_list;
    y=features_new(bat).(feature_name);
%     xx=x(1):(x(end)-x(1))/1000:x(end);
    xx=x(1):1000:x(end);
    if length(x)<5
        cishu=3;
    else
        cishu=2;
    end
    p_auto= polyfit(x,y,cishu);
    y_new=polyval(p_auto,xx);
    features_new(bat).Ah_list_fit=xx;
    feature_fit_name=[feature_name,'_fit'];
    features_new(bat).(feature_fit_name)=y_new;
      polyval_name=[feature_name,'_polyval'];
    features_new(bat).(polyval_name)=p_auto;
end
end