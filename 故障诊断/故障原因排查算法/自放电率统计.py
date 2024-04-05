# 拿全部的静置片段的首尾的SOC或者V

import support_tools
import numpy as np
import pandas as pd
class VAR:
    time_interval=1 #时间间隔，都用秒吧
    V_cutoff_up=42
    V_cutoff_low=27


still_SOC_start_end=[[53,51],[20,20],[100,100]]
still_SOC_length=[6000,562,789]

still_V_start_end = [[28, 27.9], [41, 40.5], [39, 39]]
still_V_length = [6000, 562, 789]

data_label="Vol"

def main():
    #初始值
    res = [  # 默认带上方括号，与其他接口统一
        {
            "conclusion": "",  # 结论 页面没有就不管
            "running_state_by_sys": 1,  # 运行状态 1为正常，0为异常
            "chart": [],
            "msg": '',  # 额外信息 没有就不管
        }
    ]

    start_end=still_V_start_end
    still_length=still_V_length
    res=self_discharge(start_end,still_length,data_label, res)


    return res

def self_discharge(start_end,still_length, data_label,res):
    if data_label == "SOC":
        self_dis_rate=[]
        [self_dis_rate.append(round((start_end[i][0]-start_end[i][1])/(still_SOC_length[i]*VAR.time_interval/3600),2)) for i in range(len(still_length))]

    if data_label == "Vol":
        self_dis_rate = []
        [self_dis_rate.append(round((100*(start_end[i][0]-start_end[i][1])/(VAR.V_cutoff_up-VAR.V_cutoff_low))/(still_SOC_length[i]*VAR.time_interval/3600),2)) for i in range(len(still_length))]


    x=list(range(1,len(self_dis_rate)))
    single_chart = support_tools.write_chart(VAR.anlyse_target, VAR.cycle_list, "次数", "自放电率（%SOC/h）",
                                             "自放电率变化", "bar",
                                               x, [{"1": self_dis_rate}])
    res[0]["chart"].append(single_chart)
    if max(self_dis_rate)>5:
        res[0]["conclusion"]='自放电率偏高，请深入排查原因'
        res[0]["running_state_by_sys"]=0

main()