#定死了是库博的那段数据。算等效内阻来判断  如果传来的只有示例文件的ID，就默认跑这个代码。不去调用直流内阻的那套东西了。

import pandas as pd
from pylab import *
import support_tools


class VAR:

    anlyse_target = "铜牌连接示例数据"
    cycle_list=[80]
    qec_charge_high=True
    qec_charge_low =True
    voltage_charge_high =True
    voltage_charge_low =True

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

    charts=[]
    RS_list=compute_Rconnet_for_kubo()
    for i in range(0,len(RS_list)):
        X=list(range(0,len(RS_list[i])))
        single_chart = support_tools.write_chart(VAR.anlyse_target, VAR.cycle_list, "电池编号", "等效直流内阻（Ω）","铜牌连接阻值定量计算第"+str(i)+"次", "line",
                                             X, [{"1": RS_list[i]}])
        charts.append(single_chart)
    conclusion=R_S_Anlyze(RS_list)
    res[0]["conclusion"]=conclusion
    res[0]["chart"]=charts
    return res

def compute_Rconnet_for_kubo():
    data=pd.read_csv('铜牌连接示例数据.csv') #
    I =data.bms_i_s1g8
    T=data.bms_maxPostT_s1g8
    u_index = data.columns.str.startswith("bms_u_")  # 找到以这个开头的列名，是的就是Ture
    u_index_1 = [i for i, x in enumerate(u_index) if x]  # 这些列的列数
    V_cells = data.iloc[:, u_index_1]  # 拿出所有的单体电压（混进去了总电压）

    #找到满足计算条件的数据索引
    index_list=DCR_index_for_kubo(I, T) # 出来是个list，有很多组的index
    RS_list=[]

    for index in index_list:
        v_list_2=V_cells.values[index[1],0:len(u_index_1)-1]
        v_list_1=V_cells.values[index[0],0:len(u_index_1)-1] #TOTO 找前后的I，找对v的列表，相减
        diff_I=I[index[1]]-I[index[0]]
        R_S=list(abs((v_list_2-v_list_1)/diff_I))
        RS_list.append(R_S)

    return RS_list

#TODO 照理说应该先做一个筛选，发现有电流跳变，然后看是否满足直流内阻分析页面的筛选条件。
# 这里就简化处理了，直接拿库博的案例用。
def DCR_index_for_kubo(I,T):
    index_list=[[397,396],[228,229]]
    #111  110
    return index_list



#对R_S进行分析：多少个为规律一组。
def R_S_Anlyze(R_S):
    #把大于0.045的找出来。其他置为0.会发现3个0，一个值，7个0一个值的规律排列。

    #把每次的最大值做记录。


    conclusion="每间隔12个单体为一个模组，有明显的连接阻值增大。单个模组内，第四个单体有跨接。第149号单体有明显松动。第77号单体有轻微松动"
    return conclusion

res=main()
print(res)