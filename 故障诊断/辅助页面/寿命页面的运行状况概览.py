import support_tools
from itertools import groupby
class VAR:

    anlyse_target=""
    cycle_list=""


def main():
    #初始值
    res = [  # 默认带上方括号，与其他接口统一
        {        }
    ]
    res[0]["DOD_chart"]=DOD_statics()
    res[0]["SOC_chart"]=SOC_statics()
    res[0]["operating_ratio_chart"] =operating_ratio_statics()
    res[0]["temperature_chart"] =temperature_statics()

    return res

def DOD_statics():
    DOD=[20,23,44,12,67,23,73,47,42,72,87]
    # 返回柱状图
    x = []
    y = []
    for k, g in groupby(sorted(DOD), key=lambda x: x // 10):
        x.append('{}-{}'.format(k * 10, (k + 1) * 10 - 1))
        y.append(len(list(g)))
    single_chart = support_tools.write_chart(VAR.anlyse_target, VAR.cycle_list, "DOD区间", "出现次数",
                                             "充放电深度统计图", "bar", x, [{"1": y}])
    return single_chart

def SOC_statics():
    SOC=[15,45,85,65,12,43,57,42,65,96,23]
    # 返回柱状图
    x = []
    y = []
    for k, g in groupby(sorted(SOC), key=lambda x: x // 10):
        x.append('{}-{}'.format(k * 10, (k + 1) * 10 - 1))
        y.append(len(list(g)))
    single_chart = support_tools.write_chart(VAR.anlyse_target, VAR.cycle_list, "SOC区间", "出现次数",
                                             "起充SOC统计图", "bar", x, [{"1": y}])
    return single_chart

def operating_ratio_statics():
    C_rates_list=[1.2,1,0.8,1.5,2.2,2.6,1.9,2,1]
    # 返回柱状图
    x = []
    y = []
    for k, g in groupby(sorted(C_rates_list), key=lambda x: x // 0.5):
        x.append('{}-{}'.format(k * 0.5, (k + 1) * 0.5 - 0.1))
        y.append(len(list(g)))
    single_chart = support_tools.write_chart(VAR.anlyse_target, VAR.cycle_list, "倍率区间", "出现次数",
                                             "倍率统计图", "bar", x, [{"1": y}])
    return single_chart

def temperature_statics():
    temper_list=[25,24,26,28,29,31,35,34,38,32,18,19,19,25,24,27,35]
    # 返回柱状图
    x = []
    y = []
    for k, g in groupby(sorted(temper_list), key=lambda x: x // 2):
        x.append('{}-{}'.format(k * 2, (k + 1) * 2 - 0.1))
        y.append(len(list(g)))
    single_chart = support_tools.write_chart(VAR.anlyse_target, VAR.cycle_list, "温度区间", "出现次数",
                                             "温度统计图", "bar", x, [{"1": y}])
    return single_chart

res=main()