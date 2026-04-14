# SQL
常用的一些SQL，涵盖面试高频考点。

## 文件说明

| 文件 | 内容 |
|------|------|
| [01_create_tables.sql](./01_create_tables.sql) | 建表语句与测试数据（departments、employees、products、orders、order_items） |
| [02_single_table_queries.sql](./02_single_table_queries.sql) | 单表查询：基础查询、条件过滤、排序、聚合、GROUP BY、HAVING、LIMIT/分页、CASE WHEN、子查询 |
| [03_joins.sql](./03_joins.sql) | 连表查询：INNER JOIN、LEFT OUTER JOIN、RIGHT OUTER JOIN、FULL OUTER JOIN、SELF JOIN、CROSS JOIN 及综合练习 |

## 知识点速查

### 单表查询
- `SELECT … WHERE`：条件过滤（等值、范围、IN、LIKE、IS NULL）
- `GROUP BY … HAVING`：分组聚合与分组过滤
- `ORDER BY … LIMIT`：排序与分页
- `CASE WHEN`：条件表达式
- 子查询（标量子查询、IN、EXISTS、派生表）

### 连表查询

| 类型 | 说明 |
|------|------|
| `INNER JOIN` | 内连接，只返回两表均匹配的行 |
| `LEFT OUTER JOIN` | 左外连接，返回左表全部行，右表无匹配补 NULL |
| `RIGHT OUTER JOIN` | 右外连接，返回右表全部行，左表无匹配补 NULL |
| `FULL OUTER JOIN` | 全外连接，返回两表全部行，无匹配补 NULL（MySQL 用 `UNION` 模拟） |
| `SELF JOIN` | 自连接，同一张表与自身连接，常用于树形/层级结构 |
| `CROSS JOIN` | 交叉连接（笛卡尔积），返回两表所有行的全组合 |
