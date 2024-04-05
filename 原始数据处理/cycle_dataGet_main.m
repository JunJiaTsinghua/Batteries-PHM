%%
clear;clc
data_to_save={'Qdlin','Tdlin','discharge_dQdV'};
cycle_to_choose=[1,4,5,10,100];
%%
% 获取当前文件夹的路径
fileadd=mfilename('fullpath');
num=find(fileadd=='\');
fileadd = fileadd(1:num(1,end)); 

%%
%读取小数据块文件
files_folder='D:\程序\电池_数据与健康\small_data';
files=dir(fullfile((files_folder),'*.mat'));%找出所有数据的名字
cells=[]; 
for i =1:length(files)
    file=files(i).name;
    batch_file=strsplit(file,'_');
    batch_name=batch_file{1};
   batch= importdata([files_folder,'\',file]);
    cell=cycle_extract(batch,cycle_to_choose,data_to_save);
    cells=[cells,cell];
end
