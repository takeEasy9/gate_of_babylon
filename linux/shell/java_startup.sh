#!/bin/bash

# ==================== 配置变量 ====================
SERVICE_NAME="user-auth-center"
JAR_NAME="user-auth-center.jar"
LOG_DIR="./logs/jvm"
WAIT_TIME=30           # 等待停止的秒数
MAX_RETRIES=3          # 重试次数

# ==================== JVM 参数说明 ====================
# 【当前配置 - ZGC】
# -Xms4g / -Xmx4g: 初始和最大堆内存设为4GB
#   [说明] 在容器环境下建议使用百分比配置而非固定值，例如：
#   -XX:InitialRAMPercentage=50 -XX:MaxRAMPercentage=75
#   这样可以让 JVM 根据容器的可用内存自动调整，更适合 Kubernetes/Docker 等环境
#
# -XX:MetaspaceSize=256m / -XX:MaxMetaspaceSize=512m: 元空间初始和最大值
#   [说明] 用于存放类元数据，256m-512m 对于中等规模微服务比较合理
#
# -XX:+UseZGC: 使用 ZGC 垃圾收集器
#   [说明] 适合低延迟场景，停顿时间通常在毫秒级别，推荐生产环境使用
#
# -XX:+ZGenerational: 启用分代 ZGC
#   [说明] 分代 ZGC 进一步优化了年轻代/老年代回收，性能更好
#   要求：Java 21 或更高版本
#
# -XX:+HeapDumpOnOutOfMemoryError: OOM 时自动生成堆转储文件
#   [说明] 便于排查内存问题
#
# -XX:HeapDumpPath=./logs/jvm/: 堆转储文件路径
#   [说明] 堆转储文件会自动命名为 java_pid<pid>.hprof
#
# -Xlog:gc*:file=./logs/jvm/gc.log:time,uptime,level,tags:filecount=5,filesize=20m: GC 日志配置
#   [说明] 输出详细的 GC 信息，保留5个文件，每个20MB
#
# 【ZGC 可选优化参数】
# -XX:ConcGCThreads=n: 并发 GC 线程数
#   [说明] 建议设置为 CPU 核数的 25%，例如 8 核 CPU 设置为 2-4
#   作用：影响 ZGC 并发阶段的处理速度
#
# -XX:ParallelGCThreads=n: 并行 GC 线程数
#   [说明] 建议设置为 CPU 核数的 60-80%，例如 8 核 CPU 设置为 5-6
#   作用：影响 ZGC 并行阶段的处理速度
#
# -XX:ZCollectionInterval=seconds: ZGC 收集间隔（秒）
#   [说明] 一般不推荐设置，ZGC 自适应策略通常表现更好
#   适用场景：内存增长极慢的应用
#
# -XX:SoftRefLRUPolicyMSPerMB=n: SoftReference 存活时间（每 MB 堆空间）
#   [说明] 默认值 1000ms，可根据应用对软引用使用情况调整
#
# ==================== G1 收集器推荐配置 ====================
# 如需使用 G1GC，建议配置如下：
# java \
# -Xms4g -Xmx4g \
# -XX:MetaspaceSize=256m \
# -XX:MaxMetaspaceSize=512m \
# -XX:+UseG1GC \
# -XX:MaxGCPauseMillis=200 \
# -XX:+HeapDumpOnOutOfMemoryError \
# -XX:HeapDumpPath=./logs/jvm/ \
# -Xlog:gc*:file=./logs/jvm/gc.log:time,uptime,level,tags:filecount=5,filesize=20m \
# -jar user-auth-center.jar
#
# G1 独有参数说明：
# -XX:+UseG1GC: 启用 G1 垃圾收集器
#   [说明] G1 是服务器端垃圾收集器，适合大内存（4GB+）应用，平衡了吞吐量和停顿时间
#
# -XX:MaxGCPauseMillis=200: 最大 GC 停顿目标（毫秒）
#   [说明] G1 会尽量控制每次 GC 停顿不超过此值，默认 200ms
#   可根据业务对延迟的容忍度调整：
#   - 低延迟场景：100-200ms
#   - 高吞吐场景：300-500ms
#
# 【补充 G1 可选优化参数】
# -XX:InitiatingHeapOccupancyPercent=45: 触发并发 GC 的堆占用阈值（默认 45%）
# -XX:G1HeapRegionSize=n: 设置 G1 区域大小（1-32MB，2的幂）
# -XX:G1NewSizePercent=5: 年轻代最小占比（默认 5%）
# -XX:G1MaxNewSizePercent=60: 年轻代最大占比（默认 60%）

# 创建日志目录
mkdir -p $LOG_DIR

# ==================== 启动服务方法 ====================
start_app() {
    local log_file=$(date "+%Y%m%d%H%M%S").log
    
    echo "开始启动 $SERVICE_NAME 服务"
    nohup java \
        -Xms4g \
        -Xmx4g \
        -XX:MetaspaceSize=256m \
        -XX:MaxMetaspaceSize=512m \
        -XX:+UseZGC \
        -XX:+ZGenerational \
        -XX:+HeapDumpOnOutOfMemoryError \
        -XX:HeapDumpPath=$LOG_DIR \
        -Xlog:gc*:file=$LOG_DIR/gc.log:time,uptime,level,tags:filecount=5,filesize=20m \
        -jar $JAR_NAME > "$log_file" &
    echo "$SERVICE_NAME 服务启动成功"
}

# ==================== 停止服务方法 ====================
stop_app() {
    local pid=$1
    
    echo "找到线程: $pid "
    kill -15 "$pid"
    
    for ((retry=1; retry<=MAX_RETRIES; retry++)); do
        echo "第 $retry 次等待服务停止... (最多 $WAIT_TIME 秒)"
        
        for ((i=1; i<=WAIT_TIME; i++)); do
            if ! kill -0 $pid 2>/dev/null; then
                echo "服务已成功停止"
                return 0
            fi
            sleep 1
        done
    done
    
    echo "服务未在 $((MAX_RETRIES * WAIT_TIME)) 秒内停止，强制终止"
    kill -9 $pid
}

# ==================== 主逻辑 ====================
echo "开始停止 $SERVICE_NAME 服务"

sp_pid=$(pgrep -al java | grep "java -jar.*$JAR_NAME" | awk '{print $1}')

if [ -z "$sp_pid" ]; then
    echo "[ 找不到 $SERVICE_NAME 服务 ]"
    start_app
else
    stop_app "$sp_pid"
    echo "成功停止 $SERVICE_NAME 服务"
    start_app
fi
