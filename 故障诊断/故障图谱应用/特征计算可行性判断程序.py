#可以用在自定义诊断页面的时候判断特征可用性
#也可以用在其他相关的算法页面，第一次调用后，存起来，后面直接拿结果。


#TODO 下面的这些参数需要传入。
analyze_object="怀柔储能电站-11B舱-6簇-2模组"
analyze_range=""
station_topu={"舱":0,"簇":2,"模组":19,"单体":12,"探针":4}
data_quality={"数据维度":["总电压","总电流","模组电压","单体电压","温度"],"电压":0.01,"电流":0.01,"温度":1,"时间":1,"额外信息":["上截止电压","下截止电压","额定容量"],"空值个数":0,"漏值个数":0,"错值个数":0}

#TODO 这儿需要做一个绑定，各个数据集是固定的描述。？？问题是绑在哪儿呢？
working_condition="随电力系统调度指令充放电，无明显规律，为多阶段恒功率运行，存在大倍率阶跃"

class VAR:
    dcr_min_voltage_accuracy=0.05
    dcr_min_current_accuracy=0.05
    dcr_min_time_accuracy=1
    rc_min_voltage_accuracy = 0.05
    rc_min_current_accuracy = 0.05
    rc_min_time_accuracy = 1
    ah_min_current_accuracy=0.01
    ah_min_time_accuracy=1
    qecvar_min_voltage_accuracy = 0.05
    ahvar_min_current_accuracy= 0.05
    chiyu_min_voltage_accuracy= 0.05
    chiyu_min_current_accuracy = 0.05
    chiyu_min_time_accuracy=1
    ica_min_voltage_accuracy= 0.05
    ica_min_current_accuracy= 0.05
    ica_min_time_accuracy=1

def feature_available_judge(analyze_object,analyze_range,station_topu,data_quality,working_condition):

    all_features={"可测量特征及其统计计算":{"电压极值":0,"温度极值":0,"电压差":0,"温度差":0,"电压方差":0,"温度方差":0,"电压熵":0,
                             "温度熵":0,"温升":0,"等效循环数":0,"完整充电时间":0,"完整放电时间":0,"等压升充电时间":0,"等压降放电时间":0},
"基于电气物理性质的进一步分析":{"等效直流内阻":0,"等效电路内阻":0,"等效电路电容":0,"可放出电量":0,"容量衰减斜率":0,"自放电率":0},
"通过复杂模型计算":{"电量增量方差":0,"弛豫电压特征":0,"ICA特征":0,"SEI膜厚度":0,"LAM":0,"LLI":0}}


    #一定能够用的：
    if "温度" in data_quality["数据维度"]:
        all_features["可测量特征及其统计计算"]["温升"] = 1

    #根据实际情况判断一轮

    #模组级别的电压横向统计分析，有模组电压数据
    if "簇" in analyze_object[len(analyze_object)-2:] and station_topu["模组"]>1 and "模组电压" in data_quality["数据维度"]:
        all_features["可测量特征及其统计计算"]["电压差"]=1
        all_features["可测量特征及其统计计算"]["电压方差"] = 1
        all_features["可测量特征及其统计计算"]["电压熵"] = 1
        all_features["可测量特征及其统计计算"]["电压极值"] = 1

    # 单体级别的电压横向统计分析，有单体电压数据
    if "模组" in analyze_object[len(analyze_object)-2:] and station_topu["单体"] > 1 and "单体电压" in data_quality["数据维度"]:
        all_features["可测量特征及其统计计算"]["电压差"]=1
        all_features["可测量特征及其统计计算"]["电压方差"] = 1
        all_features["可测量特征及其统计计算"]["电压熵"] = 1
        all_features["可测量特征及其统计计算"]["电压极值"] = 1

    # 单体级别的温度横向统计分析，有温度探针数据
    if  station_topu["探针"] > 1 and "温度" in data_quality["数据维度"]:
        all_features["可测量特征及其统计计算"]["温度差"]=1
        all_features["可测量特征及其统计计算"]["温度方差"] = 1
        all_features["可测量特征及其统计计算"]["温度熵"] = 1
        all_features["可测量特征及其统计计算"]["温度极值"] = 1

    #等效循环次数，要么是电压和截止电压能提供。要么是SOC直接就有可以算
    if "SOC" in data_quality["数据维度"] or ("电压" in data_quality and "上截止电压" in data_quality["额外信息"] and  "下截止电压" in data_quality["额外信息"]):
        all_features["可测量特征及其统计计算"]["等效循环数"] = 1

    #SOC和时间都在，能估计完整充电时间； 或者电压、截止电压、时间都在。
    if ("SOC" in data_quality["数据维度"] and "时间" in data_quality ) or  ("电压" in data_quality and "时间" in data_quality and "上截止电压" in data_quality["额外信息"] and  "下截止电压" in data_quality["额外信息"]):
        all_features["可测量特征及其统计计算"]["完整充电时间"] = 1
        all_features["可测量特征及其统计计算"]["完整放电时间"] = 1

    # 电压和时间在，可以搞等压升降的时间
    if "电压" in data_quality and "时间" in data_quality:
        all_features["可测量特征及其统计计算"]["等压升充电时间"] = 1
        all_features["可测量特征及其统计计算"]["等压降放电时间"] = 1

    # 有阶跃，电压电流时间都在且满足最低颗粒度要求，能算直流内阻

    if "阶跃"  in working_condition and "时间" in data_quality and "电压" in data_quality and "电流" in data_quality:
        if data_quality["电压"]<=VAR.dcr_min_voltage_accuracy and data_quality["电流"]<=VAR.dcr_min_current_accuracy and data_quality["时间"]<=VAR.dcr_min_time_accuracy:
            all_features["基于电气物理性质的进一步分析"]["等效直流内阻"] = 1

    # 工况有，OCV能拿到（直接测了OCV是不可能的，就看有没有SOC-OCV的映射表，那么SOC也需要有才行）并且数据精度到位，能做等效电路模型辨识
    RC_working_conditon_exist=0
    for i in ['HPPC','DST','BBDST','DST','FUDS']:
        if i in working_condition:RC_working_conditon_exist=1

    if RC_working_conditon_exist==1 and ("OCV" in data_quality["数据维度"] or ("SOC" in data_quality and "SOC-OCV" in data_quality["额外信息"])) and "时间" in data_quality and "电压" in data_quality:
        if data_quality["电压"] <= VAR.rc_min_voltage_accuracy and data_quality[ "电流"] <= VAR.rc_min_current_accuracy and data_quality["时间"] <= VAR.rc_min_time_accuracy:

            all_features["基于电气物理性质的进一步分析"]["等效电路内阻"] = 1
            all_features["基于电气物理性质的进一步分析"]["等效电路电容"] = 1

    # 可放出电量，比完整时间多一个电流
    if "电流" in data_quality and "时间" in data_quality and ( ("SOC" in data_quality["数据维度"] ) or ("电压" in data_quality and "上截止电压" in data_quality["额外信息"] and "下截止电压" in data_quality["额外信息"])):
        if data_quality[ "电流"] <= VAR.ah_min_current_accuracy and data_quality["时间"] <= VAR.ah_min_time_accuracy:
            all_features["基于电气物理性质的进一步分析"]["可放出电量"] = 1


    #容量衰减斜率，一般是实验数据才有
    if "循环容量" in data_quality["数据维度"]:
        all_features["基于电气物理性质的进一步分析"]["容量衰减斜率"] = 1

    #自放电率,有电流和时间就能算，算的准不准都能有
    if "电流" in data_quality and "时间" in data_quality:
        all_features["基于电气物理性质的进一步分析"]["自放电率"] = 1

    #电量方差
    if "电压" in data_quality and "电流" in data_quality:
        if data_quality["电压"]<=VAR.qecvar_min_voltage_accuracy and data_quality["电流"]<=VAR.ahvar_min_current_accuracy :
            all_features["通过复杂模型计算"]["电量增量方差"] = 1



    #弛豫电压特征,好像跟直流内阻是一样的
    if "阶跃"  in working_condition and "时间" in data_quality and "电压" in data_quality and "电流" in data_quality:
        if data_quality["电压"]<=VAR.chiyu_min_voltage_accuracy and data_quality["电流"]<=VAR.chiyu_min_current_accuracy and data_quality["时间"]<=VAR.chiyu_min_time_accuracy :
            all_features["通过复杂模型计算"]["弛豫电压特征"] = 1

    #ICA特征
    if "电流" in data_quality and "时间" in data_quality and "电压" in data_quality and "恒流" in working_condition:
        if data_quality[ "电流"] <= VAR.ica_min_current_accuracy and data_quality["电压"] <= VAR.ica_min_voltage_accuracy  and data_quality["时间"] <= VAR.ica_min_time_accuracy:
            all_features["通过复杂模型计算"]["ICA特征"] = 1


    #根据数据来源针对性修改

    #如果是怀柔数据（后期改成兴隆湖）

    #如果是MIT实验数据集

    #如果是库博数据（后期改成科学城）


    #如果是马里兰

    # 如果分析范围很短，都凑不出一个循环来。把一些算不了的标记了.先不管吧


    return  all_features

# 测试
all_features=feature_available_judge(analyze_object,analyze_range,station_topu,data_quality,working_condition)

print(all_features)