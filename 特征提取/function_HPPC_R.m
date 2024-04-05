function [Ro,Rp]= function_HPPC_R(I,V)
%% HPPC 80%时候的值
    % 真实的直流电阻

    deltaI=I(2:end)-I(1:end-1);
    deltaV=V(2:end)-V(1:end-1);
    Ro=min(deltaV)/min(deltaI);
    [~,V_Rp_start]=min(deltaV);
    V_Rp_1=V(V_Rp_start+1);
    V_Rp_2=min(V);
    Rp=(V_Rp_2-V_Rp_1)/min(deltaI);

end
%%


