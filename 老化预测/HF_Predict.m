function [HF_pre] = HF_Predict(Maps,features,feature_name,results)
    %ȡ�õ�ǰֵ
    HF=features.char(feature_name);
    % �����н�����õ�������е�ƽ��DOD��C��Ah
    DOD_average=results.DOD;
    C_average=results.C;
    Ah_all=results.Ah_all;
    % �������HF��map
    map_thisHF=Maps.char(feature_name);
    % �õ�ǰmap�ҵ�Ҫ�õ�����map�����ݱ߽�������k������Ԥ���HF
    k=function_map_lookup(DOD_average,C_average,map_thisHF,HF);
    HF_pre=HF+k*Ah_all;

end

