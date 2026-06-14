# PostgreSQL

[TOC]

## 1)数据类型

## 2) 聚合函数

count、max、min、avg

| 聚合函数 | 描述 | 示例                                      |
| :------- | ---- | ----------------------------------------- |
| count    |      |                                           |
| max      |      |                                           |
| min      |      |                                           |
| avg      |      |                                           |
| str_agg  |      | str_agg(expression, delimiter， order by) |
|          |      |                                           |
|          |      |                                           |

PostgreSQL 提供 **Filter** 子句可以限制分组后聚合函数作用于特定的行。

```
SELECT city, count(*) FILTER (WHERE temp_lo < 45), max(temp_lo)
    FROM weather
    GROUP BY city;
```

## 3) 窗口函数

窗口函数示例

```
SELECT WINDOW_FUNCTION() OVER (PARTITION BY column1, column2 ORDER BY column1, column2) FROM TABLE
```

窗口函数调用总是包含一个直接位于窗口函数名称和参数之后的 `OVER` 子句， PARTITION BY 与 ORDER BY 都是可选的。

窗口函数还有一个重要的概念：对于每一行，在其分区中都有一组称为其*窗口帧*的行。某些窗口函数仅对窗口帧中的行起作用，而不是整个分区。默认情况下，如果提供了 `ORDER BY`，则帧由从分区的开头到当前行的所有行组成，以及根据 `ORDER BY` 子句与当前行相等的任何后续行。

当查询涉及多个窗口函数时，可以为每个窗口函数编写一个单独的 `OVER` 子句，但是如果多个函数需要相同的窗口行为，这会是重复的且容易出错。相反，可以在 `WINDOW` 子句中命名每个窗口行为，然后在 `OVER` 中引用它。例如

```
SELECT sum(salary) OVER w, avg(salary) OVER w
  FROM empsalary
  WINDOW w AS (PARTITION BY depname ORDER BY salary DESC);
```

## 4) 运算符优先级

**运算符优先级（从高到低）**

| 运算符/元素                             | 结合性 | 描述                                                      |
| --------------------------------------- | ------ | --------------------------------------------------------- |
| `.`                                     | 左     | 表/列名称分隔符                                           |
| `::`                                    | 左     | PostgreSQL 样式类型强制转换                               |
| `[` `]`                                 | 左     | 数组元素选择                                              |
| `+` `-`                                 | 右     | 一元加号、一元减号                                        |
| `COLLATE`                               | 左     | 排序规则选择                                              |
| `AT`                                    | 左     | `AT TIME ZONE`, `AT LOCAL`                                |
| `^`                                     | 左     | 指数                                                      |
| `*` `/` `%`                             | 左     | 乘法、除法、取模                                          |
| `+` `-`                                 | 左     | 加法、减法                                                |
| （任何其他运算符）                      | 左     | 所有其他本机和用户定义的运算符                            |
| `BETWEEN` `IN` `LIKE` `ILIKE` `SIMILAR` |        | 范围包含、集合成员资格、字符串匹配                        |
| `<` `>` `=` `<=` `>=` `<>`              |        | 比较运算符                                                |
| `IS` `ISNULL` `NOTNULL`                 |        | `IS TRUE`、`IS FALSE`、`IS NULL`、`IS DISTINCT FROM` 等。 |
| `NOT`                                   | 右     | 逻辑否定                                                  |
| `AND`                                   | 左     | 逻辑合取                                                  |
| `OR`                                    | 左     | 逻辑析取                                                  |

## 5）索引类型

PostgreSQL 索引类型从数据结构的角度分为 

- B+树：
- 哈希索引：
- GiST：通用搜索树(Generalized Search Tree)，不是一个具体的索引而是一个索引框架，任何数据类型只要能够实现Gist要求的接口，就可以利用Gist框架创建索引。GiST索引非常适合地理位置、集合图形、IP地址、时间范围进行是否有重叠、距离远近的查询。
- GIN：通用倒排索引(Generalized Inverted Index)，建立从值到行的反向映射

从索引功能上可分为

- 唯一索引

- 普通索引

- 表达式索引：支持把列的计算结果进行索引。

  ```
  CREATE UNIQUE INDEX users_email_idx ON users (lower(email))
  ```

  

- 部分索引：PostgreSQL支持在索引后面添加一个条件，使得索引只对符合和条件的索引生效。

  ```
  CREATE UNIQUE INDEX uk_phone_idx ON users (phone) WHERE (active_ind = 'Y')
  ```

  

## 6) 事务

### 6.1) DDL

PostgreSQL 内部所有关于数据库结构的信息比如表、列、索引都存储在一系列特殊的系统表里面。

pg_class 存储关于表，索引，视图等对象信息。

pg_attribute存储了所有表的列信息。

PostgreSQL支持把DDL(数据定义语言)也就是表结构的修改语句使用事务进行管理。

```
ALTER TABLE usersADD COLUMN first_name text,ADD COLUMN last_name text;
UPDATE usersSET first_name = regexp_replace(name, '\s+.$', ''), -- 取第一空格前
last_name = regexp_replace (name, '^\S+\s', ''); -- 去掉
ALTER TABLE usersALTER COLUMN first_name SET NOT NULL,ALTER COLUMN last_name SET NOT NULL;
ALTER TABLE users DROP COLUMN name;
```

上述一系列操作可以在同一个事务里面执行，中间任务一个环节出现错误，整体都可以进行回滚。保证了数据库里不会出现任何的脏数据。

### 6.2）可延迟约束

```
CREATE TABLE users (id serial PRIMARY KEY,
username text NOT NULL UNIQUE DEFERRABLE INITIALLY DEFERRED); -- 用户名字段不能为空且唯一
```

可延迟约束指的是只有在事务提交的时候才会对这个约束进行检查。

### 6.3）隔离级别

| 隔离级别 | 解决什么问题 | 默认隔离级别 |
| -------- | ------------ | ------------ |
| 读未提交 |              |              |
| 读已提交 | 脏读         | PostgreSQL   |
| 可重复读 | 不可重复读   | MySQL        |
| 串行化   | 幻读         |              |

