-- ============================================================
-- 02_single_table_queries.sql
-- 单表查询示例
-- 涵盖：基础查询、条件过滤、排序、分组、聚合、HAVING、
--       LIMIT/OFFSET、DISTINCT、CASE WHEN、子查询、模糊查询
-- ============================================================


-- ========================
-- 1. 基础查询
-- ========================

-- 1.1 查询所有列
SELECT * FROM employees;

-- 1.2 查询指定列（列别名）
SELECT emp_id         AS 员工编号,
       emp_name       AS 姓名,
       salary         AS 月薪
FROM employees;

-- 1.3 去重查询（DISTINCT）：查询员工所在的不同部门编号
SELECT DISTINCT dept_id FROM employees;


-- ========================
-- 2. 条件过滤（WHERE）
-- ========================

-- 2.1 等值条件：查询研发部（dept_id=1）的员工
SELECT * FROM employees WHERE dept_id = 1;

-- 2.2 范围条件（BETWEEN）：查询月薪在 10000~13000 之间的员工
SELECT emp_name, salary
FROM employees
WHERE salary BETWEEN 10000 AND 13000;

-- 2.3 IN 列表：查询部门编号为 1、2、3 的员工
SELECT emp_name, dept_id
FROM employees
WHERE dept_id IN (1, 2, 3);

-- 2.4 NULL 判断：查询未分配部门的员工
SELECT emp_name FROM employees WHERE dept_id IS NULL;

-- 2.5 NOT NULL 判断：查询已分配部门的员工
SELECT emp_name FROM employees WHERE dept_id IS NOT NULL;

-- 2.6 模糊查询（LIKE）：查询姓"张"的员工
SELECT * FROM employees WHERE emp_name LIKE '张%';

-- 2.7 组合条件（AND / OR / NOT）
--     查询研发部中月薪超过 12000 的员工，或者入职日期在 2020 年以前的员工
SELECT emp_name, dept_id, salary, hire_date
FROM employees
WHERE (dept_id = 1 AND salary > 12000)
   OR hire_date < '2020-01-01';


-- ========================
-- 3. 排序（ORDER BY）
-- ========================

-- 3.1 按月薪降序排列
SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;

-- 3.2 多列排序：先按部门升序，再按月薪降序
SELECT emp_name, dept_id, salary
FROM employees
ORDER BY dept_id ASC, salary DESC;


-- ========================
-- 4. 聚合函数
-- ========================

-- 4.1 统计员工总数
SELECT COUNT(*) AS 员工总数 FROM employees;

-- 4.2 统计有部门的员工数（COUNT 会忽略 NULL）
SELECT COUNT(dept_id) AS 有部门员工数 FROM employees;

-- 4.3 查询最高薪、最低薪、薪资总和、平均薪资
SELECT MAX(salary) AS 最高薪,
       MIN(salary) AS 最低薪,
       SUM(salary) AS 薪资总和,
       ROUND(AVG(salary), 2) AS 平均薪资
FROM employees;


-- ========================
-- 5. 分组查询（GROUP BY）
-- ========================

-- 5.1 按部门统计员工数量与平均薪资
SELECT dept_id,
       COUNT(*)            AS 员工数,
       ROUND(AVG(salary), 2) AS 平均薪资
FROM employees
GROUP BY dept_id;

-- 5.2 按商品类别统计商品数量及最高价格
SELECT category,
       COUNT(*)   AS 商品数量,
       MAX(price) AS 最高价格
FROM products
GROUP BY category;


-- ========================
-- 6. 分组过滤（HAVING）
-- ========================

-- 6.1 查询平均薪资超过 10000 的部门
SELECT dept_id,
       ROUND(AVG(salary), 2) AS 平均薪资
FROM employees
GROUP BY dept_id
HAVING AVG(salary) > 10000;

-- 6.2 查询员工数多于 2 人的部门
SELECT dept_id, COUNT(*) AS 员工数
FROM employees
GROUP BY dept_id
HAVING COUNT(*) > 2;


-- ========================
-- 7. LIMIT / OFFSET（分页）
-- ========================

-- 7.1 查询薪资最高的前 3 名员工
SELECT emp_name, salary
FROM employees
ORDER BY salary DESC
LIMIT 3;

-- 7.2 分页查询：第 2 页，每页 3 条（跳过前 3 条）
SELECT emp_name, salary
FROM employees
ORDER BY salary DESC
LIMIT 3 OFFSET 3;


-- ========================
-- 8. CASE WHEN 条件表达式
-- ========================

-- 8.1 根据薪资范围划分薪资等级
SELECT emp_name,
       salary,
       CASE
           WHEN salary >= 13000 THEN '高薪'
           WHEN salary >= 10000 THEN '中薪'
           ELSE '低薪'
       END AS 薪资等级
FROM employees
ORDER BY salary DESC;

-- 8.2 统计各部门高、中、低薪人数
SELECT dept_id,
       SUM(CASE WHEN salary >= 13000 THEN 1 ELSE 0 END) AS 高薪人数,
       SUM(CASE WHEN salary BETWEEN 10000 AND 12999 THEN 1 ELSE 0 END) AS 中薪人数,
       SUM(CASE WHEN salary < 10000 THEN 1 ELSE 0 END) AS 低薪人数
FROM employees
WHERE dept_id IS NOT NULL
GROUP BY dept_id;


-- ========================
-- 9. 子查询（Subquery）
-- ========================

-- 9.1 标量子查询：查询薪资高于全公司平均薪资的员工
SELECT emp_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- 9.2 IN 子查询：查询下过订单的员工信息
SELECT emp_name
FROM employees
WHERE emp_id IN (SELECT DISTINCT emp_id FROM orders WHERE emp_id IS NOT NULL);

-- 9.3 NOT IN 子查询：查询没有下过订单的员工
SELECT emp_name
FROM employees
WHERE emp_id NOT IN (SELECT DISTINCT emp_id FROM orders WHERE emp_id IS NOT NULL);

-- 9.4 EXISTS 子查询：查询有下属员工的管理者
SELECT emp_name
FROM employees e
WHERE EXISTS (
    SELECT 1 FROM employees sub WHERE sub.manager_id = e.emp_id
);

-- 9.5 FROM 子查询（派生表）：查询各部门薪资最高的员工
SELECT e.emp_name, e.dept_id, e.salary
FROM employees e
INNER JOIN (
    SELECT dept_id, MAX(salary) AS max_salary
    FROM employees
    GROUP BY dept_id
) dept_max ON e.dept_id = dept_max.dept_id
          AND e.salary   = dept_max.max_salary;
