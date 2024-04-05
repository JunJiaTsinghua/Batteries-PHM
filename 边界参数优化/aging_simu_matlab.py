#用于给PSO发送当前边界，让matlab返回结果

import numpy as np
from pylab import mpl
from numpy import *
import matlab.engine


class VAR:

    path='D:\程序\差异化调度\老化成本计算'

# 把边界参数发给m程序，由那边自动跑完典型曲线生成、Ah总量计算和HFs的预测，只返回一个老化成本即可。
def cost_compute(X,paras_bat):
    # 启动matlab
    eng = matlab.engine.start_matlab()

    eng.cd(VAR.path, nargout=0)
    # 返回是老化成本预测值
    cost=eng.function_aging_cost_pre(X,paras_bat)

    return cost

# 把边界参数发给m程序，判断是否能完成。返回是1或者0-成或者不成
def operate_judge(X,paras_bat):
    # 启动matlab
    eng = matlab.engine.start_matlab()

    eng.cd(VAR.path, nargout=0)
    #返回是否能运行的标志位
    if_run_flag=eng.function_typical_day_judge(X,paras_bat)

    return if_run_flag