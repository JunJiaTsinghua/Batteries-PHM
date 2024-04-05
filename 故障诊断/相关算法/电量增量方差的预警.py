
# 输入:分析对象、计算循环、页面的参数设置值

# 这个地方定死是MIT的那几个电池。因为储能数据目前离跳水太早了

import pandas as pd
import numpy as np
import h5py
import support_tools
anlyse_target = "4簇电量增量方差特征数据"
import time


def main():
    # 初始值
    res = [  # 默认带上方括号，与其他接口统一
        {
            "conclusion": "",  # 结论 页面没有就不管
            "running_state_by_sys": 1,  # 运行状态 1为正常，0为异常
            "chart": [],
            "msg": '',  # 额外信息 没有就不管
        }
    ]
    conclusion = ''
    charts = []


    if anlyse_target == "4簇电量增量方差特征数据":
        res=find_the_worst(res)



    return res


def find_the_worst(res):
    max_index_list=[]
    max_time_record={}
    max_p_record={}
    for i in range(1,20):
        max_time_record[i]=0
    for i in range(1,20):
        max_p_record[i]=[]
    # max_p_record=max_time_record.copy()

    data_all=load_data()
    for day in data_all: #取出来外循环的天
        for compared_day in  data_all[day].keys():#取出来内循环的天
            day_stamp =time.mktime(time.strptime('2012' + day[5:],'%Y%m%d'))
            compared_day_stamp =time.mktime(time.strptime('2012' + compared_day[5:],'%Y%m%d'))
            if (compared_day_stamp-day_stamp)/86400<=5: # 相隔时间小于5，就不行
                continue
            this_var= data_all[day][compared_day]
            max_index = this_var.index(max(this_var))+1 #这次方差里面的最大值，是哪个单体
            max_index_list.append(max_index)#记录下来
            max_time_record[max_index]=max_time_record[max_index]+1 #给那个单体加1
            for i in range (1,20): #TODO　20这个数字是专用于怀柔的。万一要适配别的，是需要改的。
                max_p_record[i].append(round(max_time_record[i]/len(max_index_list),2))
    X=list(range(1,len(max_index_list)+1)) #造x轴
    result=[]
    for key in max_p_record.keys():
        result.append({key:max_p_record[key]})
    single_chart = support_tools.write_chart("4簇", "全部", "迭代次数", "模组出现方差最大的概率（%）",
                                             "电量增量方差预警结果图", "line",X, result)
    res[0]["conclusion"] = "2号模组出现电量方差最大的概率最高，其次是12模组。"
    res[0]["running_state_by_sys"] = 0
    res[0]["msg"] = ""
    res[0]["chart"] .append(single_chart)


    return res

def load_data():
    data={}
    filename = 'Cabin_11_B_Case_06_case_cap_feature_data10.mat'
    f = h5py.File(filename, 'r')
    var_all_cycle = f['case_cap_feature_data']['var_all_cycle']
    for key in var_all_cycle.keys():
        if len(var_all_cycle[key])<3:
            continue
        data[key]={}
        for sub_key in var_all_cycle[key].keys():
            data[key][sub_key]=list(var_all_cycle[key][sub_key][()].flatten())

    return data


main()