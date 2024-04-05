import support_tools
import numpy as np
import pandas as pd
class VAR:
    [worst_low_temper, lowest_temper_advise, highest_temper_advise, worst_high_temper] = [-10, 15, 60, 90]
    [threshold_p_worst_low, threshold_p_bad_low , threshold_p_bad_high,threshold_p_worst_high] = [0.01,0.1, 0.1,0.01]
    threshold_temper_diff=3
    threshold_temper_var=1


#TODO　拿最开始一周的单体电压数据。是不是已经算过压差了？如果算过了，就拿压差数据。
# 为了后面能用df来算，这里用库博的做调试；
#temper_data=[[20,25,12,13,12],[20,25,12,13,12],[20,18,12,13,12],[20,-15,65,13,12],[10,68,12,-15,12],]
data=pd.read_csv('铜牌连接示例数据.csv') #
T_index = data.columns.str.startswith("bms_t_")  # 找到以这个开头的列名，是的就是Ture
T_index_1 = [i for i, x in enumerate(T_index) if x]  # 这些列的列数
T_cells = data.iloc[:, T_index_1]  # 拿出所有的温度

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

    res=temper_anlyse(T_cells, res)


    return res

def temper_anlyse(T_cells, res):


    #看不一致性的分布
    max_list = T_cells.max(axis=1)  # 求df每行的最值-其实还是个series，不是list
    min_list = T_cells.min(axis=1)
    temper_diff=max_list-min_list

    temper_var=T_cells.var(axis=1)



    #看极值的分布

    # temper_list = np.array(T_cells).flatten('C') #把Arrray拍成list。

    p_worst_low=sum(sum((T_cells<VAR.worst_low_temper).values))/(T_cells.shape[0]*T_cells.shape[1])
    p_bad_low=(sum(sum((T_cells < VAR.lowest_temper_advise).values))-sum(sum((T_cells < VAR.worst_low_temper).values)))/(T_cells.shape[0]*T_cells.shape[1])
    p_worst_high=sum(sum((T_cells > VAR.worst_high_temper).values))/(T_cells.shape[0]*T_cells.shape[1])

    p_bad_high=(sum(sum((T_cells > VAR.highest_temper_advise).values))-sum(sum((T_cells > VAR.worst_high_temper).values)))/(T_cells.shape[0]*T_cells.shape[1])


    conclusion1="可能性很低。环境温度长期均在适宜区间，无法判断是否会导致必然的故障/隐患/异常后果"
    if p_bad_high>VAR.threshold_p_bad_high:
        conclusion1="可能性很高。环境温度长期偏高，会导致衰减过快、异常自耗电明显。"
    if p_bad_low>VAR.threshold_p_bad_low:
        conclusion1="可能性很高。环境温度长期偏低，容易促成析锂，进而内短路发生。"
    if p_bad_low>VAR.threshold_p_bad_low and  p_bad_high>VAR.threshold_p_bad_high:
        conclusion1="可能性很高。环境温度出现过偏高和偏低，请进一步检查壳体密闭性和保温/散热系统。"

    temper_diff_high_times=sum(i>VAR.threshold_temper_diff for i in temper_diff)
    p_temper_diff=temper_diff_high_times/len (temper_diff)
    temper_var_high_times=sum(i>VAR.threshold_temper_var for i in temper_var)
    p_temper_var=temper_var_high_times/len (temper_var)

    conclusion2="可能性很低。环境温度比较一致，无法判断是否会导致必然的故障/隐患/异常后果"

    if p_temper_diff>0.1 or p_temper_var>0.1:
        conclusion2="可能性很高。环境温度长期分布不均，会导致不一致性显著。"

    conclusion=conclusion1+conclusion2

    res[0]["conclusion"]=conclusion
    X=list(range(1,len(temper_diff)+1))
    single_chart = support_tools.write_chart(VAR.anlyse_target, VAR.cycle_list, "数据点", "温差（摄氏度）",
                                             "环境温度差", "line",
                                             X, [{"1": list(temper_diff)}])

    res[0]["chart"].append(single_chart)

    single_chart = support_tools.write_chart(VAR.anlyse_target, VAR.cycle_list, "数据点", "温度（摄氏度）",
                                             "最高温度", "line",
                                             X, [{"1": list(max_list)}])
    res[0]["chart"].append(single_chart)

    single_chart = support_tools.write_chart(VAR.anlyse_target, VAR.cycle_list, "数据点", "温差（摄氏度）",
                                             "最低温度", "line",
                                             X, [{"1": list(min_list)}])
    res[0]["chart"].append(single_chart)

    return res

main()