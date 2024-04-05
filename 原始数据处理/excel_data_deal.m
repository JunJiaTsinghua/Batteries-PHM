 % ��ȡ��Ҫ�����ݳ������ŵ�struct���� 'C1DOD70_2',
   bat_files={'C1DOD70_1','C1DOD30_2','C1DOD30_1','C1.5DOD70_2','C1.5DOD70_1','C1.2DOD70_2','C1.2DOD70_1'};
for bat =1:length(bat_files)  
    %% ���ļ�
    folder=['D:\����\�ش�CABLE�ϻ�ʵ��\',char(bat_files(bat))];
    listing = dir(fullfile(folder,'*.xls'));

    % %����ʱ�������ţ�Ҳ����Խ�����Խǰ��
    % [~,index] = sortrows([listing.datenum].'); listing = listing(index); clear index
    % modTime = listing.datenum;
    %% ���淽���в�ͨ��̫�����ݵ�����Ҫȥ�޸���
    % ����һ��ʵ�鿪ʼʱ�䣬�������ʱ����ļ�������������
    
    filenames={listing.name};
    for i =1: length(filenames)
        
        this_file=char(filenames(i));
        try
            [~,time_begin]=xlsread([folder,'\',this_file],'Info','F8:F8');
        catch
            sheets = sheetnames([folder,'\',this_file]);
            for j=1:length(sheets)
                if  contains(sheets(j), 'Detail_')
                    [~,time_begin]=xlsread([folder,'\',this_file],sheets(j),'K2:K2');
%                     disp('�ҵ���')
                    continue
                end
                [~,time_begin]=xlsread([folder,'\',this_file],sheets(j),'D2:D2');
            end
        end
        listing(i).begindatenum=datenum(time_begin);
        listing(i).time_begin=datenum(char(time_begin));
    end
    
    [~,index] = sortrows([listing.begindatenum].'); listing = listing(index); clear index
    
    %% ��ȡ����¼
    ALL_data={};
    
    % �����ȡ���е�Detail���sheet
    filenames={listing.name};
    for i =1:length(filenames)
        
        this_file=char(filenames(i));
        
        sheets = sheetnames([folder,'\',this_file]);
        tr = regexprep(this_file,'[-+_%!. ()]','');
        I_data=[];
        V_data=[];
        for j=1:length(sheets)
            if  contains(sheets(j), 'Detail_')
                I=xlsread([folder,'\',this_file],sheets(j),'F:F');
                I_data= [I_data;I];
                V=xlsread([folder,'\',this_file],sheets(j),'G:G');
                V_data= [V_data;V];
            end
            if  contains(sheets(j), 'Statis_')
                Ah_data=xlsread([folder,'\',this_file],sheets(j),'J:J');
                Wh_data=xlsread([folder,'\',this_file],sheets(j),'Q:Q');
            end
        end
        
        ALL_data(1).(tr)=I_data;
        ALL_data(2).(tr)=V_data;
        ALL_data(3).(tr)=Ah_data;
        ALL_data(4).(tr)=Wh_data;
    end
    save([char(bat_files(bat)),'.mat'],'ALL_data')
end
