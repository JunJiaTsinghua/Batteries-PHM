###
#----用于从怀柔数据库获取需要的数据点---批量循环的那种
#本地电脑获取，前几天的
#按天获取

import pymysql 
import pickle
import read_DB_by_point
from scipy import io
import matplotlib.pyplot as plt
import numpy as np
with open('str_to_code.pkl', 'rb') as f:#版本不同，用pickle的话要用wb和rb
    str_to_code = pickle.load(f)
#连接数据库
dataBase='huairou_sample'
#从0705开始才有，但只有放。前面几天的感觉采集有问题。
db = pymysql.connect("localhost", "root", "jiajun", dataBase)

# class Var:
#     #随机被选中的是  1#储能站2-A#舱   5#簇电池簇
#     Cabin_to_choose='1#储能站1#舱'
#     Case_to_choose='5#簇电池簇'
#     Cell_vol_change_threshold=2
#     Mod_temperature_change_threshold=5


    #获取单体电压
def get_cells_voltage():
    data={}
    data_point_list=[]
    for i in range(1,229):
        #获取数据
        data_point=Cabin_to_choose+Case_to_choose+'单体电压'+str(i)
        data_point_list = read_DB_by_point.getData(db, tableName, str_to_code[data_point])
        print(data_point)
        #进行数据清理。去掉跳变（跳成0那种，只去那种，因为是传输造成的。别去多了，不然有些本就是电池有问题造成的影响也弄没了）
        if data_point_list == []: print(data_point,',点表：'+str_to_code[data_point]+'没数据');#空列表要告知
        for j in range(0,len(data_point_list)-1):
            if data_point_list[j]-data_point_list[j+1]>=Cell_vol_change_threshold:
                # print('有跳变，已被处理')
                data_point_list[j+1]=data_point_list[j]

        data['V'+str(i)] = data_point_list
    #     if i==2:break
    # plt.figure('单体电压日曲线')
    # plt.plot(data_point_list)
    # plt.show()
    return data

def get_mod_voltage(data):
    n_data_len=len(data['V'+str(1)])
    this_mod_vol = np.zeros((n_data_len))
    mod_vol={}
    mod_num=0
    for key in range(1,len(data.keys())+1):
        # print('cell',key)
        this_mod_vol = np.add(this_mod_vol, data['V'+str(key)])
        if key%12==0:
            mod_num+=1
            print('mod',mod_num)
            # 进行数据清理。去掉跳变（跳成0那种，只去那种，因为是传输造成的。别去多了，不然有些本就是电池有问题造成的影响也弄没了）
            for j in range(0, len(this_mod_vol) - 1):
                if abs(this_mod_vol[j + 1] - this_mod_vol[j]) >= Cell_vol_change_threshold*3:
                    # print('有跳变，已被处理')
                    this_mod_vol[j + 1] = this_mod_vol[j]
            mod_vol['V_mod'+str(mod_num)]=this_mod_vol
            this_mod_vol = np.zeros((n_data_len))
    # plt.figure('模组电压日曲线')
    # plt.plot(mod_vol[1])
    # plt.show()
    return mod_vol

def get_mod_temperature():
    data = {}
    data_point_list = []
    mod_num=0
    for i in range(0, 76):
        tem_sensor_num=i%4
        if tem_sensor_num==0:mod_num+=1;data['Mod'+str(mod_num)]={}
        # 获取数据
        data_point = Cabin_to_choose + Case_to_choose + '单体温度' + str(i+1)
        data_point_list = read_DB_by_point.getData(db, tableName, str_to_code[data_point])
        print(data_point)
        # 进行数据清理。去掉跳变（跳成0那种，只去那种，因为是传输造成的。别去多了，不然有些本就是电池有问题造成的影响也弄没了）
        if data_point_list == []: print(data_point, ',点表：' + str_to_code[data_point] + '没数据');  # 空列表要告知
        for j in range(0, len(data_point_list) - 1):
            if abs(data_point_list[j + 1] - data_point_list[j]) >= Mod_temperature_change_threshold:
                # print('有跳变，已被处理')
                data_point_list[j + 1] = data_point_list[j]

        data['Mod'+str(mod_num)]['Probe'+str(tem_sensor_num+1)] = data_point_list
    #     if i == 9: break
    # plt.figure('温度日曲线')
    # plt.plot(data_point_list)
    # plt.show()
    return data
def get_max_min_data():
    data_to_get_list=['最高温度','最低温度','最高电压','最低电压']
    data={}
    data_to_save_list=['TemMax','TemMin','VolMax','VolMin']
    for i in range(0,4):
        data_point = Cabin_to_choose + Case_to_choose + data_to_get_list[i]
        data[data_to_save_list[i]]={}
        data_point_list = read_DB_by_point.getData(db, tableName, str_to_code[data_point])
        print(data_point)
        # 进行数据清理。去掉跳变（跳成0那种，只去那种，因为是传输造成的。别去多了，不然有些本就是电池有问题造成的影响也弄没了）
        if data_point_list == []: print(data_point, ',点表：' + str_to_code[data_point] + '没数据');  # 空列表要告知
        if data_to_get_list[i]=='最高温度' or data_to_get_list[i]=='最低温度':threshold=Mod_temperature_change_threshold
        else:threshold=Cell_vol_change_threshold
        for j in range(0, len(data_point_list) - 1):
            if abs(data_point_list[j + 1] - data_point_list[j]) >= threshold:
                # print('有跳变，已被处理')
                data_point_list[j + 1] = data_point_list[j]
        data[data_to_save_list[i]]['value'] = data_point_list
        data[data_to_save_list[i]]['position'] = read_DB_by_point.getData(db, tableName, str_to_code[data_point+'位置'])
    # plt.figure('最低电压')
    # plt.plot(data_point_list)
    # plt.show()
    return data
def get_case_current():
    data_point = Cabin_to_choose + Case_to_choose + '总电流'
    data_point_list = read_DB_by_point.getData(db, tableName, str_to_code[data_point])
    print(tableName,data_point)
    if data_point_list == []: print(data_point, ',点表：' + str_to_code[data_point] + '没数据');  # 空列表要告知

    # plt.figure('簇的总电流')
    # plt.plot(data_point_list)
    # plt.show()
    return data_point_list
if __name__ == '__main__':
    global Cabin_to_choose,Case_to_choose,Cell_vol_change_threshold,Mod_temperature_change_threshold,tableName
    Cell_vol_change_threshold=20#改到很大，避免错过统计学异常
    Mod_temperature_change_threshold=50#改到很大，避免错过统计学异常
    Cabin_to_choose='1#储能站3-A#舱'
    for date in range(7,9):
        tableName = 'seconddata201907'+str(date).zfill(2)
        for case in [6]:
            Case_to_choose = str(case)+'#簇电池簇'
            case_current = get_case_current()
            # if 1:print(case_current);continue
            cells_voltage_data=get_cells_voltage()
            # print(cells_voltage_data[1])
            mod_voltage_data=get_mod_voltage(cells_voltage_data)
            # print(mod_voltage_data)
            mod_temperature_data=get_mod_temperature()
            # print(mod_temperature_data[3].keys())
            max_min_data=get_max_min_data()
            # print(max_min_data.keys())
            # print(max_min_data['最高温度'])

            this_case_data={}
            this_case_data['I']=case_current
            this_case_data['Vol_cells'] = cells_voltage_data
            this_case_data['Vol_mods']=mod_voltage_data
            this_case_data['Tem_mods']=mod_temperature_data
            this_case_data['max_min_position']=max_min_data
            io.savemat(tableName  + 'Cabin_3_A_Case_'+str(case).zfill(2)+'.mat', {'data': this_case_data})
