# 输入是前面确定的故障类型和确定下来的故障原因。

trouble_types=['电池内部短路','单体衰减过快']
trouble_reasons=['单体析锂','环境温度控制不当','长期低温工作','长期高SOC高温搁置']

# 根据这个去找故障-原因。如果原因是深层故障，再把深层故障-原因，给出来。
import pandas as pd
handing_advise=pd.read_excel('故障图谱关系-汇总后梳理.xlsx',sheet_name='故障-原因-处理建议')
all_advice_to_show=[]

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

exsisted_deep_reason=[]
for i in trouble_types:
    #首层显示的原因
    proved_reasons=list(set(trouble_reasons).intersection(set(list(handing_advise_dict[i].keys()))))

    if len(proved_reasons)>1:
        #它的原因如果是个故障，要补充进去
        for j in proved_reasons:
            this_trouble_advice = {"故障": i, "原因": j, "处理建议": handing_advise_dict[i][j]}
            all_advice_to_show.append(this_trouble_advice)
            if j in list(handing_advise_dict.keys()) and j not in exsisted_deep_reason:
                exsisted_deep_reason.append(j)
                advices=[]
                [advices.append(handing_advise_dict[j][k]) for k in handing_advise_dict[j].keys()]
                this_trouble_advice={"故障":j+"（补）","原因":list(handing_advise_dict[j].keys()),"处理建议":advices}
                all_advice_to_show.append(this_trouble_advice)

print(all_advice_to_show)
        