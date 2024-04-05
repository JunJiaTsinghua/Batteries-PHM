# 也可以用在基于曲线拟合的寿命预测那里
# 点开这个页面后，根据页面选择的“预测依据”调用一次/若“预测依据”被用户改了，再调用一次
# 查看是否库里面已经存在所需要的预测依据，若没有则调用特征可用性判断程序，能算的话提示框提示要多花点时间哟


prediction_material="容量"

def main():
    res = [  # 默认带上方括号，与其他接口统一
        {
            "conclusion": "",  # 结论 页面没有就不管
            "running_state_by_sys": 1,  # 运行状态 1为正常，0为异常
            "chart": [],
            "msg": '',  # 额外信息 没有就不管
        }
    ]

    # 预测依据，容量、电量变化量方差、ICA峰值，是否已经存在了库中(对象、时间段都满足才叫在库中)
    if prediction_material in XXXX and 关联对象==预测对象 and 时间范围==全部: #做寿命预测必须要过去的所有循环/天的特征都提取过

        res[0]["msg"]= "已经具备使用该特征进行预测的条件，可以继续分析"
        res[0]["button_available"]= 1


    if prediction_material not in data_base:
        all_features_compute_flag = support_tools.check_feature_availabel()
        if all_features_compute_flag[prediction_material]:
           res[0]["msg"] = "该特征暂未计算，但具备计算该特征的条件，继续计算会花费额外的特征计算时间"
           res[0]["button_available"] = 1
        else:
           res[0]["msg"] = "不具备计算该特征的条件，请重新选择"
           res[0]["button_available"] = 0