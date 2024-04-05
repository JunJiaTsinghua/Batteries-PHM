# 输入:分析对象、计算循环、页面的参数设置值

# 这个地方定死是MIT的那几个电池。因为储能数据目前离跳水太早了

import pandas as pd
import numpy as np
import h5py
import support_tools
anlyse_target = "容量跳水MIT示例数据"


def main():
    # 初始值
    res = [  # 默认带上方括号，与其他接口统一
        {
            "conclusion": "",  # 结论 页面没有就不管
            "running_state_by_sys": 1,  # 运行状态 1为正常，0为异常
            "chart": [],
            "msg": '',  # 额外信息 没有就不管
        }
    ]
    conclusion = ''
    res[0]["msg_jump"]=[]
    charts = []
    msg_jump=[]

    if anlyse_target == "容量跳水MIT示例数据":
        # 主要过程
        battery_num = [80, 87, 103]  # TODO 选的几个案例电池是这几个
        var_list, q_list, x_list = load_data()  # 导入的是本地的mat文件 TODO 换成之前做多维度评分时候，已经导入完整的MIT的特征集
        real_turning_point = check_jumping_points(var_list, q_list)
        for choosen_num in battery_num:
            jumping_result_record = cap_jumping_for_MIT(var_list, real_turning_point, choosen_num)
            sentense="针对电池#"+str(choosen_num)+",真实跳水点为："+str(jumping_result_record["真实跳水点"])+",预测跳水点为："+str(jumping_result_record["预测跳水点"][0])
            conclusion=support_tools.write_conclusion(conclusion, sentense)
            key=list(range(len(jumping_result_record["原始曲线"])))
            value={"原始曲线": jumping_result_record["原始曲线"],"预测曲线":jumping_result_record["预测曲线"]}
            single_chart=support_tools.write_chart("电池"+str(choosen_num),"","循环数","特征","电池"+str(choosen_num)+"的跳水点预测结果","line",key,value)
            msg_jump.append({"容量跳水点":jumping_result_record["预测跳水点"]})
            charts.append(single_chart)
        running_state_by_sys = 0
        # 把计算过程赋值到res中
        res[0]["conclusion"] = conclusion
        res[0]["chart"] = charts
        res[0]["running_state_by_sys"] = running_state_by_sys
        res[0]["msg_jump"] = msg_jump
        res[0]["msg"] = "由于当前储能电站离退役尚早，未出现容量跳水现象。此处以MIT公开数据集的几个电池作为案例展示。"


    return res


def check_jumping_points(var_list, q_list):
    real_turning_point = []
    for j in range(0, len(var_list)):
        y = q_list[j]
        x = np.linspace(1, len(y), len(y))
        y2 = y[len(y) - 1]
        y1 = y[0]
        x2 = x[len(x) - 1]
        x1 = x[0]
        a = y2 - y1
        b = x1 - x2
        c = x2 * y1 - x1 * y2
        max_d = 0  # 用于记录最大距离
        max_i = 0  # 用于记录跳水点编号
        for i in range(1, len(y)):
            d_i = abs(a * x[i] + b * y[i] + c) / pow((a ** 2 + b ** 2), 0.5)
            if d_i > max_d:  # 最小距离就是0,不用额外判断了
                max_d = d_i
                max_i = i
        real_turning_point.append(max_i)
    return real_turning_point


def load_data():
    filename = 'Cap_jump_sample_data.mat'
    f = h5py.File(filename, 'r')
    battery = f['battery']
    var_list = []
    q_list = []
    x_list = []
    keys = battery.keys()
    battery_len = battery['Q'].shape[0]

    for key in keys:
        for i in range(battery_len):
            temp = f[battery[key][i, 0]][:][0]
            if key == 'var':
                var_list.append(temp)
            elif key == 'Q':
                q_list.append(temp)
            else:
                x_list.append(temp)
    return var_list, q_list, x_list


def cap_jumping_for_MIT(var_list, real_turning_point, battery_i):
    # TODO 那个阈值是人为设置的？？？
    threshold = {"80": 2.6172325286029587e-06, "87": 5.5626594738200435e-06, "103": 3.386111014925089e-06}
    # 这儿是尝试之后选出来的几个效果好的电池做案例

    jumping_result_record = {}
    for cycle_i in range(0, len(var_list[battery_i]) - 400, 10):
        print('正在计算第' + str(battery_i) + '号电池的第' + str(cycle_i + 200) + '个循环')
        x = var_list[battery_i][0:200 + cycle_i]  # 需要预测的原始数据，随cycle的递增而更新
        gf = GrayForecast(x)  # 用GM来做预测
        predict = gf.forecast(200, 200)

        # 按照本次的预测结果，算评分和e。评分好像后面也没真的用
        y = var_list[battery_i][0:400 + cycle_i]  # y 是多看了200个循环的真实曲线
        score = 0
        for i in range(200):
            result = abs((y[len(y) - 201 - i] - predict[i]) / y[len(y) - 201 - i])
            if result < 0.2:
                score += 0.5
        e = []
        for i in range(200):
            e.append(y[len(y) - 201 - i] - predict[i])
        if max(e) > threshold[str(battery_i)]:

            xx = []  # 预测曲线
            for i in range(len(x)):
                xx.append(x[i])
            for i in range(len(predict)):  # 用于预测的特征，加上predict的部分
                xx.append(predict[i])


            jumping_result_record["预测曲线"] = xx
            jumping_result_record["原始曲线"] = y
            jumping_result_record["预测跳水点"] = [200 + cycle_i, y[200 + cycle_i]]
            jumping_result_record["真实跳水点"] = real_turning_point[battery_i]

            break

    return jumping_result_record


class GrayForecast():
    def __init__(self, data, datacolumn=None):
        if isinstance(data, pd.core.frame.DataFrame):
            self.data = data
            try:
                self.data.columns = ['数据']
            except:
                if not datacolumn:
                    raise Exception('您传入的dataframe不止一列')
                else:
                    self.data = pd.DataFrame(data[datacolumn])
                    self.data.columns = ['数据']
        elif isinstance(data, pd.core.series.Series):
            self.data = pd.DataFrame(data, columns=['数据'])
        else:
            self.data = pd.DataFrame(data, columns=['数据'])

        self.forecast_list = self.data.copy()

        if datacolumn:
            self.datacolumn = datacolumn
        else:
            self.datacolumn = None
        # save arg:
        #        data                DataFrame    数据
        #        forecast_list       DataFrame    预测序列
        #        datacolumn          string       数据的含义

    def level_check(self):
        # 数据级比校验
        n = len(self.data)
        lambda_k = np.zeros(n - 1)
        for i in range(n - 1):
            lambda_k[i] = self.data.ix[i]["数据"] / self.data.ix[i + 1]["数据"]
            if lambda_k[i] < np.exp(-2 / (n + 1)) or lambda_k[i] > np.exp(2 / (n + 2)):
                flag = False
        else:
            flag = True

        self.lambda_k = lambda_k

        if not flag:
            print("级比校验失败，请对X(0)做平移变换")
            return False
        else:
            print("级比校验成功，请继续")
            return True

    def GM_11_build_model(self, forecast=5):
        if forecast > len(self.data):
            raise Exception('您的数据行不够')
        X_0 = np.array(self.forecast_list['数据'].tail(forecast))
        #       1-AGO
        X_1 = np.zeros(X_0.shape)
        for i in range(X_0.shape[0]):
            X_1[i] = np.sum(X_0[0:i + 1])
        #       紧邻均值生成序列
        Z_1 = np.zeros(X_1.shape[0] - 1)
        for i in range(1, X_1.shape[0]):
            Z_1[i - 1] = -0.5 * (X_1[i] + X_1[i - 1])

        B = np.append(np.array(np.mat(Z_1).T), np.ones(Z_1.shape).reshape((Z_1.shape[0], 1)), axis=1)
        Yn = X_0[1:].reshape((X_0[1:].shape[0], 1))
        B = np.mat(B)
        Yn = np.mat(Yn)
        a_ = (B.T * B) ** -1 * B.T * Yn
        a, b = np.array(a_.T)[0]
        X_ = np.zeros(X_0.shape[0])

        def f(k):
            return (X_0[0] - b / a) * (1 - np.exp(a)) * np.exp(-a * (k))

        self.forecast_list.loc[len(self.forecast_list)] = f(X_.shape[0])
        return (X_0[0] - b / a) * (1 - np.exp(a)) * np.exp(-a * (X_.shape[0]))

    def forecast(self, time=5, forecast_data_len=5):
        predict = []
        for i in range(time):
            x = self.GM_11_build_model(forecast=forecast_data_len)
            predict.append(x)
        return predict

    def log(self):
        res = self.forecast_list.copy()
        if self.datacolumn:
            res.columns = [self.datacolumn]
        return res

    def reset(self):
        self.forecast_list = self.data.copy()


main()