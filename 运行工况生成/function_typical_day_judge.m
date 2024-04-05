function flag = function_typical_day_judge(X,paras_bat)
%% ȡ����
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
    %��ͬ����ȥ�����ֲ���
   run_curve(:,i+1)=run_curve(:,i).*Q_remain_flag';
    % ��ʼ���ж��Ƿ����ó��ģ���Ϊ�㡣Ȼ���ж�ʣ��Ĺ����Ƿ����㵱ǰ��������������ˣ���ȥ�������ǽ�����������㣬ֱ�����ø����õĵ�ء�
    
    %ֻҪ������ؿ��ŵģ���Ҫ����
     % �����������ǿ����˵ģ�����������ȥ
     if  run_curve(12,i+1)<=30*C_rate(12) && run_curve(12,i+1)>0
         run_curve(12,i+1)=Q_remain_flag(12)*max(0,run_curve(12,i+1)-(30*C_rate(12)*0.016));
         if example_curve(i+1)-sum(run_curve(:,i+1))>0
            
             
             %����̬��أ����Ѿ�������������
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
             
             % ��̬��ز�ʣ���
             if run_curve(11,i+1)<=30 && sum(run_curve(11,:))>0
                 run_curve(11,i+1)=Q_remain_flag(11)*min(30*C_rate(11),run_curve(11,i+1)+abs(example_curve(i+1)-sum(run_curve(:,i+1))));
             end
             if sum(run_curve(11,:))/3600>=30*SOH(11)*DOD(11)
                 Q_remain_flag(11)=0;
             end
             
             if example_curve(i+1)-sum(run_curve(:,i+1))<0
                 continue
             end
             
             %���о�Ҫ��û��������̬��أ�����������
             for j=2:10
                 run_curve(j,i+1)=Q_remain_flag(j)*min(30*C_rate(j),run_curve(j,i+1)+example_curve(i+1)-sum(run_curve(:,i+1)));
                 if sum(run_curve(j,:))/3600>=30*SOH(j)*DOD(j)
                     Q_remain_flag(j)=0;
                 end
                 
                 if example_curve(i+1)-sum(run_curve(:,i+1))<=0 %�������һ�����ںţ����᲻���Ȱ�û��������̬����������
                     break
                 end
             end
             
              % ���ĵ�������˵
             run_curve(1,i+1)=Q_remain_flag(1)*min(30*C_rate(1),run_curve(1,i+1)+example_curve(i+1)-sum(run_curve(:,i+1)));
             if sum(run_curve(1,:))/3600>=30*SOH(1)*DOD(1)
                 Q_remain_flag(1)=0;
             end
             if example_curve(i+1)-sum(run_curve(:,i+1))<0
                 continue
             end
             
         end
     end
        
    % ����1.5C
    if   example_curve(i+1)-example_curve(i)>=30*C_rate(12)
        run_curve(12,i+1)=C_rate(12)*30*Q_remain_flag(12); % ���ý������
        run_curve(11,i+1)=Q_remain_flag(11)*min(30*C_rate(11),example_curve(i+1)-sum(run_curve(:,i+1))); % �������ö�̬�������
        if example_curve(i+1)-sum(run_curve(:,i+1))<=0
            continue
        end
        
         
        
        % ʣ����ȶ���أ�̯��Ϊֹ���ܲ������Ķ���������
        for j=2:10
            run_curve(j,i+1)=Q_remain_flag(j)*min(30*C_rate(j),example_curve(i+1)-sum(run_curve(:,i+1)));
            if example_curve(i+1)-sum(run_curve(:,i+1))<=0               
                break
            end
        end

        % ʵ�ڲ����ˣ�������ͱ��ʵ���
        run_curve(1,i+1)=min(30*C_rate(1),example_curve(i+1)-sum(run_curve(:,i+1)));
        if example_curve(i+1)-sum(run_curve(:,i+1))<=0
            continue
        end
        
    end
    % 1C��1.5C֮��
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
    
    % С��1C����ʵ�����м��������������
    if   example_curve(i+1)-example_curve(i)<30 && example_curve(i+1)-example_curve(i)>0
    
                
      
        
        %����̬��أ����Ѿ�������������
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
        
        % ��̬��ز�ʣ���
        if run_curve(11,i+1)<=30 && sum(run_curve(11,:))>0
            run_curve(11,i+1)=Q_remain_flag(11)*min(30*C_rate(11),run_curve(11,i+1)+abs(example_curve(i+1)-sum(run_curve(:,i+1))));
        end
        if sum(run_curve(11,:))/3600>=30*SOH(11)*DOD(11)
            Q_remain_flag(11)=0;
        end

        if example_curve(i+1)-sum(run_curve(:,i+1))<0
            continue
        end
        
         %���о�Ҫ��û��������̬��أ�����������
        for j=2:10
            run_curve(j,i+1)=Q_remain_flag(j)*min(30*C_rate(j),run_curve(j,i+1)+example_curve(i+1)-sum(run_curve(:,i+1)));
            if sum(run_curve(j,:))/3600>=30*SOH(j)*DOD(j)
                Q_remain_flag(j)=0;
            end

            if example_curve(i+1)-sum(run_curve(:,i+1))<0
                break
            end
        end
          % ���ĵ�ؿ϶��Ѿ�������
        run_curve(1,i+1)=Q_remain_flag(1)*min(30*C_rate(1),run_curve(1,i+1)+example_curve(i+1)-sum(run_curve(:,i+1)));
        if sum(run_curve(1,:))/3600>=30*SOH(1)*DOD(1)
            Q_remain_flag(1)=0;
        end
        if example_curve(i+1)-sum(run_curve(:,i+1))<0
            continue
        end
        
        
    end
    %�����;�½�
    if   example_curve(i+1)-example_curve(i)<=0 
        
        % �����������������12���ڼ��ع�����û���ˣ�Ҫ��11�Ŷ���ȥ--������˵���˳�������������������
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
        
        if example_curve(i+1)-sum(run_curve(:,i+1))<0% �������
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
        
               % ��������ˣ���ͣ��1��
        if example_curve(i+1)-sum(run_curve(:,i+1))<0 
            run_curve(1,i+1)=Q_remain_flag(1)*max(0,run_curve(1,i+1)+max(-30*C_rate(1),example_curve(i+1)-sum(run_curve(:,i+1))));
            if sum(run_curve(1,:))/3600>=30*SOH(1)*DOD(1)
                Q_remain_flag(1)=0;
            end
        end
        
        if example_curve(i+1)-sum(run_curve(:,i+1))<0% ���������
            for j=2:10
                run_curve(j,i+1)=Q_remain_flag(j)*max(0,run_curve(j,i+1)+max(-30*C_rate(j),example_curve(i+1)-sum(run_curve(:,i+1))));
                if sum(run_curve(j,:))/3600>=30*SOH(j)*DOD(j)
                    Q_remain_flag(j)=0;
                end
                if example_curve(i+1)-sum(run_curve(:,i+1))>=0 % ����ͷ��
%                     run_curve(j,i+1)=Q_remain_flag(j)*max(0,run_curve(j,i+1)-abs(example_curve(i+1)-sum(run_curve(:,i+1))));
                    break
                end
            end
        end
       
    end
    
    % �κ�����£����û���ˣ�Ӧ����ض�����. ǰ���ǻ��е�
    if example_curve(i+1)-sum(run_curve(:,i+1))>0 && run_curve(12,i+1)<=30*C_rate(12)
        run_curve(12,i+1)=Q_remain_flag(12)*min(30*C_rate(12),example_curve(i+1)-sum(run_curve(1:11,i+1)));
    end
    
    % �жϣ���;û��Ӧ�ɹ����ͽ�����flag��Ϊ0.��������ˣ�flag�ͻᱣ��Ϊ1
    if example_curve(i+1)>sum(run_curve(:,i+1))
      flag=0;
        break
    end
end

end

