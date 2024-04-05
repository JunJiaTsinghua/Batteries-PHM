# 用于在每个周期初，优化边界参数，
from pso_tri import PSO
import numpy as np

bound = [[1, 3] * 12, [0.1, 1] * 12, [0.5, 1.5] * 12]
bound = np.array(bound) #创建三个变量的边界参数
pNum=60
dim=bound.shape[0]*bound.shape[1]/2 #每个电池3个参数要寻优，共36个。
max_iter=1000
para=[0.5,1,1,1,1]
# 其他电池相关的参数 para_bats-包含轮值状态约束、需要传递的季节参数、当前SOH状态等
# DOD_C_RS=[[1,1],[0.7,1.25],[0.5,1.5]] #前面是DOD，后面是C

def use_PSO(pNum,dim,max_iter,bound,para,para_bats):
    my_pso = PSO(pN=pNum, dim=dim, max_iter=max_iter, bound=bound,para=para,para_bats=para_bats)#[粒子数，维度，边界，最大迭代次数，参数]
    my_pso.init_Population()
    fitness = my_pso.iterator()
    X=my_pso.X
    return X