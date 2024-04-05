%% 计算指定特征对象、特征值的100Ah 变化量k
%%
function [feature_k,x,y,z]=get_k_ratio_map(features_new,feature_name,feature_value)
feature_k={};
for bat =1:length(features_new)%-1:length(bats)
    if strcmp('C1-DOD50-1',features_new(bat).battery) || strcmp('C2-DOD70-2',features_new(bat).battery)
        continue
    end
    num_str = regexp(features_new(bat).battery,'\d*\.?\d*','match');
    info=str2double(num_str);
    feature_k(bat).C=info(1);
    feature_k(bat).DOD=info(2);
    feature_k(bat).num=info(3);
    poly_name=[feature_name,'_polyval'];
    result=double(solve(poly2sym(features_new(bat).(poly_name))==feature_value,'Real',true));
    id =  result<features_new(bat).Ah_list_fit(end)& result>features_new(bat).Ah_list_fit(1) ;

    feature_k(bat).k=abs(polyval(features_new(bat).(poly_name),result(id)+100)-feature_value);
 
end
x=[feature_k.C];
y=[feature_k.DOD];
z=[feature_k.k];
model = fit([x', y'], z','poly22');
[x, y] = meshgrid(min(x):0.1:max(x), min(y):10:max(y));
z = feval(model, x, y);

end
