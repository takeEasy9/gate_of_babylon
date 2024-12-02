面试复盘：

2024-11-28 合合信息

1.Mybatis 怎么预防SQL注入？

#{} 的${}区别：dollar符号只做字符串替换，#{}采用预编译的方式来处理 SQL 语句，`#{}`会被当作一个参数占位符？，MyBatis 会将实际的参数值（如用户输入的用户名和密码）以安全的方式传递给数据库。对于数字类型直接传递，对于字符串类型对于字符串类型，MyBatis 会对特殊字符进行转义处理，MyBatis 会确保数据库将这个参数当作字符串。

1.1 Mybatis 预防SQL注入是在客户端做还服务端做？

客户端做

2. Java如何实现跨平台？与Python实现跨平台机制的区别？

3. java 编译后的的·class文件都有哪些内容？

4. 针对后端IO频繁写入的场景， 有哪些处理方案？

5. Mybatis、JPA 这两种ORM框架的区别？

6. Servlet 

   WSGI（Web Server Gateway Interface）

7. linux常用命令top查看内存，查看网络连接

8. Mysql select for update 与 lock in share mode的区别?

select for update: 写锁

lock in share mode：读锁

