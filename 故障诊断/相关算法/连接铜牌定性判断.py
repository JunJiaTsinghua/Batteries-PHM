# 输入：分析对象、分析范围、拓扑图的结构说明信息、分析循环列表、分析内容
# 输出：判断返回结论
# 两个可以很好用于展示的案例，z999000001314task10.csv的230-231---已经找到了充高放低的证据
# seconddata20191118Cabin_3_A_Case_06.mat 的12244-12248 ---这个不好用，有时移，有时候是5s，有时候不是
import support_tools
import pandas as  pd


class VAR:
    topu_description="该电池为8个单体串联为1个模组，模组之间串联。1号和8号单体的电压传感器包含一个电池，其他传感器包含一个单体和一个铜牌。" #这句话不应该是我这儿写死。应该是从数据库去拿这个站点绑定的这句话。但是由于我们上传录入的时候没有做。先这样写死用着

    # 输入值 TODO 这个是从前端来的
    anlyse_target="铜牌连接示例数据"
    cycle_list="近七天"
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
    conclusion = ''
    flag_continue_compute = 1
    charts=[]
    res_ = res.copy()
    #依次分析选中的现象
    #最好不用这种eval
    # for item in anlyse_content:
    #     eval_str = "result=" + item + "(" + anlyse_target + ")"
    #     eval(eval_str)
    #     eval("results[item]=result")
    #就一个个调用吧
    if VAR.qec_charge_high:

        res1=charge_qec_compare(res_)
        res=support_tools.combine_res(res,res1)
    if VAR.qec_charge_low:
        res1=discharge_qec_compare(res_)
        res=support_tools.combine_res(res,res1)
    if VAR.voltage_charge_high:
        res1=charge_vol_compare(res_)
        res = support_tools.combine_res(res, res1)
    if VAR.voltage_charge_low:
        res1=discharge_vol_compare(res_)
        res = support_tools.combine_res(res, res1)


    # # 其中任意一个有明显现象，就判断存在问题
    # for key in results:
    #     charts.append(results[key]["chart"])
    #     if results[key]["flag_by_algorithm"]:
    #         flag_continue_compute=1
    #         running_state_by_sys=0

    #综合拓扑结构进行判断
    if "一个电池和一个铜牌" in VAR.topu_description :
        if not res[0]["running_state_by_sys"]:
            conclusion=support_tools.write_conclusion(conclusion, '连接铜牌存在异常，建议进一步定量分析')
        else:
            conclusion =support_tools.write_conclusion(conclusion, '根据计算结果，未得出显著的异常/故障/隐患结论')
    else:
        if not res[0]["running_state_by_sys"]:
            conclusion = support_tools.write_conclusion(conclusion, '可能存在连接铜牌异常问题，但拓扑结构不允许定量计算')

        else:
            conclusion = support_tools.write_conclusion(conclusion, '信息不足，无法判断')


    #把计算过程赋值到res中
    res[0]["conclusion"]=conclusion
    res[0]["charts"]=charts
    res[0]["flag_continue_compute"] = flag_continue_compute

    return res

#TODO 给几个库博的

def charge_qec_compare(res):

    res[0]["msg"]="该数据集采样颗粒度过大，计算所得的充电电量数据不具备参考性；"
    return res


def discharge_qec_compare(res):

    res[0]["msg"]="该数据集采样颗粒度过大，计算所得的放电电量数据不具备参考性；"
    return res


def charge_vol_compare(res):
    #刚开始充电的4到80 .就有5号单体很明显偏高

    data = pd.read_csv('铜牌连接示例数据.csv')  #
    u_index = data.columns.str.startswith("bms_u_")  # 找到以这个开头的列名，是的就是Ture
    u_index_1 = [i for i, x in enumerate(u_index) if x]  # 这些列的列数
    V_cells = data.iloc[4:80, u_index_1[0:10]]  # 拿出所有的单体电压（混进去了总电压）
    lines=[] #TODO 这块儿改过
    for key in V_cells.keys():
        lines.append({key: list(V_cells[key])})

    single_chart = support_tools.write_chart(VAR.anlyse_target, VAR.cycle_list, "数据点", "电压（V）",
                                             "充电电压细节图", "line",lines)

    res[0]["chart"].append(single_chart)
    res[0]["conclusion"]="发现了个别单体充电过程电压偏高的现象"
    res[0]["running_state_by_sys"] =0

    return res


def discharge_vol_compare(res):
    # 110-145，也是这个单体明显偏低
    data = pd.read_csv('铜牌连接示例数据.csv')  #
    u_index = data.columns.str.startswith("bms_u_")  # 找到以这个开头的列名，是的就是Ture
    u_index_1 = [i for i, x in enumerate(u_index) if x]  # 这些列的列数
    V_cells = data.iloc[110:145, u_index_1[0:10]]  # 拿出所有的单体电压（混进去了总电压）
    lines = []
    for key in V_cells.keys():
        lines.append({key:list(V_cells[key])})

    single_chart = support_tools.write_chart(VAR.anlyse_target, VAR.cycle_list, "数据点", "电压（V）",
                                                "放电电压细节图", "line", lines)
    res[0]["chart"].append(single_chart)

    res[0]["conclusion"] ="发现了个别单体放电过程电压偏低的现象"
    res[0]["running_state_by_sys"] = 0

    return res


main()