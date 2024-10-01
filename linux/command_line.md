# Linux 常用命令

## grep

全拼: Global search REgular expression And Print out line

**作用：文本搜索工具，根据用户指定的“模式（过滤条件)”对目标文本逐行进行匹配检查，打印匹配到的行。**

**模式：模式:由正则表达式的==元字符==及==文本字符==所编写出的过滤条件**

```
语法：
grep [optional] [pattern] file1 file2
命令  参数        匹配模式 文件数据(可以是多个文件对象)
                -i： ignorecase，忽略字符大小写
                -0：仅显示匹配到的字符串本身
                -v: invert-match, 反向匹配不符合匹配模式的行
                -E：支持使用扩展的正则表达式元字符
                -q: --quiet, --silent 静默模式，即不输出任何信息
```

grep 命令是 Linux 系统中最重要的命令之一，功能是从文本文件或管道数据流中筛选匹配的行和数据，如果再配合正则表达式，功能十分强大，是 Linux 运维人员必备的命令。

grep 命令里的匹配模式就是你想要找的东西，可以是普通的文字符号，也可以是正则表达式

| 参数选项            | 解释说明                                                           |
| ------------------- | ------------------------------------------------------------------ |
| -v                  | 反向匹配不符合匹配模式的行                                         |
| -n                  | 显示匹配到的行号                                                   |
| -i                  | 不区分大小写                                                       |
| -c                  | 只统计匹配的行数                                                   |
| -E                  | 使用 egrep 命令                                                    |
| --color=auto        | 为 grep 过滤结果添加颜色                                           |
| -w                  | 只匹配过滤单词                                                     |
| -o                  | 只输出匹配内容                                                     |
| -m, --max-count=NUM | NUM 次匹配后停止                                                   |
| -H                  | 打印每个匹配项的文件名。 当有多个文件要搜索时，这是默认设置。      |
| -l                  | 只打印匹配的文件名而不输出匹配项，在遇到第一符合的匹配项时停止匹配 |

**正则表达式 grep 实践**

测试文件 grep_test.txt 文件内容：

```
I am oldboy teacher.
I teach Linux.
I like Python.

My qq 877348180.

My name is chaoge.

Our school website is http;//oldboyedu.cn
#我是注释行，系统不会读取我的， 一般被程序员用作，代码的注解信息行

```

```
#找出所有的空行
grep -n "^$" luffy.txt
# 找出所有的非空行
grep -nv "^$" luffy.txt
#找出所有非注释行且非空的行
grep -v "^#" | grep -v "^$"

```

## sed

**注意 sed 和 awk 使用单引号，双引号有特殊的解释。**原因是 shell 中单引号中像\$variable 这样的变量不会被解释，而双引号中的变量被解释替换为\$variable 变量值。

```
#定义变量
greeting=hello
#单引号
echo '$greeting' #输出 $greeting
#双引号
echo ”$greeting" #输出 hello
```

参考链接:1. [Why does using double quotes to enclose awk's action statements produce different results than when using single quotes to enclose them?](https://links.jianshu.com/go?to=https%3A%2F%2Faskubuntu.com%2Fquestions%2F475243%2Fwhy-does-using-double-quotes-to-enclose-awks-action-statements-produce-differen)

2. [Shell Quoting Issues](https://links.jianshu.com/go?to=https%3A%2F%2Fwww.gnu.org%2Fsoftware%2Fgawk%2Fmanual%2Fhtml_node%2FQuoting.html)

sed 是 Stream Editor(字符流编辑器)的缩写，简称流编辑器。

sed 是操作、过滤和转换文本内容的强大工具。

常用功能包括结合正则表达式对文件实现快速增删改查，其中查询的功能中最常用的两大功能是过滤（过滤指定字符串）、取行（取出指定行）。

```
sed 语法：
sed [选项] [sed内置命令字符] [输入文件]
```

选项：

| 参数选项 | 解释                                                                                   |
| -------- | -------------------------------------------------------------------------------------- |
| -n       | 取消默认 sed 的输出, 常与 sed 内置命令 p 一起使用                                      |
| -i       | 将修改后的结果写入文件，sed 修改的是内存中的数据，不使用该选项修改后的结果不会写入文件 |
| -e       | 多次编辑，无需使用管道符                                                               |
| -r       | 支持扩展表达式                                                                         |

sed 内置命令字符，用于对文件的不同操作功能，如对文件的增删改查。

sed 常用的内置命令字符：

| sed 内置命令字符        | 解释                                                                                                                   |
| ----------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| a                       | Append, 在指定行**后面**添加一行或多行文本                                                                             |
| d                       | delete， 删除匹配行                                                                                                    |
| i                       | insert， 在指定行**前面**添加一行或多行文本                                                                            |
| p                       | print，打印匹配行的内容，通常 p 与 -n 一起使用                                                                         |
| s/原内容/替换后的内容/g | 匹配正则内容，然后替换内容(支持正则)， 结尾 g 代表全局匹配， 也可以是 s@原内容@替换后的内容@g、s#原内容#替换后的内容#g |

sed 匹配范围：

| 范围      | 解释                                                                                                                                      |
| --------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| 空地址    | 全文处理                                                                                                                                  |
| 单地址    | 指文件的某一行                                                                                                                            |
| /pattern/ | 被匹配模式匹配到的所有行， 修饰符：**g **全局匹配，**I** 忽略大小                                                                         |
| 范围区间  | 10,20 表示十到二十行， 10,+5 表示第 10 行向下 5 行， /pattern1/,/pattern/，**\$表示最后一行**， 10,$p 打印第十行到最后一行， \$d 表示删除 |
| 步长      | 1~2 表示从第一行开始步长为 2，即 1,3,5,7,9...奇数行；2~2 表示从第二行开始步长为 2，即 2,4,6,8,...偶数行                                   |

模式修饰符：

| 修饰符 | 解释                                                                                                         |
| ------ | ------------------------------------------------------------------------------------------------------------ |
| g      | global - 全局匹配， 查找所有的匹配项。                                                                       |
| I      | ignore - 不区分大小写， 将匹配设置为不区分大小写，匹配时不区分大小写: A 和 a 没有区别。/pattern/I , i 为大写 |

sed 命令实践

测试文件 sed_test.txt 文件内容：

```
My name is chaoge.
I teach Linux.
I like play computer game.
My qq is 8773421.
My website is http://pythonav.cn
```

**1.输出文件第二行和第三行的内容**

**2.过滤出含有 Linux 的行**

**3.删除含有 game 的行**

**4.删除第五行一直到文件末尾的内容**

**5.将文件中的 My 替换为 His**

**6.将文件中的 My 替换为 His, 同时将 QQ 号替换为 888888**

**7.在文件第二后追加 I like Python**

**8.在第四行前添加 My telphone is 000100120**

**9.在第三行后追加多行内容**

**10.全文处理，每一行后添加 --- **

```
sed -n "2,3p" sed_test.txt # 输出文件第二行与第三行的内容
sed -n '/linux/Ip' sed_test.txt # 过滤出含有Linux的行
sed -i '/game/d' sed_test.txt # 删除含有game的行，注意sed想要修改文件内容，还得用 -i 参数
sed -i '5,$d' sed_test.txt # 删除第五行一直到文件末尾的内容
sed -i 's/My/His/g' sed_test.txt # .将文件中的My替换为His
sed -i 's/My/His/g' sed_test.txt | sed -i 's/8773421/888888/g'  sed_test.txt #使用管道符 将文件中的My替换为His, 同时将QQ号替换为888888
sed -i -e 's/My/His/g' sed_test.txt -e 's/8772421/888888/g' #使用 -e 参数多次编辑 将文件中的My替换为His, 同时将QQ号替换为888888
sed -i '2aI like Python' sed_test.txt
sed '4i My telphone is 000100120' sed_test.txt -i #在第四行前添加 My telphone is 000100120
sed '3a I like girl.\npretty girl.' sed_test.txt -i # 在第三行后追加多行内容, 这里主要用到换行符 \n
sed 'a ---' sed_test.txt  -i #全文处理，每一行后添加 ---
```

**sed 配合正则表达式企业案例**

**取出 Linux 的 IP 地址**

```
[root@k8s-master command]# ifconfig docker0
docker0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        inet6 fe80::42:7cff:fe6d:426e  prefixlen 64  scopeid 0x20<link>
        ether 02:42:7c:6d:42:6e  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 27  bytes 3103 (3.0 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

掐头去尾法

```
ifconfig docker0 | sed -n '2p' | sed -r -e 's/.*inet\s*//' -e 's/\s*netmask.*$//'
```

## awk

awk 是一个强大的 Linux 命令，有强大的文本格式化能力，好比将一些文本数据格式化成专业的 excel 表样式。

awk 早期在 Unix 上实现，我们用的 awk 是 gawk， 是 GNU awk 的意思。

awk 更像是一门编程语言，支持条件判断、数组、循环等功能。

- grep 擅长单纯地查找或匹配文本内容。
- sed 更适合编辑、处理匹配到的文本内容。
- awk 更适合格式化文本内容，对文本进行复杂处理。

这三个命令称之为 Linux 三剑客。

**awk 基础**

awk 语法

```
awk [options] 'pattern{action}' file...
awk 可选参数     模式 动作         文件/数据
```

- action 指的是动作，awk 擅长文本格式化，且输出格式化后的结果，因此最常用的动作就是`print`与`printf`, print 自动换行，printf 不会自动换行。

**awk 场景**

awk 测试文件 awk_test.txt 内容

```
pyyu1 pyyu2 pyyu3 pyyu4 pyyu5
pyyu6 pyyu7 pyyu8 pyyu9 pyyu10
pyyu11 pyyu12 pyyu13 pyyu14 pyyu15
pyyu16 pyyu17 pyyu18 pyyu19 pyyu20
pyyu21 pyyu22 pyyu23 pyyu24 pyyu25
pyyu26 pyyu27 pyyu28 pyyu29 pyyu30
pyyu31 pyyu32 pyyu33 pyyu34 pyyu35
pyyu36 pyyu37 pyyu38 pyyu39 pyyu40
pyyu41 pyyu42 pyyu43 pyyu44 pyyu45
pyyu46 pyyu47 pyyu48 pyyu49 pyyu50
```

动作场景： 取出第二列

```
awk '{print $2}' awk_test.txt
```

该场景下执行的命令是`awk '{print $2}'`，没有使用参数和模式，`$2` 表示输出文本的`第二列`信息。

awk 默认以空格作为分隔符，且多个空格也是识别为一个·空格，作为分隔符。

awk 是按行处理文件，一行处理完毕，处理下一行，根据用户指定的分割符去工作，没有指定则默认空格。

指定了分隔符后，awk 把每一行切割后的数据对应到`内置变量`

- $0 表示整行，\$1 表示第一列，以此类推 \$2 表示第二列
- $NF 表示每一行的最后一列
- 倒数第二列可以写成$(NF-1)

**awk 变量**

对 awk 而言，变量分为

- 内置变量
- 自定义变量

| 内置变量              | 解释                                                           |
| --------------------- | -------------------------------------------------------------- |
| $n                    | 指定分隔符后，当前记录的第 n 个字段， 如\$1,\$2                |
| $0                    | 表示整行                                                       |
| NF(Number of Fields)  | 按分隔符分割后，当前行一共有几个字段                           |
| NR(Number of records) | 当前处理的文本行的行号(Line of number)                         |
| FNR()                 | 读取文件的记录数（行号），从 1 开始，新的文件重新从 1 开始计数 |
| FS                    | 输入字段分隔符，默认是空格                                     |
| OFS                   | 输出字段分隔符，默认是空格                                     |
| RS                    | 输入记录分隔符（输入换行符），指定输入时的换行符               |
| ORS                   | 输出记录分隔符（输出换行符），输出时用指定符号代替换行符       |
| FILENAME              | 当前文件名                                                     |
| ARGC                  | 命令行参数的个数                                               |
| ARGV                  | 参数数组，保存的是命令行所给定的各个参数                       |

**注意：**

- awk 的内置变量 NR，NF 等是不用添加$符号的
- \$0,\$1,\$2,\$3 ...是需要添加$符号的

更多内置变量可以通过`man awk`查看。

**一次性输出多列信息**

```
awk '{print "第一列:"$1 "第二列:"$2}' awk_test.txt
```

自定义输出内容，必须外层单引号，内层双引号

内置变量 ` $1``$2 `都不得添加双引号，否则会识别为文本，尽量别加引号。

**输出整行信息**

```
#下面两种写法都可以
awk '{print}' awk_test.txt
awk '{print $0}' awk_test.txt
```

**awk 参数**

| 参数 | 解释                        |
| ---- | --------------------------- |
| -F   | 指定分隔符字段              |
| -v   | 定义或修改一个 awk 内置变量 |
| -f   | 从脚本文件中读取 awk 命令   |

**awk 案例**

pwd.txt 测试文件内容

```
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
halt:x:7:0:halt:/sbin:/sbin/halt
mail:x:8:12:mail:/var/spool/mail:/sbin/nologin

```

**显示文件第五行**

```
#NR在awk中表示行号，NR==5bu'i表示行号是五的那一行
#注意一个等号，是变量赋值，两个等于号是关系运算符，是“等于”的意思
awk 'NR==5{print $0}' pwd.txt
```

**显示文件 2 到 5 行**

设置模式（条件）

```
awk 'NR==2,NR==5' /etc/passwd.txt
```

**给每一行内容添加行号**

添加变量，NR 等于行号，$0 表示一整行的内容

{print} 是 awk 的动作

```
awk '{print NR,$0}' pwd.txt
```

**显示文件 3 到 5 行且显示行号**

```
awk 'NR==3,NR==5{print NR,$0}' pwd.txt
```

以`:`作为分隔符，**显示 pwd.txt 文件第一列，倒数第二列和最后一列**

```
awk -F ':' '{print $1, $(NF-1),$NF}' pwd.txt
```

awk 分隔符有两种

- 输入分隔符，awk 默认是空格，空白字符，内置变量是 FS(Field Separator)
- 输出分隔符，内置变量是 OFS(Out Field Separator)

**FS 输入分隔符**

awk 逐行处理文本的时候，以输入分隔符为准，把文本切成多个片段，默认符号是空格

当我们处理不是以空格分隔的特殊文件时，可以通过 FS 来指定分隔符来切分每一行

取出/etc/passwd.txt 文件的第一列， 使用 -F 参数将原来的空格分隔符改为冒号

```
awk -F ':' '{print $1}' pwd.txt
```

除了使用-F 选项，还可以使用变量的形式，指定分隔符， 使用-v 选项搭配，修改 FS 变量

```
awk -v FS=':' '{print $1}' pwd.txt
```

**OFS 输出分隔符**

awk 执行完命令，默认用空格分开每一列，这个空格就是 awk 的默认分隔符， 使用-v 选项搭配， 修改 OFS 变量

```
awk -v FS=':' -v OFS='#' '{print $1,$NF}' pwd.txt
```

**NR, NF,FNR**

输出每行行号，以及字段总个数

```
awk -F ':' '{print NR,NF,$0}' pwd.txt
```

处理多个文件显示行号

```
awk '{print FNR, $0}' pwd.txt awk_test.txt
```

**RS,ORS**

RS 变量的作用是`输入行分隔符`, 默认是`回车符`,=， 也就是`回车(Enter键)换行符`，也可以自定义`空格`作为行分隔符。每遇见一个空格，就换行处理

```
awk -v RS=' ' '{print NR,$0}' awk_test.txt
```

ORS 是输出行分隔符， awk 默认每一行结束添加`回车换行符`， 修改 ORS 变量值可以更改输出符

```
awk -v RS=' ' -v ORS='Enter' '{print $0}' awk_test.txt
```

**FILENAME**

显示 awk 正在处理的文件的名字

```
awk '{print FILENAME,FNR, $0}' pwd.txt awk_test.txt
```

**ARGC , ARGV**

ARGV 表示的是一个数组，数组中保存的是命令行中的参数

```
awk 'NR==2{print ARGV[1],$2}' awk_test.txt
```

**自定义变量**

方法一

```
awk -v greeting='hello' 'BEGIN{print greeting, "world!"}'
```

方法二

```
awk 'BEGIN{greeting="hello";world="world!"}{print greeting,world, $0}' awk_test.txt
```

方法三

间接引用 shell 变量

```
reeting="hello"
awk -v gre=$greeting 'BEGIN{print gre}'
```

**awk 格式化**

awk 使用 print， 只能对文本进行简单输出，对文本进行美化或者修改格式， 需要使用到 printf

**print 和 printf 的区别**

format 的使用

要点：

1. 其与 print 最大的不同是，printf 需要指定 format；
2. format 用于指定后面的每个 item 的输出格式;
3. printf 语句不会自动打印换行符:\\n

format 格式的指示符都以%开头，后面跟一个字符：如下：

| format  | 含义                                   |
| ------- | -------------------------------------- |
| %c      | 显示字符的 ASCII 码                    |
| %d， %i | 十进制整数                             |
| %e， %E | 科学计数法显示数值                     |
| %f      | 显示浮点数                             |
| %g， %G | 以科学计数法的格式或浮点数格式显示数值 |
| %s      | 显示字符                               |
| %u      | 无符号整数                             |
| %%      | 显示%本身                              |

printf 修饰符

| 修饰符 | 含义                           |
| ------ | ------------------------------ |
| -      | 左对齐， 默认右对齐            |
| +      | 显示数值符号， 如 printf "%+d" |

- printf 动作默认不会添加换行符
- print 默认添加空格换行符

**给 printf 添加格式**

格式化字符串%s 代表字符串的意思

```
awk  '{printf "%s\n",$0}' awk_test.txt
```

格式化显示 pwd.txt 文件

```
awk -F ":" 'BEGIN{printf "%-25s\t %-25s\t %-25s\t %-25s\t %-25s\t %-25s\t %-25s\n", "用户名", "密码", "UID", "GID", "用户注释", "用户家目录", "用户使用的解释器"}{printf "%-25s\t %-25s\t %-25s\t %-25s\t %-25s\t %-25s\t %-25s\n", $1, $2, $3, $4, $5, $6, $7}'
```

**awk 模式 pattern**

再来回顾下 awk 的语法， 这里的`模式`也可以理解为`条件`，**awk 默认是按行处理文本， 如果不指定任何`模式（条件）`，awk 默认一行一行处理，如果指定了模式， 只有符合模式的才会被处理。**

```
awk [option] 'pattern{action}' file ...
```

awk 是按行处理文本， 前面讲了`print`动作，现在讲解特殊的`pattern`：`BEGIN`和`END`

- BEGIN 模式是处理文本之前需要执行的动作
- END 模式是处理文本之后需要执行的动作

```
awk 'BEGIN{print "hello world!"}'
#上述操作没有指定任何文件作为数据源， 而是awk首选会执行BEGIN模式指定的print操作, 打印出如上结果
```

BEGIN 与 END 模式结合

```
awk 'BEGIN{print "处理文本之前, awk 执行了这个动作!"}{print $0}END{print "处理文本之后， awk 执行了这个动作"}' awk_test.txt
```

**模式（条件）案例**

```
# 某一行字段数量是5时，打印第一列的的数据
awk 'NF==5{print $1}' awk_test.txt
```

awk 模式关系运算符

| 关系运算符 | 解释       | 示例      |
| ---------- | ---------- | --------- |
| <          | 小于       | x<y       |
| <=         | 小于等于   | x<=y      |
| ==         | 等于       | x==y      |
| !=         | 不等于     | x!=y      |
| >=         | 大于等于   | x>=y      |
| >          | 大于       | x>y       |
| ~          | 匹配正则   | x~/正则/  |
| !~         | 不匹配正则 | x!~/正则/ |

示例

```
awk 'NR>3{print $0}' awk_test.txt
awk '$1=="pyyu46"{print $0}' awk_test.txt
```

**awk 基础总结**

空模式，没有指定任何模式（条件）， 因此每一行都执行了相应的动作，空模式会匹配文档的每一行。

```
awk '{print $1}' awk_test.txt
```

关系运算符模式， awk 默认执行打印输出动作

```
awk 'NR==2,NR==5' awk_test.txt
```

BEGIN/END 模式

```
awk 'BEGIN{print "处理文本之前, awk 执行了这个动作!"}{print $0}END{print "处理文本之后， awk 执行了这个动作"}' awk_test.txt
```

**awk 与正则表达式**

正则表达式主要与 awk 的 pattern 模式（条件）结合使用。

<font color="red"> grep '正则表达式' file </font>>

<font color="red">awk '/正则表达式/动作' file</font>

awk 命令使用正则表达式，必须把正则放入"//"中（正则表达式中如果出现了"/",则需要进行转义），匹配到结果后执行动作{print $0}， 打印整行信息，相较于 grep 命令， awk 的命令的优点在于强大的**文本格式化能力**。

找出 pwd.txt 中以 games 开头的行

```
# 1.使用 grep
grep -niE '^games' pwd.txt
# 2.使用 awk 与正则表达式
awk '/^games/{print $0}' pwd.txt
# 3. awk 省略写法
awk '/^games/' pwd.txt
```

awk 命令执行流程

```
awk 'BEGIN{ commands } pattern{ command }END{ command }'
```

1. 优先执行 BEGIN{}模式的语句
2. 从文件中读取第一行，然后执行 pattern{commands}进行正则匹配`/^n/`寻找 n 开头的行，找到执行相应指令，如 print
3. 当 awk 读取到文件数据流结尾时，会执行 END{command}

**找出 pwd.txt 文件中禁止登录的用户（/sbin/nologin）**

```
# 使用 grep
grep '/sbin/nologin' pwd.txt
# 使用 awk
awk -F ":" 'BEGIN{printf "%-25s\t", "用户名"}/\/sbin\/nologin/{printf "%-25s\t", $1}END{print "awk 结束执行"}'
awk -F ":" 'BEGIN{printf "%-25s\t%-25s\t\n", "行号", "用户名"}/\/sbin\/nologin$/{printf "%-25d\t%-25s\t\n", NR, $1}' pwd.txt
```

找出文件区间内容

找出 mail 用户到 nobody 用户之间的内容

行范围模式

<font color="red">awk '/正则表达式 1/,/正则表达式 2/动作' file</font>

```
awk -F ":" 'BEGIN{printf "%-25s\t%-25s\t\n", "行号", "用户名"}/^mail/,/^nobody/{printf "%-25d\t%-25s\t\n", NR, $1}' pwd.txt
```

awk 企业实战 nginx 日志

access.log

```
39.96.187.239 - -[11/Nov/2019:10:08:01 +0800] "GET / HTTP/1.1" 302 0"-""Zabbix"
211.162,238.91 -- [11/Nov/2019:10:08:02 +0800] "GET /api/v1/course_sub/category/list/?belon
211.162.238.91 - - [11/Nov/2019:10:08:02 +0800] "GET /api/v1/degree_course/ HTTP/1.1" 200 37
```

统计日志的访客 ip 数量

```
# sort -n 依照数值的大小排序
# wc -l 统计行数， 也就是ip的条目数
awk '{print $1}' | sort -n | uniq | wc -l
```

查看访问最频繁的前 10 个 ip

```
# uniq -c 去重显示个数
# sort -n 从大到小排序
# 1.先找出所有ip排序，然后去重统计出现次数
awk '{print $1}' | sort -n | uniq -c
# 2. 再次从大到小排序，显示前10个ip
awk '{print $1}' access.log | sort -n | uniq -c | sort -nr | head -10
```

### grep 练习题

1. 找出有关 root 的行
2. 找出 root 开头的行
3. 匹配 yiroot 开头或以 yu 开头的行
4. 找出以 bin 开头的行，且显示行号
5. 找出除了以 root 开头的行
6. 统计 yu 用户出现的次数
7. 匹配 yu 用户最多两次
8. 匹配多文件，列出存在信息的文件名字
9. 显示/etc/passwd 文件中不以/bin/bash 结尾的行
10. 找出/etc/passwd 文件中的两位或三位数
11. 找出文件中以至少一个<font color="red">空白字符(不仅仅是空格)</font>开头，后面是非空字符的行
12. 找出文件中以 i（不区分大小写）开头的行
13. 找出系统上 root，yu， nobody 用户的信息
14. 找出/etc/init.d/functions 文件中的所有函数名
15. 找出用户名和 shell 相同的用户

grep 练习题参考

```
#1.找出有关root的行
grep "root" pwd.txt
#2.找出root开头的行
grep "^root" pwd.txt
#3.匹配yiroot开头或以yu开头的行
grep "^(root|yu)" pwd.txt
#4.找出以bin开头的行，且显示行号
grep -n "^bin" pwd.txt
#5.找出除了以root开头的行
grep -v "^root" pwd.txt
#6.统计yu用户出现的次数
grep -c "yu" pwd.txt
#7.匹配yu用户最多两次
grep -m 2 "yu" pwd.txt
#8.匹配多文件，列出存在信息的文件名字
grep -l "root" pwd.txt /etc/passwd
#9.显示/etc/passwd文件中不以/bin/bash结尾的行
grep -v '/bin/bash$' /etc/passwd
#10.找出/etc/passwd文件中的两位或三位数, 不匹配1234中的123，不匹配24:中的24，这里用\<和\>限制匹配范围，这个用法暂时没在网上收到，使用-w参数也可以实现相同的功能
方法一：grep -E '\<[0-9]{2,3}\>' /etc/passwd
方法二：grep -wE '[0-9]{2,3}' /etc/passwd
#11.找出文件中以至少一个空白字符开头，后面是非空字符的行
方法一：grep -E '^\s+.*' lover.txt
方法二：grep -E '^[[:space:]]+.*' lover.txt
方法三：grep -E '^[[:space:]]+[^[:space:]]+' lover.txt
#12.找出文件中以i（不区分大小写）开头的行
方法-： grep -i '^i' lover.txt
方法二：grep -E '^(i|I)' lover.txt
方法三：grep -E '^[iI]' lover.txt
#13.找出系统上root，yu， nobody用户的信息
grep -wE '^(root|yu|nobody)' /etc/passwd
#14.找出/etc/init.d/functions文件中的所有函数名
grep -E '[A-Za-z]+\(\)' /etc/init.d/functions
#15.找出用户名和shell相同的用户
grep -E '^(\<[^:]+\>).*\1$' /etc/passwd
```

### sed 练习题

1. 替换文件中的 root 为 chaoge， 只替换一次与替换所有。

2. 替换文件中的 root 为 chaoge，仅仅打印替换结果。

3. 替换前 10 行 b 开头的用户，改为 C， 且仅仅显示替换的结果。
4. 替换前 10 行 b 开头的用户，改为 C，且将 m 开头的行改为 M， 且仅仅显示替换的结果。
5. 删除第四行后所有内容
6. 删除从 root 开始，到 ftp 之间的行
7. 将文件中空白字符开头的行，添加注释符
8. 删除文件的空白行与注释行
9. <font color="red">给文件前三行添加@符号</font>
10. 通过 sed 取出 ip 地址
11. 找出系统的版本

sed 练习题参考

```
#1.替换文件中的root为chaoge， 只替换一次与替换所有。
sed 's/root/chaoge/' -i pwd2.txt #只替换一次
sed 's/root/chaoge/g' -i pwd2.txt # 替换所有
#2.替换文件中的root为chaoge，仅仅打印替换结果。
sed -n 's/root/chaoge/gp' pwd2.txt
#3.替换前10行b开头的用户，改为C， 且仅仅显示替换的结果。
sed -n '1,10s/^b/C/gp' pwd2.txt
#4.替换前10行b开头的用户，改为C，且将m开头的行改为M， 且仅仅显示替换的结果。
sed -e '1,10s/^b/C/gp' -e '1,10s/^m/M/gp' -n -i pwd2.txt
#5.删除第四行后所有内容
sed '4,$d' -i pwd2.txt
#6.删除从root开始，到ftp之间的行
sed '/^root/,/^ftp/d' pwd2.txt -i
#7.将文件中空白字符开头的行，添加注释符
sed 's/^[[:space:]]/#/gp' -n -i lover.txt
#8.删除文件的空白行与注释行
sed '/^$/d;/^#/d' lover.txt
#9.给文件前三行添加@符号
sed '1,3s/\(^.\)/@\1/g' lover.txt
#10.通过sed取出ip地址
ifconfig virbr0 | sed '2s/^.*inet//;s/netmask.*//p' -n
#11.找出系统的版本
sed -r 's/^.*release//;s/.9..*//p' centos-release.txt -n
```

### awk 练习题

1. 在当前系统中打印出所有普通用户(UID>=1000)的用户和家目录

以以 passwd 文件中 root 一行为例介绍各个字段作用

| 1        | 2         | 3         | 4            | 5         | 6           | 7             |
| -------- | --------- | --------- | ------------ | --------- | ----------- | ------------- |
| root     | :x        | :0        | :0           | :root     | :/root      | :/bin/bash    |
| 用户名称 | :用户密码 | :用户 UID | :用户组 GIUD | :用户说明 | :用户家目录 | :shell 解释器 |

2. 给文件前 5 行添加#号
3. 统计文本信息

 测试文件内容(姓名、区号、电话、三个月捐款数量)

```
Mike Harrington:[510] 548-1278:250:100:175

Christian Dobbins:[408] 538-2358:155:90:201

Susan Dalsass:[206] 654-6279:250:60:50

Archie McNichol:[206] 548-1348:250:100:175

Jody Savage:[206] 548-1278:15:188:150

Guy Quigley:[916] 343-6410:250:100:175

Dan Savage:[406] 298-7744:450:300:275

Nancy McNeil:[206] 548-1278:250:80:75

John Goldenrod:[916] 348-4278:250:100:175

Chet Main:[510] 548-5258:50:95:135

Tom Savage:[408] 926-3456:250:168:200

Elizabeth Stachelin:[916] 440-1763:175:75:300
```

3.1 显示所有电话号码

3.2 显示 Tom 的电话号码

3.3 显示 Nancy 的姓名、区号、电话

3.4 显示出所有 D 开头的姓

3.5 显示所有区号是 916 的人名

3,6 显示 Mike 的捐款信息，在每一笔捐款前加上美元符号$

3.7 显示所有人的姓+逗号+名

3.8 删除文件空白行

awk 练习题参考

```
显示所有区号是916的人名
# 1.在当前系统中打印出所有普通用户的用户和家目录
awk -F ':' '$3>=1000{print $1, $6}' /etc/passwd
#2.给文件前5行添加#号
awk 'NR<=5{print "#"$0}' awk_test.txt
#3.1 显示所有电话号码
方法一：以'] '作为分隔符
awk -F '] ' '{print $2}' awk_stat.txt
方法二：以：或空格作为分隔符
awk -F '[ :]' '$0!~/^$/{print $4}'  awk_stat.txt
#3.2 显示Tom的电话号码
awk -F '[ :]' '$0~/^Tom/{print $4}'  awk_stat.txt
#3.3 显示Nancy的姓名、区号、电话
awk -F '[ :]' '$0~/^Nancy/{print $1,$2,$3,$4}'  awk_stat.txt
#3.4 显示出所有D开头的姓
awk -F '[ :]' '$2~/^D/{print $2}'  awk_stat.txt
#3.5 显示所有区号是916的人名
awk -F '[ :]' '$3~/\[916\]/{print $1}'  awk_stat.txt
#3.6显示Mike的捐款信息，在每一笔捐款前加上美元符号$
awk -F '[ :]' '$1~/Mike/{print "$"$(NF-2),"$"$(NF-1),"$"$NF}'  awk_stat.txt
#3.7显示所有人的姓+逗号+名
awk  -F '[ :]' '$0!~/^$/{print $2","$1}' awk_stat.txt
#3.8删除文件空白行
awk  -F '[ :]' '$0!~/^$/{print $0}' awk_stat.txt
```

### pmap

pmap 查看进程内存布局。

pmap -x pid





## Java JDK 自带命令

### jps 

jps 用户列出当前系统上所有 Java 进程的 PID

| 参数 | **描述**                                  |
| :--- | :---------------------------------------- |
| -l   | 显示主类的完全限定名，包括包名。          |
| -m   | 显示传递给主类的参数。                    |
| -v   | 显示传递给 JVM 的参数。                   |
| -q   | 仅输出进程的 PID，不输出任何其他信息。    |
| -V   | 显示主类的完全限定名和传递给 JVM 的参数。 |

### jstack

jstack <pid>，用于生成Java虚拟机当前时刻的线程快照信息的命令。

| 参数 | 描述                             |
| ---- | -------------------------------- |
| -l   | 显示更详细的信息，包括锁的信息。 |
| -e   | 显示额外的信息。                 |
|      |                                  |

### jcmd

直接运行 jcmd 输出与jps一样，jcmd 是一个从JDK7开始推荐使用的工具集，它能以极低的性能损耗或者无任何性能损耗的方式，提供一些JVM增强型类型诊断能力。

jcmd <pid> help 列出所有支持的命令，因为不同版本的JDK支持的参数不同，help命令需指定pid。

jcmd 105604 help GC.run 给出参数说明。

```
GC.run
Call java.lang.System.gc().

Impact: Medium: Depends on Java heap size and content.

Syntax: GC.run
```

### jstat

是JDK提供的一个用于监控Java虚拟机各种运行状态信息的命令行工具。可以显示本地或远程虚拟机进程中的类装载、内存、垃圾收集、JIT编译等运行数据。

jstat  <options> <pid> <interval> <count>

| **参数** | **描述**                                                    |
| -------- | ----------------------------------------------------------- |
| options  | 显示可用的输出选项。                                        |
| pid      | 虚拟机进程ID                                                |
| interval | 显示信息的时间间隔，单位默认为毫秒。                        |
| count    | 显示数据的次数，如果不指定则一直显示直到JVM终止或手动停止。 |

常用的输出选项：

- `-class`: 显示类加载统计信息。
- `-compiler`: 显示即时编译器的统计信息。
- `-gc`: 显示垃圾回收相关的统计信息。
- `-gccapacity`: 显示各区域的容量统计信息。
- `-gcutil`: 显示垃圾回收统计信息的摘要。
- `-gccause`: 显示垃圾回收统计信息的摘要，并显示最近和当前垃圾回收的原因。
- `-gcnew`: 显示新生代的垃圾回收统计信息。
- `-gcnewcapacity`: 显示新生代的大小统计信息。
- `-gcold`: 显示老年代的垃圾回收统计信息。
- `-gcoldcapacity`: 显示老年代的大小统计信息。
- `-gcmetacapacity`: 显示元空间的大小统计信息。
- `-printcompilation`: 显示即时编译方法的统计信息。

### jmap

jmap 是JDK提供的一个用于生成堆转储（heap dump）的命令行工具。

| 参数                       | 描述                                                         |
| -------------------------- | ------------------------------------------------------------ |
| -clstats                   | 打印类加载器的统计信息，包括类加载器地址、已加载类的数量、字节数等。 |
| -finalizerinfo             | 打印等待终结的对象的信息。                                   |
| -histo[:[<histo-options>]] | 打印堆中对象的直方图，包括对象数量和占用空间。               |
| -dump:<dump-options>       | 转储Java堆到文件。                                           |



### jconsole



