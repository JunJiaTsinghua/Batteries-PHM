trouble_types=['电池内部短路','单体衰减过快']

import pandas as pd
handing_advise=pd.read_excel('故障图谱关系-汇总后梳理.xlsx',sheet_name='故障-原因-处理建议')
all_reasons_to_show=[]
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

# 找第一层故障的所属原因
for i in trouble_types:
    all_reasons_to_show.extend(list(handing_advise_dict[i].keys()))#TODO 应当有个机制报错，万一excel被改了，这个故障类型找不到了

#如果里面包含二层故障，找出来它的下属原因。
deep_fault=list(set(all_reasons_to_show).intersection(set(fault_list)))

if len(deep_fault)>0:
    for i in deep_fault:
        deep_reasons=list(handing_advise_dict[i].keys())
        [all_reasons_to_show.append(j+'(补)') for j in deep_reasons]

all_reasons_to_show=list(set(all_reasons_to_show))
#return all_reasons_to_show