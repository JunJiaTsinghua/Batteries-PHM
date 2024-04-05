from itertools import groupby
import pandas as pd
import numpy as np
class VAR:
    threshod_high_c=1
    threshod_high_rsik_c_percentage=0.8
    threshod_middle_rsik_c_percentage=0.5
    A_for_1C=50 #1C情况下的电流值



    # TODO，拿近一周的电流？随机抽取几天的电流？

#这块儿是测试用的。
# data = pd.read_csv('铜牌连接示例数据.csv')  #
# I_index = data.columns.str.startswith("bms_i_")  # 找到以这个开头的列名，是的就是Ture
# I_index_1 = [i for i, x in enumerate(I_index) if x]  # 这些列的列数
# I = data.iloc[:, I_index_1]  # 拿出所有的温度
# I=后端传入，根据对象和时间范围。

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

    res=C_rate_statics(I, res)


    return res


def C_rate_statics(I, res):
    C_rates=abs(I)/VAR.A_for_1C

    x=sum(sum((C_rates > VAR.threshod_high_c).values))#T
    p_high_C_rate=x/len(I)

    if p_high_C_rate<VAR.threshod_middle_rsik_c_percentage:
        conclusion="可能性很低。运行倍率处于正常范围，无法判断是否会导致必然的故障/隐患/异常后果"
        C_rate_abnormal=0
    if p_high_C_rate>VAR.threshod_middle_rsik_c_percentage and p_high_C_rate<VAR.threshod_high_rsik_c_percentage:
        conclusion = "可能性中等。有少量情况下倍率偏高，有导致衰减过快的倾向，但不太可能导致其他严重故障。"
        C_rate_abnormal =1
    if p_high_C_rate>VAR.threshod_high_rsik_c_percentage:
        conclusion = "可能性很高。运行倍率普遍偏高，可能会导致：老化速度增加，衰减过快；锂离子嵌入脱嵌应力造成材料颗粒损坏，在低温、低SOC区间长期运行容易析锂，形成内短路；倍率长期过大会导致产热量增加，影响系统散热。"
        C_rate_abnormal = 1

    x = []
    y = []
    C_rates_list=np.array(C_rates).flatten('C')
    for k, g in groupby(sorted(C_rates_list), key=lambda x: x // 0.5):
        x.append('{}-{}'.format(k * 0.5, (k + 1) * 0.5 - 0.1))
        y.append(len(list(g)))

    single_chart = support_tools.write_chart(VAR.anlyse_target, VAR.cycle_list, "倍率区间（C）", "次数",
                                             "倍率统计结果", "bar",
                                             x, [{"1": y}])
    res[0]["chart"].append(single_chart)

    res[0]["conclusion"] = conclusion
    res[0]["running_state_by_sys"] =C_rate_abnormal

    return res

main()
