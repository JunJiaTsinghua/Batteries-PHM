import support_tools
import pandas as pd


#TODO 这些应当是从数据库拿的参数设置。并且能在那个汇总页面做修改。
class VAR:
    threshod_high_rsik_initial_inconsis=0.1
    threshod_middle_rsik_initial_inconsis=0.05
    threshold_initial_V_diff=[0.05,0.1,0.15]
    threshold_initial_V_var=[]

#TODO　拿最开始一周的单体电压数据。
# 为了后面能用df来算，这里用库博的做调试；
# V_cells=[[3.21,3.11,3.12,3.14,3.14],[3.21,3.11,3.12,3.14,3.14],[3.21,3.21,3.22,3.24,3.24]]
# data=pd.read_csv('铜牌连接示例数据.csv') #
# u_index = data.columns.str.startswith("bms_u_")  # 找到以这个开头的列名，是的就是Ture
# u_index_1 = [i for i, x in enumerate(u_index) if x]  # 这些列的列数
# V_cells = data.iloc[:, u_index_1]  # 拿出所有的单体电压（混进去了总电压）

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

    res=initial_incons_anlyze(V_cells, res)


    return res

def initial_incons_anlyze(V_cells,res):
    max_list=V_cells.max(axis=1) #求df每行的最值
    min_list=V_cells.min(axis=1)
    V_diff=max_list-min_list


    flag_high=0
    flag_middle=0

    times_level1=sum(i>VAR.threshold_initial_V_diff[0] for i in V_diff)
    times_level2=sum(i>VAR.threshold_initial_V_diff[1] for i in V_diff)
    times_level3=sum(i>VAR.threshold_initial_V_diff[2] for i in V_diff)

    p_level1=times_level1/len(V_diff)
    p_level2=times_level2/len(V_diff)
    p_level3=times_level3/len(V_diff)

    if p_level1>VAR.threshod_high_rsik_initial_inconsis: #一级异常比较多
        flag_middle=1
    if p_level2>VAR.threshod_middle_rsik_initial_inconsis:#二级异常比较多
        flag_middle=1
    if p_level2>VAR.threshod_high_rsik_initial_inconsis:#二级异常非常多
        flag_high=1
    if p_level3>VAR.threshod_middle_rsik_initial_inconsis:#三级异常比较多
        flag_high=1

    if flag_high:
        conclusion="可能性很高。初始不一致性很明显，说明早期电池单体之间直流参差不齐或系统集成有问题。是导致后续温差大、压差大、电流差大等" \
                   "不一致性显著的重要原因。木桶效应持续变严重，会导致可用电量更快下降，表现出衰减过快 。当不一致性非常严重后，均衡系统可能无法起到良好效果。"

    if not flag_high and  flag_middle:
        conclusion = "可能性中等。初始不一致性不明显，可能不是导致后续不一致性变严重的主要原因。"

    if not flag_high and not flag_middle:
        conclusion="可能性很低。初始一致性良好。无法判断是否会导致必然的故障/隐患/异常后果"

    res[0]["conclusion"]=conclusion
    X=list(range(1,len(V_diff)+1))
    single_chart = support_tools.write_chart(VAR.anlyse_target, VAR.cycle_list, "数据点", "压差（V）",
                                             "初始电压不一致性分析", "line",
                                             X, [{"1": list(V_diff)}])

    res[0]["chart"].append(single_chart)

    return res