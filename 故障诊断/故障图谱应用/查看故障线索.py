# 输入是前面确定的故障类型,步骤一给出的推荐词，以及点击的这条原因

words_to_recommend=['单体间压差大','部分电池单体异常','单体衰减过快','模组可放出电量少','单体间不一致性显著']
trouble_types=['内短路','单体衰减过快']
trouble_reason='长期高SOC高温搁置'

#导入图谱
import pandas as pd
import re
import numpy as np
Fault_Graph=pd.read_excel('故障图谱关系-汇总后梳理.xlsx',sheet_name='图谱本体')
fault_phenomenons_dict={}
#故障现象对应的现象细分、相关故障和后果，先做成字典
for row in range(Fault_Graph.shape[0]):
    fault_phenomenons_dict[Fault_Graph['故障现象'][row]]={}
    fault_phenomenons_dict[Fault_Graph['故障现象'][row]]["现象细分"]=re.sub(r'[ 01234567.89（）*&%$#@、-]', '', Fault_Graph['现象细分'][row]).split('\n')
    fault_phenomenons_dict[Fault_Graph['故障现象'][row]]["可能后果"]=re.sub(r'[ 01234567.89（）*&%$#@、-]', '', Fault_Graph['可能后果'][row]).split('\n')
    fault_phenomenons_dict[Fault_Graph['故障现象'][row]]["相关故障"]=re.sub(r'[ 01234567.89（）*&%$#@、-]', '', Fault_Graph['相关故障'][row]).split('\n')


#故障都有哪些原因
handing_advise=pd.read_excel('故障图谱关系-汇总后梳理.xlsx',sheet_name='故障-原因-处理建议')
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



#反过来看看故障出现过哪些现象
_fault_phenomenons_dict = {}
for key in fault_phenomenons_dict.keys():
    for i in fault_phenomenons_dict[key]["相关故障"]:

        if i not in _fault_phenomenons_dict.keys():

            _fault_phenomenons_dict[i] = []

        _fault_phenomenons_dict[i].append(key)
        # 有些是二层故障，他的下面一层还有故障，需要对应上现象。
        if '数据采集异常' in i:
            i_ = '数据采集异常'
        else:
            i_ = i
        if i_ in handing_advise_dict.keys():
            reasons = handing_advise_dict[i_].keys()
            for j in reasons:
                if j in handing_advise_dict.keys():
                    if j not in _fault_phenomenons_dict.keys():
                        _fault_phenomenons_dict[j] = []
                    if key != j:
                        _fault_phenomenons_dict[j].append(key)
graph_to_show=''
conclusion=''
advice=''
for trouble in trouble_types:
    relation_phenomenons=list(set(words_to_recommend).intersection(set(_fault_phenomenons_dict[trouble])))
    if len(relation_phenomenons)>0:
        if trouble_reason in handing_advise_dict[trouble].keys():
            graph_to_show={}
            graph_to_show['first']=relation_phenomenons
            graph_to_show['second']=[{'name':trouble,'children':[trouble_reason]}]
        advice="现象："+str(relation_phenomenons)+"；故障："+trouble+"；原因："+str(trouble_reason)
    else:
        advice='该原因导致的连锁反应不清晰，建议补充分析'

res=[{"map":graph_to_show,"conclusion":conclusion,"advice":advice}]



