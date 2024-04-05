function flag = function_typical_day_judge(X,paras_bat)
%% 取数据
ESS_curves=function_condition_generate(paras_bat);
example_curve=ESS_curves.(char(paras_bat.season));
SOH=paras_bat.SOH_list;
DOD=X(13:24);
C_rate=X(25:36);
flag=0;
%% 
run_curve=zeros(12,length(example_curve));
Q_remain_flag=ones(1,12);
for i=1:length(example_curve)-1
%     i
    %先同步过去，保持不变
   run_curve(:,i+1)=run_curve(:,i).*Q_remain_flag';
    % 开始就判断是否有用超的，置为零。然后判断剩余的功率是否满足当前的需求，如果满足了，再去看是升是降，如果不满足，直接启用该启用的电池。
    
    %只要紧急电池开着的，就要缓降
     % 如果紧急电池是开机了的，就慢慢降下去
     if  run_curve(12,i+1)<=30*C_rate(12) && run_curve(12,i+1)>0
         run_curve(12,i+1)=Q_remain_flag(12)*max(0,run_curve(12,i+1)-(30*C_rate(12)*0.016));
         if example_curve(i+1)-sum(run_curve(:,i+1))>0
            
             
             %搞稳态电池，让已经启动的先拉满
             for j=2:10
                 if run_curve(j,i+1)>0 
                     run_curve(j,i+1)=Q_remain_flag(j)*min(30*C_rate(j),run_curve(j,i+1)+example_curve(i+1)-sum(run_curve(:,i+1)));
                 end
                 if sum(run_curve(j,:))/3600>=30*SOH(j)*DOD(j)
                     Q_remain_flag(j)=0;
                 end
                 
                 if example_curve(i+1)-sum(run_curve(:,i+1))<0
                     break
                 end
             end
             
             % 动态电池补剩余的
             if run_curve(11,i+1)<=30 && sum(run_curve(11,:))>0
                 run_curve(11,i+1)=Q_remain_flag(11)*min(30*C_rate(11),run_curve(11,i+1)+abs(example_curve(i+1)-sum(run_curve(:,i+1))));
             end
             if sum(run_curve(11,:))/3600>=30*SOH(11)*DOD(11)
                 Q_remain_flag(11)=0;
             end
             
             if example_curve(i+1)-sum(run_curve(:,i+1))<0
                 continue
             end
             
             %不行就要让没启动的稳态电池，启动起来了
             for j=2:10
                 run_curve(j,i+1)=Q_remain_flag(j)*min(30*C_rate(j),run_curve(j,i+1)+example_curve(i+1)-sum(run_curve(:,i+1)));
                 if sum(run_curve(j,:))/3600>=30*SOH(j)*DOD(j)
                     Q_remain_flag(j)=0;
                 end
                 
                 if example_curve(i+1)-sum(run_curve(:,i+1))<=0 %这里改了一个等于号，看会不会先把没启动的稳态启动起来吧
                     break
                 end
             end
             
              % 最差的电池最后再说
             run_curve(1,i+1)=Q_remain_flag(1)*min(30*C_rate(1),run_curve(1,i+1)+example_curve(i+1)-sum(run_curve(:,i+1)));
             if sum(run_curve(1,:))/3600>=30*SOH(1)*DOD(1)
                 Q_remain_flag(1)=0;
             end
             if example_curve(i+1)-sum(run_curve(:,i+1))<0
                 continue
             end
             
         end
     end
        
    % 大于1.5C
    if   example_curve(i+1)-example_curve(i)>=30*C_rate(12)
        run_curve(12,i+1)=C_rate(12)*30*Q_remain_flag(12); % 先用紧急电池
        run_curve(11,i+1)=Q_remain_flag(11)*min(30*C_rate(11),example_curve(i+1)-sum(run_curve(:,i+1))); % 不够的用动态电池来顶
        if example_curve(i+1)-sum(run_curve(:,i+1))<=0
            continue
        end
        
         
        
        % 剩余的稳定电池，摊完为止。能不启动的都不启动。
        for j=2:10
            run_curve(j,i+1)=Q_remain_flag(j)*min(30*C_rate(j),example_curve(i+1)-sum(run_curve(:,i+1)));
            if example_curve(i+1)-sum(run_curve(:,i+1))<=0               
                break
            end
        end

        % 实在不行了，才让最低倍率的来
        run_curve(1,i+1)=min(30*C_rate(1),example_curve(i+1)-sum(run_curve(:,i+1)));
        if example_curve(i+1)-sum(run_curve(:,i+1))<=0
            continue
        end
        
    end
    % 1C和1.5C之间
    if   example_curve(i+1)-example_curve(i)>=30 && example_curve(i+1)-example_curve(i)<30 *C_rate(12)
        run_curve(11,i+1)=Q_remain_flag(11)*30*C_rate(11);
        run_curve(1,i+1)=Q_remain_flag(1)*min(30*C_rate(1),example_curve(i+1)-sum(run_curve(:,i+1)));
        if example_curve(i+1)-sum(run_curve(:,i+1))<=0
            continue
        end
        for j=2:10
            run_curve(j,i+1)=Q_remain_flag(j)*min(30*C_rate(j),example_curve(i+1)-sum(run_curve(:,i+1)));
            if example_curve(i+1)-sum(run_curve(:,i+1))<=0
                %                 run_curve(j,i+1)=-example_curve(i+1)+sum(run_curve(:,i+1));
%                 run_curve(j:-1:2,i+1)
                break
            end
        end
    end
    
    % 小于1C。其实就是中间的正常增长过程
    if   example_curve(i+1)-example_curve(i)<30 && example_curve(i+1)-example_curve(i)>0
    
                
      
        
        %搞稳态电池，让已经启动的先拉满
        for j=2:10
            if run_curve(j,i+1)>0
               run_curve(j,i+1)=Q_remain_flag(j)*min(30*C_rate(j),run_curve(j,i+1)+example_curve(i+1)-sum(run_curve(:,i+1)));
            end
            if sum(run_curve(j,:))/3600>=30*SOH(j)*DOD(j)
                Q_remain_flag(j)=0;
            end

            if example_curve(i+1)-sum(run_curve(:,i+1))==0
                break
            end
        end
        
        % 动态电池补剩余的
        if run_curve(11,i+1)<=30 && sum(run_curve(11,:))>0
            run_curve(11,i+1)=Q_remain_flag(11)*min(30*C_rate(11),run_curve(11,i+1)+abs(example_curve(i+1)-sum(run_curve(:,i+1))));
        end
        if sum(run_curve(11,:))/3600>=30*SOH(11)*DOD(11)
            Q_remain_flag(11)=0;
        end

        if example_curve(i+1)-sum(run_curve(:,i+1))<0
            continue
        end
        
         %不行就要让没启动的稳态电池，启动起来了
        for j=2:10
            run_curve(j,i+1)=Q_remain_flag(j)*min(30*C_rate(j),run_curve(j,i+1)+example_curve(i+1)-sum(run_curve(:,i+1)));
            if sum(run_curve(j,:))/3600>=30*SOH(j)*DOD(j)
                Q_remain_flag(j)=0;
            end

            if example_curve(i+1)-sum(run_curve(:,i+1))<0
                break
            end
        end
          % 最差的电池肯定已经启动了
        run_curve(1,i+1)=Q_remain_flag(1)*min(30*C_rate(1),run_curve(1,i+1)+example_curve(i+1)-sum(run_curve(:,i+1)));
        if sum(run_curve(1,:))/3600>=30*SOH(1)*DOD(1)
            Q_remain_flag(1)=0;
        end
        if example_curve(i+1)-sum(run_curve(:,i+1))<0
            continue
        end
        
        
    end
    %如果中途下降
    if   example_curve(i+1)-example_curve(i)<=0 
        
        % 遇到这种意外情况：12号在减载过程中没电了，要把11号顶上去--好像改了调度顺序后，这种情况不会出现了
        if  Q_remain_flag(12)==0 && example_curve(i+1)>sum(run_curve(:,i+1))
            run_curve(11,i+1)=Q_remain_flag(11)*min(example_curve(i+1)-sum(run_curve(:,i+1)),30*C_rate(11));
            if sum(run_curve(11,:))/3600>=30*SOH(11)*DOD(11)
                Q_remain_flag(11)=0;
                
            end
            if example_curve(i+1)>sum(run_curve(:,i+1))
                for j=2:10
                    run_curve(j,i+1)=Q_remain_flag(j)*min(30*C_rate(j),run_curve(j,i+1)+example_curve(i+1)-sum(run_curve(:,i+1)));
                    if sum(run_curve(j,:))/3600>=30*SOH(j)*DOD(j)
                        Q_remain_flag(j)=0;
                    end
                    
                    if example_curve(i+1)-sum(run_curve(:,i+1))<0
                        break
                    end
                end
            end
            continue
        end
        %         kw_need_desend=example_curve(i+1)-sum(run_curve(1:8,i+1));
        
        if example_curve(i+1)-sum(run_curve(:,i+1))<0% 如果超了
            run_curve(12,i+1)=Q_remain_flag(12)*max(0,run_curve(12,i+1)+max(-30*C_rate(12),example_curve(i+1)-sum(run_curve(:,i+1))));
            if sum(run_curve(12,:))/3600>=30*SOH(12)*DOD(12)
                Q_remain_flag(12)=0;
                
            end
        end
        if example_curve(i+1)-sum(run_curve(:,i+1))<0 
            run_curve(11,i+1)=Q_remain_flag(11)*max(0,run_curve(11,i+1)+max(-30*C_rate(11),example_curve(i+1)-sum(run_curve(:,i+1))));
            if sum(run_curve(11,:))/3600>=30*SOH(11)*DOD(11)
                Q_remain_flag(11)=0;
            end
        end
        
               % 如果还超了，先停下1号
        if example_curve(i+1)-sum(run_curve(:,i+1))<0 
            run_curve(1,i+1)=Q_remain_flag(1)*max(0,run_curve(1,i+1)+max(-30*C_rate(1),example_curve(i+1)-sum(run_curve(:,i+1))));
            if sum(run_curve(1,:))/3600>=30*SOH(1)*DOD(1)
                Q_remain_flag(1)=0;
            end
        end
        
        if example_curve(i+1)-sum(run_curve(:,i+1))<0% 如果还超了
            for j=2:10
                run_curve(j,i+1)=Q_remain_flag(j)*max(0,run_curve(j,i+1)+max(-30*C_rate(j),example_curve(i+1)-sum(run_curve(:,i+1))));
                if sum(run_curve(j,:))/3600>=30*SOH(j)*DOD(j)
                    Q_remain_flag(j)=0;
                end
                if example_curve(i+1)-sum(run_curve(:,i+1))>=0 % 减过头了
%                     run_curve(j,i+1)=Q_remain_flag(j)*max(0,run_curve(j,i+1)-abs(example_curve(i+1)-sum(run_curve(:,i+1))));
                    break
                end
            end
        end
       
    end
    
    % 任何情况下，如果没电了，应急电池顶上来. 前提是还有电
    if example_curve(i+1)-sum(run_curve(:,i+1))>0 && run_curve(12,i+1)<=30*C_rate(12)
        run_curve(12,i+1)=Q_remain_flag(12)*min(30*C_rate(12),example_curve(i+1)-sum(run_curve(1:11,i+1)));
    end
    
    % 判断，中途没响应成功，就结束，flag置为0.如果跑完了，flag就会保持为1
    if example_curve(i+1)>sum(run_curve(:,i+1))
      flag=0;
        break
    end
end

end

