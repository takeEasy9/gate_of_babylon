echo "开始停止服务"
current_time=$(date "+%Y%m%d%H%M%S")
format=".log"
log_file=$current_time$format
sp_pid=$(pgrep -al java | grep "java -jar /home/my/app/data/app/app.jar"  | awk '{print $1}')
if [ -z "$sp_pid" ];
then
  echo "[ 找不到服务 ]"
  echo "开始启动服务"
  nohup java -jar /home/my/app/data/app/app.jar > "$log_file" &
  echo "服务启动成功"
else
  echo "找到线程: $sp_pid "
  kill -9 "$sp_pid"
  echo "成功停止服务"
  echo "开始启动服务"
  nohup java -jar /home/my/app/data/app/app.jar > "$log_file" &
  echo "服务启动成功"
fi