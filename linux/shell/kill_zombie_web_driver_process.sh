#!/usr/bin/env bash
# 超时时间
EXPIRE_TIME=900
if [ "$EXPIRE_TIME" -lt 0 ]
then
    echo "expire time must be positive integer value"
fi
echo "开始清理未正确关闭的 web driver 进程, 超期时间为 $EXPIRE_TIME 秒"
# shellcheck disable=SC2009
WEB_DRIVER_PID=$(ps -eo pid,etimes,cmd | grep -iE 'geckodriver|firefox|chrome' | grep -v 'grep' | awk -v expire_time="$EXPIRE_TIME" '{if ($2 >= expire_time) printf "%s ",$1;}')
if [ -z "$WEB_DRIVER_PID" ]
then
  echo "未发现未正确关闭的 web driver 进程, 无需清理"
  exit 0
else
  echo "发现未正确关闭的 web driver 进程, pid: $WEB_DRIVER_PID"
  if echo "$WEB_DRIVER_PID" | xargs kill -9
  then
    echo "成功清理未正确关闭的 web driver 进程"
  else
    echo "清理未正确关闭的 web driver 进程失败"
  fi
fi