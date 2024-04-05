#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#从下面的作者那里，改编的适合MIT数据的模糊聚类方法。
"""
Created on Wed Mar 27 10:51:45 2019
模糊c聚类:https://blog.csdn.net/lyxleft/article/details/88964494
@author: youxinlin
"""
import copy
import math
import random
import time

global MAX  # 用于初始化隶属度矩阵U
MAX = 100.0

global Epsilon  # 结束条件
Epsilon = 0.001


def print_matrix(list):
    """
    以可重复的方式打印矩阵
    """
    for i in range(0, len(list)):
        print(list[i])


def initialize_U(data, cluster_number):
    """
    这个函数是隶属度矩阵U的每行加起来都为1. 此处需要一个全局变量MAX.
    """
    global MAX
    U = []
    for i in range(0, len(data)):
        current = []
        rand_sum = 0.0
        for j in range(0, cluster_number):
            dummy = random.randint(1, int(MAX))
            current.append(dummy)
            rand_sum += dummy
        for j in range(0, cluster_number):
            current[j] = current[j] / rand_sum
        U.append(current)
    return U


def distance(point, center):
    """
    该函数计算2点之间的距离（作为列表）。我们指欧几里德距离。闵可夫斯基距离
    """
    if len(point) != len(center):
        return -1
    dummy = 0.0
    for i in range(0, len(point)):
        dummy += abs(point[i] - center[i]) ** 2
    return math.sqrt(dummy)


def end_conditon(U, U_old):
    """
	结束条件。当U矩阵随着连续迭代停止变化时，触发结束
	"""
    global Epsilon
    for i in range(0, len(U)):
        for j in range(0, len(U[0])):
            if abs(U[i][j] - U_old[i][j]) > Epsilon:
                return False
    return True


def normalise_U(U):
    """
    在聚类结束时使U模糊化。每个样本的隶属度最大的为1，其余为0
    """
    result_list=[]
    for i in range(0, len(U)):
        this_U=U[i]
        index_max=this_U.index(max(this_U))
        result_list.append(index_max)
    return result_list


def fuzzy(data, cluster_number, m):
    """
    这是主函数，它将计算所需的聚类中心，并返回最终的归一化隶属矩阵U.
    输入参数：簇数(cluster_number)、隶属度的因子(m)的最佳取值范围为[1.5，2.5]
    """
    # 初始化隶属度矩阵U
    U = initialize_U(data, cluster_number)
    # print_matrix(U)
    # 循环更新U
    while (True):
        # 创建它的副本，以检查结束条件
        U_old = copy.deepcopy(U)
        # 计算聚类中心
        C = []
        for j in range(0, cluster_number):
            current_cluster_center = []
            for i in range(0, len(data[0])):
                dummy_sum_num = 0.0
                dummy_sum_dum = 0.0
                for k in range(0, len(data)):
                    # 分子
                    dummy_sum_num += (U[k][j] ** m) * data[k][i]
                    # 分母
                    dummy_sum_dum += (U[k][j] ** m)
                # 第i列的聚类中心
                current_cluster_center.append(dummy_sum_num / dummy_sum_dum)
            # 第j簇的所有聚类中心
            C.append(current_cluster_center)

        # 创建一个距离向量, 用于计算U矩阵。
        distance_matrix = []
        for i in range(0, len(data)):
            current = []
            for j in range(0, cluster_number):
                current.append(distance(data[i], C[j]))
            distance_matrix.append(current)

        # 更新U
        for j in range(0, cluster_number):
            for i in range(0, len(data)):
                dummy = 0.0
                for k in range(0, cluster_number):
                    # 分母
                    dummy += (distance_matrix[i][j] / distance_matrix[i][k]) ** (2 / (m - 1))
                U[i][j] = 1 / dummy

        if end_conditon(U, U_old):
            break
    U = normalise_U(U)
    return U

