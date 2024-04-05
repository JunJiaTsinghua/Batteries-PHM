# 用于八步法第一步，SOP对比判断里面，判断两个按钮的可用性



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

    #如果循环数太少了，就不用分析了
    if max_cycle_num<30: # 右边那个循环
        res[0]["button_SOC_SOE_available"] = 0
        res[0]["button_Ah_available"] = 1
    else:
        #SOC_SOE方法的可用性
        if "SOC_SOP" not in 数据库 # TODO 这个不属于中间特征，属于是属性信息，导入时候填的那个，一般都没有
            res[0]["button_SOC_SOP_available"]= 0
        else:
            res[0]["button_SOC_SOP_available"] = 1
        #等效电路法始终不可用吧 #TODO　最后有精力的时候再去搞
        res[0]["button_SOC_SOP_available"] = 1

        #等效直流内阻的可用性

        all_features_compute_flag = support_tools.check_feature_availabel()

        # 判断可用性
        if all_features_compute_flag["等效直流内阻"]:
            res[0]["button_Ah_available"] = 1
        else:
            res[0]["button_Ah_available"] = 0




    return res