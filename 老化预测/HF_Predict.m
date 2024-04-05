function [HF_pre] = HF_Predict(Maps,features,feature_name,results)
    %取得当前值
    HF=features.char(feature_name);
    % 从运行结果中拿到这次运行的平均DOD、C和Ah
    DOD_average=results.DOD;
    C_average=results.C;
    Ah_all=results.Ah_all;
    % 调用这个HF的map
    map_thisHF=Maps.char(feature_name);
    % 用当前map找到要用的那张map，根据边界参数查的k，计算预测的HF
    k=function_map_lookup(DOD_average,C_average,map_thisHF,HF);
    HF_pre=HF+k*Ah_all;

end

