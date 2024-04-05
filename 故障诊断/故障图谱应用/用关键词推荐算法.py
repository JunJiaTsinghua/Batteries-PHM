import pandas as pd
import numpy as np
import json


## TODO 这儿是需要的输入，包括：是哪个页面、结论文本的汇总、映射表

#哪个页面 --这个叫法是否需要统一一下
recommend_page=  '类型隔离'#TODO 这个需要适配一下现在的叫法

#输入进来的结论，汇总成一个字符串
conclusions=['压差大告警次数为NN。以上标志位告警次数超过合理值，系统运行异常。',
             '两次SOE结果相差25%，超过合理值，提示可用电量少于预期、衰减过快等风险。',
             '两次SOP结果相差28%，超过合理值，提示电阻大等风险。',
             '模组2 的电压在所在电池系统为极值的次数是100次，提示电压极值次数高、电压不一致性显著等风险。']

#导入映射表excel
key_words_table={}


relation_table=pd.read_excel('关键词-推荐算法映射表.xlsx')
relation_table=relation_table.drop('类别', axis=1)
Algorithm_pages=relation_table['算法/页面']
for row in range(0,len(Algorithm_pages)):
    if type(Algorithm_pages[row])== str:
        words=list(relation_table.loc[row].values)
        words_ = [word for word in words if word==word]
        key_words_table[words_[0]]=words_[1:len(words_)]



def main_function(conclusions,key_words_table,recommend_page):

    conclusions_text=''
    for i in range(0,len(conclusions)):
        conclusions_text=conclusions_text+conclusions[i]


    #有哪些现象、有哪些附件、分别是如何映射的
    phenomenons=["温差大","压差大","过电压","欠电压","SOC异常","极值次数高","电压极值次数高","温度极值次数高","电流极值次数高","衰减过快","高温","低温","温升","电量少","电阻大",
                 "不一致性显著","电压不一致性显著","温度不一致性显著","电流不一致性显著","过电流","电流差大"]

    attachments={"电压传感器":'XX',"电流传感器":'XX',"温度传感器":'XX',"连接铜牌":'XX',"均衡系统故障":'XX',"散热系统故障":'XX',"加热系统故障":'XX',"箱体结构损坏":'XX',"充放电故障":'XX'}

    faultnames={"内短路":'XX',"析锂":'XX',"弛豫电压":'XX',"容量异常跳水":'XX',"老化模式辨识":'XX',"异常自耗电":'XX'}

    runningDescription={"运行倍率统计":'C_rate_statics',"搁置SOC统计":'still_SOC_statics',"环境温度分析":'ambient_temperature_analysis',
                        "初始不一致性分析":'initial_inconsist_anlysis',"早期循环衰减率分析":'initial_cycle_aging_anlysis',"早期循环能量效率分析":'initial_cycle_efficiency_anlysis',"制造缺陷分析":'manufacturing_defect_analysis'}


    if recommend_page=='部件分离':
        words_collection=phenomenons
        algrithms_toRecommend=attachments
    if recommend_page=='类型隔离':
        words_collection=phenomenons+list(attachments.keys())
        algrithms_toRecommend = faultnames
    if recommend_page=='故障溯源':
        words_collection=phenomenons+list(attachments.keys())+list(faultnames.keys())
        algrithms_toRecommend=runningDescription

    res=Recommended_algorithm_Sort(conclusions_text,words_collection,algrithms_toRecommend,key_words_table)

    # json_str = json.dumps(reconmend_algrithms,ensure_ascii=False)
    return res


def Recommended_algorithm_Sort(conclusions_text, words_collection, algrithms_toRecommend,key_words_table):
    algrithms_toRecommend_list=list(algrithms_toRecommend)
    # 出现过那些关键词
    words_shown = []
    for i in range(0, len(words_collection)):
        if words_collection[i] in conclusions_text and (words_collection[i] not in words_shown):
            words_shown.append(words_collection[i])

    # 查看各自都出现过几次,按照概率排序
    reconmend_algrithms = {'高': [], '中': [], '低': []}

    for algrithm in algrithms_toRecommend_list:
        this_recomend = list(set(key_words_table[algrithm]).intersection(set(words_shown)))
        if not (this_recomend):
            continue

        reconmend_algrithms[algrithm] = this_recomend
        if len(this_recomend) >= 3:
            reconmend_algrithms['高'].append(algrithm)
        if len(this_recomend) == 2:
            reconmend_algrithms['中'].append(algrithm)
        if len(this_recomend) == 1:
            reconmend_algrithms['低'].append(algrithm)
    res = []
    for key in ['高', '中', '低']:
        for key_algrithm in reconmend_algrithms[key]:
            res.append({'key':key_algrithm,'algorithm':algrithms_toRecommend[key_algrithm],'explain':reconmend_algrithms[key_algrithm]})
    return res
res=main_function(conclusions,key_words_table,recommend_page)
print()