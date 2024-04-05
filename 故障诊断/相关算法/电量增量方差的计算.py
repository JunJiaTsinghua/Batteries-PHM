# 返回两组，MIT的，后续是拿去算综合评分；怀柔的，后续是拿去做预警。
#cabin_11_B_Case_06_case_cap_feature_data10.mat 如果是怀柔的数据就算了，那个转py的难度太大了
#cell_1_4_5_10_100.mat 如果是MIT的，就还是从原始数据拿一下，然后计算差值
import h5py
import scipy.io as  scio
import numpy as  np
anlyse_target = '4簇电量增量方差特征数据'
import support_tools

def main():
    # 初始值
    res = [  # 默认带上方括号，与其他接口统一
        {
            "conclusion": "",  # 结论 页面没有就不管
            "running_state_by_sys": 1,  # 运行状态 1为正常，0为异常
            "chart": [],
            "msg": '',  # 额外信息 没有就不管
        }
    ]
    conclusion = ''
    charts = []


    if anlyse_target == "MIT数据集示例电池":
        res = VAR_qec_for_MIT(res)

    if anlyse_target == "4簇电量增量方差特征数据":
        res = load_data(res)



    return res

def VAR_qec_for_MIT(res):
    filename = 'cell_1_4_5_10_100.mat'
    data_dict={}
    f=scio.loadmat(filename)
    data=f['cells']
    names=data.dtype.names
    bat_num=np.shape(data)[1]
    for name in names:
        data_dict[name]={}
        for i in range(bat_num):
            data_dict[name][i]=data[name ][0][i][()].flatten()
    diff_10_100={}
    var_10_100=[]


    for i in range(bat_num):
        diff_10_100[i]=list(data_dict['Qdlin100'][i]-data_dict['Qdlin10'][i])
        var_10_100.append({i:np.var(diff_10_100[i])})

    X = list(range(1, 1001))
    single_chart = support_tools.write_chart("MIT数据集示例电池", "全部", "数据点（插值后）", "电量（插值后）",
                                             "电量增量图（循环10-100）", "line", X, diff_10_100)

    res[0]['chart'].append(single_chart)

    X = list(range(1, bat_num+1))
    single_chart = support_tools.write_chart("MIT数据集示例电池", "全部", "电池编号", "电量增量方差",
                                             "电量增量方差图（循环10-100）", "line", X, {"方差":var_10_100})
    res[0]['chart'].append(single_chart)

    diff_1_5 = {}
    var_1_5 = []
    for i in range(bat_num):
        diff_1_5[i]=list(data_dict['Qdlin5'][i]-data_dict['Qdlin1'][i])
        var_1_5.append(np.var(diff_1_5[i]))

    X = list(range(1, 1001))
    single_chart = support_tools.write_chart("MIT数据集示例电池", "全部", "数据点（插值后）", "电量（插值后）",
                                             "电量增量图（循环1-5）", "line", X, diff_1_5)

    res[0]['chart'].append(single_chart)

    X = list(range(1, bat_num + 1))
    single_chart = support_tools.write_chart("MIT数据集示例电池", "全部", "电池编号", "电量增量方差",
                                             "电量增量方差图（循环1-5）", "line", X, {"方差": var_1_5})
    res[0]['chart'].append(single_chart)


    life=[]
    for i in range(bat_num):
        life.append(data_dict['life'][i][0])

    single_chart = support_tools.write_chart("MIT数据集示例电池", "全部", "电池编号", "圈数",
                                             "全部电池寿命", "line", X, {"寿命": life})
    res[0]['chart'].append(single_chart)

    return res


def load_data(res):
    data = {}
    filename = 'Cabin_11_B_Case_06_case_cap_feature_data10.mat'
    f = h5py.File(filename, 'r')
    var_all_cycle = f['case_cap_feature_data']['var_all_cycle']
    lines=[]
    for key in var_all_cycle.keys():
        if len(var_all_cycle[key]) < 3:
            continue
        data[key] = {}
        for sub_key in var_all_cycle[key].keys():
            line_name = key + sub_key
            lines.append({line_name: list(var_all_cycle[key][sub_key][()].flatten())})
    X = list(range(1, 20))
    single_chart = support_tools.write_chart("4簇电量增量方差特征数据", "全部", "电池编号", "电量增量方差",
                               "电量增量曲线", "line", X, lines)
    res[0]['chart'].append(single_chart)


    return res

main()