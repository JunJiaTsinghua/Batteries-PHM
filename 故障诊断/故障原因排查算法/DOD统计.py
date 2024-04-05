from itertools import groupby
import support_tools
class VAR:
    threshod_deep_dod=0.7
    threshod_high_rsik_dod_percentage=0.8
    threshod_middle_rsik_dod_percentage=0.5

    V_cutoff_up=42
    V_cutoff_low=27
    diff_min=0.05

    anlyse_target=""
    cycle_list=""
# 如果有SOC，充放电片段切割，充电片段的结束SOC减去开始SOC
# 有个问题，如果是充电进程被中止，下一次的开始SOC跟上一次的结束SOC很接近，应该把这两次合为1 次
# [[10,20], [20, 50], [30, 80], [10,50], [48, 80]]把充电的SOC拿出来，放到列表里面。相邻两次的结束和开始SOC差距在5以内，说明中间
# 没有真的工作过。

SOC_range_list=[[10,20], [20, 50], [51,70],[30, 80], [10,50], [48, 80],[20,90]]
vol_range_list=[[28,35], [35.2, 41], [29, 42], [28,39], [38.6, 42],[29,40]]
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
    range_list=vol_range_list
    res=DOD_statics(range_list, data_label,res)


    return res

def DOD_statics(range_list, data_label,res):

    if data_label=="SOC":
        real_charge_section=[]

        for section in range(0,len(range_list)-1):
            diff=range_list[section+1][0]- range_list[section][1]
            if abs(diff) <VAR.diff_min*100:
                range_list[section+1][0]=range_list[section][0]
            else:
                real_charge_section.append(range_list[section])

        DOD=[]
        [DOD.append(round(i[1]-i[0],2)) for i in  real_charge_section]

    # 如果没有SOC，充放电片段切割后，是电压。
    # 相邻两次的结束和开始SOC差距在V_min以内，说明中间没有真的工作过。
    if data_label == "Vol":
        real_charge_section=[]

        for section in range(0,len(range_list)-1):
            diff=range_list[section+1][0]- range_list[section][1]
            if abs(diff) <(VAR.V_cutoff_up-VAR.V_cutoff_low)*VAR.diff_min:
                range_list[section+1][0]=range_list[section][0]
            else:
                real_charge_section.append(range_list[section])

        DOD=[]
        [DOD.append(round(100*(i[1]-i[0])/((VAR.V_cutoff_up-VAR.V_cutoff_low)),2)) for i in  real_charge_section]

    res[0]["trouble_reason"]=[] #TODO 这几个算法，都做一下原因append

    x=sum(i>=100*VAR.threshod_deep_dod for i in DOD)
    p_deep_DOD=x/len(DOD)
    if p_deep_DOD<VAR.threshod_middle_rsik_dod_percentage:
        conclusion="可能性很低。DOD处于正常范围，无法判断是否会导致必然的故障/隐患/异常后果"
        DOD_abnormal=0
    if p_deep_DOD>VAR.threshod_middle_rsik_dod_percentage and p_deep_DOD<VAR.threshod_high_rsik_dod_percentage:
        conclusion = "可能性中等。有少量情况下DOD较深，有导致衰减过快的倾向，但不太可能导致其他严重故障。"
        DOD_abnormal =1
    if p_deep_DOD>VAR.threshod_high_rsik_dod_percentage:
        conclusion = "可能性很高。DOD普遍较深，可能会导致：老化速度增加，衰减过快；部分质量较差的电池容易出现欠电压。进而导致不一致性显著；"
        DOD_abnormal = 1

    #返回柱状图
    x=[]
    y=[]
    for k, g in groupby(sorted(DOD), key= lambda x: x // 10):
        x.append('{}-{}'.format(k * 10, (k + 1) * 10 - 1))
        y.append(len(list(g)))
    single_chart = support_tools.write_chart(VAR.anlyse_target, VAR.cycle_list, "DOD 区间", "出现次数",
                                             "充放电深度统计图", "bar",x, [{"1": y}])
    res[0]["chart"].append(single_chart)

    res[0]["conclusion"]=conclusion

    res[0]["running_state_by_sys"]=DOD_abnormal

main()
