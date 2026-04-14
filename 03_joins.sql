-- ============================================================
-- 03_joins.sql
-- 连表查询示例
-- 涵盖：INNER JOIN（内连接）、LEFT OUTER JOIN（左外连接）、
--       RIGHT OUTER JOIN（右外连接）、FULL OUTER JOIN（全外连接）、
--       CROSS JOIN（交叉连接）、SELF JOIN（自连接）、多表连接
-- ============================================================


-- ============================================================
-- 一、INNER JOIN（内连接）
-- 只返回两张表中满足连接条件的行（交集）
-- ============================================================

-- 1.1 基础内连接：查询员工姓名及其所在部门名称
--     未分配部门的员工（dept_id IS NULL）和没有员工的部门均不出现
SELECT e.emp_name       AS 员工姓名,
       d.dept_name      AS 部门名称,
       e.salary         AS 月薪
FROM employees  e
INNER JOIN departments d ON e.dept_id = d.dept_id
ORDER BY d.dept_name, e.salary DESC;

-- 1.2 内连接 + 条件过滤：查询研发部月薪超过 12000 的员工
SELECT e.emp_name  AS 员工姓名,
       d.dept_name AS 部门名称,
       e.salary    AS 月薪
FROM employees  e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_name = '研发部'
  AND e.salary > 12000;

-- 1.3 内连接 + 聚合：统计每个部门的员工数量和平均薪资
SELECT d.dept_name            AS 部门名称,
       COUNT(e.emp_id)        AS 员工数,
       ROUND(AVG(e.salary), 2) AS 平均薪资
FROM departments d
INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY 平均薪资 DESC;

-- 1.4 三表内连接：查询订单中的员工姓名、部门、订单日期和订单状态
SELECT e.emp_name   AS 员工姓名,
       d.dept_name  AS 所属部门,
       o.order_id   AS 订单号,
       o.order_date AS 订单日期,
       o.status     AS 状态
FROM orders     o
INNER JOIN employees  e ON o.emp_id  = e.emp_id
INNER JOIN departments d ON e.dept_id = d.dept_id
ORDER BY o.order_date;

-- 1.5 四表内连接：查询每笔订单的明细（员工、部门、商品、数量、金额）
SELECT e.emp_name          AS 员工姓名,
       d.dept_name         AS 部门,
       p.product_name      AS 商品名称,
       oi.quantity         AS 数量,
       oi.unit_price       AS 单价,
       oi.quantity * oi.unit_price AS 小计
FROM order_items  oi
INNER JOIN orders      o  ON oi.order_id   = o.order_id
INNER JOIN employees   e  ON o.emp_id      = e.emp_id
INNER JOIN departments d  ON e.dept_id     = d.dept_id
INNER JOIN products    p  ON oi.product_id = p.product_id
ORDER BY e.emp_name, o.order_id;


-- ============================================================
-- 二、LEFT OUTER JOIN（左外连接）
-- 返回左表所有行，右表无匹配时用 NULL 填充
-- ============================================================

-- 2.1 查询所有员工及其部门（包含未分配部门的员工）
SELECT e.emp_name                          AS 员工姓名,
       COALESCE(d.dept_name, '未分配部门')  AS 部门名称,
       e.salary                            AS 月薪
FROM employees  e
LEFT JOIN departments d ON e.dept_id = d.dept_id
ORDER BY d.dept_name NULLS LAST, e.emp_name;

-- 2.2 查询所有部门及其员工数（包含没有员工的部门，如"运营部"）
SELECT d.dept_name       AS 部门名称,
       COUNT(e.emp_id)   AS 员工数   -- COUNT 会自动忽略 NULL
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY 员工数 DESC;

-- 2.3 利用 LEFT JOIN + WHERE IS NULL 找出没有下属的员工
--     思路：将 employees 自身左连接，找出从未出现在 manager_id 列中的员工
SELECT e.emp_name AS 非管理者员工
FROM employees  e
LEFT JOIN employees sub ON sub.manager_id = e.emp_id
WHERE sub.emp_id IS NULL;

-- 2.4 查询所有员工的订单情况（含从未下过订单的员工）
SELECT e.emp_name  AS 员工姓名,
       o.order_id  AS 订单号,
       o.order_date AS 订单日期,
       o.status    AS 状态
FROM employees e
LEFT JOIN orders o ON e.emp_id = o.emp_id
ORDER BY e.emp_name, o.order_date;

-- 2.5 LEFT JOIN + 聚合：统计每位员工的订单数（无订单显示 0）
SELECT e.emp_name        AS 员工姓名,
       COUNT(o.order_id) AS 订单数
FROM employees e
LEFT JOIN orders o ON e.emp_id = o.emp_id
GROUP BY e.emp_id, e.emp_name
ORDER BY 订单数 DESC;


-- ============================================================
-- 三、RIGHT OUTER JOIN（右外连接）
-- 返回右表所有行，左表无匹配时用 NULL 填充
-- （效果等同于交换表位置后的 LEFT JOIN）
-- ============================================================

-- 3.1 查询所有部门及其员工（包含没有员工的部门）
SELECT COALESCE(e.emp_name, '（暂无员工）') AS 员工姓名,
       d.dept_name                          AS 部门名称
FROM employees  e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
ORDER BY d.dept_name;

-- 3.2 查询所有订单及其对应员工（包含匿名订单，即 emp_id 为 NULL 的订单）
SELECT o.order_id   AS 订单号,
       o.order_date AS 订单日期,
       o.status     AS 状态,
       COALESCE(e.emp_name, '匿名') AS 下单员工
FROM employees  e
RIGHT JOIN orders o ON e.emp_id = o.emp_id
ORDER BY o.order_date;

-- 3.3 查询所有商品及其订购情况（包含从未被购买的商品）
SELECT p.product_name      AS 商品名称,
       SUM(oi.quantity)    AS 累计销量,
       SUM(oi.quantity * oi.unit_price) AS 累计金额
FROM order_items  oi
RIGHT JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY 累计销量 DESC NULLS LAST;


-- ============================================================
-- 四、FULL OUTER JOIN（全外连接）
-- 返回两张表的所有行，无匹配时对应列用 NULL 填充
-- MySQL 不原生支持 FULL OUTER JOIN，可用 LEFT JOIN UNION RIGHT JOIN 模拟
-- ============================================================

-- 4.1 查询所有员工和所有部门的对应关系（含未分配员工 & 空部门）
--     标准语法（PostgreSQL / SQL Server / Oracle）：
SELECT e.emp_name                          AS 员工姓名,
       COALESCE(d.dept_name, '未分配部门')  AS 部门名称
FROM employees  e
FULL OUTER JOIN departments d ON e.dept_id = d.dept_id
ORDER BY d.dept_name NULLS LAST, e.emp_name;

-- 4.2 MySQL 模拟 FULL OUTER JOIN（LEFT JOIN UNION RIGHT JOIN）
SELECT e.emp_name                          AS 员工姓名,
       COALESCE(d.dept_name, '未分配部门')  AS 部门名称
FROM employees  e
LEFT JOIN departments d ON e.dept_id = d.dept_id

UNION

SELECT e.emp_name                          AS 员工姓名,
       COALESCE(d.dept_name, '未分配部门')  AS 部门名称
FROM employees  e
RIGHT JOIN departments d ON e.dept_id = d.dept_id

ORDER BY 部门名称, 员工姓名;


-- ============================================================
-- 五、SELF JOIN（自连接）
-- 同一张表连接自身，常用于处理层级/树形结构数据
-- ============================================================

-- 5.1 查询每位员工及其直属上级的姓名
SELECT e.emp_name                         AS 员工姓名,
       COALESCE(m.emp_name, '（无上级）')  AS 直属上级
FROM employees  e
LEFT JOIN employees m ON e.manager_id = m.emp_id
ORDER BY m.emp_name NULLS FIRST;

-- 5.2 查询每位管理者及其所有下属
SELECT m.emp_name AS 管理者,
       e.emp_name AS 下属员工
FROM employees e
INNER JOIN employees m ON e.manager_id = m.emp_id
ORDER BY m.emp_name;

-- 5.3 查询与"张伟"在同一部门的其他员工
SELECT b.emp_name AS 同部门员工
FROM employees  a
INNER JOIN employees b ON a.dept_id = b.dept_id
WHERE a.emp_name = '张伟'
  AND b.emp_name <> '张伟';


-- ============================================================
-- 六、CROSS JOIN（交叉连接 / 笛卡尔积）
-- 返回两张表所有行的组合，结果行数 = 左表行数 × 右表行数
-- 生产中需谨慎使用，常用于生成组合数据
-- ============================================================

-- 6.1 列出所有部门与所有商品类别的组合（用于报表占位）
SELECT d.dept_name AS 部门,
       p.category  AS 商品类别
FROM departments d
CROSS JOIN (SELECT DISTINCT category FROM products) p
ORDER BY d.dept_name, p.category;


-- ============================================================
-- 七、综合练习
-- ============================================================

-- 7.1 查询各部门薪资最高的员工信息
SELECT d.dept_name  AS 部门名称,
       e.emp_name   AS 最高薪员工,
       e.salary     AS 月薪
FROM employees  e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary = (
    SELECT MAX(salary)
    FROM employees sub
    WHERE sub.dept_id = e.dept_id
)
ORDER BY e.salary DESC;

-- 7.2 查询下单金额最高的前 3 名员工（含未下过单的员工，金额显示 0）
SELECT e.emp_name                                   AS 员工姓名,
       COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS 消费总额
FROM employees   e
LEFT JOIN orders      o  ON e.emp_id      = o.emp_id
LEFT JOIN order_items oi ON o.order_id    = oi.order_id
GROUP BY e.emp_id, e.emp_name
ORDER BY 消费总额 DESC
LIMIT 3;

-- 7.3 查询从未被订购过的商品
SELECT p.product_name AS 未被购买的商品
FROM products    p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.item_id IS NULL;

-- 7.4 查询同时存在订单且薪资高于部门平均薪资的员工
SELECT DISTINCT e.emp_name  AS 员工姓名,
                e.salary    AS 月薪,
                d.dept_name AS 部门
FROM employees   e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN orders      o ON e.emp_id  = o.emp_id
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees sub
    WHERE sub.dept_id = e.dept_id
)
ORDER BY e.salary DESC;
