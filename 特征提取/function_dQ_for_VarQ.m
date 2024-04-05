function [V_interval,Q_interval] = function_dQ_for_VarQ(Q_list,V_list)

Q_interval=[];
V_interval=4.2:-0.01:2.8;
for v =V_interval
    index=find(V_list<v,1);
    Q_interval=[Q_interval,Q_list(index)];
end

end

