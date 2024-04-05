#几种聚类方法'K_means','Fuzzy_C_means','GaussianMixture'--不同的聚类个数-2,3,4,5
#当聚类方法越多，聚类个数越多之后，得到的结果会越准确。但是为了不太过增加复杂度，就三种聚类方法和四种聚类个数

from pylab import *
mpl.rcParams['font.sans-serif'] = ['SimHei']
matplotlib.rcParams['axes.unicode_minus']=False

import pickle
import pandas as pd

import numpy as np 
from itertools import combinations

#用这三类
import FuzzyCmeans_mode
from sklearn.cluster import KMeans
from sklearn.mixture import GaussianMixture
import PCA_for_MIT

#对df进行归一化
def regularit(df):
    newDataFrame = pd.DataFrame(index=df.index)
    columns = df.columns.tolist()
    for c in columns:
        d = df[c]
        MAX = d.max()
        MIN = d.min()
        newDataFrame[c] = ((d - MIN) / (MAX - MIN)).tolist()
    return newDataFrame


class Var:
    classification_boundary = 550
    if_PCA = 1

#加载所有特征
#温度和ica的有二级字典，其他的直接取
with open('feature_dict.pkl', 'rb') as f:#版本不同，用pickle的话要用wb和rb
    features = pickle.load(f)

print(features.keys())
print(features['T_features'].keys())
print(features['ica_features'].keys())
features_dict={}
T_features=['T_Sum_1', 'T_Sum_10', 'T_Sum_100', 'T_Sum_4', 'T_Sum_5', 'Tavg_1', 'Tavg_10', 'Tavg_100', 'Tavg_4', 'Tavg_5', 'Tmax_1', 'Tmax_10', 'Tmax_100',  'Tmax_4', 'Tmax_5']
for i in T_features:
    features_dict[i]=features['T_features'][i]
ica_features=['ica_peak_value_1', 'ica_peak_value_10', 'ica_peak_value_4', 'ica_peak_value_5', 'ica_peak_voltage_1',
                        'ica_peak_voltage_10','ica_peak_voltage_4', 'ica_peak_voltage_5']
for i in ica_features:
    features_dict[i]=features['ica_features'][i]
other_features=['cap_cycle2', 'cap_diff_2_100', 'cap_diff_2_max', 'cap_max_real', 'cycle_life_Per95_absolute', 'cycle_life_Per95_relative',  'kur_10_100', 'life', 'min_diffQ_10_100', 'skew_10_100', 'var_10_100', 'var_1_5', 'var_4_5']
for i in other_features:
    features_dict[i]=features[i]


#识别好坏电池
life=features['life']
cycle_life=[]
classfication_result=zeros(len(life))
for i in range(0,len(life)):
    cycle_life.append(int(life[i][0]))
    if life[i] <= Var.classification_boundary:
        classfication_result[i] =0
    else:
        classfication_result[i] =1


#var和sum温度，需要用log10；与寿命成正比的，给他倒过来，变成反比；转化为df结构；
# #用了PCA得全都搞成正比,所以要全都加一个负号
# feature_cannot_use=[]
# if Var.if_PCA==1:
#     flag_reverse=-1
# else:
#     flag_reverse=1
# for j in features_dict.keys():
#     this_feature_list_old=features_dict[j]
#     this_feature_list = []
#     try:
#         for i in range(0, len(life)):
#             if j[0:3]=='var' or j[2:5]=='Sum' :
#                 this_feature_list.append(flag_reverse*log10(float(this_feature_list_old[i])))
#             elif  'cycle_life_Per95' in j or j=='cap_cycle2' or j=='cap_max_real':
#                 this_feature_list.append(flag_reverse*1/abs(float(this_feature_list_old[i])))
#             elif 'skew_10_100' in j or 'min_diffQ_10_100' in j or j=='cap_diff_2_100':
#                 this_feature_list.append(flag_reverse*abs(float(this_feature_list_old[i])))
#             else:
#                 this_feature_list.append(flag_reverse*float(this_feature_list_old[i]))
#     except ValueError:feature_cannot_use.append(j);continue
#     features_dict[j]=this_feature_list
#var和sum温度，需要用log10；与寿命成正比的，给他倒过来，变成反比；转化为df结构；
feature_cannot_use=[]
for j in features_dict.keys():
    this_feature_list_old=features_dict[j]
    this_feature_list = []
    try:
        for i in range(0, len(life)):
            if j[0:3]=='var' or j[2:5]=='Sum' :
                this_feature_list.append(log10(float(this_feature_list_old[i])))
            elif  'cycle_life_Per95' in j :
                this_feature_list.append(1/abs(float(this_feature_list_old[i])))
            elif 'skew_10_100' in j or 'min_diffQ_10_100' in j or j[0:3]=='cap':
                this_feature_list.append(abs(float(this_feature_list_old[i])))
            else:
                this_feature_list.append(float(this_feature_list_old[i]))
    except ValueError:feature_cannot_use.append(j);continue
    features_dict[j]=this_feature_list

# if Var.if_PCA==1:
#     for j in features_dict.keys():
#         this_feature__reverse=[-l for l in features_dict[j]]
#         features_dict[j]=this_feature__reverse

features_df1=pd.DataFrame(features_dict)

features_df = regularit(features_df1)


cluster_algorithms=['K_means','Fuzzy_C_means','GaussianMixture']


#所有可能的特征组合方式
# all_features=[ 'cap_diff_2_max', 'cycle_life_Per95_absolute', 'cycle_life_Per95_relative'];data_type='较后期数据'
# all_features=['Tmax_100','Tavg_100','cap_diff_2_100','min_diffQ_10_100','var_10_100','skew_10_100'];data_type='循环100次左右'
# all_features=[ 'cap_cycle2','cap_max_real','var_1_5', 'var_4_5', 'T_Sum_4',  'Tavg_4' 'Tmax_10',  'Tmax_4'];data_type='最早期数据'
all_features=[ 'var_1_5', 'var_4_5', 'Tmax_100','Tavg_100',  'T_Sum_100','T_Sum_10', 'Tavg_10',  'Tmax_10'];data_type='工程可获取数据'
# all_features=['var_4_5', 'var_10_100'];data_type='测试用'
# all_features=features_dict.keys()
all_features = list(set(all_features) ^ set(feature_cannot_use))


if Var.if_PCA==1:
    # features_df1 = regularit(features_df1)
    #cum_max指的是，对特征值求和，当总和大于98之后，后面的特征几乎不起作用，可以去除
    features_df, all_features=PCA_for_MIT.PCA(features_df1,all_features,cum_max=98)
    features_df.to_excel('features_pca.xls')


features_to_choose_combinations=[]
for num_features_to_choose in range(1,len(all_features)+1):
    feature_combinations = combinations(all_features, num_features_to_choose)
    for combination in feature_combinations:
        features_to_choose_combinations.append(combination)

print(len(features_to_choose_combinations))

result =pd.DataFrame()
idx=0
for cluster_algorithm in cluster_algorithms:
    print(cluster_algorithm)
    for features_to_choose in features_to_choose_combinations:
        # features_to_choose=('Tavg_10', 'Tmax_10', 'var_1_5', 'Tmax_100', 'var_4_5')
        print(features_to_choose)
        for Num_cluster in [2,3]:

            # print('聚类',Num_cluster,'类')
            feature_and_result = features_df.ix[:, features_to_choose]

            # feature_and_result['Tavg_5'] = feature_and_result['Tavg_5'] * 0.8
            try:

                if cluster_algorithm == 'Fuzzy_C_means':
                    feature_list_every_cell = np.array(feature_and_result).tolist()
                    labels = FuzzyCmeans_mode.fuzzy(feature_list_every_cell, Num_cluster, 2)
                    feature_and_result['cluster'] = labels

                if cluster_algorithm == 'K_means':
                    km = KMeans(n_clusters=Num_cluster).fit(feature_and_result)  # kmeans分类器
                    labels = km.labels_
                    feature_and_result['cluster'] = labels

                if cluster_algorithm == 'GaussianMixture':
                    ##设置gmm函数
                    gmm = GaussianMixture(n_components=Num_cluster, covariance_type='full').fit(feature_and_result)
                    ##训练数据
                    labels = gmm.predict(feature_and_result)
                    feature_and_result['cluster'] = labels

            except ValueError:continue
            idx = idx + 1
            # print('聚类',Num_cluster,'类:',features_to_choose)
            #按照聚类结果求一个平均，然后对每个类所有特征求和；如果本身特征与寿命成反比，那么就把求和大的归为坏电池一类。

            centers=feature_and_result.groupby('cluster').mean().reset_index()
            cluster_list=centers['cluster']#在求和的时候，暂时把这个丢掉，中转记录一下
            centers=centers.drop(columns=['cluster'])
            centers['sum']=centers.apply(lambda x:x.sum(),axis=1)

            #只是聚2类的话，就是最大的
            # bad_cluster=centers['sum'].argmax()
            centers['cluster']=cluster_list
            #如果聚多类的话，要找出前几大的。
            clusters_to_choose=math.floor(Num_cluster * 0.5)
            # print('选择前',clusters_to_choose,'类')
            if Var.if_PCA == 1:
                centers_sorted = centers.nsmallest(clusters_to_choose, 'sum')
            else:
                centers_sorted = centers.nlargest(clusters_to_choose, 'sum')
            bad_cluster_list = centers_sorted['cluster']

            # 打上标签，记录下来.这里等于1不是说是好电池，是说被认为是坏的，投了一票
            feature_and_result['classify'] = 0
            for i in bad_cluster_list:
                this_bad_cluster_num = i
                feature_and_result.ix[(feature_and_result['cluster'] == this_bad_cluster_num), 'classify'] = 1

            result[str(idx)] = feature_and_result['classify']

result['sum'] = result.apply(lambda x: x.sum(), axis=1)
result['概率'] = result['sum']/idx


result['cell']=list(range(1,len(life)+1))
col_name = result.columns.tolist()
col_name.insert(0,'cell')

result=result.reindex(columns=col_name)

result['is_good']=classfication_result
result['classify']=result['概率']<=min(result.nlargest(int(len(result['is_good'])-sum(result['is_good'])),'概率')['概率'])

result['judge']=(result['is_good'] == result['classify'])
result['life']=cycle_life
socre=[1-l for l in result['概率'] ]
result['评分']=socre
right_ratio= sum(result['judge']) / len(result['judge'])
print(right_ratio)


# #画图，二维的情况下；黑的是真正的坏电池，大个头的是我识别的坏电池。也就是说黑的都是大的，才是对的
# result[all_features[0]]=features_df[all_features[0]]
# result[all_features[1]]=features_df[all_features[1]]
# colors = np.where(result['is_good'] ==1, 'r', 'k')#颜色是实际的好坏
# sizes = np.where(result['classify'] ==0, 120, 60)#尺寸是我们判断的好坏。也就是说黑的都得大号现实才是对的
# markers = np.where(result['classify'] ==0, '1', '2')
# result.plot(kind='scatter', x=all_features[0], y=all_features[1], s=sizes, c=colors)
# plt.show()


pickle.dump(result,open('result.pkl','wb'))
try:
    result.to_csv(data_type+str(right_ratio)+'_PCA.csv' ,sep=',' ,index=False )
except PermissionError:
    result.to_csv( data_type +str(right_ratio)+ '_PCA_1.csv', sep=',', index=False)
