# Java

[toc]

## 1）Java 类加载

**双亲委派模型**(Parent Delegation Model)：当一个类加载器收到类加载请求时，它首先会把请求委派给其父类加载器。这个过程会沿着类加载器层次结构向上进行，直至到达启动类加载器。只有当父类加载器无法找到该类时，当前类加载器才会尝试自己加载该类。

Parent Delegation Model：更合适的翻译应该是**父类优先逐级加载模型**。

JVM 内置 classloader：

- 引导类加载器(Boostrap ClassLoader)：加载 Java 核心类库，如 java.lang.Object/Thread。
- 扩展类加载器(Extension ClassLoader) ：加载扩展包类库(jre/lib/ext/) 目录下的类，如解密相关的类。
- 应用类加载器(APP ClassLoader)：加载当前应用的ClASSPATH下的所有类，默认情况下，我们自己定义的类和依赖的第三方jar包都由其加载，典型的如：Main类。

JVM类加载过程： 引导类加载器(Boostrap ClassLoader) &rarr; 扩展类加载器(Extension ClassLoader) &rarr; 应用类加载器(Application ClassLoader)

为什么要打破**双亲委派**？

打破**双亲委派模型**可以实现应用隔离、热部署、插件化。

从以下问题出发，理解 Java 的 classloader - 隔离与共享的平衡

1. Java 为什么要有 classloader？C 语言有 classloader 吗？classloader 是必须的吗？
2. 为什么 classloader 要设计双亲委托机制？
3. 为什么同一个类会出现 ClassCastException？
4. 如何通过 ClassLoader 实现不停机修 bug？

**隔离避免相互干扰 - 运行时包（namespace）**

不同应用引用同一个开源，源 Jar 包的不同版本，包名和类名完全一样，只有内容不一样
只靠包名 + 类名是无法区分的，为避免相互干扰就需要额外引入一个维度：classloader

classloader 实现了 “运行时包”（namespace）的概念，即使是同一个类，由不同的 classloader 加载，也会被 JVM 认为是不同的类。

**单个类的隔离是没用的 —— 连锁加载机制**

**隔离与共享的平衡 —— 双亲委托机制**

Tomcat 是如何打破双亲委派的？

Tomcat 类加载器层次结构图

```
├─Boostrap ClassLoader
│  ├─_Extension ClassLoader
│  │  ├─APP ClassLoader
│  │      └─Common ClassLoader
|  |          |  └─Catalina ClassLoader
|  |          |
              |
              |─Shared ClassLoader
              |    └─WebApp ClassLoader
```

Common ClassLoader：Web应用程序和 Tomcat 共享的类。

Catalina ClassLoader：Tomcat 自身的类。

WebApp ClassLoader：web 应用程序独显的类。

WebApp ClassLoader 有两种加载模式，默认加载模式是优先加载自身 lib 下的包，如果找不到才向上委托。另一种是正常的双亲委派加载模式，在加载类时，会先将类加载请求委托给父类加载器。WebApp ClassLoader 默认加载模式 打破了双亲委派，是为了实现 Tomcat 应用间的隔离，不同应用之间的 Jar 不互相冲突，应用可以热部署，不需要重启 Tomcat。

## 2) JVM 

### 3.1) JVM 内存布局

JVM内存布局全景图

```

┌───────────────────────────────────────────┐
│ 方法区 / Metaspace（JDK 8+）                │
│ 「类元数据」「运行时常量池」「静态变量」「JIT」│
└───────────────────────────────────────────┘
          ^ 线程共享 ^

┌───────────────────────────────────────────┐
│ 堆（Heap）                                 │
│ ┌───────────────┐   ┌───────────────┐     │
│ │ Young Gen     │   │ Old Gen       │     │
│ │ 「Eden」「S0」「S1」│   长期存活对象         │
│ └───────────────┘   └───────────────┘     │
└───────────────────────────────────────────┘
          ^ 线程共享 ^

┌───────────┐ ┌───────────┐ ┌───────────┐
│ Thread-1  │ │ Thread-2  │ │ Thread-N  │  线程私有
│ 「Stack 」│ │ 「Stack 」│ │ 「Stack 」│
│ 「PC Reg」│ │ 「PC Reg」│ │ 「PC Reg」│
│ 「Native」│ │ 「Native」│ │ 「Native」│
└───────────┘ └───────────┘ └───────────┘
```

**线程共享**: 方法区/元空间、堆

**线程私有**: 程序计数器、线程栈、本地方法栈

典型的线上 JVM 启动参数

```
# 典型线上 JVM 启动参数
java -Xms2g -Xmx2g \          # [ARCH] 堆初始/最大 2GB
  -Xss512k \                  # [ARCH] 每线程栈大小 512KB
  -XX:MetaspaceSize=256m \    # Metaspace 初始 256MB
  -XX:MaxMetaspaceSize=512m \ # Metaspace 最大 512MB
  -XX:NewRatio=2 \            # Old:Young = 2:1
  -XX:SurvivorRatio=8 \       # Eden:S0:S1 = 8:1:1
  -XX:+UseG1GC \              # 使用 G1 收集器
  -XX:+HeapDumpOnOutOfMemoryError \  # OOM 时自动生成堆转储文件
  -XX:HeapDumpPath=/var/log/app/heapdump.hprof \ # 指定堆dump文件保存路径
  -jar app.jar
```

JVM 参数与内存区域映射

| 参数                              | 影响区域                             | 默认值              |
| --------------------------------- | ------------------------------------ | ------------------- |
| `-Xms / -Xmx`                     | 堆总大小                             | 物理内存 1/64 ~ 1/4 |
| `-Xmn`                            | Young Gen（新生代）                  | 堆的 1/3            |
| `-XX:NewRatio`                    | Old/Young 比例（老年代 / 新生代）    | 2                   |
| `-XX:SurvivorRatio`               | Eden/S 比例（Eden 区 / Survivor 区） | 8                   |
| `-XX:MaxTenuringThreshold`        | 新生代晋升老年代年龄阈值             | 15（G1 动态调整）   |
| `-XX:TargetSurvivorRatio`         | Survivor 区目标占用率                | 50%                 |
| `-Xss`                            | 线程栈大小                           | 512K ~ 1M           |
| `-XX:MetaspaceSize`               | Metaspace（元空间）                  | 21MB                |
| `-XX:MaxDirectMemorySize`         | 直接内存                             | 约等于 `-Xmx`       |
| `-XX:+HeapDumpOnOutOfMemoryError` | OOM 堆转储触发                       | 关闭                |
| `-XX:HeapDumpPath`                | 堆 dump 文件存储路径                 | 进程启动目录        |

常见内存溢出异常

```
// 1. 堆溢出 -- 对象太多，GC回收不过来
// java.lang.OutOfMemoryError: Java heap space
List<byte[]> list = new ArrayList<>();
while (true) {
    list.add(new byte[1024 * 1024]);  // [ARCH] 持续分配1MB，GC无法回收
}

// 2. 栈溢出 -- 递归太深
// java.lang.StackOverflowError
public void infinite() {
    infinite();  // [ARCH] 每次递归压入新栈帧，直到-Xss用尽
}

// 3. Metaspace溢出 -- 动态生成类太多
// java.lang.OutOfMemoryError: Metaspace
```

堆分代结构详解

```
┌ 堆的分代结构详解
+================ Heap（-Xms ~ -Xmx）================+
│
┌──────────────── Young Generation（-Xmn）────────────────┐
│  ┌──────────────┐ ┌──────┐ ┌──────┐                  │
│  │    Eden      │ │  S0  │ │  S1  │                  │
│  │（新对象诞生地）│ │(From)│ │(To)  │                  │
│  │ Eden:S0:S1=8:1:1 │      │      │                  │
│  └──────────────┘ └──────┘ └──────┘                  │
│  Minor GC：复制算法        触发：Eden空间不足          │
└──────────────────────────────────────────────────────┘
                │
                ∨  age >= 15 或 S区放不下
┌──────────────── Old Generation ───────────────────────┐
│  长期存活对象 + 大对象直接晋升                        │
│  Major GC：标记-清除                                 │
└──────────────────────────────────────────────────────┘
```

创建对象的分配过程

```
Object allocate(int size) {
    // 1. 尝试 TLAB 分配
    if (tlab.remaining() >= size) {
        obj = tlab.allocate(size);  // [ARCH] TLAB无锁分配，极快
        return obj;
    }

    // 2. TLAB不够，Eden中CAS分配
    obj = eden.casAllocate(size);  // [ARCH] CAS原子操作，无锁但有竞争
    if (obj != null) return obj;

    // 3. Eden满了，触发Minor GC
    minorGC();

    // 4. GC后重试Eden分配
    obj = eden.casAllocate(size);
    if (obj != null) return obj;

    // 5. 大对象直接进入Old Gen
    if (size >= PretenureSizeThreshold) {
        obj = oldGen.allocate(size);  // [ARCH] 大对象跳过Young Gen
        return obj;
    }

    // 6. 全部失败 -> OOM
    throw new OutOfMemoryError("Java heap space");
}
```

对象在堆中的内存布局

```
┌ 对象在堆中的内存布局
+====================================================+
│                  对象头（Object Header）           │
│  ┌────────────────────────────────────────────┐  │
│  │ Mark Word（8 bytes）                        │  │
│  │  - 哈希码（hashCode）    25 bits             │  │
│  │  - GC 分代年龄（age）    4 bits              │  │
│  │  - 锁标志位              2 bits              │  │
│  │  - 偏向锁标志             1 bit              │  │
│  └────────────────────────────────────────────┘  │
│  │ Klass Pointer（4 bytes，压缩后）             │  │
│  │ 指向方法区中的类元数据                        │  │
+====================================================+
```

一个空object至少占16字节。

虚拟机栈与栈帧的关系

```
┌ 虚拟机栈与栈帧的关系
Thread-1 的虚拟机栈（-Xss控制大小）
+================================================+
│
│  ┌──────── Frame 3（栈顶，当前方法：methodC）────────┐
│  │  局部变量表（Local Variable Table）              │
│  │    slot[0] = this                              │
│  │    slot[1] = param1                            │
│  │    slot[2] = localVar                          │
│  │                                                │
│  │  操作数栈（Operand Stack）                      │
│  │  字节码指令在此入栈/出栈运算                      │
│  │                                                │
│  │  动态链接 -> 运行时常量池方法引用                  │
│  │                                                │
│  │  返回地址 -> 调用方的PC值                        │
│  └────────────────────────────────────────────────┘
│
│  Frame 2：methodB()
│
│  Frame 1（栈底）：main()
│
+================================================+
```

方法区的历史演变

```
┌───────────────────────────── JDK 7 及以前 ─────────────────────────────┐     ┌────────────────────────────── JDK 8+ ──────────────────────────────┐
│ JVM 堆内存                                                             │     │ JVM 堆内存                                                             │
│ ┌───────────┐  ┌───────────┐  ┌───────────────────────────────────┐    │     │ ┌───────────┐  ┌───────────┐                                          │
│ │ Young Gen │  │ Old Gen   │  │ PermGen（方法区）                  │    │     │ │ Young Gen │  │ Old Gen   │                                          │
│ │           │  │           │  │ 固定大小，易OOM                     │    │     │ │           │  │           │                                          │
│ └───────────┘  └───────────┘  └───────────────────────────────────┘    │     │ └───────────┘  └───────────┘                                          │
│                                                                         │     │                                                                         │
│ 问题：                                                                   │     │ Native Memory                                                          │
│  - 大小难以预估                                                          │     │ ┌───────────────────────────────────┐                                  │
│  - 字符串常量池在此                                                       │     │ │ Metaspace                          │                                  │
│  - Full GC 才回收                                                        │     │ │ 自动扩展                            │                                  │
│                                                                         │     │ │ 类卸载更高效                        │                                  │
└─────────────────────────────────────────────────────────────────────────┘     └─────────────────────────────────────────────────────────────────────────┘
```

Jdk8 把永久代替换成了 Metaspace, 这是一个重大改变, 永久带有三个硬伤，大小必须启动时指定，字符串常量池在里面，效率低，和堆共用垃圾收集器。

Metaspace 改用本地内存，可以自动扩展，彻底解决了这些问题。

```
public class UserService {
    // Metaspace 中存储:
    // 1. 类元数据 Klass 结构
    //    类名、父类、接口列表
    //    字段描述符、方法描述符、字节码
    //
    // 2. 运行时常量池
    //    符号引用在运行时解析为直接引用
    private static final String PREFIX = "USER";  // [ARCH] 字面量在堆中，引用在常量池

    // 3. 静态变量 (JDK 7+ 移到堆中)
    private static int instanceCount = 0; // [ARCH] static字段存在堆的Class对象中

    // 4. 方法字节码
    public void serve() {
        instanceCount++;
    }
}
```

GC Roots可达性分析

```

GC Roots（起始节点集合）
┌───────────────────────────────────────────┐
│ 1. 虚拟机栈中引用的对象（局部变量表）        │
│ 2. 方法区中的静态变量引用                    │
│ 3. 方法区中的常量引用                      │
│ 4. JNI（Native方法）引用                   │
│ 5. JVM 内部引用（Class/异常/ClassLoader）  │
│ 6. 同步锁持有的对象                        │
└───────────────────────────────────────────┘
          ↓          ↓          ↓
[Obj A] --> [Obj B]    [Obj D] --> ...
(可达)      (可达)      (可达)
              ↓
          [Obj C]
          (可达)

[Obj X] --> [Obj Y]
(不可达)    (不可达)
      <-- 互相引用但无GC Root
      <-- 引用计数会误判为存活
      <-- 可达性分析正确判定为垃圾
```

三色标记法

```
白色 = 未访问 灰色 = 已访问子引用未扫完 黑色 = 全部扫完
初始：所有对象白色[A 白] --> [B 白] --> [C 白] [D 白] --> [E 白]^ GC Root
Step1：A 标灰[A 灰] --> [B 白] --> [C 白] [D 白] --> [E 白]
Step2：扫描 A 的子引用，B 标灰，A 标黑[A 黑] --> [B 灰] --> [C 白] [D 白] --> [E 白]
Step3：扫描 B 的子引用，C 标灰，B 标黑[A 黑] --> [B 黑] --> [C 灰] [D 白] -->
```

三色标记法是现代 GC 的核心算法，通过三种颜色区分对象的标记状态：

**白色**：未被访问过，标记结束后仍为白色的对象会被回收

**灰色**：已被访问，但它的子引用还没有全部扫描完成

**黑色**：已被访问，且所有子引用都扫描完成，是存活对象

从GC root出发逐层扫描，最终还是白色的对象，就是垃圾。

CMS G1 ZGC 都基于三色标记实现并发标记，大幅减少了Stop The world的时间。

三大 GC 算法

**标记 - 清除（Mark-Sweep）**

|AA|  |BB|CC|  |DD|  |EE|  |FF|  标记前

|AA|  |  |CC|  |  |  |EE|  |  |  清除后

问题：内存碎片

**标记 - 复制（Mark-Copy）**—— Young Gen 使用

From：|AA|  |BB|CC|  |DD|

To：|AA|CC|

只复制存活对象

优点：无碎片  代价：浪费 50% 空间（S0/S1 轮换）

**标记 - 整理（Mark-Compact）**—— Old Gen 使用

|AA|  |  |CC|  |  |  |EE|  |  |  标记后

|AA|CC|EE|  向一端滑动

优点：无碎片  代价：移动对象需 STW

**JMM抽象内存模型**

JMM 规定了一个线程对共享变量的写操作何时对另一个线程可见，可见每个线程有自己的工作内存，相当于CPU缓存的抽象，线程不能直接读写主内存，必须经过工作内存中转，这就是volatile和synchronized存在的根本原因，volatile写操作会插入内存屏障。强制把工作内存的值刷到主内存，volatile读会强制从主内存重新加载，配合happens before的传递性。

```
┌ JMM抽象内存模型
+================ 主内存（Main Memory）================+
│  共享变量 x = 0
│  共享变量 flag = false
+====================================================+
          ↓read/load                ↓read/load
          ↑store/write              ↑store/write
┌──────────────────────┐      ┌──────────────────────┐
│ Thread-1              │      │ Thread-2              │
│ 工作内存               │      │ 工作内存               │
│ ┌──────────────────┐ │      │ ┌──────────────────┐ │
│ │ x副本=0           │ │      │ │ x副本=0           │ │
│ │ flag副本=false    │ │      │ │ flag副本=false    │ │
│ └──────────────────┘ │      │ └──────────────────┘ │
└──────────────────────┘      └──────────────────────┘

Thread-1修改x=1后，Thread-2何时能看到？
答案：取决于 happens-before 规则
```



**JVM进程的虚拟地址空间布局**

```
高地址
+──────────────────────────────────────────────────────+
│ Kernel Space（用户进程不可访问）                      │
+──────────────────────────────────────────────────────+
│ Stack（OS线程栈，向下增长）                           │
│ <- 每个Java线程的OS栈 + JVM虚拟机栈                    │
+──────────────────────────────────────────────────────+
│ Memory Mapped Files（mmap）                           │
│ <- JIT CodeCache, Metaspace（native memory）          │
+──────────────────────────────────────────────────────+
│ Heap（向上增长）                                     │
│ <- JVM通过 mmap/brk 向OS申请                          │
│ <- -Xms：初始commit  -Xmx：reserve上限                 │
+──────────────────────────────────────────────────────+
│ BSS / Data / Text                                    │
│ <- libjvm.so, libc.so, 字节码相关代码                  │
+──────────────────────────────────────────────────────+
低地址
```

JVM进程的内存并不是直接使用物理内存，而是操作系统分配的虚拟地址空间。堆通过 mmap 向 OS 申请，Xmx 只是 reserve 了地址空间，并不占物理内存。

Metasapce 使用 mmap 映射到 native memory。

**CPU缓存与JMM的映射关系**

```
┌ CPU缓存与JMM的映射关系
+========== CPU Core 0 ==========+
│ Store Buffer（写缓冲）
│ JMM的assign操作写到这里
│ volatile写 -> lock前缀 -> 刷出
+--------------------------------+
│ L1 Cache（32~64KB）
│ JMM "工作内存" 的物理对应
+--------------------------------+
│ L2 Cache（256KB~1MB）
+--------------------------------+
          ↓
+--------------------------------+
│ L3 Cache（共享，8~32MB）
+--------------------------------+
          ↓
+--------------------------------+
│ 主内存（DRAM）
│ JMM "主内存" 的物理对应
+--------------------------------+

MESI缓存一致性协议：
M(Modified) E(Exclusive) S(Shared) I(Invalid)
```

G1 Region化内存布局

```
┌ G1 Region化内存布局
+-------------------------------------------------+
| E | S | 0 | E | 0 | 0 | E | H | H | 0 | E | S |
+-------------------------------------------------+
| 0 | E | E | 0 | 0 | E | S | 0 | 0 | E | 0 |   |
+-------------------------------------------------+
| E | 0 | 0 | E | 0 | E | 0 | 0 | E | 0 | E | 0 |
+-------------------------------------------------+

E=Eden   S=Survivor   0=Old   H=Humongous   空白=Free

每个Region大小相同（1MB~32MB）
逻辑分代，物理不连续
优先回收垃圾最多的Region（Garbage-First）
-XX:MaxGCPauseMillis 控制目标停顿时间
```

对象的完整生命周期

```
┌ 对象的完整生命周期
T=0ns    new Object()
          | 检查类是否已加载（方法区Klass查找）
T=10ns   计算对象大小（对象头+实例数据+对齐）
T=15ns   TLAB分配尝试
          | -> 成功：指针碰撞，纳秒级返回
          | -> 失败：Eden CAS分配
T=100us  Eden满 -> 触发Minor GC（STW）
          | GC Roots枚举
          | Eden+S0存活对象 -> 复制到S1，age++
T=200us  Minor GC完成，线程恢复

--- 多次 Minor GC 后 ---

T=Nmin   age >= 15 -> 晋升到Old Generation

--- Old Gen 空间不足 ---

T=Mmin   触发Major GC / Full GC
          | 三色标记(并发) -> 清除/整理(可能STW)
          | 对象不可达 -> 回收内存
```

### 3.2) Java 引用类型

### 3.2.1) 强引用(StrongReference)

强引用--只要引用在，对象永不回收。

Java 里使用 new 创建对象, 默认就是强引用。

### 3.2.2) 软引用(SoftReference)

软引用--若对象不存在强引用，内存充足时，GC不回收，内存不足时，GC 回收掉软引用指向的对象。

notes: HOTSPOT对软引用有LRU策略，越久没被访问的软引用越容易被回收。

### 3.2.3) 弱引用(WeakReference)

弱引用--若对象不存在强引用，弱引用指向的对象直接被回收，不管内存够不够,  是防止内存泄漏的利器。

WeakHashMap 就是典型应用，当key对象没有其他强引用时，整个entry会自动被清除。

ThreadLocal 内部也用了弱引用，Entry 的key就是弱引用，防止 ThreadLocal 对象内存泄露。

**ThreadLocal 用了弱引用 为什么还会内存泄露？**

ThreadLocal 内存泄漏机制是ThreadLocalMap 里的 Entry 的 key 是弱引用指向 ThreadLocal 对象，GC 回收后 key 为 null, 但 value 还是强引用，被 entry 牢牢持有着，entry 被 ThreadLocalMap 持有，ThreadLocalMap  被 Thread 持有，只要线程不死，value 就不会被回收，这就是为什么每次用完 ThreadLocal ，都必须调用remove手动清除value的强引用()。

```
Thread
  └─ ThreadLocalMap
       ├─ Entry[0]
       │    ├─ key ----weak----> ThreadLocal
       │    │                  (GC 后 key=null)
       │    └─ value --strong--> Object !!
       │                           (不会被回收!)
       └─ Entry[1]
            ├─ key ----weak----> ThreadLocal
            └─ value --strong--> Object
```

ThreadLocalMap 在 set/get 时会自动清理，还是有可能会内存泄露，因为这种清理仅会发生在同一个线程使用多个local对象的情况下。在实际开发中，往往一个线程只会用到一个 ThreadLocal 对象，自动清理顶多是作为一种兜底手段。内存泄露，我认为是发生在几千几万个线程进来的且使用线程池的情况下。每个线程内部都绑定了一个不能被清理的value。所以**使用完手动remove是最优解法**。

### 3.2.4) 虚引用(PhantomReference)

虚引用是四种引用中最特殊的一种，它的get方法永远返回null， 它的作用是 死亡通知，当你持有对外资源，比如direct bite buffer对应的native内存，

你需要在java对象被回收后释放这些资源。JDK9的cleaner就是基于虚引用实现的。

### 3.2.5) finalize 被废弃的原因

finalize: 不确定何时执行，对象可能"复活" 。

finalize: 增加 GC 负担，对象多活一个 GC 周期 。

finalize: JDK 9 @Deprecated, JDK 18 标记移除。

Java9 资源清理新的方式

PhantomReference: get 返回 null, 不可能复活

 Cleaner(JDK9+): 基于虚引用，时机可控 

Cleaner: 不影响 GC 效率，通过 ReferenceQueue 通知

### 3.3) 100GB堆暂停不到1毫秒ZGC和分代ZGC凭什么这么快

CMSS是第一个尝试并发的收集器，但初始标记和重新标记还是要暂停。

G1引入了分区收集和可预测暂停，但年轻带回收仍然是stop the world。

ZGC在JDK15正式发布，目标很激进，无论堆多大，暂停不超过一毫秒，到JDK21引入分带ZGC，吞吐量还反超了G1。

ZGC的架构可以分成三层：

- 应用线程：每次加载一个对象，每次加载一个对象引用时，中间这层读屏障就会介入检查指针的颜色对不对，如果颜色不对，读屏障会自动修正，

自愈颜色信息存在哪就存在指针本身，这就是染色指针。

- 并发回收引擎：标记转移重映射，全部与应用线程同时进行。

ZGC 整个设计的精妙之处在于GC的状态信息直接编码在指针里，不需要暂停应用就能协调工作。从操作层面看，启用 ZGC 非常简单。

```
// JDK 15-20: 启用非分代 ZGC
// -XX:+UseZGC                  // [ARCH] 开启 ZGC
// -Xmx16g -Xms16g               // 堆大小固定

// JDK 21-22: 启用分代 ZGC
// -XX:+UseZGC -XX:+ZGenerational  // [ARCH] 开启分代模式

// JDK 23+: 分代 ZGC 已是默认
// -XX:+UseZGC                  // [ARCH] 直接就是分代

// 常用调优参数
// -XX:SoftMaxHeapSize=12g      // 软上限
// -XX:ConcGCThreads=4          // 并发 GC 线程数
```

ZGC VS G1

100G堆模拟电商订单系统

G1 平均暂停: 83 ms

G1 P99 暂停: 245 ms

G1 最大暂停: 512 ms (半秒！)

G1 吞吐量: 92%

分代 ZGC 平均暂停: 0.03 ms

分代 ZGC P99 暂停: 0.08 ms

分代 ZGC 最大暂停: 0.3 ms (亚毫秒)

分代 ZGC 吞吐量: 93% (反超 G1)

传统 GC 为什么必须暂停？

核心困境有两个：

- 第一**标记阶段**：GC线程正在便利对象图标记谁活着，但应用线程同时在修改引用关系，GC看到A指向B还没标记B呢，应用线程把A改成指向D了，B断开了，

GC漏标了，D被错误回收程序崩溃。

- 第二**转移阶段**：GC要把对象从旧地址搬到新地址，如果不暂停应用，现成还在读旧地址，对象已经搬走了，读到的是垃圾数据。

所以传统GC的选择是暂停一切安全操作，ZGC 采用了另外一种方式--染色指针，染色指针是ZGC最核心的创新，其把GC原数据直接编码到64位指针的高位比特中，普通指针只用第48位存地址，高位浪费了ZGC在中间插入了四个比特，分别是 Marked0、 Marked1、Remapped、Finalizable，这四个比特就是指针的颜色，颜色代表GC状态，这个对象是否被标记为存活，指针是否已经重映射到新地址，传统GC把标记信息存在对象头里，要访问对象才能看到，ZGC 直接看指针就知道状态不需要碰对象本身。

 ZGC 染色指针 64 位布局

```
64-bit 指针布局:
+----------------------------------------------------------------+
| unused | M0 | M1 | Remapped | Finalizable |      对象地址      |
| 18 bit |    |    |   2 bit  |    1 bit    |       42 bit       |
|        |    |    |           |             |                    |
+----------------------------------------------------------------+

4 个颜色位 = GC 状态

颜色含义：
Marked0:    本轮标记存活(偶数轮)
Marked1:    本轮标记存活(奇数轮)
Remapped:   指针已重映射到新地址
Finalizable: 仅通过 Finalizer 可达
```

不同颜色的指针访问同一个对象怎么办?

ZGC 通过 mmap 系统调用把同一块物理内存映射到三个不同的虚拟地址上，Mark0视图、Mark1视图、Remapped 视图 三个虚拟地址的第42位完全一样，只是颜色为不同，不管你用哪个颜色的指针去访问，最终都指向同一块物理内存，物理内存没有增加一个字节，只是虚拟地址空间多用了三倍，这就是零拷贝的颜色切换。有了染色指针，读屏障就是让病发成为可能的胶水，每次从堆中加载一个对象，引用读屏障都会介入快速路径。

ZGC 回收流程分三个阶段

- 第一阶段并发标记: 先暂停0.01ms扫描GC根，然后并发遍历整个对象图。
- 第二阶段准备转移：选择碎片率高的内存页。
- 第三阶段并发转移：暂停0.003ms，扫描跟引用中需要重映射的指针，然后GC线程并发搬运对象。

关键在于所有重活都是并发的，三次STW暂停加起来不到0.02ms，标记几10亿个对象，搬运成千上万个对象，这些耗时的操作全部在后台进行，应用线程几乎感觉不到GC的存在。

为什么暂停时间跟堆大小无关？

ZGC最反直觉的地方是 100G堆和1TB堆暂停时间一样， 因为ZGC的STW暂停只做一件事， 扫描 GC Roots，跟堆有多大没半点关系。 GC Roots: 线程站上的局部变量、静态字段、GNI引用, 他们的的数量取决于活跃线程数和占深度，跟堆多大完全无关，100个线程平均占身20帧，每帧五个引用跟引用总共大约1万个，扫描1万个指针只需要0.01ms。

传统GC的暂停为什么跟堆大小有关，因为GC在STW中还要做对象转移，对象越多，转移越慢。

ZGC把转移这件事完全移到了并发阶段，代价是 ZGC 选择读屏障，而不是写屏障，可以做到并发转移。

ZGC 暂停时间已经很完美了，但吞吐量一直是短板，非分代ZGC比G1低5%到10%。分代垃圾回收告诉我们，90%以上的对象朝生夕灭，非分带ZGC每次GC都要标记和处理整个堆，大量时间花在标记那些马上就死的年轻对象上，下一轮又重新确认它们已经死了，这是巨大的浪费。

分代ZGC的思路很简单，把堆分成年轻代和老年代，年轻代频繁收集范围小，速度快，老年代偶尔收集，日常只扫一小块区域，效率直接翻倍。分带ZGC把堆分成两个区域，年轻代用小页面存放新分配的对象，minor gc频繁收集这块区域，大部分对象在这里出生和死亡。老年代存放长寿命对象，major gc偶尔收集一次，但仍然是全并发的，年轻对象存活超过阈值就晋升到老年代，大对象直接分配到老年代，关键是两种回收模式的暂停时间，都不超过一毫秒。但分代带来一个新问题，老年代对象可能引用年轻代对象，minor gc只扫描年轻代，怎么知道哪些年轻对象被老年代引用着，分带ZGC用双缓冲记忆集解决跨代引用问题。

```
┌ 分代 ZGC 内存布局
┌──────────────────────────────────────────┐
│                ZGC 堆空间                 │
│  ┌────────────────────────────────────┐  │
│  │ 年轻代（Young Generation）          │  │
│  │ │Y│Y│Y│Y│Y│Y│Y│Y│  2MB Pages       │  │
│  │ Minor GC：频繁回收，范围小          │  │
│  └────────────────────────────────────┘  │
│  ┌────────────────────────────────────┐  │
│  │ 老年代（Old Generation）            │  │
│  │ │O│O│O│O│O 32MB O│                  │  │
│  │ Major GC：偶尔回收，仍是并发        │  │
│  └────────────────────────────────────┘  │
└──────────────────────────────────────────┘

晋升：年轻对象存活超过阈值 -> 老年代
大对象：直接分配到老年代
```

**ZGC 的代价**

> ZGC 的 Trade-offs

1. 不支持压缩指针

   每个引用 8 字节 vs 4 字节

   堆空间利用率降低约 5-15%

2. 虚拟地址空间占用 3 倍

   多重映射的代价

   物理内存不变，只是虚拟地址

3. 读屏障开销

   每次加载引用多 2 条指令

   JIT 优化后实际开销 < 4%

4. 仅支持 64 位系统

GC 选择决策树

```
┌ GC 选择决策树
你的应用需要什么？

延迟敏感(P99 < 10ms)?
+-- 是 -> ZGC
    +-- JDK 21+? -> 分代 ZGC
    +-- JDK 15-20? -> 非分代 ZGC
+-- 否 -> 吞吐量优先?
    +-- 是 -> G1 或 Parallel GC
    +-- 否 -> 资源受限?
        +-- 是 -> Serial GC
        +-- 否 -> G1 (万金油)
```

## 3) JVM 参数设置十条建议

JVM 进程占用 = 堆 + 元空间 + 每个线程的栈 + 直接内存 + JIT 代码缓存 + JVM自身开销，是 -Xmx 参数设置内存的 1.5 至 2 倍。

1.) **-Xms 和 -Xmx 设置为一样大**

-Xms 是 JVM 启动时向操作系统申请的初始堆大小，-Xmx 是最大堆大小。如果两者不同，JVM 会在运行中动态的扩容，每次扩容要向内核申请新内存、更新页表、刷新 TLB。每次扩容 相当于一次隐形的 GC 停顿。生产环境推荐设置成一样大。

2.) **-Xmn和NewRatio 控制新生代大小**

默认新生代占堆大小的三分之一，老年代占三分之二，如果服务是高并发API服务，大量短暂的对象，可以把新生代扩大到堆的一般，降低对象晋升到老年代，降低 Full GC 频率。

3.) **元空间要记得设置 MaxMetaspaceSize 上限**

元空间大小默认时无限制的，使用 CGLIB、动态代理、Groovy，不断加载类，元空间占用空间一直上涨，最后 OOM，而且没有 HeadDump文件，排查起来及其痛苦。

4.）**GC 收集器怎么选？**

大多数在线服务用 G1GC，JDK9 以上已经是默认值。

需要停顿时间小于10毫秒的超低延迟场景，比如金融交易和实时推荐，使用 ZGC， JDK 15以上生产可用。如果是批处理、数据分析这类只关心吞吐量不在意停顿的场景，使用 Parall GC。

5.) **MaxGzCPauseMillis**

G1 GC 设置一个停顿时间目标，默认 200 ms， API 服务可以设置 100 毫秒。MaxGzCPauseMillis 是尽力目标，不是默认限制，G1会根据整个目标动态调整每次 GC 回收的 Region。

6.) **HeapDumpOnOutOfMemoryError 和 HeapDumpPath 参数**

最容易被忽略但最重要的参数: HeapDumpOnOutOfMemoryError，生产环境必须要开启。OOM 是最难复现的 bug，没有 dump 文件，无法快速定位问题。

HeapDumpPath 设置路径，发生 OOM 时 JVM 会自动写一个 hprof 文件，可使用 MAT或者VisualVM打开，分析内存泄露的原因。

7.) **完整的GC日志配置**

JVM 性能调优大师 Kirk Pepperdine 说过：所有 JVM 调优都应该从 GC 日志开始，而不是凭感觉改参数。不看数据就调参，是在浪费时间。

-Xlog:gc* 是 JDK9 以上的统一的日志格式，设置好文件滚动就不用担心磁盘被打满。

看到 GC 日志里有大量 Full GC，说明老年代压力过大。

看到 Pause 时间超过 MaxGzCPauseMillis 参数设置目标，说明 MaxGzCPauseMillis 设置太激进或者堆太小。

```
# [ARCH] 完整的 GC 日志配置（生产标配）
java \
    -Xlog:gc*:file=/var/log/jvm/gc.log \
        :time,uptime,level,tags \
        :filecount=5,filesize=20m \
    -jar app.jar

# 日志中你能看到:
# - 每次 GC 的类型 (Young/Mixed/Full)
# - GC 前后堆大小变化
# - 停顿时间 (Pause)
# - 并发标记阶段耗时
# - 内存回收效率

# 分析工具: GCEasy.io (在线, 拖入即分析)
```

8 ）**-XX:StringTableSize 参数**

intern 密集场景（缓存 key、协议解析）

默认 65536，建议设质数 1000003

过小 → 哈希碰撞增多 → GC 扫描 StringTable 变慢

9 ) **-XX:+UseCompressedOops**

堆 ≤ 32GB: 对象引用 4 字节 (压缩开启)

堆 > 32GB: 对象引用 8 字节 (压缩自动关闭)

宁可两个 28GB JVM，也不要一个 36GB JVM	

UseCompressedOops 的 32GB红线是最坑的：堆超过 32 GB， JVM 自动关闭指针压缩，所有对象引用从 4 字节变 8 字节，内存占用可能暴涨 30%至 40%。

宁可两个 28GB JVM，也不要一个 36GB JVM

10 ）**-Xss**

默认 512KB，1000 线程 = 512MB 堆外内存!

高并发服务考虑减到 256KB。

深递归服务考虑增到 1MB~2MB。

**JVM 调优思路**

未配置（默认值）→ 分析 GC 日志 → 识别瓶颈 → 调整参数 → 验证效果 → 生产稳定

1 ) 使用默认参数启动，开启GC日志。

2）分析 GC 日志，看 Minor GC 频率、Full GC频率、停顿时间。

3）根据分析结果调整参数，比如新生代太小就增大 -Xmn，元空间频繁 GC 就增大 MetaspaceSize，停顿过长就切换 ZGC。-Xms 和 -Xmx 设置为一样大，冰面扩容时带来的隐形 GC 停顿。

-Xmn和 NewRatio 控制新生代大小，根据对象存活模式调整。

MetaspaceSize 和 MetaspaceMaxSize 元空间上限必须设置，不然无线膨胀。

GC 收集器选择：G1 GC 是默认均衡选择，ZGC 是低延迟超大堆选择。

MaxGzCPauseMillis G1停顿时间目标。

HeapDumpOnOutOfMemoryError 是必备参数。

JVM 参数调优不是玄学，也不是背一堆参数，是对系统行为的精确控制，从 GC 日志开始，数据说话，本质上是理解 JVM 的内存分区、GC 算法、对象生命周期。然后根据应用特征精确配置。每一个参数背后都有具体的设计意图和取舍。上面给出的十条建议是对线上稳定性影响最大的十条。

**生产环境 G1 最小参数模板**

```
java \
# 固定堆大小（避免运行时扩容）
-Xms4g -Xmx4g \
# 元空间保护（防止无限膨胀 OOM）
-XX:MetaspaceSize=256m \
-XX:MaxMetaspaceSize=512m \
# G1GC + 停顿目标
-XX:+UseG1GC \
-XX:MaxGCPauseMillis=200 \
# OOM 黑匣子（必须配！）
-XX:+HeapDumpOnOutOfMemoryError \
-XX:HeapDumpPath=/var/log/jvm/ \
# GC 日志（调优数据来源）
-Xlog:gc*:file=/var/log/jvm/gc.log \
    :time,uptime,level,tags \
    :filecount=5,filesize=20m \
-jar app.jar
```

**生产环境 ZGC 最小参数模板**

```
java \
# 固定堆大小（避免运行时扩容）
-Xms4g -Xmx4g \
# 元空间保护（防止无限膨胀 OOM）
-XX:MetaspaceSize=256m \
-XX:MaxMetaspaceSize=512m \
# ZGC + 分代
-XX:+UseZGC \
-XX:+ZGenerational \
# OOM 黑匣子（必须配！）
-XX:+HeapDumpOnOutOfMemoryError \
-XX:HeapDumpPath=/var/log/jvm/ \
# GC 日志（调优数据来源）
-Xlog:gc*:file=/var/log/jvm/gc.log \
    :time,uptime,level,tags \
    :filecount=5,filesize=20m \
-jar app.jar
```

 初始和最大堆内存，在容器环境下建议使用百分比配置而非固定值，例如：-XX:InitialRAMPercentage=50 -XX:MaxRAMPercentage=75，这样可以让 JVM 根据容器的可用内存自动调整，更适合 Kubernetes/Docker 等环境。

## 4) Java 内存模型

### 4.1) Java 内存模型根源--可见性/原子性/有序性问题

从Java代码到CPU执行五层结构

- Java 应用层 (你写的代码)

- JVM 解释器 + JIT 编译器 (会重排序)

- CPU 多核架构 (乱序执行)

- 每核 L1/L2 + Store Buffer (每核独立)

- 共享 L3 + 主存 DRAM (~100ns)

**可见性问题**

x86 架构CPU 写数据流向

应用写内存 → Store Buffer → L1 Cache → L2 Cache → L3 Cache → 主内存

Store Buffer(写缓冲): 每个核心独有， **只临时存放还没刷进 L1 的写数据**，容量极小，队列式 FIFO，解决CPU 写速远快于缓存，避免阻塞等待。

L1 Cache: 每个核心独有, 读写最快，容量最小, 程序高频数据常驻这里。

L2 Cache: 每个核心独有, 速度次之，容量比 L1 大。

L3 Cache：同插槽所有核心共享，速度最慢、容量最大。

```
单个CPU核心
├─ 运算单元
├─ Store Buffer(私有写缓冲)
├─ L1 Cache(私有缓存)
└─ L2 Cache(私有缓存)

同插槽所有核心共用：L3 Cache
```

x86 架构CPU 内存架构会导致并发代码有**可见性**问题。

**原子性问题**

简单一条 i++ 字节码层面就是4步--读 this, 读 i 值, 加1, 写回, **字节码层面就已经不是原子的**。

x86 单条 inc 指令进入译码器也会被翻译为三个 读，算，写指令，乱序执行CPU可以在中间插入别的指令。

只有加上 lock 前缀硬件才保证整条 RMW 对所有核一起可见。

**有序性问题**

重排序源头

- 编译器重排序（JIT C2 优化）
- CPU 乱序执行（Out-of-Order）
- 内存系统重排序（Store Buffer）

MESI 已经保证一致性，为什么还要需要 volatile ?

关键在于写不会直接进 MESI，要现在 Store buffer 里待一会，失效消息也不会立刻生效，要先在 Invalid Queue 里排队。

MESI 保证最终一致，但最终可以任意长。volatile 做的是就是把最终变成立即。

4.2) JMM

JMM 不规定 JIT 必须怎么编译，CPU 必须怎么乱序， 它只规定一组叫 happens-before 的关系。

只要 A happens-before B ，那么A的所有写对B都是可见的。

JSR-133 的八条 happens-before

- 程序顺序规则（同线程内按代码顺序(逻辑顺序)）

- 监视器锁规则（unlock hb 后续 lock）(sychronized 关键字锁)

- volatile 规则（写 hb 后续读）

- 线程启动规则（start () hb 线程内操作）

- 线程终止规则（线程操作 hb join 返回）

- 中断规则（interrupt hb 检测到中断）

- 对象终结规则（构造完成 hb finalize）

- 传递性（A hb B, B hb C → A hb C）

这8条不是说CPU一定按照这个执行，而是说逻辑上就是这个顺序，具体怎么实现是JIT和硬件的事。

DRF‑SC 定理：如果一个程序是 “无数据竞争” 的（Data‑Race‑Free），那么它在弱内存模型下的所有执行，都等价于顺序一致性（Sequential Consistency）的执行。

**JMM 抽象出四种屏障**

内存操作只有 Load 和 Store，两两组合 = 4 种禁止重排序。

- LoadLoad: 屏障前的读完成才能执行后面的读。
- LoadStore: 屏障前的读完成才能执行后面的写。
- StoreStore: 屏障前的写完成才能执行后面的写。
- StoreLoad: 屏障前的写完成才能执行后面的读 ← 最贵。

**volatile 读写的屏障布局**

volatile 写

```
StoreStore ← 防止前面普通写重排到后面

volatile 写

StoreLoad ← 最贵！强制 flush store buffer
```

volatile 读

```
volatile 读

LoadLoad ← 防止后面普通读重排到前面

LoadStore
```

**经典可见性问题**

DCL 半构造对象，volatile 不只是可见。

Java new 对象分为三步：分配内存,  跑构造函数，把地址赋给 变量。

JIT 可以把后两步重排，先赋给地址，但构造函数还没跑完，另外一个线程看到不为空，直接返回，读到了半构造对象。这就是 DCL 必须加 volatile 的真正原因。

volatile 在 DCL 里真正干的事情不是可见性，而是顺序保证。

final 字段在 JMM 里有一条特殊承诺，构造函数内的对 final 字段的写，**绝对不会重排到构造函数返回之后**，所以不可变对象只要所有字段都是 final, 线程拿到引用就一定能看到完整的状态。JVM 实现很简单，在构造函数结尾插入一个 StoreStore 屏障。

硬件层面 x86 VS ARM 对比

x86（TSO 强模型）

LoadLoad 重排： No

LoadStore 重排： No

StoreLoad 重排： Yes（store buffer 导致）

StoreStore 重排： No

→ 不加 volatile 大多数时候也对

ARM v8（弱模型）

LoadLoad 重排： Yes

LoadStore 重排： Yes

StoreLoad 重排： Yes

StoreStore 重排： Yes

→ 不加 volatile 必崩，必须插 dmb 屏障。

volatile 与 synchronized

volatile  保证 可见性 + 有序性，不保证 原子性。

synchronized  可见性 + 有序性 + 原子性（整段）

AtomicXxx    可见性 + 有序性 + 原子性（单字段 CAS）

## 5) AQS 同步队列 --  CLH 变体、CAS 入队、共享模式与独占模式

AQS 核心：int 类型的 state 字段，FIFO 的队列， 与其让每个同步器自己实现一套阻塞唤醒逻辑，不如抽象出一套框架，让子类只关心 state 怎么解释，什么时候算抢到。基于QAS，只需要重写五个方法就能造一把新锁。

AQS 全景架构

从上到下的层级结构：

1. **JUC 同步组件**`(ReentrantLock / Semaphore / CountDownLatch / RWLock / FutureTask / Worker)`
2. **AbstractQueuedSynchronizer 模板方法骨架**`(acquire / release / acquireShared)`
3. **state 字段 + CLH 双向队列**`(volatile int) + (head / tail)`
4. **底层原语**`(Unsafe CAS + LockSupport park/unpark + Thread interrupt)`

AQS 队列结构

从上到下的队列结构：

1. `head 哨兵 (dummy, thread=null, ws=SIGNAL)`
2. `Node A (Thread T1, prev/next, ws=SIGNAL) — parked`
3. `Node B (Thread T2, prev/next, ws=SIGNAL) — parked`
4. `Node C (Thread T3, prev/next, ws=0) — 刚入队`
5. `tail (指向 Node C)`

state 在不同同步器中的语义

- `ReentrantLock`: state=0 空闲，state=N 同一线程重入 N 次
- `ReentrantReadWriteLock`: 高 16 位读锁计数 + 低 16 位写锁计数
- `Semaphore`: state = 剩余可用许可数
- `CountDownLatch`: state = 剩余倒计数，到 0 全部放行
- `FutureTask`: state = 任务状态码 (NEW/COMPLETING/NORMAL/...)
- `ThreadPoolExecutor.Worker`: 0 未启动，-1 不允许中断，1 持锁运行
- 所有同步器共享同一个 state 字段，但语义完全由子类决定

volatile state 的三重作用

- `volatile int state` 同时承担三件事

1. **互斥语义**：CAS `0→1` 抢锁 / `0→N` 共享
2. **重入计数**：持有者写 `state += 1` 累加
3. **happens-before 发布点**：unlock 写 `0` 发布临界区写

- JMM 保证 `volatile write happens-before` 后续 `volatile read`
- T1 临界区普通写 `x = 42`
- T1 unlock `setState(0)`（volatile write）
- T2 lock CAS `state 0 → 1`（volatile read）
- T2 临界区普通读 `x` 必然看到 `42`
- 互斥保（末尾截断）

QAS 队列 Node.waitStatus 五态状态机

五个状态定义：

1. **INITIAL (0)**：刚入队，初始状态
2. **SIGNAL (-1)**：已托付前驱，需要前驱唤醒自己
3. **CONDITION (-2)**：挂在条件队列中，等待被 signal
4. **PROPAGATE (-3)**：共享传播标记，用于共享模式下的唤醒传递
5. **CANCELLED (+1)**：节点作废，已取消（超时 / 中断）

独占模式

独占模式 `acquire/release`

- `tryAcquire` 返回 `boolean`（成功 / 失败）
- 拿到锁后只设 `head`，不主动唤醒后继
- 释放时 `unparkSuccessor` 唤醒一个
- 节点 `mode = Node.EXCLUSIVE (null)`
- 典型：`ReentrantLock`, `WriteLock`

共享模式 `acquireShared/releaseShared`

- `tryAcquireShared` 返回 `int`（`>0` 传播 / `=0` 不传播 / `<0` 失败）
- 拿到资源后走 `setHeadAndPropagate`，可能链式唤醒
- 释放时 `doReleaseShared` 可能唤醒多个
- 节点 `mode = Node.SHARED`
- 典型：`Semaphore`, `CountDownLatch`, `ReadLock`

条件队列

ConditionObject 条件队列（单向，nextWaiter 串联）

firstWaiter → NodeA(ws=CONDITION) → NodeB → lastWaiter

signal () 把节点搬到主队列尾部

AQS 主队列(双向 FIFO)

head ↔ Node1 ↔ Node2 ↔ NodeA(ws=0) ↔ tail

signal动作本身不会唤醒任何线程，他只做把节点从条件队列挪到主队列尾部，真正的unpark等主队列前驱release的时候才触发, 避免无效唤醒。

最容易问错的两个面试题

park 和 sleep/ next 和 pre

park vs sleep

- park 和 sleep 的本质差异

1. **唤醒源不同**
   - sleep 只能等时间到自然醒
   - park 可被 unpark 精确唤醒
2. **凭证机制**
   - park 有 permit，unpark 可以提前到
   - sleep 没有这个机制
3. **持锁行为**
   - sleep 不释放 synchronized 锁
   - park 进入时已经不在 tryAcquire 里

- 底层都是 futex_wait，差别在唤醒条件（末尾截断）

为什么 unparkSuccessor 倒着扫 ？

1. **addWaiter 入队顺序**
   - step 1 `node.prev = oldTail`（CAS 前）
   - step 2 `CAS tail oldTail → node`
   - step 3 `oldTail.next = node`（CAS 后）
2. CAS 成功瞬间 `prev` 已完整，`next` 未补全
3. 从 `head` 沿 `next` 遍历可能漏新节点
4. 从 `tail` 沿 `prev` 倒着扫永远完整
5. 这是 AQS「前驱可信，后继不可信」的工程实现

## 6）ReentrantLock 

ReentrantLock 是 synchronized 的严格超集，把原本写在 JVM 里的加锁解锁语义，放到了代码里，而且还支持中断，超时， 公平特性。

### 6.1）ReentrantLock  VS synchronized 写法 性能 功能

synchronized 

`synchronized (obj) { ... }` — 自动释放，块结束 / 异常都安全

锁对象隐式，不能查询锁状态

永远非公平，只有一组 wait/notify

不可中断，不可超时，不可尝试

ReentrantLock 

`lock.lock(); try {...} finally {lock.unlock();}` — 手动释放

锁对象显式，可查 `isLocked`/`getHoldCount`/`getQueueLength`

可选公平：`new ReentrantLock(true)`，多 Condition

支持 `lockInterruptibly()` + `tryLock(timeout)` + `tryLock()`

ReentrantLock  模板代码

```
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class Counter {
    private final Lock lock = new ReentrantLock();  // [ARCH] 字段类型用接口 Lock
    private int count = 0;

    public void increment() {
        lock.lock();        // [ARCH] 1. 加锁 必须在 try 之外
        try {
            count++;        // [ARCH] 2. 临界区 越短越好
        } finally {
            lock.unlock();  // [ARCH] 3. 解锁 必须在 finally
        }
    }
}
```

ReentrantLock 内部组成

1. `ReentrantLock` (外壳: lock /unlock/tryLock 委托给 sync)
2. `Sync` 抽象基类 (定义 `tryRelease` 和 `isHeldExclusively`)
3. `FairSync` vs `NonfairSync` (lock 行为差异化)
4. `AbstractQueuedSynchronizer` AQS (`state` + `ownerThread` + CLH 队列)
5. `volatile int state` (重入计数 0 = 空闲 N = 重入 N 次)
6. `LockSupport.park` / `unpark` (拿不到锁的线程在这里阻塞)

### 6.2) tryLock 方法

**经典死锁案例-两个账户互转**

存在死锁的代码

```
void transfer(Account from, Account to, int amount) {
    from.lock.lock();             // [ARCH] T1: 锁 A
    try {
        to.lock.lock();           // [ARCH] T1: 试图锁 B 卡在这里
        try {
            from.balance -= amount;
            to.balance += amount;
        } finally {
            to.lock.unlock();
        }
    } finally {
        from.lock.unlock();
    }
}

// 主程序
new Thread(() -> transfer(A, B, 100)).start();  // 顺序: 锁 A → 锁 B
new Thread(() -> transfer(B, A, 200)).start();  // 顺序: 锁 B → 锁 A
```

工业级转账代码

先失败、再重试，试一下拿 from，再试一下拿 to，都拿到了 提交，没拿到 to 必须释放 from 否则又死锁，随机退避 避免活锁。

```
boolean transfer(Account from, Account to, int amount) throws InterruptedException {
    while (true) {
        if (from.lock.tryLock()) {             // [ARCH] 试一下拿 from
            try {
                if (to.lock.tryLock()) {       // [ARCH] 再试一下拿 to
                    try {
                        from.balance -= amount;
                        to.balance += amount;
                        return true;           // [ARCH] 都拿到了 提交
                    } finally {
                        to.lock.unlock();
                    }
                }
            // [ARCH] 没拿到 to 必须释放 from 否则又死锁
            } finally {
                from.lock.unlock();
            }
        }
        // [ARCH] 随机退避 避免活锁
        Thread.sleep(ThreadLocalRandom.current().nextLong(1, 10));
    }
}
```

### 6.3）lockInterruptibly 方法

 lockInterruptibly  方法在等锁的过程中，能响应 Thread interrupt，这是 synchronized 永远做不到的事。

```
public void doWork() {
    try {
        lock.lockInterruptibly();    // [ARCH] 等锁期间可被 interrupt
    } catch (InterruptedException e) {
        Thread.currentThread().interrupt();  // [ARCH] 恢复中断标志
        System.out.println("任务被取消（等锁阶段）");
        return;
    }
    try {
        longRunningJob();
    } finally {
        lock.unlock();
    }
}

// 使用方
Thread worker = new Thread(task::doWork);
worker.start();

// 用户点击"取消"
worker.interrupt();  // [ARCH] 立刻让 worker 从等锁状态退出
```

整个流程

```
任务被取消（等锁阶段）

取消

批量导入

等锁期间可被 interrupt

恢复中断标志

立刻让 worker 从等锁状态退出

InterruptedException

Thread
```

lockInterruptibly  方法是服务关停，取消任务这些场景的必须品。

### 6.4）可重入特性

可重入是指 同一个线程 同一把锁 多次进入。

ReentrantLock  与 synchronized 均被设计为可重入的。

### 6.5) Condition 与阻塞队列 — 多等待集精细控制生产者-消费者

Condition 设计的最大价值点在于精确唤醒，而非 notifyAll 的惊群效应。

synchronized VS ReentrantLock  实现生产者与消费者队列

**synchronized 方案**

```
synchronized: 1 个 Object 1 个隐式 WaitSet
生产者消费者全挤同一个等待队列
notifyAll: N 个等待者全部 unpark
N-1 个抢锁失败又睡回去（CPU 浪费）
notify: JVM 任选一个，可能选错对象
极端情况下 lost notification 死锁
```

**Lock + Condition 方案**

```
Condition: 1 个 Lock 任意多个 Condition
notFull 队列只装生产者
notEmpty 队列只装消费者
signal: FIFO 顺序唤醒确定的那一个
完全不打扰另一边的线程
实测吞吐量 80 万 op/s -> 400 万 op/s
```

Lock 加多 Condition 的分层架构

```
应用层 业务代码 BoundedBuffer RateLimiter
接口层 Lock 接口 + Condition 接口
实现层 ReentrantLock + ConditionObject
框架层 AbstractQueuedSynchronizer AQS
队列层 同步队列 Sync Queue + 条件队列 Condition Queue
原语层 LockSupport park / unpark
内核层 futex / pthread_cond
```

多 Condition 示例代码

```
final Lock lock = new ReentrantLock();
final Condition condition = lock.newCondition();

// 等待方
lock.lock();                // [ARCH] 1. 必须先持锁
try {
    while (!conditionPredicate()) { // [ARCH] 2. while 不能 if (虚假唤醒!)
        condition.await();      // [ARCH] 3. 等待 (原子释放锁 + park)
    }
    // 4. 条件满足执行业务
} finally {
    lock.unlock();          // [ARCH] 5. finally 释放锁
}

// 通知方
lock.lock();
try {
    changeStateMakingPredicateTrue();
    condition.signal();     // [ARCH] 状态改完再 signal
} finally {
    lock.unlock();
}
```

生产者与消费者

```
private final Condition notFull = lock.newCondition();    // [ARCH] 生产者候诊区
private final Condition notEmpty = lock.newCondition();  // [ARCH] 消费者候诊区

public void put(E e) throws InterruptedException {
    lock.lockInterruptibly();
    try {
        while (count == items.length) {     // [ARCH] while 防虚假唤醒
            notFull.await();                // [ARCH] 生产者睡自己的队列
        }
        items[putIndex] = e;
        if (++putIndex == items.length) putIndex = 0;
        count++;
        notEmpty.signal();                  // [ARCH] 只唤醒消费者!
    } finally { lock.unlock(); }
}

public E take() throws InterruptedException {
    lock.lockInterruptibly();
    try {
        while (count == 0) notEmpty.await(); // [ARCH] 消费者睡自己的队列
        E x = (E) items[takeIndex];
        items[takeIndex] = null;
        if (++takeIndex == items.length) takeIndex = 0;
        count--;
        notFull.signal();                   // [ARCH] 只唤醒生产者!
        return x;
    } finally { lock.unlock(); }
}
```

await 内部到底做了什么？

原子释放 + 阻塞

先加入条件队列，再释放，再park

Condition.await() 执行时序(带重入锁场景)

```
| 时间点 | 关键步骤 | 说明 |
|--------|----------|------|
| 0ms    | `[T1 持锁]` | AQS state=2(重入 2 层) |
| 1ms    | `[addConditionWaiter]` | T1 加入条件队列尾部，`waitStatus=CONDITION` |
| 2ms    | `[fullyRelease]` | 保存 `savedState=2`，一次性释放锁，AQS `state=0` |
| 3ms    | `[park]` | `while` 检查 `isOnSyncQueue` 失败，调用 `LockSupport.park` |
| 4ms    | `[T1 沉睡]` | 进入 OS 级阻塞（底层 `futex` 等待） |
| 5ms    | `[T2 持锁改状态 调 signal]` | `doSignal` 将 T1 节点从条件队列转移到同步队列 |
| 6ms    | `[T1 unpark]` | 唤醒后检查 `isOnSyncQueue` 返回 `true`，跳出等待循环 |
| 7ms    | `[acquireQueued]` | T1 在同步队列中排队，等待 T2 释放锁 |
| 8ms    | `[T2 unlock]` | T2 释放锁，执行 `unpark` 唤醒 T1 |
| 9ms    | `[T1 acquire 成功]` | 恢复锁状态 `state = savedState = 2` |
| 10ms   | `[await 返回]` | T1 重新持有锁，重入计数与调用 `await` 前完全一致 |
```

为什么 await 必须放在 while 里 ？

三个原因综合起来要求必须用while

- 虚假唤醒, JVM规范明确允许await在没有signal的情况下, 自己醒来，这是兼容OS底层的代价(（比如 Linux 的 `futex`、POSIX 的条件变量，本身就存在这种 “无信号唤醒” 的可能）。
- signal后到拿回所之间有时间窗期间，其他线程可能改了状态，比如另一个消费者抢先取走了元素。
- signalAll 一次唤醒多个, 只有一个能拿到锁。

永远把await理解为我可能莫名其妙就醒了，需要 while重新检查条件是否成立。

**await 节点的 4 个状态转换**

1. **持锁运行中**（初始状态，线程持有锁并运行）
2. **条件队列等待 CONDITION (-2)**（线程调用 `await()` 后，进入条件队列等待，节点 `waitStatus` 设为 `CONDITION`，值为 `-2`）
3. **迁移到同步队列 0**（被 `signal()` 唤醒后，节点从条件队列转移到同步队列，`waitStatus` 设为 `0`）
4. **争锁中 SIGNAL (-1)**（在同步队列中排队竞争锁，此时节点 `waitStatus` 会被前驱节点设为 `SIGNAL`，值为 `-1`，表示需要被唤醒）
5. **重新持锁 await 返回**（线程成功重新获取锁，`await()` 方法返回，恢复运行状态）

AQS底层维护**两类独立队列**：

同步队列(Sync Queue)   **双向 CLH 变体**

- 竞争锁的线程都在这里排队
- 线程 `unlock` 释放锁时，只会**唤醒同步队列队首线程**

条件队列(Condition Queue)   **单向链表**

- 调用 `condition.await()` 的线程，会进入这里阻塞
- 只有 `signal() / signalAll()` 才会把条件队列的节点迁移到同步队列

await 实战

`awaitNanos` 是一个**带 “时间预算” 的等待方法**，它返回的剩余时间，可以在循环里实现 “总等待时间不超过上限” 的逻辑。

```
// 限流场景：awaitNanos 处理“等到下次填充”
// 只需要单次等待，不需要循环重试，所以不需要处理返回值。
long waitNanos = nextRefillTime - now;
if (waitNanos > 0) {
    // [ARCH] 返回剩余时间
    canPass.awaitNanos(waitNanos);
}

// 连接池场景：awaitNanos 处理“总等待时间不超 timeout”
long nanos = unit.toNanos(timeoutMs);
while (idle.isEmpty() && active >= maxSize) {
    if (nanos <= 0) {
        return null;
    }
    // [ARCH] 累计扣减剩余时间
    nanos = hasIdle.awaitNanos(nanos);
}
```

## 7) 怎么选锁决策树

能不锁就不锁，要锁先synchronized。

HOTSPOT团队为synchronized，注入了大量编译器优化，让他在无竞争场景下开销趋近于零。

JDK 15 synchronized 锁升级

无锁 ---> 偏向锁  ---> 轻量级锁   ---> 重量级锁

Mark Word 64 位四态布局

1. 无锁：`unused | hashCode | age | bias=0 | lock=01`
2. 偏向锁：`thread_id | epoch | age | bias=1 | lock=01`
3. 轻量级锁：`ptr_to_lock_record | lock=00`
4. 重量级锁：`ptr_to_monitor | lock=10`
