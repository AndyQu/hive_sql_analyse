# hive_sql_analyse

## 需要的开发工具
Eclipse，需要的Eclipse插件：

1. gradle（支持gradle工程）
2. minimal gradle editor（编辑gradle文件）
3. data tools platform (编辑sql)
4. antlr4
5. tmf-xtext（编辑antlr4 文件）。由于存在bug，tmf-xtext必须通过[zip文件](http://www.eclipse.org/modeling/tmf/downloads/?)安装 
6. gconsole（存在问题，无法使用）
7. [webclipse](https://www.genuitec.com/products/webclipse/download/)（web开发，javascript）

在Windows上，需要的工具：

1. [windows git](https://git-scm.com/download/win)

## 计划
### 精确地汇报语法错误
目前能够做Hive SQL 语法检查的工具有：

1. https://sql.treasuredata.com/。在线检查并显示语法错误，然而我贴了一个有语法错误的SQL进去，工具毫无反应。
2. https://github.com/mayanhui/Hive-SQL-Syntax-Checker。使用命令行检查语法，对用户很不友好。因此我木有试用。
3. http://pythonhackers.com/p/jagatsingh/hive-syntax-validator。基于Hive-SQL-Syntax-Checker所做的maven/sbt插件。
4. http://gethue.com/。Hue中包含了一个Hive编辑器，据说有基本的语法检查功能。
5. 

以上的工具要么存在功能性问题，要么存在易用性问题。

### 尽可能汇报语义错误
由于缺少Meta数据，因此全面、精准地检测语义错误是不可能的。目前能够想到的、能够cover到的语义错误包括：

1. 函数的参数个数错误（类型错误？）
2. 不同的SQL子句可能不能共存
3. 不同层次query间的column名称一致性
4. 

### query层次分离
1. 将不同层次的query分割，每一个都是一个Query Document，每一个Document都有唯一ID。
2. 所有的Document构成一个Tree，通过Document ID索引。
3. 每一个Document进行结构上的化简

  a. 在包含sub query的地方，以Document ID代替
  b. 除去冗余的、中间层的AST Node
  
### 前端展示
1. Rest API请求Query Document
2. 每一个页面展示一个Query
3. 涉及到sub query处，点击能够跳转到sub query的Document
4. 涉及到column处，点击能够跳转到column来源的sub query的Document
