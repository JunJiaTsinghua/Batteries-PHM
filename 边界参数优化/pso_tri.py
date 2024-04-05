#三种群的PSO

import numpy as np
import random
import matplotlib.pyplot as plt
import aging_simu_matlab
import struct_to_dict
# ----------------------PSO参数设置---------------------------------
class PSO():
    def __init__(self, pN, dim, max_iter,bound,para,para_bats):
        self.para_bats =struct_to_dict.struct_to_dict('para_bats',para_bats) #mat的struct变成python的dict
        self.bound=bound
        self.DOD_C_RS=self.para_bats['DOD_C_RS']
        self.previous_DOD_C = self.para_bats['previous_DOD_C']
        self.new_bound = bound
        self.w = np.zeros(pN)
        self.W=para[0]
        self.c1 =para[1]
        self.c2 = para[2]
        self.r1 = para[3]
        self.r2 = para[4]
        self.pN=pN#总粒子数
        self.pN1 = int(pN/3)  # 粒子数量
        self.dim = dim  # 搜索维度
        self.max_iter = max_iter  # 迭代次数
        self.X = np.zeros((self.pN, self.dim))  # 所有粒子的位置和速度
        self.V = np.zeros((self.pN, self.dim))
        self.pbest = np.zeros((self.pN, self.dim))  # 个体经历的最佳位置和全局最佳位置
        self.gbest = np.zeros((1, self.dim))
        self.p_fit = np.zeros(self.pN)  # 每个个体的历史最佳适应值
        self.fit = 1e10  # 全局最佳适应值
        self.flag={}#越界标志位
    # ---------------------目标函数-----------------------------
    def aging_cost_by_matlab(self, X,para_bats):
        ans = aging_simu_matlab.cost_compute(X,para_bats) # 调用matlab用典型曲线预估这个周期的老化情况。
        return ans
    def operate_judge_by_matlab(self, X,para_bats):
        ans = aging_simu_matlab.operate_judge(X,para_bats) # 调用matlab用典型曲线预估这个周期的老化情况。
        return ans
    # ---------------------初始化种群----------------------------------
    def init_Population(self):
        rnd = np.random.random(size=self.dim)
        for i in range(self.pN):
            for j in range(self.dim):
                # 按照参数类型保留小数点数
                if len(self.previous_DOD_C) == 0:#没有上一轮的参考，就随机
                    if j%3==0: #轮值状态都是证整数
                        self.X[i][j] =round( self.new_bound[j][ 0] + \
                                        (self.new_bound[j][1] - self.new_bound[j][0]) * rnd[j])
                        # 如果是轮值状态，是要更新边界的
                        self.bound_update_by_RS()
                    if j%3==1: #第二列是DOD，取一位数
                        self.X[i][j] =round( self.new_bound[j][ 0] + \
                                        (self.new_bound[j][1] - self.new_bound[j][0]) * rnd[j],1)
                    if j%3==2: #第三列是C，取一位数
                        self.X[i][j] =round( self.new_bound[j][ 0] + \
                                        (self.new_bound[j][1] - self.new_bound[j][0]) * rnd[j],1)
                else:
                    self.X[i][j]=self.previous_DOD_C[j] #初始化为上一周期的
                self.V[i][j] = random.uniform(0, 1)
                self.flag[j] = 0
            self.pbest[i] = self.X[i]
            tmp = self.aging_cost_by_matlab(self.X[i],self.para_bats)
            self.p_fit[i] = tmp
            if tmp < self.fit:
                self.fit = tmp
                self.gbest = self.X[i]
    #更新轮值状态后，重置边界
    def bound_update_by_RS(self):
        for k in range(self.new_bound.shape(1)/2):
            if self.gbest[k*3]==1:
                self.new_bound[1][k*3+1]=self.DOD_C_RS[0][0]
                self.new_bound[2][k * 3 + 1] = self.DOD_C_RS[0][1]
            if self.gbest[k*3]==2:
                self.new_bound[1][k*3+1]=self.DOD_C_RS[1][0]
                self.new_bound[2][k * 3 + 1] = self.DOD_C_RS[1][1]
            if self.gbest[k*3]==3:
                self.new_bound[1][k*3+1]=self.DOD_C_RS[2][0]
                self.new_bound[2][k * 3 + 1] = self.DOD_C_RS[2][1]
    #越界标志位置0
    def init_flat(self):
        for j in range(self.dim):
            self.flag[j] = 0
 #-----------------三种粒子权重产生器------------------------
    # cloud_PSO的粒子更新方法
    def cloudW(self,Ex, En, He, N,pi=0.9):
        # numpy随机数发生器，指定种子为0
        np.random.seed(0)
        for i in range(int(N[0]),int(N[1])):
            En2 = np.random.normal(En, He)
            y = 0.9 * np.exp(-pow(self.X[i] - Ex, 2) / (2 * pow(En2, 2)))#生成的是对称的正态云分布
            if self.aging_cost_by_matlab(self.X[i],self.para_bats) <self.aging_cost_by_matlab(Ex,self.para_bats):#如果比当前最佳值小，越小权重就越小
                self.w[i]=y[0]#取一边就可以
            else:#否则就按大权重，迭代得快一点
                self.w[i] =pi
    # w_PSO的粒子更新方法
    def oumigaW(self,N,t):
        for i in range(int(N[0]), int(N[1])):
            self.w[i]=(self.W*2-t)*(self.W*2-self.W*0.5)/self.max_iter

    # 普通PSO的粒子更新方法
    def ordinaryW(self,N):
        for i in range(int(N[0]),int(N[1])):
            self.w[i]=self.W
            # ----------------------更新粒子位置----------------------------------
    def iterator(self):
        fitness = []
        for t in range(self.max_iter):
            for Type in [1, 2, 3]:#分批次产生不同种类的权重
                if Type == 1:num=[0,1/3*self.pN];self.ordinaryW(num)#这里的w也要搞成列表
                elif Type == 2:num=[1/3*self.pN,2/3*self.pN]; self.cloudW(self.gbest, 10,1, num,pi=0.9)
                else :num=[2/3*self.pN,self.pN];self.oumigaW(num,t)
                for i in range(int(num[0]),int(num[1])):  # 更新gbest\pbest

                    temp = self.aging_cost_by_matlab(self.X[i],self.para_bats)
                    # 判断：如果不能满足运行，则这个粒子被跳过
                    if self.operate_judge_by_matlab(self.X[i])==0:
                        continue
                    # 没被跳过，说明能运行成功，看一下老化成本是变高还是变低
                    if temp < self.p_fit[i]:  # 更新个体最优
                        self.p_fit[i] = temp
                        self.pbest[i] = self.X[i]
                        if self.p_fit[i] < self.fit:  # 更新全局最优
                            self.gbest = self.X[i]
                            self.fit = self.p_fit[i]
                    self.V[i] = self.w[i] * self.V[i] + self.c1 * self.r1 * (self.pbest[i] - self.X[i]) + \
                                self.c2 * self.r2 * (self.gbest - self.X[i])
                    temp_X = self.X[i] + self.V[i]  # 尝试不成功的话，要把原来的值赋回去
                    for item in self.flag:
                        if self.flag[item] >= 2*self.pN:
                            self.V[i][item] = -self.V[i][item]

                            print('多次越界，尝试反向迭代')
                            k = 0#反向后优化成功的粒子数
                            self.X[i] = self.X[i] + self.V[i]
                            for j in range(self.dim):
                                # 按照参数类型保留小数点数
                                if j % 3 == 0:  # 轮值状态都是证整数
                                    self.X[i][j] = round(self.X[i][j])
                                    # 如果是轮值状态，是要更新边界的
                                    self.bound_update_by_RS()
                                if j % 3 == 1:  # 第二列是DOD，取一位数
                                    self.X[i][j] = round(self.X[i][j], 1)
                                if j % 3 == 2:  # 第三列是C，取一位数
                                    self.X[i][j] = round(self.X[i][j], 1)
                            self.boundJudge()
                            print(self.X[i])
                            for i in range(self.pN):
                                temp = self.aging_cost_by_matlab(self.X[i],self.para_bats)
                                if temp < self.p_fit[i]: k = k + 1
                            if k < int(0.8*self.pN):#优化不成功，给赋值回去，并充值flag
                                self.X[i] = temp_X
                                self.init_flat()
                            else:
                                print('反向迭代是正确的')
                                self.init_flat()  # 重置标志位
                        else:
                            self.X[i] = temp_X
                #如果越界，只能取边界值
                self.boundJudge()
            fitness.append(self.fit)#这里是显示每种pso的最佳值，还要再次筛选的
            print(self.X[0], end=" ")
            print(self.fit)  # 输出最优值
        return fitness
    #--------------判断是否越过边界---------------
    def boundJudge(self):
        for i in range(self.pN):
            for j in range(self.dim):
                if self.X[i][j]>self.new_bound[j][1]:self.X[i][j]=self.new_bound[j][1];self.flag[j]+=1
                if self.X[i][j] < self.new_bound[j][0]: self.X[i][j] = self.new_bound[j][0];self.flag[j]+=1


