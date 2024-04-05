from pylab import mpl
import scipy.io
import matplotlib.pyplot as plt
import numpy as np
from pylab import *
mpl.rcParams['font.sans-serif'] = ['SimHei']
matplotlib.rcParams['axes.unicode_minus']=False
from sklearn import  linear_model
from sklearn import gaussian_process
from sklearn.gaussian_process.kernels import RBF, ConstantKernel as C# REF就是高斯核函数
from sklearn.svm import SVR
from sklearn import model_selection
from sklearn.linear_model import LogisticRegression
from sklearn import metrics
import h5py
import pickle
import pandas as pd

class Var:
    classification_boundary = 550

with open('feature_dict.pkl', 'rb') as f:#版本不同，用pickle的话要用wb和rb
    features = pickle.load(f)

print(features.keys())
print(features['T_features'].keys())
feature_to_choose1='Tavg_1'
feature_to_choose2='var_4_5'
feature_to_choose3='T_Sum_5'
life=features['life']
# feature1=features[feature_to_choose1]
feature1=features['T_features'][feature_to_choose1]
feature2=features[feature_to_choose2]
# feature3=features[feature_to_choose3]
feature3=features['T_features'][feature_to_choose3]
cycle_life=[]
feature1_list=[]
feature2_list=[]
feature3_list=[]
classfication_result=zeros(len(life))

#识别好坏电池
for i in range(0,len(life)):
    cycle_life.append(life[i][0])
    feature1_list.append(log10(float(feature1[i])))
    feature2_list.append(log10(float(feature2[i])))
    feature3_list.append((float(feature3[i])))
    if life[i] <=Var.classification_boundary:
        classfication_result[i]=1
    else:
        classfication_result[i]=0

df=pd.DataFrame({'feature1':feature1_list,'feature2':feature2_list,'feature3':feature3_list,'is_good':classfication_result})
X=df.ix[:,['feature1','feature2','feature3']]
y=df['is_good']
clf_lg=LogisticRegression()

X_train, X_test, y_train, y_test = model_selection.train_test_split(X, y, test_size=0.3, random_state=0)
clf_lg.fit(X_train, y_train)
y_pred=clf_lg.predict(X_test)

print(len(y_pred))

# 绘制散点图
plt.figure(1)
plt.title('训练结果')
plt.xlabel('cells_to_predict')
plt.ylabel('result')
x_axis=list(range(0,len(y_test)))
plt.scatter(x_axis, y_test, marker='x', color='black', s=50, label='真实结果')
plt.scatter(x_axis,y_pred , marker='o', color='blue', s=10, label='预测结果')
plt.legend(loc='upper right')

print('准确率',metrics.accuracy_score(y_test, y_pred))
print('精确率',metrics.precision_score(y_test, y_pred))
print('召回率',metrics.recall_score(y_test, y_pred))

#绘制预测结果的散点图
# plt.figure(3)
# plt.title('概率结果')
# plt.xlabel('实际寿命')
# plt.ylabel('为好电池的概率')
# y_proba_list=[]
# for i in y_proba:
#     y_proba_list.append(i[0])
# plt.scatter(X_test,y_proba_list, marker='o', color='blue', s=10, label='预测概率')


# 绘制特征与寿命的散点图
plt.figure('特征与分类')
plt.title('样本集')
classfication_result=np.array(classfication_result).reshape(-1,1)
feature1_list=np.array(feature1_list).reshape(-1,1)
feature2_list=np.array(feature2_list).reshape(-1,1)
plt.scatter(feature1_list[classfication_result == 0], feature2_list[classfication_result ==  0], marker='o', color='red', s=10, label='bad')
plt.scatter(feature1_list[classfication_result == 1], feature2_list[classfication_result ==  1], marker='o', color='green', s=10, label='good')
plt.xlabel(feature_to_choose1)
plt.ylabel(feature_to_choose2)
# for i in range(0,len(y)):
#     print(i)
#     if y[i] ==0:plt.scatter(feature1_list[i], feature2_list[i], marker='o', color='red', s=10, label='bad')
#     else:plt.scatter(feature1_list[i], feature2_list[i], marker='o', color='green', s=10, label='good')
plt.legend(loc='upper right')
# plt.show()

plt.show()

