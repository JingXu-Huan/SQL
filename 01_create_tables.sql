-- ============================================================
-- 01_create_tables.sql
-- 创建示例表并插入测试数据，供后续 SQL 练习使用
-- 表结构：departments（部门）、employees（员工）、
--         products（商品）、orders（订单）、order_items（订单明细）
-- ============================================================

-- -------------------- 部门表 --------------------
CREATE TABLE departments (
    dept_id   INT         PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    location  VARCHAR(50)
);

INSERT INTO departments (dept_id, dept_name, location) VALUES
(1,  '研发部',   '北京'),
(2,  '市场部',   '上海'),
(3,  '财务部',   '北京'),
(4,  '人力资源', '广州'),
(5,  '运营部',   '深圳');   -- 注意：该部门暂无员工，用于演示外连接


-- -------------------- 员工表 --------------------
CREATE TABLE employees (
    emp_id    INT          PRIMARY KEY,
    emp_name  VARCHAR(50)  NOT NULL,
    dept_id   INT,                          -- 可为 NULL（表示未分配部门）
    salary    DECIMAL(10,2),
    hire_date DATE,
    manager_id INT,                         -- 自引用，用于演示自连接
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

INSERT INTO employees (emp_id, emp_name, dept_id, salary, hire_date, manager_id) VALUES
(1,  '张伟',   1,    15000.00, '2020-03-15', NULL),
(2,  '李娜',   1,    12000.00, '2021-06-01', 1),
(3,  '王芳',   2,    10000.00, '2019-09-10', NULL),
(4,  '刘洋',   2,     9500.00, '2022-01-20', 3),
(5,  '陈静',   3,    11000.00, '2018-07-08', NULL),
(6,  '赵磊',   3,     8000.00, '2023-02-14', 5),
(7,  '孙丽',   4,     9000.00, '2020-11-30', NULL),
(8,  '周强',   1,    13500.00, '2017-05-22', 1),
(9,  '吴敏',   NULL,  7500.00, '2024-01-05', NULL), -- 未分配部门
(10, '郑浩',   2,    10500.00, '2021-08-18', 3);


-- -------------------- 商品表 --------------------
CREATE TABLE products (
    product_id   INT           PRIMARY KEY,
    product_name VARCHAR(100)  NOT NULL,
    category     VARCHAR(50),
    price        DECIMAL(10,2) NOT NULL
);

INSERT INTO products (product_id, product_name, category, price) VALUES
(1,  '笔记本电脑', '电子产品', 5999.00),
(2,  '机械键盘',   '外设',     399.00),
(3,  '显示器',     '外设',    1299.00),
(4,  '鼠标',       '外设',      89.00),
(5,  '耳机',       '电子产品',  299.00),
(6,  '办公椅',     '家具',      799.00),
(7,  '站立桌',     '家具',     2199.00),
(8,  '台灯',       '家具',      159.00);


-- -------------------- 订单表 --------------------
CREATE TABLE orders (
    order_id    INT          PRIMARY KEY,
    emp_id      INT,                         -- 下单员工（可为 NULL）
    order_date  DATE         NOT NULL,
    status      VARCHAR(20)  DEFAULT '待处理',
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

INSERT INTO orders (order_id, emp_id, order_date, status) VALUES
(1001, 1,    '2024-01-10', '已完成'),
(1002, 2,    '2024-01-15', '已完成'),
(1003, 3,    '2024-02-01', '处理中'),
(1004, 1,    '2024-02-20', '已完成'),
(1005, 5,    '2024-03-05', '待处理'),
(1006, NULL, '2024-03-10', '已完成'), -- 匿名订单
(1007, 8,    '2024-04-01', '处理中'),
(1008, 2,    '2024-04-15', '已完成');


-- -------------------- 订单明细表 --------------------
CREATE TABLE order_items (
    item_id    INT           PRIMARY KEY,
    order_id   INT           NOT NULL,
    product_id INT           NOT NULL,
    quantity   INT           NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO order_items (item_id, order_id, product_id, quantity, unit_price) VALUES
(1,  1001, 1, 1, 5999.00),
(2,  1001, 2, 2,  399.00),
(3,  1002, 3, 1, 1299.00),
(4,  1002, 4, 3,   89.00),
(5,  1003, 5, 2,  299.00),
(6,  1004, 1, 1, 5999.00),
(7,  1004, 6, 1,  799.00),
(8,  1005, 7, 1, 2199.00),
(9,  1006, 8, 4,  159.00),
(10, 1007, 2, 1,  399.00),
(11, 1008, 3, 2, 1299.00),
(12, 1008, 4, 1,   89.00);
