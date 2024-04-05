# 用于八步法第二步，横向对比法里面，判断三个按钮的可用性


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
    res[0]["button_TemRise_available"] = 1

    if all_features_compute_flag["电压差"] or all_features_compute_flag["温度差"] or all_features_compute_flag["电流差"]:
        res[0]["button_diff_available"] = 1
    else:
        res[0]["button_diff_available"] = 0

    if all_features_compute_flag["电压方差"] or all_features_compute_flag["温度方差"] or all_features_compute_flag["电流方差"]:
        res[0]["button_inconsist_available"] = 1
    else:
        res[0]["button_inconsist_available"] = 0
    #有这几个差值，就说明肯定有这几个数据
    if all_features_compute_flag["电压差"]:
        res[0]["checkBox_Vol_available"] = 1
    else:
        res[0]["checkBox_Vol_available"] = 0
    if all_features_compute_flag["温度差"]:
        res[0]["checkBox_Tem_available"] = 1
    else:
        res[0]["checkBox_Tem_available"] = 0
    if all_features_compute_flag["电流差"]:
        res[0]["checkBox_Current_available"] = 1
    else:
        res[0]["checkBox_Current_available"] = 0