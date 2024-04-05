# 各种聚类方式，用于改变单个的参数，进行测试用 
from pylab import *
import warnings
warnings.filterwarnings("ignore")
mpl.rcParams['font.sans-serif'] = ['SimHei']
matplotlib.rcParams['axes.unicode_minus'] = False
from os import listdir
import os
import shutil

import pickle
import pandas as pd

import numpy as np
from itertools import combinations

import FuzzyCmeans_mode
from sklearn.cluster import KMeans
from sklearn.cluster import MeanShift, estimate_bandwidth
from sklearn.cluster import AgglomerativeClustering
from sklearn.cluster import Birch
from sklearn.mixture import GaussianMixture
import all_features_load


# 搬动文件
def moveFiles(new_path, newFile):
    oldpath = os.getcwd()
    full_path = os.path.join(oldpath, newFile)
    newpathfile = os.path.join(new_path, newFile)  # 查看已有文件夹是否有这个文件
    if os.path.isfile(newpathfile):
        os.remove(newpathfile)
        shutil.move(full_path, new_path)
    else:
        shutil.move(full_path, new_path)


# 对df进行归一化
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

#有哪些日子是能用的。
day_dates = []
for i in range(7,16):
    day_dates.append('07'+str(i).zfill(2))
for i in range(1, 28):
    day_dates.append('08' + str(i).zfill(2))

#哪个簇。创存它的相关文件夹
case_name = 'Cabin_2_A_Case_03'
new_path = os.getcwd() + '\\' + case_name
if not os.path.exists(new_path):
    os.makedirs(new_path)
#开始循环计算评分值
score = pd.DataFrame()
score['cell'] = list(range(1, 20))
for day_date in day_dates:
    # day_date = '0816'

    try:
        with open(new_path+'\\'+day_date + 'features_dict.pkl', 'rb') as f:  # 版本不同，用pickle的话要用wb和rb
            features = pickle.load(f)
            features_dict, var_cycles = features[0], features[1]
    except BaseException:
        features_dict, var_cycles = all_features_load.load_feature(new_path,day_date, case_name)
        newFile=case_name + '_' + day_date + 'features_dict.pkl'
        pickle.dump([features_dict, var_cycles], open(newFile, 'wb'))
        moveFiles(new_path, newFile)
    life = np.zeros(19)  # 实际工程数据无法得知真实life

    ##后面加怎么去掉一些不用的特征。或者重复度极高的特征
    feature_cannot_use = []

    features_df = pd.DataFrame(features_dict)
    features_df = regularit(features_df)
    cluster_algorithms = ['K_means', 'Fuzzy_C_means', 'GaussianMixture']
    cluster_algorithm = ['Fuzzy_C_means']

    # 所有的特征组合方式【温度、电压、容量】
    tem_features = ['tem_max_sampEn_count', 'tem_max_diff_count', 'tem_max_tem_count',
                    'tem_max_space_sampEn', 'tem_sum_space_sampEn', 'tem_avg_space_sampEn', 'tem_var_space_sampEn',
                    'tem_max_time_sampEn', 'tem_sum_time_sampEn', 'tem_avg_time_sampEn', 'tem_var_time_sampEn',
                    'tem_sum_max_tem', 'tem_avg_max_tem',
                    'tem_max_diff', 'tem_sum_diff', 'tem_avg_diff', 'tem_var_diff'
                    ]
    vol_features = ['vol_max_sampEn_count', 'vol_max_diff_count', 'vol_min_vol_count',
                    'vol_max_space_sampEn', 'vol_sum_space_sampEn', 'vol_avg_space_sampEn', 'vol_var_space_sampEn',
                    'vol_max_time_sampEn', 'vol_sum_time_sampEn', 'vol_avg_time_sampEn', 'vol_var_time_sampEn',
                    'vol_sum_min_vol', 'vol_avg_min_vol',
                    'vol_max_diff', 'vol_sum_diff', 'vol_avg_diff', 'vol_var_diff'
                    ]
    if len(var_cycles)<3:
        cap_features =  var_cycles
    else:
        cap_features = [var_cycles[0],var_cycles[-1]]

    # 初步选择的特征，温度和电压的差、极值、熵，容量有多少用多少
    all_features = ['tem_avg_space_sampEn', 'tem_avg_max_tem','tem_avg_diff',
                    'vol_avg_space_sampEn', 'vol_avg_min_vol','tem_avg_diff', ] + cap_features
    # all_features=['tem_max_diff']
    # all_features=cap_features
    # print(all_features)
    # data_type='较后期数据'

    all_features = list(set(all_features) ^ set(feature_cannot_use))
    features_to_choose_combinations = []
    for num_features_to_choose in range(1, len(all_features) + 1):
        feature_combinations = combinations(all_features, num_features_to_choose)
        for combination in feature_combinations:
            features_to_choose_combinations.append(combination)

    print(len(features_to_choose_combinations))

    result = pd.DataFrame()

    idx = 0
    for cluster_algorithm in cluster_algorithms:
        print(cluster_algorithm)
        for features_to_choose in features_to_choose_combinations:
            # features_to_choose=('Tavg_10', 'Tmax_10', 'var_1_5', 'Tmax_100', 'var_4_5')
            # print(features_to_choose)
            for Num_cluster in [2, 3]:

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

                except BaseException:
                    del feature_and_result;continue;
                idx = idx + 1
                # print('聚类',Num_cluster,'类:',features_to_choose)
                # 按照聚类结果求一个平均，然后对每个类所有特征求和；如果本身特征与寿命成反比，那么就把求和大的归为坏电池一类。

                centers = feature_and_result.groupby('cluster').mean().reset_index()
                cluster_list = centers['cluster']  # 在求和的时候，暂时把这个丢掉，中转记录一下
                centers = centers.drop(columns=['cluster'])
                centers['sum'] = centers.apply(lambda x: x.sum(), axis=1)

                # 只是聚2类的话，就是最大的
                # bad_cluster=centers['sum'].argmax()
                centers['cluster'] = cluster_list
                # 如果聚多类的话，要找出前几大的。
                clusters_to_choose = math.floor(Num_cluster * 0.5)
                # print('选择前',clusters_to_choose,'类')
                centers_sorted = centers.nlargest(clusters_to_choose, 'sum')
                bad_cluster_list = centers_sorted['cluster']

                # 打上标签，记录下来.这里等于1指的是好电池
                feature_and_result['classify'] = 1
                for i in bad_cluster_list:
                    this_bad_cluster_num = i
                    feature_and_result.ix[(feature_and_result['cluster'] == this_bad_cluster_num), 'classify'] = 0

                result[str(idx)] = feature_and_result['classify']

                del feature_and_result

    result['sum'] = result.apply(lambda x: x.sum(), axis=1)
    result['评分'] = 100 * result['sum'] / idx

    result['cell'] = list(range(1, len(life) + 1))
    col_name = result.columns.tolist()
    col_name.insert(0, 'cell')

    result = result.reindex(columns=col_name)

    score[day_date] = result['评分']

    # result['classify']=result['评分']>=max(result.nsmallest(int(len(result['is_good'])-sum(result['is_good'])),'评分')['评分'])

    # result['judge']=(result['is_good'] == result['classify'])

    # right_ratio= sum(result['judge']) / len(result['judge'])
    # print(right_ratio)

    # #画图，二维的情况下；黑的是真正的坏电池，大个头的是我识别的坏电池。也就是说黑的都是大的，才是对的
    # result[all_features[0]]=features_df[all_features[0]]
    # result[all_features[1]]=features_df[all_features[1]]
    # colors = np.where(result['is_good'] ==1, 'r', 'k')#颜色是实际的好坏
    # sizes = np.where(result['classify'] ==0, 120, 60)#尺寸是我们判断的好坏。也就是说黑的都得大号现实才是对的
    # markers = np.where(result['classify'] ==0, '1', '2')
    # result.plot(kind='scatter', x=all_features[0], y=all_features[1], s=sizes, c=colors)
    # plt.show()

    # pickle.dump(result,open('result.pkl','wb'))
    try:
        result.to_csv(day_date + case_name + '.csv', sep=',', index=False)
        moveFiles(new_path, day_date + case_name + '.csv')
    except PermissionError:
        result.to_csv(day_date + case_name + '_1.csv', sep=',', index=False)
        moveFiles(new_path, day_date + case_name + '_1.csv')

    try:
        score.to_csv(case_name + '.csv', sep=',', index=False)
    except PermissionError:
        score.to_csv(case_name + '_1.csv', sep=',', index=False)
moveFiles(new_path, case_name + '.csv')