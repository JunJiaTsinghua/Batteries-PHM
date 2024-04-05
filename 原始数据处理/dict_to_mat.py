import numpy as np
import pickle
from scipy import io

for k in range (10,15):
    print('seconddata201907'+str(k).zfill(2)+'_1#储能站2-A#舱5#簇电池簇.pkl')
    this_case_data_mat={}
    with open('seconddata201907'+str(k).zfill(2)+'_1#储能站2-A#舱5#簇电池簇.pkl', 'rb') as f:#版本不同，用pickle的话要用wb和rb
        this_case_data = pickle.load(f)
    this_case_data_mat['I']=this_case_data['电流']

    V_cells={}
 
    for i in range(1,len(this_case_data['单体电压'].keys())+1):
        V_cells['V'+str(i)]=this_case_data['单体电压'][i]
    this_case_data_mat['Vol_cells']=V_cells

    V_mods={}
    for i in range(1,20):
        V_mods['V_mod'+str(i)]=this_case_data['模组电压'][i]
    this_case_data_mat['Vol_mods']=V_mods

    data_to_get_list = ['最高温度', '最低温度', '最高电压', '最低电压']
    data = {}
    data_to_save_list = ['TemMax', 'TemMin', 'VolMax', 'VolMin']
    for i in range(0, 4):
        data_point_list = this_case_data['极值与位置'][data_to_get_list[i]]
        data[data_to_save_list[i]]={}
        data[data_to_save_list[i]]['value'] = data_point_list['值']
        data[data_to_save_list[i]]['position'] = data_point_list['位置']
    this_case_data_mat['max_min_position']=data

    Tem_mods={}
    for i in range(1,20):
        Tem_mods['Mod'+str(i)]={}
        for j in range(1,5):
            Tem_mods['Mod' + str(i)]['Probe'+str(j)]=this_case_data['模组温度'][i][j]

    this_case_data_mat['Tem_mods']=Tem_mods

    io.savemat('seconddata201907'+str(k).zfill(2)+'Cabin_2_A_Case_05.mat', {'data': this_case_data_mat})


