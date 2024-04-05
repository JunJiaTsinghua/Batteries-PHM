import support_tools
from itertools import groupby

"假数据，后面记得接成怀柔的"
import pandas as pd
data = pd.read_csv('铜牌连接示例数据.csv')  #
u_index = data.columns.str.startswith("bms_u_")  # 找到以这个开头的列名，是的就是Ture
u_index_1 = [i for i, x in enumerate(u_index) if x]  # 这些列的列数
V_cells = data.iloc[:, u_index_1[0:len(u_index_1)-1]]  # 拿出所有的单体电压（混进去了总电压）


T_index = data.columns.str.startswith("bms_t_")  # 找到以这个开头的列名，是的就是Ture
T_index_1 = [i for i, x in enumerate(T_index) if x]  # 这些列的列数
T_cells = data.iloc[:, T_index_1]  # 拿出所有的温度

class VAR:

    anlyse_target=""
    cycle_list=""


def main():
    #初始值
    res = [  # 默认带上方括号，与其他接口统一
        {        }
    ]
    res[0]["voltage_chart"]=voltage_example(V_cells)
    res[0]["temperature_chart"]=temperature_example(T_cells)
    res[0]["cut_off_voltage_chart"] =cut_off_statics()
    res[0]["discharge_electricity_chart"] =discharge_electricity_statics()

    return res

def voltage_example(V_cells):

    x=list(range(len(V_cells)))
    lines=[]
    for i in V_cells.columns:
        lines.append({i:V_cells[i].values.tolist()})
    single_chart = support_tools.write_chart(VAR.anlyse_target, VAR.cycle_list, "采样点", "电压(V)",
                                             "电压运行样例图", "lines", x, lines)
    return single_chart

def temperature_example(T_cells):
    x = list(range(len(T_cells)))
    lines = []
    for i in T_cells.columns:
        lines.append({i: T_cells[i].values.tolist()})
    single_chart = support_tools.write_chart(VAR.anlyse_target, VAR.cycle_list, "采样点", "温度(℃)",
                                             "温度运行样例图", "lines", x, lines)
    return single_chart

def cut_off_statics():
    cut_off_list=[2.50,2.51,2.52,2.53,2.52,2.53,2.52,2.50,2.50,3.64,3.65,3.65,3.66,3.64,3.64,3.67,3.68,3.66]
    # 返回柱状图
    x = []
    y = []
    for k, g in groupby(sorted(cut_off_list), key=lambda x: x // 0.01):
        x.append('{}-{}'.format(k * 0.01, (k + 1) * 0.01 - 0.001))
        y.append(len(list(g)))
    single_chart = support_tools.write_chart(VAR.anlyse_target, VAR.cycle_list, "电压区间", "出现次数",
                                             "截止电压分布图", "bar", x, [{"1": y}])
    return single_chart

def discharge_electricity_statics():
    discharge_electricity_list=[220,221,222,223,225,228,235,224,231,236]
    # 返回柱状图
    x = []
    y = []
    for k, g in groupby(sorted(discharge_electricity_list), key=lambda x: x // 2):
        x.append('{}-{}'.format(k * 2, (k + 1) * 2 - 0.1))
        y.append(len(list(g)))
    single_chart = support_tools.write_chart(VAR.anlyse_target, VAR.cycle_list, "电量区间", "出现次数",
                                             "可放出电量分布图", "bar", x, [{"1": y}])
    return single_chart

res=main()