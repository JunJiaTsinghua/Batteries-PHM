from pylab import mpl
import scipy.io
import matplotlib.pyplot as plt
import numpy as np 
from pylab import *
from sklearn import  linear_model
from sklearn import gaussian_process
from sklearn.gaussian_process.kernels import RBF, ConstantKernel as C# REF就是高斯核函数
from sklearn.svm import SVR
mpl.rcParams['font.sans-serif'] = ['SimHei']

n_train=90
matFilename = './麻省理工/model1/dataset_variance.mat'
f=scipy.io.loadmat(matFilename)
dataset_variance=f['dataset_variance'][0][0]

life_list=dataset_variance[1]
life_list_log=[]
for i in life_list[0]:
    life_list_log.append(i)
    # life_list_log.append(np.log10(i))
life_list_log=np.atleast_2d(life_list_log).T
life_list=np.atleast_2d(life_list).T

var_list=dataset_variance[0]
var_list_log=[]
for i in var_list[0]:
    # var_list_log.append(i)
    var_list_log.append(np.log10(i))
var_list_log=np.atleast_2d(var_list_log).T

Ncyc = np.shape(var_list_log)[0]
x_train, y_train = var_list_log[0:n_train], life_list_log[0:n_train]  # 手动切分，训练集和预测集
x_test, y_test = var_list_log[n_train:Ncyc + 1], life_list_log[n_train:Ncyc + 1]


##回归模型
regr =linear_model.Ridge()
# regr = linear_model.ElasticNet(alpha=1, l1_ratio=0.1)
regr.fit(x_train, y_train)
y_pre_liner=regr.predict(x_test)
print ('Coefficients :\n', regr.coef_)
print ("Residual sum of square: %.2f" %np.mean((regr.predict(x_test) - y_test) ** 2))
print ("variance score: %.2f" % regr.score(x_test, y_test))



####GPR模型
kernel = C(10, (1, 1)) * RBF(10, (1,1000))  #
    # 获取拟合数据
gp = gaussian_process.GaussianProcessRegressor \
        (kernel, n_restarts_optimizer=1, alpha=0.001 )
gp.fit(x_train, y_train)
y_pre_gpr ,err= gp.predict(x_test,return_std=True)
print ("Residual sum of square: %.2f" %np.mean((gp.predict(x_test) - y_test) ** 2))
print ("variance score: %.2f" % gp.score(x_test, y_test))


####SVR模型
# 线性核函数配置支持向量机
linear_svr = SVR(kernel="linear")
# 训练
linear_svr.fit(x_train, y_train)
# 预测 保存预测结果
y_pre_svr1 = linear_svr.predict(x_test)

# 多项式核函数配置支持向量机
poly_svr = SVR(kernel="poly")
# 训练
poly_svr.fit(x_train, y_train)
# 预测 保存预测结果
y_pre_svr2 = linear_svr.predict(x_test)
print ("Residual sum of square: %.2f" %np.mean((gp.predict(x_test) - y_test) ** 2))
print ("variance score: %.2f" % gp.score(x_test, y_test))


#########画图
figure("模型示意图：黑色为实际值，红色为与测试，每个点代表一个cell")

subplot(221)
plt.scatter(x_test,y_test, color = 'black')
plt.scatter(x_test,y_pre_liner, color = 'red')
plt.xticks(())
plt.yticks(())
plt.title("线性")
subplot(222)
plt.scatter(x_test,y_test, color = 'black')
plt.scatter(x_test,y_pre_gpr, color = 'red')
plt.xticks(())
plt.yticks(())
plt.title("GPR")
subplot(223)
plt.scatter(x_test,y_test, color = 'black')
plt.scatter(x_test,y_pre_svr1, color = 'red')
plt.xticks(())
plt.yticks(())
plt.title("SVR-线性核函数")
subplot(224)
plt.scatter(x_test,y_test, color = 'black')
plt.scatter(x_test,y_pre_svr2, color = 'red')
plt.xticks(())
plt.yticks(())
plt.title("SVR—多项式核函数")


figure("预测图：黑色为实际值，红色为与测试，每个点代表一个cell")
subplot(221)
x = np.atleast_2d(np.arange(0,len(life_list_log))).T
plt.plot(x, life_list_log, color="black", linewidth=1, linestyle="-")
plt.plot(x[n_train:], y_pre_liner, color="red", linewidth=1.2, linestyle="-")
plt.title("回归")

subplot(222)
x = np.atleast_2d(np.arange(0,len(life_list_log))).T
plt.plot(x, life_list_log, color="black", linewidth=1, linestyle="-")
plt.plot(x[n_train:], y_pre_gpr, color="red", linewidth=1.2, linestyle="-")
plt.title("GPR")

subplot(223)
x = np.atleast_2d(np.arange(0,len(life_list_log))).T
plt.plot(x, life_list_log, color="black", linewidth=1, linestyle="-")
plt.plot(x[n_train:], y_pre_svr1, color="red", linewidth=1.2, linestyle="-")
plt.title("SVR—线性核函数")

subplot(224)
x = np.atleast_2d(np.arange(0,len(life_list_log))).T
plt.plot(x, life_list_log, color="black", linewidth=1, linestyle="-")
plt.plot(x[n_train:], y_pre_svr2, color="red", linewidth=1.2, linestyle="-")
plt.title("SVR—多项式核函数")

plt.show()