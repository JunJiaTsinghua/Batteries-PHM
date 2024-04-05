 % 提取需要的数据出来，放到struct里面 'C1DOD70_2',
   bat_files={'C1DOD70_1','C1DOD30_2','C1DOD30_1','C1.5DOD70_2','C1.5DOD70_1','C1.2DOD70_2','C1.2DOD70_1'};
for bat =1:length(bat_files)  
    %% 读文件
    folder=['D:\数据\重大CABLE老化实验\',char(bat_files(bat))];
    listing = dir(fullfile(folder,'*.xls'));

    % %按照时间升序排，也就是越早的在越前面
    % [~,index] = sortrows([listing.datenum].'); listing = listing(index); clear index
    % modTime = listing.datenum;
    %% 上面方法行不通，太多数据的日期要去修改了
    % 都读一次实验开始时间，按照这个时间把文件的排序先做了
    
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
%                     disp('找到了')
                    continue
                end
                [~,time_begin]=xlsread([folder,'\',this_file],sheets(j),'D2:D2');
            end
        end
        listing(i).begindatenum=datenum(time_begin);
        listing(i).time_begin=datenum(char(time_begin));
    end
    
    [~,index] = sortrows([listing.begindatenum].'); listing = listing(index); clear index
    
    %% 读取并记录
    ALL_data={};
    
    % 逐个读取所有的Detail这个sheet
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
