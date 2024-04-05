#输入：处理后的运行曲线数据、页面参数、计算内容
#返回：ICA曲线原始值、特征、message。
#其他工作：用库博的为例，把峰值、峰电压、峰面积、峰宽度、左斜率、右斜率的值p图准备了

import support_tools
from scipy.signal import savgol_filter

class VAR:
    diffL=30 #
    diffV=3
    anlyse_target = []
    anlyse_content= "仅IC曲线" #有这些种类：“仅IC曲线”、“仅峰值”、“仅峰面积”、“所有曲线特征”、“峰值”、“峰面积（左）”、“峰面积（右）”、“峰所在电压”
    #TODO 这儿传的是字符串，下面才是那样写。如果这儿是列表的话，可能需要先把列表合成字符串
    pre_res = {}  # 上一步预处理得到的结果

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




    # 主要过程
    res=IC_compute_for_kubo(res)


    return res



#适合库博数据的IC主算法
def IC_compute_for_kubo(res):
    IC_feature_info_dict={}
    IC_feature_info_list=[]
    charts=[]

    for data in  VAR.pre_res[0]["charts"]:
        Q=data["key"]
        V=data["value"]["1"]
        V_IC, dQ = ICcomputeNorm(V, Q)


        single_chart=support_tools.write_chart(data["obj"], data["cycle"], "电压", "dQ/dV", data["obj"]+"第"+data["cycle"]+"个循环的平滑数据", "line", V_IC, dQ)
        charts.append(single_chart)
        #进行特征提取
        if data["obj"] not in IC_feature_info_dict.keys():
            IC_feature_info_dict[data["obj"]] = []
        if VAR.anlyse_content=='仅IC曲线':
            res[0]["msg"]="用户未选择特征选择"

            IC_feature_info_dict[data["obj"]].append({"cycle":data["cycle"],'peak': '/','peak_voltage': '/'
                ,'peak_area': '/','peak_width': '/','peak_left_slope': '/','peak_right_slope': '/'})
        else:
            feature_str=""
            if "峰值" in VAR.anlyse_content:
                feature_str=feature_str+"峰值"
            if "面积" in VAR.anlyse_content:
                feature_str = feature_str +"峰面积"
            if "电压" in VAR.anlyse_content:
                feature_str = feature_str +"峰电压"
            if "所有" in VAR.anlyse_content:
                feature_str = feature_str +"峰宽度"+"峰面积"+"峰电压"+"峰值"+"峰左斜率"+"峰右斜率"

            feature_record=IC_feature_extract_for_kubo(V_IC, dQ, feature_str,data["obj"])
            feature_record["cycle"]=data["cycle"]
            IC_feature_info_dict[data["obj"]].append(feature_record)

    #把IC_feature_info改成要的形式
    for key in IC_feature_info_dict.keys():
        IC_feature_info_list.append({'obj': key,"ic_info":IC_feature_info_dict[key]})

    res[0]["chart"]=charts
    res[0]["IC_feature_info"]=IC_feature_info_list


    return charts



#这种常规的IC计算方法，就是按照dQ/dV的方式做的，超参数diffV是选取一定步长电压变化，
# 把单个点的求导变成多个点平均求导，这样可以自带一次平滑
def ICcomputeNorm(V, Q):
    dQ = []
    V_IC = []
    for i in range(0, len(V) - 1):
        j = 1
        while V[i + j] - V[i] < VAR.diffV:
            j = j + 1
            if i + j >= len(V): break
        if i + j >= len(V): break
        dQ.append((Q[i + j] - Q[i]))
        V_IC.append(V[i + j])
        i = i + j
    return V_IC, dQ

# 采用电流数点法计算IC,这种方法可以在边记录数据的时候边获取IC，但是这里5min一次的数据采集率不够满足这种计算
def ICcompute(Vsmooth, Ismooth, T):
    # L = len(T)
    Vsmooth=savgol_filter(Vsmooth,33, 3)#电压平滑越好，曲线越平滑
    # Ismooth = savgol_filter(Ismooth, 21, 3)#电流平滑意义不大
    L = len(Vsmooth)

    V_cal = [Vsmooth[i] for i in range(VAR.diffL, L)]
    dQ_dV = [sum(Ismooth[i - VAR.diffL:i]) / len(Ismooth[i - VAR.diffL:i]) * (T[i] - T[i - VAR.diffL]) / 3600 /
             (Vsmooth[i] - Vsmooth[i - VAR.diffL]) for i in range(VAR.diffL, L)]
    CAPACITY = sum(dQ_dV)

    # Picture.picSave()
    return  V_cal, dQ_dV, Ismooth,CAPACITY

#提取ICA曲线的特征
def IC_feature_extract_for_kubo( V_IC, dQ,feature_str,object):
    feature_record={"cycle":0, 'peak': '/', 'peak_voltage': '/'
        , 'peak_area': '/', 'peak_width': '/', 'peak_left_slope': '/', 'peak_right_slope': '/'}
    tod="峰宽度峰面积峰电压峰值峰值左斜率峰值右斜率"


    if  "簇" in object and "模组" not in object:
        v1=720
        v2=725
        v3=730
    else: # TODO 只用于簇和模组两种。簇是七百多的电压，模组是多少呢？
        v1 = 720
        v2 = 725
        v3 = 730

    for i in range(0,len(V_IC)-1):
        if V_IC[i+1]>=v1 and V_IC[i]<=v1:
            index_start = i
            break

    for i in range(0,len(V_IC)-1):
        if V_IC[i+1]>=v3 and V_IC[i]<=v3:
            index_end=i
            break
    dQ_curve_temp=dQ[index_start:index_end]
    V_IC_curve_temp= V_IC[index_start:index_end]
    peak_value=max(dQ_curve_temp)
    peak_voltage= V_IC_curve_temp[dQ_curve_temp.index(peak_value)]
    peak_index=V_IC.index(peak_voltage)
    dQ_curve_temp_ = dQ[peak_index:index_end]
    index_end=dQ_curve_temp_.index(min(dQ_curve_temp_))+peak_index
    peak_range=V_IC[index_end]-V_IC[index_start]
    peak_area=sum(dQ[index_start:index_end])
    feature_record["peak_width"] = peak_range
    feature_record["peak_area"] = peak_area

    peak_left_slope=(peak_value-dQ[index_start])/(peak_voltage-720) #TODO 这个720用哪个v代替？
    peak_right_slope=(peak_value-dQ[index_end])/(V_IC[index_end]-peak_voltage)
    feature_record["peak_left_slope"] = peak_left_slope
    feature_record["peak_right_slope"] = peak_right_slope



    return feature_record

import pandas as pd
Fault_Graph=pd.read_excel('D:\\3_程序\电池安全健康管理\故障诊断\相关算法\\39A充电的IC数据.xlsx',sheet_name='94')
V_IC=list(Fault_Graph['V_IC'])
dQ=list(Fault_Graph['dQ'])
feature_record=IC_feature_extract_for_kubo(V_IC, dQ, "峰宽度峰面积峰电压峰值峰值左斜率峰值右斜率","4簇")
print(feature_record)