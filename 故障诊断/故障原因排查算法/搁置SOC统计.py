from itertools import groupby
import support_tools
import numpy as np

#这个里面的内容是需要传入的
class VAR:
    threshod_high_soc=0.7
    threshod_high_rsik_soc_percentage=0.8
    threshod_middle_rsik_soc_percentage=0.5
    anlyse_target = ""
    cycle_list = ""

    V_cutoff_up=42  #TODO　这个是不是导入数据的时候要填的上下截止电压
    V_cutoff_low=27



#TODO　根据片段切割的index。拿到静止开始到结束的SOC。如果没有的话，就拿到开始到结束的电压。（对象是模组，就拿模组电压）。
still_SOC_start_end=[[53,51],[20,20],[100,100],[65,65],[100,99]]
still_SOC_length=[6000,562,789,20,50]
still_V_start_end = [[28, 27.9], [41, 40.5], [39,39]]
still_V_length = [6000, 562, 789]
data_label="Vol"  #TODO 这块儿怎么给个标志位？

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

    if data_label == "SOC":
        start_end=still_SOC_start_end
        still_length=still_SOC_length
    else:
        start_end = still_V_start_end
        still_length = still_V_length
    res=Still_SOC_Static(start_end, still_length,data_label,res)


    return res


def Still_SOC_Static(start_end, still_length,data_label,res):
    if data_label=="SOC":
        still_SOC = []
        [still_SOC.extend(list(np.ones(still_length[i])*start_end[i][0])) for i in range(len(start_end))]

    if data_label == "Vol":
        still_SOC = []
        [still_SOC.extend(list(np.ones(still_length[i])*round(100 * (start_end[i][0] - VAR.V_cutoff_low) / (VAR.V_cutoff_up - VAR.V_cutoff_low), 2))) for i in range(len(start_end))]


    x = sum(i >= 100 * VAR.threshod_high_soc for i in still_SOC)

    p_high_SOC_still = x / sum(still_SOC_length)
    if p_high_SOC_still < VAR.threshod_middle_rsik_soc_percentage:
        conclusion = "可能性很低.无法判断是否会导致必然的故障/隐患/异常后果"
        still_SOC_abnormal = 0
    if p_high_SOC_still > VAR.threshod_middle_rsik_soc_percentage and p_high_SOC_still < VAR.threshod_high_rsik_soc_percentage:
        conclusion = "可能性中等。较少情况下存在高SOC搁置情况。"
        still_SOC_abnormal = 1
    if p_high_SOC_still > VAR.threshod_high_rsik_soc_percentage:
        conclusion = "可能性很高。搁置时SOC普遍偏高，若存储温度偏高很容易造成衰减过快。"
        still_SOC_abnormal = 1

    # TODO 按照SOC10％的间隔，返回柱状统计图。
    # 返回柱状图
    x = []
    y = []
    for k, g in groupby(sorted(still_SOC), key=lambda x: x // 10):
        x.append('{}-{}'.format(k * 10, (k + 1) * 10 - 1))
        y.append(len(list(g)))
    single_chart = support_tools.write_chart(VAR.anlyse_target, VAR.cycle_list, "SOC区间", "出现次数",
                                             "静置SOC统计图", "bar", x, [{"1": y}])
    res[0]["chart"].append(single_chart)

    res[0]["conclusion"] = conclusion

    res[0]["running_state_by_sys"] = still_SOC_abnormal


    return res
main()


