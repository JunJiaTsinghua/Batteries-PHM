

def check_feature_availabel():
    # 特征可用性的判断，没有的话需要计算
    if all_features not in 数据库:
        all_features = 特征可用性判断程序
    all_features_compute_flag = {}
    for i in ["可测量特征及其统计计算", "基于电气物理性质的进一步分析", "通过复杂模型计算"]:
        for key in all_features[i].keys():
            all_features_compute_flag[key] = all_features[i][key]
    return all_features_compute_flag

def write_chart(obj,cycle,x_title,y_title,table_title,chart_type,key,value):
    single_chart={
                "obj": obj,
                "cycle": cycle,
                'x_title':x_title,  # X轴标题
                'y_title': y_title,  # Y轴标题
                'table_title': table_title,  # 表名
                "type": chart_type,  # 图像类型： line，bar
                "key": key,  # 横坐标
                'value':value  # 纵坐标
     }

    return  single_chart

def write_data(obj,cycle,key,value):
    single_data =  {
            "obj": obj,
        "cycle": cycle,
            "data": [
                {
                    "key": key,  # 横坐标
                    'value': value  # 纵坐标
                }
            ]

        }
    return single_data

def write_conclusion(conclusion,sentense):
    if len(conclusion)>0:
        conclusion=conclusion+'\n'
    conclusion=conclusion+sentense

    return  conclusion
def combine_res(res,res1):
    #合并信息
    if len(res[0]["msg"]) > 0:
        res[0]["msg"] = res[0]["msg"] + '\n'
        res[0]["msg"] = res[0]["msg"] + res1[0]["msg"]


     #合并结论
    if len(res[0]["conclusion"]) > 0:
        res[0]["conclusion"] = res[0]["conclusion"] + '\n'
        res[0]["conclusion"]=res[0]["conclusion"] +res1[0]["conclusion"]

     #改变标志位，有0就是0。否则就不动
    if res[0]["running_state_by_sys"]==0 or res1[0]["running_state_by_sys"]==0:
        res[0]["running_state_by_sys"] = 0

    #合并图
    res[0]["chart"].extend( res1[0]["chart"])

    return res