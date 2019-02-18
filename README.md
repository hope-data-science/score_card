
# 信用评分卡模型

## 项目目的
通过迭代，做一个能够敏捷应对变化的灵活的信用评分卡模型。项目会结合国内外对信用评分的一些基本知识体系，并模拟现实场景的内容，得到基本的评分卡模型操作体系。  
实现方法而言，目前是R语言。希望本项目能够吸引一些大佬来写更加优秀的评分卡的包，目前已经发现scorecard这一优秀的包，正在学习。

## 技术路线 
采用比较经典的CRISP-DM路线：1.商务理解；2.数据探索性分析；3.数据预处理（含特征工程）；4.统计建模分析；5.模型评估；6.模型应用。  
![](https://www.ibm.com/developerworks/cn/data/library/techarticle/dm-1312datapreparation/figures/CRISP-DM.gif)

## 数据集选择
为了避免利益相关的问题，这里通过加载klaR包，并且运行`data(GermanCredit)`来使用德国信贷的数据，来进行我们初步的探索性尝试。

## 商务理解
根据客户的基本信息，判断客户违约的概率，从而实现个性化产品推荐，并采取不同的放贷策略。尽管评级中只有好和坏两种，但是如果我们能够求得极大似然估计，可以进行更加精细的客户风险评估，从而构造更加精细的策略。

## 探索性数据分析
最近发现了一个包，叫做`DataExplorer`，能够用尽量少的代码来进行基本的探索性数据分析，非常方便。尽管部分功能还不完善，但是我认为已经非常省事，简直就是一个灵活版的dashboard，因此我会用这个包来做探索性数据分析。

## 参考文献
[信用标准评分卡模型开发及实现](https://blog.csdn.net/lll1528238733/article/details/76602006)  
[知乎的R语言评分卡模型案例](https://zhuanlan.zhihu.com/p/28322270)  
[国外大佬的R语言评分卡分析案例](https://artemiorimando.com/2018/02/18/scorecard-building-part-i-introduction/)  
[基于Python的信用评分卡模型分析（一）](https://www.jianshu.com/p/f931a4df202c)  
[基于Python的信用评分卡模型分析](https://zhuanlan.zhihu.com/p/35284849)  
[信用评分卡(申请评分卡)模型](https://zhuanlan.zhihu.com/p/46642169)  
[信用评分卡建模分析——基于R语言 - 薛定谔的猫的文章 - 知乎](https://zhuanlan.zhihu.com/p/29676042)  
[信用评分卡拒绝推断1](https://zhuanlan.zhihu.com/p/51927257)  
[信用评分卡拒绝推断2](https://zhuanlan.zhihu.com/p/46090290)
