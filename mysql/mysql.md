## MYSQL 问题排查

### MYSQL 锁未释放问题排查

```
# 1)查看处理列表
show processlist
# 2)mysql 锁等待可以通过 data_lock_waits 表查看，阻塞的SQL可以通过events_statements_current表查看
select request_e. sql_text wait_sql,w. blocking_thread_id, block_e. sql_text block_sql, block_t. processlist_host block_ip 
from performance_schema.data_lock_waits w
JOIN performance_schema.events_statements_current request_e on request_e.thread_id = w. requesting_thread_id 
JOIN performance_schema.events_statements_current block_e on block_e.thread_id = w. blocking_thread_id 
JOIN performance_schema.threads block_t on block_t. thread_id =w.blocking_thread_id;
# 3) nmap 查看未释放锁的ip主机信息
nmap -O -Pn <ip>
# 4) 找出未释放锁的的人, 下面命令有风险，谨慎执行;
echo 'boys, you locked table, please reply Meng when you see'> data.txt 
hping3 - flood -P -p 8080 -d 50 -E data. txt <ip>

```

