本人所在团队长久以来从事电池健康管理、故障诊断和控制优化的相关研究，目前已陆续为多个车企、电网公司、发电集团的车用动力电池系统、储能电池系统提供诊断服务。
所分享的项目为近期研究的差异化调度方法。
有别于传统的仅使用SOH为标杆的均衡调度策略，我们以SOH和综合评分计算了老化成本，以所在场景下的总老化成本降低为目标，优化了指令分解方式。
其中综合评分依赖可表征多个运行能力的健康特征，用上了团队多年来积累的各种评估方法。
通过实验建立了DOD、C对各个健康特征的变化影响规律，用于判断所分解的工况在一段时间后导致的健康特征变化情况，进而评估老化成本。

1、分享了数据处理代码
其中包含一部分以DOD\C为实验变量的实验数据。
也分享了针对储能电站在线数据的获取和处理算法。
	
2、分享了健康特征提取代码
分享了集成在AILiOn(AI_driven Li-On Tool，我们开发的一个用于电池数据分析的matlab APP)工具的多个特征提取模块代码
也分享了部分还处于离线验证的特征提取代码。
具体内容可以查看我们已经发表的论文：
（1）Xiong, R.; Wang, S.; Feng, F.; Yu, C.; Fan, Y.; Cao, W.; Fernandez, C. Co-Estimation of State-of-Charge and State-of-Health for High-Capacity Lithium-Ion Batteries. Batteries 2023, 9 (10), 509. https://doi.org/10.3390/batteries9100509.

（2）Liu, W.; Hu, X.; Lin, X.; Yang, X.-G.; Song, Z.; Foley, A. M.; Couture, J. Toward High-Accuracy and High-Efficiency Battery Electrothermal Modeling: A General Approach to Tackling Modeling Errors. eTransportation 2022, 14, 100195. https://doi.org/10.1016/j.etran.2022.100195.

（3）Deng, Z.; Xiao, W.; Li, Y.; Huang, Y.; Jia, J.; Hu, X. Cycle Mileage Prediction of Electric Vehicle over Macro Timescale. Journal of Mechanical Engineering 2021, 57 (24), 250–258. https://doi.org/10.3901/JME.2021.24.250.

（4）Gu, Y.; Wang, J.; Chen, Y.; Xiao, W.; Deng, Z.; Chen, Q. A Simplified Electro-Chemical Lithium-Ion Battery Model Applicable for in Situ Monitoring and Online Control. Energy 2022. https://doi.org/10.1016/j.energy.2022.126192.

3、分享了老化预测代码，其中包括健康特征预测算法、老化成本计算方法
具体内容可以查看我们已经发表的论文：
（1）Xiong, R.; Wang, S.; Yu, C.; Fernandez, C.; Xiao, W.; Jia, J. A Novel Nonlinear Decreasing Step-Bacterial Foraging Optimization Algorithm and Simulated Annealing-Back Propagation Model for Long-Term Battery State of Health Estimation. Journal of Energy Storage 2023, 59, 106484. https://doi.org/10.1016/j.est.2022.106484.

（2）Wu, Z.; Yin, L.; Xiong, R.; Wang, S.; Xiao, W.; Liu, Y.; Jia, J.; Liu, Y. A Novel State of Health Estimation of Lithium-Ion Battery Energy Storage System Based on Linear Decreasing Weight-Particle Swarm Optimization Algorithm and Incremental Capacity-Differential Voltage Method. International Journal of Electrochemical Science 2022, 17 (7), 220754. https://doi.org/10.20964/2022.07.41.

（3）Xiong, R.; Wang, S.; Huang, Q.; Yu, C.; Fernandez, C.; Xiao, W.; Jia, J.; Guerrero, J. M. Improved Cooperative Competitive Particle Swarm Optimization and Nonlinear Coefficient Temperature Decreasing Simulated Annealing-Back Propagation Methods for State of Health Estimation of Energy Storage Batteries. Energy 2024, 292, 130594. https://doi.org/10.1016/j.energy.2024.130594.

4、分享了光储园区的典型工况生成算法


5、分享了基于多种群粒子群算法的边界参数优化算法
通过py调用matlab引擎实现目标值获取
具体内容可以查看我们已经发表的论文：
Xiao, W.; Xu, H.; Jia, J.; Feng, F.; Wang, W. State of Health Estimation Framework of Li-on Battery Based on Improved Gaussian Process Regression for Real Car Data. IOP Conference Series: Materials Science and Engineering 2020, 793, 012063. https://doi.org/10.1088/1757-899X/793/1/012063.

6、分享了基于多维度特征的健康综合评分
具体内容可以查看我们已经发表的论文：
（1）Jia, J.; Hu, X.; Deng, Z.; Xiao, W.; Xu, H.; Han, F. Data-Driven Comprehensive Evaluation of Lithium-Ion Battery State of Health and Abnormal Battery Screening. Journal of Mechanical Engineering 2021, 57 (14), 141-149,159. https://doi.org/10.3901/JME.2021.14.141.

（2）Wu, Z.; Jia, J.; Liu, Y.; Qi, Q.; Yin, L.; Xiao, W. Prediction of Battery Remaining Useful Life Based on Multi-Dimensional Features and Machine Learning. In 2022 4th International Conference on Smart Power & Internet Energy Systems (SPIES); 2022; pp 1825–1831. https://doi.org/10.1109/SPIES55999.2022.10082287.

7、分享了部分集成在电池安全评估诊断平台的故障算法
具体内容可以查看我们已经发表的论文：
（1）Hu, X.; Zhang, K.; Liu, K.; Lin, X.; Dey, S.; Onori, S. Advanced Fault Diagnosis for Lithium-Ion Battery Systems: A Review of Fault Mechanisms, Fault Features, and Diagnosis Procedures. IEEE Industrial Electronics Magazine 2020, 14 (3), 65–91. https://doi.org/10.1109/MIE.2020.2964814.

（2）Zhao, J.; Gao, L.; Huang, B.; Yan, H.; He, M.; Jia, J.; Xu, H. Dynamic Monitoring of Voltage Difference Fault in Energy Storage System Based on Adaptive Threshold Algorithm. In 2020 IEEE 4th Conference on Energy Internet and Energy System Integration (EI2); 2020; pp 2413–2418. https://doi.org/10.1109/EI250167.2020.9347044.

（3）Xiao, W.; Miao, S.; Jia, J.; Zhu, Q.; Huang, Y. Lithium-Ion Batteries Fault Diagnosis Based on Multi-Dimensional Indicator. In 2021 Annual Meeting of CSEE Study Committee of HVDC and Power Electronics (HVDC 2021); 2021; Vol. 2021, pp 96–101. https://doi.org/10.1049/icp.2021.2544.
