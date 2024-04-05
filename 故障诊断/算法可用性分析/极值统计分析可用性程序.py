# 用于八步法第二步，极值统计分析里面，判断可测量参数的可勾选性。以及计算极值按钮的可用性


anlyse_target="XX 簇"

def main():
    res = [  # 默认带上方括号，与其他接口统一
        {
            "conclusion": "",  # 结论 页面没有就不管
            "running_state_by_sys": 1,  # 运行状态 1为正常，0为异常
            "chart": [],
            "msg": '',  # 额外信息 没有就不管
        }
    ]


    # 特征可用性的判断，没有的话需要计算
    if all_features not in 数据库:
        all_features = 特征可用性判断程序
    all_features_compute_flag = {}
    for i in ["可测量特征及其统计计算", "基于电气物理性质的进一步分析", "通过复杂模型计算"]:
        for key in all_features[i].keys():
            all_features_compute_flag[key] = all_features[i][key]

    # 判断可用性
    if all_features_compute_flag["电压极值"] or all_features_compute_flag["温度极值"] or all_features_compute_flag["电流极值"] :
        res[0]["button_MaxMin_available"] = 1
    else:
        res[0]["button_MaxMin_available"] = 0

    if all_features_compute_flag["电压极值"]:
        res[0]["checkBox_Vol_available"] = 1
    else:
        res[0]["checkBox_Vol_available"] = 0
    if all_features_compute_flag["温度极值"]:
        res[0]["checkBox_Tem_available"] = 1
    else:
        res[0]["checkBox_Tem_available"] = 0
    if all_features_compute_flag["电流极值"]:
        res[0]["checkBox_Current_available"] = 1
    else:
        res[0]["checkBox_Current_available"] = 0