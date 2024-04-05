## 根据前面的关键词，结合分析对象是个啥，把那个落脚点的词语拿了
## 同步把这个词语的图谱信息拿了，如果是个现象，就拿故障、拿原因。如果是个故障，就拿前面出现过的关键词里面的现象，拿后面的原因。
## 同步补充关键词方面，如果是个故障，给原因。如果是个现象，给故障。

# TODO 这里需要的是对象的名称+前面所有的结论。
analyze_object="怀柔储能电站-11B舱-6簇-2模组"

#输入进来的结论，汇总成一个字符串
conclusions=['压差大告警次数为NN。以上标志位告警次数超过合理值，系统运行异常。',
             '两次SOE结果相差25%，超过合理值，提示可用电量少于预期、衰减过快等风险。',
             '两次SOP结果相差28%，超过合理值，提示电阻大等风险。',
             '模组2 的电压在所在电池系统为极值的次数是100次，提示电压极值次数高、电压不一致性显著等风险。',
             '簇SOH估计错误']

#导入图谱
import pandas as pd
import re
import numpy as np
Fault_Graph=pd.read_excel('故障图谱关系-汇总后梳理.xlsx',sheet_name='图谱本体')
reasons_explain=pd.read_excel('故障图谱关系-汇总后梳理.xlsx',sheet_name='深层原因解释')
handing_advise=pd.read_excel('故障图谱关系-汇总后梳理.xlsx',sheet_name='故障-原因-处理建议')

fault_phenomenons_dict={}
fault_phenomenon_names=list(Fault_Graph['故障现象'])


#故障现象对应的现象细分、相关故障和后果，先做成字典
for row in range(Fault_Graph.shape[0]):
    fault_phenomenons_dict[Fault_Graph['故障现象'][row]]={}
    fault_phenomenons_dict[Fault_Graph['故障现象'][row]]["现象细分"]=re.sub(r'[ 01234567.89（）*&%$#@、-]', '', Fault_Graph['现象细分'][row]).split('\n')
    fault_phenomenons_dict[Fault_Graph['故障现象'][row]]["可能后果"]=re.sub(r'[ 01234567.89（）*&%$#@、-]', '', Fault_Graph['可能后果'][row]).split('\n')
    fault_phenomenons_dict[Fault_Graph['故障现象'][row]]["相关故障"]=re.sub(r'[ 01234567.89（）*&%$#@、-]', '', Fault_Graph['相关故障'][row]).split('\n')

#反过来看看故障出现过哪些现象
_fault_phenomenons_dict = {}
for key in fault_phenomenons_dict.keys():
    for i in fault_phenomenons_dict[key]["相关故障"]:

        if i not in _fault_phenomenons_dict.keys():
            _fault_phenomenons_dict[i] = []
        _fault_phenomenons_dict[i].append(key)

#深层原因解释，先放出来吧，最后才看怎么用

reasons_explain_dict={}
for row in range(reasons_explain.shape[0]):
    reasons_explain_dict[reasons_explain['关键词（句）'][row]]=reasons_explain['深层原因'][row]

#处理建议。故障-多个原因，每个原因的多条建议，放到一起
handing_advise_dict={}
fault_list=[]
for row in range(handing_advise.shape[0]):
    if type(handing_advise['故障'][row])== str:
        fault_list.append(handing_advise['故障'][row])
    if fault_list[-1] not in handing_advise_dict.keys():
        handing_advise_dict[ fault_list[-1]]={}

    handing_advise_dict[fault_list[-1]][handing_advise['原因'][row]]=[]
    for j in range(1,5):
        this_advice='处理建议'+str(j)
        if type(handing_advise['处理建议'+str(j)][row])== str:
            handing_advise_dict[fault_list[-1]][handing_advise['原因'][row]].append(handing_advise['处理建议'+str(j)][row])



conclusions_text=''
for i in range(0,len(conclusions)):
    conclusions_text=conclusions_text+conclusions[i]

# 到这一步出现过的全部关键词包括
phenomenons=["温差大","压差大","过电压","欠电压","SOC异常","极值次数高","电压极值次数高","温度极值次数高","电流极值次数高","衰减过快","高温","低温","温升","电量少","电阻大",
                 "不一致性显著","电压不一致性显著","温度不一致性显著","电流不一致性显著","过电流","电流差大"]
faultnames=["内短路","析锂","弛豫电压","容量异常跳水","老化模式辨识","异常自耗电"]
# attachments=["电压传感器","电流传感器","温度传感器","连接铜牌","均衡故障","散热系统故障","加热系统故障","箱体结构损坏","充放电故障"] #照理来说，附件也可以故障类型识别、溯源啥的，但是这个项目不关注
words_collection=phenomenons+faultnames

words_shown = []
for  i in words_collection:
    if i in conclusions_text:
        words_shown.append(i)
        

#是什么层级
if "簇"  in analyze_object[-2:]:
    analyze_object_layer='簇'
elif "模组"  in analyze_object[-2:]:
    analyze_object_layer = '模组'
else :
    analyze_object_layer = '数据集'

#造一个空的返回表
words_to_recommend=[]
    

#对应要显示的什么推荐关键词
for i in words_shown:
    if i=="压差大" and analyze_object_layer=="簇" :words_to_recommend.append("模组间压差大")
    if i == "压差大" and analyze_object_layer== "模组": words_to_recommend.append("单体间压差大")

    if i=="温差大" and analyze_object_layer=="簇" :words_to_recommend.append("模组间温差大")
    if i == "温差大" and analyze_object_layer== "模组": words_to_recommend.append("模组内温差大")

    if i=="过电压" and analyze_object_layer=="簇" :words_to_recommend.append("簇过电压")
    if i == "过电压" and analyze_object_layer== "模组": words_to_recommend.append("模组过电压")
    if i == "过电压" and analyze_object_layer== "数据集": words_to_recommend.append("单体过电压")

    if i == "欠电压" and analyze_object_layer == "簇": words_to_recommend.append("簇欠电压")
    if i == "欠电压" and analyze_object_layer == "模组": words_to_recommend.append("模组欠电压")
    if i == "欠电压" and analyze_object_layer == "数据集": words_to_recommend.append("单体欠电压")

    if i == "SOC异常" and analyze_object_layer == "簇": words_to_recommend.append("簇SOC异常")
    if i == "SOC异常" and analyze_object_layer == "模组": words_to_recommend.append("模组SOC异常")

    if i == "极值次数高" : words_to_recommend.append("部分电池单体异常")
    if i == "衰减过快" : words_to_recommend.append("单体衰减过快")
    if i == "电阻大" : words_to_recommend.append("单体衰减过快")
    if i == "异常自耗电": words_to_recommend.append("异常自耗电")

    if i == "高温" and analyze_object_layer == "簇": words_to_recommend.append("电池模组高温")
    if i == "高温" and analyze_object_layer == "模组": words_to_recommend.append("电池模组高温")
    if i == "高温" and analyze_object_layer == "数据集": words_to_recommend.append("局部（单体）高温")

    if i == "低温" and analyze_object_layer == "簇": words_to_recommend.append("电池模组低温")
    if i == "低温" and analyze_object_layer == "模组": words_to_recommend.append("电池模组低温")
    if i == "低温" and analyze_object_layer == "数据集": words_to_recommend.append("局部（单体）低温")

    if i == "温升" and analyze_object_layer == "簇":words_to_recommend.append("部分电池单体异常")
    if i == "温升" and analyze_object_layer == "模组":words_to_recommend.append("部分电池单体异常")
    if i == "温升" and analyze_object_layer == "数据集":words_to_recommend.append("部分电池单体异常")
    if i == "温升" and analyze_object_layer == "簇": words_to_recommend.append("模组内温度管理不当")
    if i == "温升" and analyze_object_layer == "簇": words_to_recommend.append("电池外部短路")
    if i == "温升" and analyze_object_layer == "模组": words_to_recommend.append("模组内温度管理不当")
    if i == "温升" and analyze_object_layer == "模组": words_to_recommend.append("电池外部短路")
    if i == "温升" and analyze_object_layer == "数据集": words_to_recommend.append("电池内部短路")

    
    
    
    if i == "电量少" and analyze_object_layer == "簇": words_to_recommend.append("簇可放出电量少")
    if i == "电量少" and analyze_object_layer == "模组": words_to_recommend.append("模组可放出电量少")
    if i == "电量少" and analyze_object_layer == "数据集": words_to_recommend.append("单体衰减过快")

    if i == "不一致性显著" and analyze_object_layer == "簇": words_to_recommend.append("模组间不一致性显著")
    if i == "不一致性显著" and analyze_object_layer == "模组": words_to_recommend.append("单体间不一致性显著")

    if i == "过电流" and analyze_object_layer == "簇": words_to_recommend.append("簇过电流")
    if i == "电流差大" and analyze_object_layer == "簇": words_to_recommend.append("（并联）模组间电流差大")



    if i == "内短路" : words_to_recommend.append("电池内部短路")
    if i == "内短路" and "低温" in words_shown:words_to_recommend.append("析锂")

    if i == "容量异常跳水" and analyze_object_layer == "簇": words_to_recommend.append("部分电池单体异常")
    if i == "容量异常跳水" and analyze_object_layer == "簇": words_to_recommend.append("簇可放出电量少")
    if i == "容量异常跳水" and analyze_object_layer == "模组": words_to_recommend.append("部分电池单体异常")
    if i == "容量异常跳水" and analyze_object_layer == "模组": words_to_recommend.append("模组可放出电量少")
    if i == "容量异常跳水" and analyze_object_layer == "数据集": words_to_recommend.append("单体衰减过快")
    if i == "容量异常跳水" and analyze_object_layer == "数据集": words_to_recommend.append("部分电池单体异常")



#根据推荐词，来找图谱。

graph_to_show={}

words_to_add={}
for word in words_to_recommend:
# 如果是个现象，会对应出来多个故障，每个故障有很多原因。 图谱的话就展示全。 但需要添加的关键词就只加相关故障了
    if word in fault_phenomenons_dict.keys():
        graph_to_show[word]={}
        graph_to_show[word]['first'] =[word]
        graph_to_show[word]['second'] = []
        words_to_add [word]=[]
        for fault in fault_phenomenons_dict[word]["相关故障"]:
            words_to_add[word].append(fault)
            if "数据采集异常" in fault:fault="数据采集异常"

            graph_to_show[word]['second'].append({'name':fault,'children':list(handing_advise_dict[fault].keys())})

#如果是个故障，会找出多个现象，但是不能都放出来，前面 出现的过的才展示。 原因的话就对应这个故障自己的了
    if word in _fault_phenomenons_dict.keys():
        # if word=="数据采集异常" : word = "数据采集异常"
        graph_to_show[word] = {}
        #第一层是看出现过哪些现象
        phenomenons_shown=list(set(_fault_phenomenons_dict[word]).intersection(set(words_to_recommend)))
        words_to_add[word] = []
        words_to_add[word].extend(phenomenons_shown)
        graph_to_show[word]['first']=phenomenons_shown

        #第二层是根据这个故障记录后面的原因
        graph_to_show[word]['second'] = []
        #记录后面的原因
        resons=list(handing_advise_dict[word].keys())
        graph_to_show[word]['second'].append({'name':word,'children':resons})
        words_to_add[word]=[]
        words_to_add[word].extend(resons)
    words_to_add[word]=list(set(words_to_add[word]))

print()
