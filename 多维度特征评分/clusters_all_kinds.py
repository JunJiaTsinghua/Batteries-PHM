#批量操作，把所有聚类算法、所有特征选择、所有聚类个数选择，都遍历一遍，并且存档

from pylab import *
mpl.rcParams['font.sans-serif'] = ['SimHei']
matplotlib.rcParams['axes.unicode_minus']=False
import pickle
import pandas as pd
from sklearn.cluster import KMeans
import numpy as np
from itertools import combinations
import FuzzyCmeans_mode
from sklearn.cluster import MeanShift, estimate_bandwidth
from sklearn.cluster import AgglomerativeClustering
from sklearn.cluster import Birch
from sklearn.mixture import GaussianMixture


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

features_df=pd.DataFrame(features_dict)
features_df = regularit(features_df)


#各类算法
cluster_algorithms=['K_means','Fuzzy_C_means','MeanShift','Birch','GaussianMixture','AgglomerativeClustering']
# cluster_algorithm=cluster_algorithms[0]

#所有可能的特征组合方式
# all_features=[ 'cap_diff_2_max', 'cap_max_real', 'cycle_life_Per95_absolute', 'cycle_life_Per95_relative'];data_type='较后期数据'
# all_features=['Tmax_100','Tavg_100','cap_diff_2_100', 'kur_10_100','min_diffQ_10_100', 'skew_10_100', 'var_10_100'];data_type='循环100次左右'
# all_features=[ 'cap_cycle2','var_1_5', 'var_4_5', 'T_Sum_4',  'Tavg_4' 'Tmax_10',  'Tmax_4'];data_type='最早期数据'
all_features=[ 'var_1_5', 'var_4_5','var_10_100', 'Tmax_100','Tmax_10'];data_type='工程可获取数据'
# all_features=[ 'var_4_5', 'T_Sum_10'];data_type='测试用';

all_features = list(set(all_features) ^ set(feature_cannot_use))
features_to_choose_combinations=[]
for num_features_to_choose in range(1,len(all_features)+1):
    feature_combinations = combinations(all_features, num_features_to_choose)
    for combination in feature_combinations:
        features_to_choose_combinations.append(combination)

print(len(features_to_choose_combinations))

result =pd.DataFrame()
idx=0
#所有算法
for cluster_algorithm in cluster_algorithms:
    #选择要用于聚类的特征，并重组；需要进行log计算的，进行log计算
    for features_to_choose in features_to_choose_combinations:
        print(features_to_choose)
        for Num_cluster in [2,3 , 4, 5]:
            # print('聚类',Num_cluster,'类')
            feature_and_result = features_df.ix[:, features_to_choose]

            # feature_and_result['Tavg_5'] = feature_and_result['Tavg_5'] * 0.8
            try:

                if cluster_algorithm=='Fuzzy_C_means':
                    feature_list_every_cell=np.array(feature_and_result).tolist()
                    labels=FuzzyCmeans_mode.fuzzy(feature_list_every_cell, Num_cluster, 2)
                    feature_and_result['cluster'] = labels

                if cluster_algorithm=='K_means':
                    km= KMeans(n_clusters=Num_cluster).fit(feature_and_result)#kmeans分类器
                    labels=km.labels_
                    feature_and_result['cluster'] = labels

                if cluster_algorithm=='MeanShift':
                    feature_list_every_cell = np.array(feature_and_result).tolist()
                    ##带宽，也就是以某个点为核心时的搜索半径
                    bandwidth = estimate_bandwidth(feature_list_every_cell, quantile=0.2, n_samples=30)
                    ##设置均值偏移函数
                    ms = MeanShift(bandwidth=bandwidth, bin_seeding=True)
                    # ms = MeanShift()

                    ##训练数据
                    ms.fit(feature_list_every_cell)
                    ##每个点的标签
                    labels = ms.labels_
                    feature_and_result['cluster'] = labels
                    ##总共的标签分类
                    labels_unique = np.unique(labels)
                    ##聚簇的个数，即分类的个数
                    Num_cluster = len(labels_unique)

                if cluster_algorithm == 'Birch':
                    birch = Birch(n_clusters=Num_cluster)
                    ##训练数据
                    labels = birch.fit_predict(feature_and_result)
                    feature_and_result['cluster'] = labels

                if cluster_algorithm == 'GaussianMixture':
                    ##设置gmm函数
                    gmm = GaussianMixture(n_components=Num_cluster, covariance_type='full').fit(feature_and_result)
                    ##训练数据
                    labels = gmm.predict(feature_and_result)
                    feature_and_result['cluster'] = labels


                if cluster_algorithm == 'AgglomerativeClustering':
                    feature_list_every_cell = np.array(feature_and_result).tolist()
                    linkages = ['ward', 'average', 'complete']  # 计算组合数据点距离的三种方法，中间的比较合理，虽然计算量比较大。
                    ac = AgglomerativeClustering(linkage=linkages[0], n_clusters=Num_cluster)
                    ##训练数据
                    ac.fit(feature_list_every_cell)

                    ##每个数据的分类
                    labels = ac.labels_
                    feature_and_result['cluster'] = labels


            except ValueError:continue
            idx = idx + 1
            print('聚类',Num_cluster,'类:',features_to_choose)
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
            centers_sorted=centers.nlargest(clusters_to_choose,'sum')
            bad_cluster_list=centers_sorted['cluster']
            feature_and_result['cluster']=labels

            # 评判准确率
            feature_and_result['classify']=1
            for i in bad_cluster_list:
                this_bad_cluster_num=bad_cluster_list[i]
                feature_and_result.ix[(feature_and_result['cluster'] == this_bad_cluster_num), 'classify']=0
            feature_and_result['is_good']=classfication_result
            feature_and_result['judge']=(feature_and_result['is_good'] == feature_and_result['classify'])
            feature_and_result['life']=cycle_life
            right_ratio= sum(feature_and_result['judge']) / len(cycle_life)
            # print('准确率',right_ratio)
            result = result.append(pd.DataFrame({'idx':idx,'特征个数':len(features_to_choose),'特征':str(features_to_choose),'聚类总数':Num_cluster,'选择个数':clusters_to_choose,'准确率':right_ratio},index=[idx]))
            # #画图，二维的情况下；黑的是真正的坏电池，大个头的是我识别的坏电池。也就是说黑的都是大的，才是对的
            # colors = np.where(feature_and_result['is_good'] ==1, 'r', 'k')
            # sizes = np.where(feature_and_result['classify'] ==0, 120, 60)
            # markers = np.where(feature_and_result['classify'] ==0, 'o', '.')
            # feature_and_result.plot(kind='scatter', x='var_4_5', y='Tavg_5', s=sizes, c=colors)
            # plt.show()

            #每次训练重置模型和特征
            del  feature_and_result
            if cluster_algorithm == 'MeanShift' :break

    pickle.dump(result,open('result.pkl','wb'))
    try:
        result.to_csv(cluster_algorithm+data_type+'.csv' ,sep=',' ,index=False )
    except PermissionError:
        result.to_csv(cluster_algorithm + data_type + '1.csv', sep=',', index=False)
