function [dV_list,dQdV]=function_ICA_compute(I,V,dV)
dQdV=[];
V_change_list=V(1):-dV:V(end);
index_V_change=ones(size(V_change_list));
for i =2:length(V_change_list)
    index_V_change(i)=find(V<=V_change_list(i),1,'first');
    dQ=sum(I(index_V_change(i-1):index_V_change(i)))/3600;
    dQdV=[dQdV,abs(dQ)/dV];
    
end
dV_list=V_change_list(2:end);

end