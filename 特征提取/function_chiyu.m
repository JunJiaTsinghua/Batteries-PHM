function [chiyu_V]= function_chiyu(V)
%% 弛豫过程
 deltaV=V(2:end)-V(1:end-1);
    [~,V_chiyu_start]=min(V);
   V_chiyu_start=V_chiyu_start+1;
   for i=V_chiyu_start:length(deltaV)
      if  deltaV(i)>0.03
          break
      end
   end
   V_chiyu_end=i-1;
    chiyu_V=V(V_chiyu_start:V_chiyu_end);

end
%%


