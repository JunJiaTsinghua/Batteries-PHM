# 输入：分析的对象、需计算的循环、预处理参数：{“剔除异常值方法”：“……”，填补遗漏值方法”：“……”，“平滑滤波算法”：“……”}
# 输出：被美化处理过的运行曲线。多条line图画到一起
# 先搞成一版能用的。。其实不完整，说了那么多预处理，其实就只用了三次样条
import support_tools
import numpy as np
from scipy.interpolate import interp1d

class VAR:
    max_cycle=11 #默认去拿充电的循环数（电网工况的放电一般都不可能是恒流）
    targets=["模组1","模组2"]

anlyse_target = "4模组"# \""4模组所有单体" #是个列表。主函数要循环分析--可能进来时候是个字符串
anlyse_cyle="all" #"1,80" #也是个列表---可能进来时候是个字符串
station_name='库博'


def main():
    # 初始值
    res = [  # 默认带上方括号，与其他接口统一
        {
            "conclusion": "",  # 结论 页面没有就不管
            "running_state_by_sys": 1,  # 运行状态 1为正常，0为异常
            "chart": [],
            "msg": '',  # 额外信息 没有就不管
            # "data":[]

        }
    ]



    conclusion = ''
    running_state_by_sys = 1

    datas=[]
    # 主要过程

    charts=data_pre_deal()



    # 把计算过程赋值到res中
    res[0]["conclusion"] = conclusion
    res[0]["chart"] = charts
    res[0]["running_state_by_sys"] = running_state_by_sys

    return res


# 做预处理的主流程函数
def data_pre_deal():
    charts = []
#分析需要计算的对象和循环
    if "模组" in anlyse_target[len(anlyse_target) - 2:] and "所有" not in anlyse_target:
        targets=VAR.targets
    if "簇" in anlyse_target[len(anlyse_target) - 2:] and "所有" not in anlyse_target:
        targets = VAR.targets
    if "所有模组" in anlyse_target:
        targets = VAR.targets
    if "所有单体" in anlyse_target:
        targets = VAR.targets

    if anlyse_cyle == "all":
        max_cyle = VAR.max_cycle
        anlyse_cyles = range(1, max_cyle + 1)
    else:
        anlyse_cyles = list(map(int, anlyse_cyle.split(",")))

    for target in  targets: #TODO 不是特别对。Ah_data不一定是有的，如果没有，应该是用I_data来算才对

        for cycle in anlyse_cyles:
            V_data= 用当前的对象和循环拿到对应的数据

            SOC_data= 用当前的对象和循环拿到对应的数据
            I_data= 用当前的对象和循环拿到对应的数据


            Ah_data= 用当前的对象和循环拿到对应的数据


            Ah_data_smooth,V_data_smooth=spline(Ah_data, V_data)

            single_chart=support_tools.write_chart(target,cycle,"SOC","电压",target+"第"+str(cycle)+"个循环的平滑数据","line",Ah_data_smooth,{"1":V_data_smooth})
            # single_data=write_data(target,cycle,SOC_data_smooth,{"1":V_data_smooth})
            charts.append(single_chart)
                # datas.append(single_data)Ah.append(Ah[-1]+float(i_total[-1])*300/3600)
    return charts


#这个是噪音滤除函数，采用三次样条曲线插值去平滑数据
def spline(x, y):
    try:
        f = interp1d(x, y, kind='cubic')  # 三次样条插值
    except ValueError:
        return [], []
    # n=len(T)
    x_pred = np.linspace(min(x), max(x), num=800)
    y_pred = f(x_pred)
    # figure('三次样条插值')
    # plot(x_pred, y2, 'b', label='cubic')
    return x_pred, y_pred
