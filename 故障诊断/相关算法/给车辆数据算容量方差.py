import copy
import numpy as np
import matplotlib.pyplot as plt

def VehicleTest_variance(VehicleTestData):

    IntervalVVarGlobal = 0.05
    ChrNumDiffVarGlobal = 3
    CrrtDiffToleranceVarGlobal = 15
    MinChrLengthVarGlobal = 40
    DiffCapToleranceVarGlobal = 0.4

    # VehicleTestData = loadmat('data_30_2.mat')
    VehicleChr = VehicleTestData['b']
    ChrNames = list(VehicleChr.dtype.names)
    CharToDelete = []
    AbnormalMessage = [[] for z in range(4)]
    DataStruct = {}
    IntervalToDelete = []

    # 定义取自定义范围区间里的数对应的索引的函数
    def indices(a, func):
        return [i for (i, val) in enumerate(a) if func(val)]

    for Chrnum in range(1, len(ChrNames) + 1, 1):
        DataStruct['Chr'+str(Chrnum)] = {}
        thisChrName = ChrNames[Chrnum - 1]
        # 此处仅读取嵌套结构体下的Chrx，还不是存储的数据
        VehicleChr_Chr = VehicleChr[0, 0][thisChrName]
        # 此处读取真正存储数据
        FlaBICelluAll = VehicleChr_Chr[0, 0]['FlaBICelluAll']
        FlaBIBCUBattCrrt = VehicleChr_Chr[0, 0]['FlaBIBCUBattCrrt']
        FlaBIGPSmiles = VehicleChr_Chr[0, 0]['FlaBIGPSmiles']
        FlaBIBCUBattSOC = VehicleChr_Chr[0, 0]['FlaBIBCUBattSOC']
        FlaBICellTAll = VehicleChr_Chr[0, 0]['FlaBICellTAll']
        FlaBIBCUBattU = VehicleChr_Chr[0, 0]['FlaBIBCUBattU']
        Time = VehicleChr_Chr[0, 0]['Time1']
        DiffTime = (Time[1:] - Time[:-1]) * 24 * 3600
        # 秩为2的ndarray，添加一行
        DiffTime = np.append(DiffTime, [[10]], axis=0)
        Cap = abs(FlaBIBCUBattCrrt) * DiffTime / 3600
        Cap = np.cumsum(Cap)
        Cap.resize((len(Cap), 1))
        if FlaBICelluAll.shape[0] < MinChrLengthVarGlobal:
            CharToDelete.append(thisChrName)
            del DataStruct['Chr'+str(Chrnum)]
            continue
        FlagV = [3.5]
        for k in range(1, 101, 1):
            FlagV = np.append(FlagV, [3.5 + IntervalVVarGlobal * k])
            if abs(3.5 + IntervalVVarGlobal * k - 4.2) < 0.00000001:
                break
        minV = FlaBICelluAll.min(0)
        maxV = FlaBICelluAll.max(0)
        SUM = [sum(sum(abs(minV - np.tile(FlagV[0], (1, FlaBICelluAll.shape[1])))))]
        SUM1 = [sum(sum(abs(maxV - np.tile(FlagV[0], (1, FlaBICelluAll.shape[1])))))]
        for l in range(1, FlagV.shape[0], 1):
            SUM = np.append(SUM, [sum(sum(abs(minV - np.tile(FlagV[l], (1, FlaBICelluAll.shape[1])))))])
            SUM1 = np.append(SUM1, [sum(sum(abs(maxV - np.tile(FlagV[l], (1, FlaBICelluAll.shape[1])))))])
        idxmin = np.argmin(SUM)
        idxmax = np.argmin(SUM1)
        StartFlag = FlagV[idxmin]
        EndFlag = FlagV[idxmax]
        if len(np.unique(minV < StartFlag)) == 2 or np.unique(minV < StartFlag) == 0:
            StartFlag = FlagV[idxmin]
        else:
            StartFlag = FlagV[idxmin] - IntervalVVarGlobal
        if len(np.unique(maxV >= EndFlag)) == 2 or np.unique(maxV >= EndFlag) == 0:
            EndFlag = FlagV[idxmax]
        else:
            EndFlag = FlagV[idxmax] + IntervalVVarGlobal
        del FlagV
        Flag = [StartFlag]
        for p in range(1, 101, 1):
            Flag = np.append(Flag, [StartFlag + IntervalVVarGlobal * p])
            for leng in range(0, len(Flag)):
                Flag[leng] = round(Flag[leng], 2)
            if abs(StartFlag + IntervalVVarGlobal * p - EndFlag) < 0.00000001:
                break
        for v in range(1, FlaBICelluAll.shape[1] + 1):
            DataStruct['Chr'+str(Chrnum)]['cell'+str(v)] = {}
            thisCellName = 'cell' + str(v)
            thisChrCellV = FlaBICelluAll[:, v - 1]
            for s in range(1, len(Flag) - 1 + 1, 1):
                xx = thisChrCellV - Flag[s - 1]
                sx = thisChrCellV - Flag[s]
                idx1 = indices(xx, lambda x: x > 0.00000001)
                idx2 = indices(sx, lambda x: x < 0.00000001)# indices相当于matlab的find
                idx = [val for val in idx1 if val in idx2]
                idx = np.array(idx)
                delta_idx = idx[1:] - idx[:-1]
                delta_idx.resize((len(delta_idx), 1))
                repmat = np.tile(1, (delta_idx.shape[0], 1))
                if (delta_idx != repmat).any():
                    num = indices(delta_idx, lambda x: x != 1)
                    if len(num) >= 1:
                        num1 = min(num)#不能用int 比如num=[17] ,int(array(num)) = 1而不是17
                        num2 = max(num)
                    else:
                        continue
                    if max(thisChrCellV[idx[num1] + 1: idx[num2+1]-1+1]) > Flag[s]:# 不能用.any() .any()出来的是bool型 这儿是在这个区间内存在一个比Flag[s]大的thisChrCellV 用max就行
                        idx = idx[0: num1+1]
                if len(idx) != 0:
                    CellV = thisChrCellV[idx]
                    DiffCellV = CellV[1:] - CellV[:-1]
                else:
                    CellV = []
                    CellV = np.array(CellV)
                    DiffCellV = []
                    DiffCellV = np.array(DiffCellV)
                thisIntervalName = 'V_' + str(Flag[s - 1]).replace('.', '_') + '_' + str(Flag[s]).replace('.', '_')
                DiffCellVDY0 = [y for y in DiffCellV if y >= 0]
                DiffCellVXY0 = [w for w in DiffCellV if w < 0]
                c = DiffCellV.shape[0]
                if len(DiffCellVDY0) != DiffCellV.shape[0]:
                    AbnormalMessage[0].append(thisChrName)
                    AbnormalMessage[1].append(thisCellName)
                    AbnormalMessage[2].append(thisIntervalName)
                    AbnormalMessage[3].append(len(DiffCellVXY0))
                try:
                    if len(idx) >= 1:
                        vol = list(thisChrCellV[idx[0]:idx[-1]])
                        vol.append(thisChrCellV[idx[-1]])
                        Crrt = list(FlaBIBCUBattCrrt[idx[0]:idx[-1]])
                        Crrt.append(FlaBIBCUBattCrrt[idx[-1]])
                        # SOC = list(FlaBIBCUBattSOC[idx[0]:idx[-1]])
                        # SOC.append(FlaBIBCUBattSOC[idx[-1]])
                        # Temp = list(FlaBICellTAll[idx[0]:idx[-1], :])
                        # BusV = list(FlaBIBCUBattU[idx[0]:idx[-1]])
                        # BusV.append(FlaBIBCUBattU[idx[-1]])
                        time = list(Time[idx[0]:idx[-1]])
                        time.append(Time[idx[-1]])
                        cap = list(Cap[idx[0]:idx[-1]])
                        cap.append(Cap[idx[-1]])
                        for length in range(0, len(Crrt)):
                            Crrt[length] = float(Crrt[length])
                            time[length] = float(time[length])
                            cap[length] = float(cap[length])
                        DataStruct['Chr' + str(Chrnum)]['cell' + str(v)][thisIntervalName] = {'voltage': vol, 'current': Crrt, 'CrrtMean': np.mean(Crrt),
                                                                                              'CrrtVar': np.var(Crrt, ddof=1), 'time': time, 'cap': cap}
                    else:
                        print(thisChrName, thisCellName, '在', thisIntervalName, '区间竟然有', str(len(idx)), '个值')
                        IntervalToDelete.append(thisChrName + ';' + thisIntervalName)
                except:
                    print(thisChrName, thisCellName, '在', thisIntervalName, '区间竟然有', 'something wrong')

    IntervalToDelete = np.unique(IntervalToDelete)
    for itd in range(0, IntervalToDelete.shape[0], 1):
        Cell = str.split(IntervalToDelete[itd], ';')
        thisChrName = Cell[0]
        thisIntervalName = Cell[1]
        for Cellnum in range(0, FlaBICelluAll.shape[1], 1):
            thisCellName = 'cell' + str(Cellnum+1)
            if thisIntervalName in DataStruct[thisChrName][thisCellName].keys():# 相当于matlab的isfield
                del DataStruct[thisChrName][thisCellName][thisIntervalName]

    OldDataStruct = copy.deepcopy(DataStruct)
    CrrtErrMess = {}
    CrrtRange = {}
    CrrtMean = [0 for z in range(0, FlaBICelluAll.shape[1])]
    CrrtVar = [0 for z in range(0, FlaBICelluAll.shape[1])]
    for Chrnum in range(len(ChrNames), 0, -1):
        thisChrName = ChrNames[Chrnum - 1]
        if len(CharToDelete) != 0:
            panduan = any(thisChrName in s for s in CharToDelete)
            if panduan:
                continue
        IntervalNames = DataStruct[thisChrName]['cell1'].keys()
        IntervalNames = list(IntervalNames)
        for IntervalNum in range(0, len(IntervalNames)):
            thisIntervalName = IntervalNames[IntervalNum]
            for CellNum in range(0, FlaBICelluAll.shape[1], 1):
                thisCellName = 'cell' + str(CellNum + 1)
                CrrtMean[CellNum] = DataStruct[thisChrName][thisCellName][thisIntervalName]['CrrtMean']
                CrrtVar[CellNum] = DataStruct[thisChrName][thisCellName][thisIntervalName]['CrrtVar']
            CrrtRange[thisChrName + ';' + thisIntervalName] = abs(max(CrrtMean) - min(CrrtMean))
            if abs(max(CrrtMean) - min(CrrtMean)) > CrrtDiffToleranceVarGlobal:
                CrrtErrMess[thisChrName + ';' + thisIntervalName] = abs(max(CrrtMean) - min(CrrtMean))
                for i in range(0, FlaBICelluAll.shape[1], 1):
                    del DataStruct[thisChrName]['cell' + str(i + 1)][thisIntervalName]

    IntervalBelong2Chrs = {}
    VarStruct = {}
    IntervalBelong2Chrsanother = [[] for z in range(4)]
    CapError = {}
    CrrtRange1 = [0 for z in range(0, FlaBICelluAll.shape[1])]
    CrrtRange2 = [0 for z in range(0, FlaBICelluAll.shape[1])]
    CapChrCmped = [0 for z in range(0, FlaBICelluAll.shape[1])]
    CapChrToCmp = [0 for z in range(0, FlaBICelluAll.shape[1])]
    for ChrNum in range(len(ChrNames), 0, -1):
        thisChrCmped = ChrNames[ChrNum - 1]
        if len(CharToDelete) != 0:
            panduan1 = any(thisChrCmped in s for s in CharToDelete)
            if panduan1:
                continue
        IntervalBelong2Chrs[thisChrCmped] = {}
        VarStruct[thisChrCmped] = {}
        CapError[thisChrCmped] = {}
        for ChrNum2 in range(1, (ChrNum-1-ChrNumDiffVarGlobal)+1, 1):
            thisChrToCmp = ChrNames[ChrNum2 - 1]
            if len(CharToDelete) != 0:
                panduan2 = any(thisChrToCmp in s for s in CharToDelete)
                if panduan2:
                    continue
            IntervalBelong2Chrs[thisChrCmped][thisChrToCmp] = {}
            VarStruct[thisChrCmped][thisChrToCmp] = {}
            CapError[thisChrCmped][thisChrToCmp] = {}
            IntervalCmped = list(DataStruct[thisChrCmped]['cell1'].keys())
            IntervalToCmp = list(DataStruct[thisChrToCmp]['cell1'].keys())
            for i in range(0, len(IntervalCmped), 1):
                panduan3 = any(IntervalCmped[i] in s for s in IntervalToCmp) # 等价于matlab的ismember
                if panduan3:
                    FindThisInterval = IntervalCmped[i]
                    for CellNum in range(0, FlaBICelluAll.shape[1], 1):
                        thisCellName = 'cell' + str(CellNum + 1)
                        cap1 = DataStruct[thisChrCmped][thisCellName][FindThisInterval]['cap']
                        cap2 = DataStruct[thisChrToCmp][thisCellName][FindThisInterval]['cap']
                        CapChrCmped[CellNum] = max(cap1) - min(cap1)
                        CapChrToCmp[CellNum] = max(cap2) - min(cap2)
                        crrt1 = DataStruct[thisChrCmped][thisCellName][FindThisInterval]['current']
                        crrt2 = DataStruct[thisChrToCmp][thisCellName][FindThisInterval]['current']
                        CrrtRange1[CellNum] = abs(max(crrt1)-min(crrt1))
                        CrrtRange2[CellNum] = abs(max(crrt2)-min(crrt2))
                    CrrtRange1DY20 = 0
                    CrrtRange1XY20 = 0
                    CrrtRange2DY20 = 0
                    CrrtRange2XY20 = 0
                    for i in range(0, FlaBICelluAll.shape[1], 1):
                        if CrrtRange1[i] > 20:
                            CrrtRange1DY20 = CrrtRange1DY20 + 1
                        if CrrtRange1[i] < 20:
                            CrrtRange1XY20 = CrrtRange1XY20 + 1
                        if CrrtRange2[i] > 20:
                            CrrtRange2DY20 = CrrtRange2DY20 + 1
                        if CrrtRange2[i] < 20:
                            CrrtRange2XY20 = CrrtRange2XY20 + 1
                    if CrrtRange1DY20 != 0 and CrrtRange1XY20 != 0:# 若CrrtRange1列表中 有的值大于20，有的小于20
                    # if len(np.unique(CrrtRange1[s] < 20)) == 2:
                        print(thisChrCmped, '在', FindThisInterval, '存在大电流阶跃，最大值为', str(max(CrrtRange1)))
                    # if len(np.unique(CrrtRange2 < 20)) == 2:
                    if CrrtRange2DY20 != 0 and CrrtRange2XY20 != 0:
                        print(thisChrToCmp, '在', FindThisInterval, '存在大电流阶跃，最大值为', str(max(CrrtRange2)))
                    if abs(max(CapChrCmped)-min(CapChrCmped))/max(CapChrCmped) > DiffCapToleranceVarGlobal:
                        print(thisChrCmped, '在', FindThisInterval, '所有单体充入容量相差太大')
                        continue
                    if abs(max(CapChrToCmp)-min(CapChrToCmp))/max(CapChrToCmp) > DiffCapToleranceVarGlobal:
                        print(thisChrToCmp, '在', FindThisInterval, '所有单体充入容量相差太大')
                        continue
                    Tolerance = abs(np.mean(CapChrCmped) - np.mean(CapChrToCmp)) / np.maximum(np.mean(CapChrCmped), np.mean(CapChrToCmp))
                    if Tolerance <= DiffCapToleranceVarGlobal:
                        IntervalBelong2Chrs[thisChrCmped][thisChrToCmp][FindThisInterval] = Tolerance
                        IntervalBelong2Chrsanother[0].append(thisChrCmped)
                        IntervalBelong2Chrsanother[1].append(thisChrToCmp)
                        IntervalBelong2Chrsanother[2].append(FindThisInterval)
                        IntervalBelong2Chrsanother[3].append(Tolerance)# IntervalBelong2Chrs是字典 不好算出所有元素的个数已经取对应每行的元素 所有新建一个0*4的[]，用与下面的循环
                        #IntervalBelong2Chrs方便查看 IntervalBelong2Chrsanother方便取值
                    else:
                        CapError[thisChrCmped][thisChrToCmp][FindThisInterval] = Tolerance
            if IntervalBelong2Chrs[thisChrCmped][thisChrToCmp] == {}:# 构造的字典由于有的地方FindThisInterval没有，所以对应地方为空，即要删掉某些字典内容（注意if在哪个循环，注意if语句的位置）
                del IntervalBelong2Chrs[thisChrCmped][thisChrToCmp]
        if IntervalBelong2Chrs[thisChrCmped] == {}:# 此时是删空的IntervalBelong2Chrs[thisChrCmped]，应当在if删掉IntervalBelong2Chrs[thisChrCmped][thisChrToCmp]语句的上一个循环中
            del IntervalBelong2Chrs[thisChrCmped]

    NormalizeVarTable = []
    for i in range(0, len(IntervalBelong2Chrsanother[0]), 1):
        thisChrCmped = IntervalBelong2Chrsanother[0][i]
        thisChrToCmp = IntervalBelong2Chrsanother[1][i]
        Dict = IntervalBelong2Chrs[thisChrCmped][thisChrToCmp]
        if len(Dict) < 2:
            continue
        IntervalName = list(Dict.keys())
        VarStruct[thisChrCmped][thisChrToCmp]['Varlist'] = []
        for CellNum in range(0, FlaBICelluAll.shape[1], 1):
            thisCellName = 'cell' + str(CellNum + 1)
            CapChrCmped = []
            CapChrToCmp = []
            for IntervalNum in range(0, len(IntervalName), 1):
                thisIntervalName = IntervalName[IntervalNum]
                C1 = DataStruct[thisChrCmped][thisCellName][thisIntervalName]['current']
                T1 = DataStruct[thisChrCmped][thisCellName][thisIntervalName]['time']
                DeltaT1 = np.array(T1[1:])*24*3600 - np.array(T1[:-1])*24*3600
                DeltaT1 = DeltaT1.tolist()# 列表对应元素相减 可转成array减完再转回来
                DeltaT1.append(10)
                CapChrCmped.append(abs(sum(np.array(C1[:]) * np.array(DeltaT1[:])/3600)))
                C2 = DataStruct[thisChrToCmp][thisCellName][thisIntervalName]['current']
                T2 = DataStruct[thisChrToCmp][thisCellName][thisIntervalName]['time']
                DeltaT2 = np.array(T2[1:]) * 24 * 3600 - np.array(T2[:-1]) * 24 * 3600
                DeltaT2 = DeltaT2.tolist()  # 列表对应元素相减 可转成array减完再转回来
                DeltaT2.append(10)
                CapChrToCmp.append(abs(sum(np.array(C2[:]) * np.array(DeltaT2[:])/3600)))
            cd = np.var((np.array(CapChrCmped) - np.array(CapChrToCmp)).tolist(), ddof=1)# python的var是除以N，总体方差 matlab的Var是除以N-1，样本方差，doff=1即自由度为1，为N-1
            VarStruct[thisChrCmped][thisChrToCmp]['Varlist'].append(cd)

    for Cmped in range(len(ChrNames), 0, -1):
        thisChrCmped = ChrNames[Cmped - 1]
        if len(CharToDelete) != 0:
            panduan4 = any(thisChrCmped in s for s in CharToDelete)
            if panduan4:
                continue
        for ToCmp in range(1, (Cmped-1-ChrNumDiffVarGlobal)+1, 1):
            thisChrToCmp = ChrNames[ToCmp - 1]
            if len(CharToDelete) != 0:
                panduan5 = any(thisChrToCmp in s for s in CharToDelete)
                if panduan5:
                    continue
            if VarStruct[thisChrCmped][thisChrToCmp] == {}:
                del VarStruct[thisChrCmped][thisChrToCmp]
                continue
            VarList1 = VarStruct[thisChrCmped][thisChrToCmp]['Varlist']
            MaxVar = max(VarList1)
            MinVar = min(VarList1)
            DiffVar = MaxVar - MinVar
            NormalizeVarList = []
            if DiffVar != 0:
                for m in range(0, len(VarList1), 1):
                    NormalizeVarList.append((VarList1[m] - MinVar) / DiffVar)
            else:
                NormalizeVarList = np.tile(0, (1, FlaBICelluAll.shape[1]))
            NormalizeVarTable.append(NormalizeVarList)

    # 把NormalizeVarTable按对应每个电池的所有归一化方差相加，形成sumNormalizeVarTable，长度为电池数
    sumNormalizeVarTable = []
    for g in range(0, len(NormalizeVarTable[0]), 1):
        sumn = 0
        for h in range(0, len(NormalizeVarTable), 1):
            sumn = NormalizeVarTable[h][g] + sumn
        sumNormalizeVarTable.append(sumn)

    plt.rcParams['font.sans-serif'] = ['SimHei']  # 显示中文标签
    plt.rcParams['axes.unicode_minus'] = False
    plt.figure()
    plt.plot(range(1, len(sumNormalizeVarTable) + 1, 1), sumNormalizeVarTable,
             linewidth=1)  # plot用来画散点图,linewidth为线条的粗细
    plt.ylabel('归一化后各单体方差之和')
    plt.xlabel('单体序号cell#')

    VarTable = [[] for z in range(4)]
    for j in range(0, len(VarStruct.keys()), 1):
        thisChrCmped = list(VarStruct.keys())
        for i in range(0, len(VarStruct[thisChrCmped[j]].keys()), 1):
            thisChrToCmp = list(VarStruct[thisChrCmped[j]].keys())
            VarList = VarStruct[thisChrCmped[j]][thisChrToCmp[i]]['Varlist']
            value = max(VarList)
            index = VarList.index(max(VarList))# 求列表最大值索引的方法
            VarTable[0].append(thisChrCmped[j])
            VarTable[1].append(thisChrToCmp[i])
            VarTable[2].append(value)
            VarTable[3].append(index)

    x1 = [i + 1 for i in VarTable[3]]  # 把最大方差对应的index加1，不然cell从0开始
    y1 = VarTable[2]
    plt.figure()
    plt.scatter(x1, y1, color='r', s=5)  # scatter用来画散点图,s为点的尺寸
    plt.title('预处理后各单体的可用方差')
    plt.xlabel('Cell')
    plt.ylabel('方差')

    prob = [0.0 for z in range(0, FlaBICelluAll.shape[1])]
    for i in range(0, FlaBICelluAll.shape[1], 1):
        icount = indices(VarTable[3], lambda x: x == i)  # 求列表中自定义某个数或者某个区间数的索引
        if len(icount) == 0:
            prob[i] = 0
        else:
            prob[i] = len(icount) / len(VarTable[3])

    plt.figure()
    plt.plot(range(1, len(prob) + 1, 1), prob, linewidth=1)  # plot用来画散点图,linewidth为线条的粗细
    plt.ylabel('最大方差的概率')
    plt.xlabel('cell#')

    plt.figure()
    plt.plot(range(1, len(VarTable[2]) + 1, 1), VarTable[2], linewidth=1)
    plt.ylabel('最大方差的值')  # 在这两个Chr里，取VarList（VarList为在这两个Chr时，cell1到85的各个方差）中最大的值
    plt.xlabel('第几对符合条件的两个Chr')

    plt.show()

    return VarTable[2]


def VehicleTest_inconsistency(VehicleTestData):

    # VehicleTestData = loadmat('data_30_2.mat')
    VehicleChr = VehicleTestData['b']
    ChrNames = list(VehicleChr.dtype.names)
    DataStruct = {}

    STD = []
    for Chrnum in range(1, len(ChrNames) + 1, 1):
        DataStruct['Chr'+str(Chrnum)] = {}
        thisChrName = ChrNames[Chrnum - 1]
        # 此处仅读取嵌套结构体下的Chrx，还不是存储的数据
        VehicleChr_Chr = VehicleChr[0, 0][thisChrName]
        # 此处读取真正存储数据
        FlaBICelluAll = VehicleChr_Chr[0, 0]['FlaBICelluAll']
    for i in range(FlaBICelluAll.shape[0]):
        STD.append(np.std(FlaBICelluAll[i,:],ddof=1))

    return STD

