## 导入MATLAB的structure数据，变成Python的dict 

from pylab import *

mpl.rcParams['font.sans-serif'] = ['SimHei']
import h5py
import pickle
import struct_to_dict
import pandas as pd


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


def load_feature(new_path,day_date, case_name):
    # 加载数据

    var_cycles=[]
    #######################电压#################
    feature_type = 'vol'
    matFilename = new_path+'\\'+day_date + '_' + case_name + '_case_' + feature_type + '_feature_data.mat'
    # f=scipy.io.loadmat(matFilename)
    f = h5py.File(matFilename)
    data = struct_to_dict.struct_to_dict('case_vol_feature_data', f)
    print('电压提取完成')
    # with open(day_date+'_'+case_anme+'_'+feature_type+'_dict.pkl', 'wb') as fp:
    #     pickle.dump(data, fp)

    # 进行二次特征提取
    all_features = ['vol_max_sampEn_count', 'vol_max_diff_count', 'vol_min_vol_count',
                    'vol_max_space_sampEn', 'vol_sum_space_sampEn', 'vol_avg_space_sampEn', 'vol_var_space_sampEn',
                    'vol_max_time_sampEn', 'vol_sum_time_sampEn', 'vol_avg_time_sampEn', 'vol_var_time_sampEn',
                    'vol_sum_min_vol', 'vol_avg_min_vol',
                    'vol_max_diff', 'vol_sum_diff', 'vol_avg_diff', 'vol_var_diff'
                    ]
    features_dict = {}
    for feature in all_features:
        features_dict[feature] = []
    print(features_dict)
    # 先拿一个大家都已经统计好的，出现极值的统计次数。
    # 温度统计的是出现最大值，电压统计的是出现最低值，压差温差统计的是出现最大的次数
    vol_max_sampEn_count = data['sampEn']['case_sampEn_position_count']['max_record']  # 某个模组的熵在整个簇里面突出的次数
    vol_max_diff_count = data['maxmin']['case_diff_position_count']['max_record']  # 某个模组的压差在整个簇里面突出的次数
    vol_min_vol_count = data['maxmin']['case_maxmin_position_count']['min_record']  # 某个模组里面有单体老是整个簇电压最低的次数
    features_dict['vol_max_sampEn_count'] = vol_max_sampEn_count
    features_dict['vol_max_diff_count'] = vol_max_diff_count
    features_dict['vol_min_vol_count'] = vol_min_vol_count
    # ---------------TO DO：是归一化好。还是求比例好。感觉应该是归一化好，那样分得比较开---那就最后成了DF之后统一标准化

    for this_mod in data['sampEn']['mods_space_sampEn'].keys():
        # this_mod='Mod1'
        #  一整天，每个数据点，12个单体在当前点的熵，一天有八万多个点
        ##问：直接累加，可以吗？难道这个不是 和工况挂钩的。
        ##答：单日的可以直接横向对比。不同天之间。不可以！----工况不同。同一个特征可能差别很大。

        # 熵
        vol_space_sampEn = data['sampEn']['mods_space_sampEn'][this_mod]
        features_dict['vol_max_space_sampEn'].append(max(vol_space_sampEn))
        features_dict['vol_sum_space_sampEn'].append(sum(vol_space_sampEn))
        features_dict['vol_avg_space_sampEn'].append(sum(vol_space_sampEn) / len(vol_space_sampEn))
        features_dict['vol_var_space_sampEn'].append(np.var(vol_space_sampEn))

        vol_time_sampEn = data['sampEn']['mods_time_sampEn'][this_mod]
        features_dict['vol_max_time_sampEn'].append(max(vol_time_sampEn))
        features_dict['vol_sum_time_sampEn'].append(sum(vol_time_sampEn))
        features_dict['vol_avg_time_sampEn'].append(sum(vol_time_sampEn) / len(vol_time_sampEn))
        features_dict['vol_var_time_sampEn'].append(np.var(vol_time_sampEn))  # 一共才四个数，还要算那么多吗

        # 极值和差值
        ##电压-出现极值，取最低的。越低越不好。记得加负号，把它变成反比---------电压高的那个说不清是好还是不好，就不用了

        vol_min_vol = data['maxmin']['mods_min_data'][this_mod]
        vol_min_vol = [-l for l in vol_min_vol]
        features_dict['vol_sum_min_vol'].append(sum(vol_min_vol))
        features_dict['vol_avg_min_vol'].append(sum(vol_min_vol) / len(vol_min_vol))

        # 压差，越大越不好，肯定的
        vol_diff = data['maxmin']['mods_diff_data'][this_mod]
        features_dict['vol_max_diff'].append(max(vol_diff))
        features_dict['vol_sum_diff'].append(sum(vol_diff))
        features_dict['vol_avg_diff'].append(sum(vol_diff) / len(vol_diff))
        features_dict['vol_var_diff'].append(np.var(vol_diff))


    #########################温度的
    feature_type = 'tem'
    matFilename = new_path+'\\'+day_date + '_' + case_name + '_case_' + feature_type + '_feature_data.mat'
    f = h5py.File(matFilename)
    data = struct_to_dict.struct_to_dict('case_tem_feature_data', f)
    print('温度特征提取完成')

    all_features = ['tem_max_sampEn_count', 'tem_max_diff_count', 'tem_max_tem_count',
                    'tem_max_space_sampEn', 'tem_sum_space_sampEn', 'tem_avg_space_sampEn', 'tem_var_space_sampEn',
                    'tem_max_time_sampEn', 'tem_sum_time_sampEn', 'tem_avg_time_sampEn', 'tem_var_time_sampEn',
                    'tem_sum_max_tem', 'tem_avg_max_tem',
                    'tem_max_diff', 'tem_sum_diff', 'tem_avg_diff', 'tem_var_diff'
                    ]

    for feature in all_features:
        features_dict[feature] = []
    # 先拿一个大家都已经统计好的，出现极值的统计次数。
    # 温度统计的是出现最大值，电压统计的是出现最低值，压差温差统计的是出现最大的次数
    tem_max_sampEn_count = data['sampEn']['case_sampEn_position_count']['max_record']  # 某个模组的熵在整个簇里面突出的次数
    tem_max_diff_count = data['maxmin']['case_diff_position_count']['max_record']  # 某个模组的温差在整个簇里面突出的次数
    tem_max_tem_count = data['maxmin']['case_maxmin_position_count']['max_record']  # 某个模组里面有单体老是整个簇温度最高的次数
    features_dict['tem_max_sampEn_count'] = tem_max_sampEn_count
    features_dict['tem_max_diff_count'] = tem_max_diff_count
    features_dict['tem_max_tem_count'] = tem_max_tem_count
    # ---------------TO DO：是归一化好。还是求比例好。感觉应该是归一化好，那样分得比较开---那就最后成了DF之后统一标准化

    for this_mod in data['sampEn']['mods_space_sampEn'].keys():
        # this_mod='Mod1'
        #  一整天，每个数据点，12个单体在当前点的熵，一天有八万多个点
        ##问：直接累加，可以吗？难道这个不是 和工况挂钩的。
        ##答：单日的可以直接横向对比。不同天之间。不可以！----工况不同。同一个特征可能差别很大。

        # 熵
        tem_space_sampEn = data['sampEn']['mods_space_sampEn'][this_mod]
        features_dict['tem_max_space_sampEn'].append(max(tem_space_sampEn))
        features_dict['tem_sum_space_sampEn'].append(sum(tem_space_sampEn))
        features_dict['tem_avg_space_sampEn'].append(sum(tem_space_sampEn) / len(tem_space_sampEn))
        features_dict['tem_var_space_sampEn'].append(np.var(tem_space_sampEn))

        tem_time_sampEn = data['sampEn']['mods_time_sampEn'][this_mod]
        features_dict['tem_max_time_sampEn'].append(max(tem_time_sampEn))
        features_dict['tem_sum_time_sampEn'].append(sum(tem_time_sampEn))
        features_dict['tem_avg_time_sampEn'].append(sum(tem_time_sampEn) / len(tem_time_sampEn))
        features_dict['tem_var_time_sampEn'].append(np.var(tem_time_sampEn))  # 一共才四个数，还要算那么多吗

        # 极值和差值
        ##温度越高越不好。温度较低应该算好

        tem_max_tem = data['maxmin']['mods_max_data'][this_mod]
        features_dict['tem_sum_max_tem'].append(sum(tem_max_tem))
        features_dict['tem_avg_max_tem'].append(sum(tem_max_tem) / len(tem_max_tem))

        # 温差，越大越不好，肯定的
        tem_diff = data['maxmin']['mods_diff_data'][this_mod]
        features_dict['tem_max_diff'].append(max(tem_diff))
        features_dict['tem_sum_diff'].append(sum(tem_diff))
        features_dict['tem_avg_diff'].append(sum(tem_diff) / len(tem_diff))
        features_dict['tem_var_diff'].append(np.var(tem_diff))


    ###################容量的
    feature_type = 'cap'
    matFilename =new_path+'\\'+ case_name + '_case_' + feature_type + '_feature_data.mat'
    f = h5py.File(matFilename)
    data = struct_to_dict.struct_to_dict('case_cap_feature_data', f)
    print('容量特征提取完成')

    capacitys_feature= data['capacitys']
    if 'cycle' + day_date in capacitys_feature.keys():
        var_cycles.append('cap_list')
        features_dict['cap_list'] = data['capacitys']['cycle' + day_date]
    var_deltaQ_feature = data['var_deltaQ_feature']
    if 'cycle' + day_date in var_deltaQ_feature.keys():
        for cycle in var_deltaQ_feature['cycle' + day_date].keys():
            var_cycles.append('var_' +cycle)
            features_dict['var_' + cycle] = var_deltaQ_feature['cycle' + day_date][cycle]

    for key in features_dict.keys():
        print(key)
    #     print(len(features_dict[key]))
    # features_df=pd.DataFrame(features_dict)
    # features_df1=regularit(features_df)
    # # features_df1.plot(kind='scatter', x='tem_var_diff', y='tem_avg_max_tem')
    # # show()


    return features_dict,var_cycles

# load_feature('1','2')