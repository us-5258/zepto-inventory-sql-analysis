USE zepto_inventory;
USE zepto_inventory;

SELECT 
    COUNT(*) AS total_rows,
    COUNT(name) AS non_null_names,
    COUNT(mrp) AS non_null_mrp,
    COUNT(Category) AS non_null_categories
FROM zepto;
SELECT 
    name,
    COUNT(*) AS duplicate_count
FROM zepto
GROUP BY name
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
SELECT 
    Category,
    name,
    mrp,
    discountPercent,
    availableQuantity,
    discountedSellingPrice,
    weightInGms,
    outOfStock,
    quantity,
    COUNT(*) AS duplicate_count
FROM zepto
GROUP BY 
    Category,
    name,
    mrp,
    discountPercent,
    availableQuantity,
    discountedSellingPrice,
    weightInGms,
    outOfStock,
    quantity
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
DESCRIBE zepto;
SELECT
    name,
    Category,
    mrp,
    discountPercent,
    discountedSellingPrice
FROM zepto
WHERE discountPercent > 0
ORDER BY discountPercent DESC
LIMIT 20;
SELECT
    Category,
    ROUND(AVG(discountPercent), 2) AS avg_discount,
    MAX(discountPercent) AS max_discount
FROM zepto
GROUP BY Category
ORDER BY avg_discount DESC;
SELECT
    name,
    Category,
    mrp,
    discountedSellingPrice,
    (mrp - discountedSellingPrice) AS savings
FROM zepto
ORDER BY savings DESC
LIMIT 20;
SELECT
    Category,
    ROUND(SUM(mrp - discountedSellingPrice), 2) AS total_savings
FROM zepto
GROUP BY Category
ORDER BY total_savings DESC;
SELECT
    outOfStock,
    COUNT(*) AS total_products,
    ROUND(AVG(discountPercent), 2) AS avg_discount
FROM zepto
GROUP BY outOfStock;
SELECT
    name,
    Category,
    availableQuantity,
    discountedSellingPrice,
    (availableQuantity * discountedSellingPrice) AS inventory_value
FROM zepto
ORDER BY inventory_value DESC
LIMIT 20;
SELECT
    Category,
    SUM(availableQuantity) AS total_inventory_units,
    SUM(availableQuantity * discountedSellingPrice) AS total_inventory_value
FROM zepto
GROUP BY Category
ORDER BY total_inventory_value DESC;
SELECT
    name,
    Category,
    availableQuantity,
    discountPercent,
    discountedSellingPrice,
    (availableQuantity * discountedSellingPrice) AS inventory_value
FROM zepto
WHERE discountPercent >= 30
ORDER BY inventory_value DESC
LIMIT 20;
SELECT
    name,
    Category,
    availableQuantity,
    discountPercent,
    discountedSellingPrice
FROM zepto
WHERE availableQuantity <= 10
  AND outOfStock = FALSE
ORDER BY availableQuantity ASC;
SELECT
    Category,
    COUNT(*) AS total_products,
    SUM(CASE WHEN availableQuantity <= 10 AND outOfStock = FALSE THEN 1 ELSE 0 END) AS low_stock_products,
    ROUND(
        SUM(CASE WHEN availableQuantity <= 10 AND outOfStock = FALSE THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS low_stock_percentage
FROM zepto
GROUP BY Category
ORDER BY low_stock_percentage DESC;
SELECT
    name,
    Category,
    availableQuantity,
    discountPercent,
    CASE
        WHEN availableQuantity <= 10 AND outOfStock = FALSE THEN 'Low Stock'
        WHEN availableQuantity > 10 AND discountPercent >= 30 THEN 'High Stock - High Discount'
        WHEN availableQuantity > 10 AND discountPercent < 10 THEN 'High Stock - Low Discount'
        ELSE 'Normal'
    END AS product_segment
FROM zepto;
SELECT
    CASE
        WHEN availableQuantity <= 10 AND outOfStock = FALSE THEN 'Low Stock'
        WHEN availableQuantity > 10 AND discountPercent >= 30 THEN 'High Stock - High Discount'
        WHEN availableQuantity > 10 AND discountPercent < 10 THEN 'High Stock - Low Discount'
        ELSE 'Normal'
    END AS product_segment,
    COUNT(*) AS total_products
FROM zepto
GROUP BY product_segment
ORDER BY total_products DESC;
WITH ranked_products AS (
    SELECT
        name,
        Category,
        availableQuantity,
        discountedSellingPrice,
        (availableQuantity * discountedSellingPrice) AS inventory_value,
        RANK() OVER (
            PARTITION BY Category
            ORDER BY (availableQuantity * discountedSellingPrice) DESC
        ) AS product_rank
    FROM zepto
)
SELECT
    name,
    Category,
    availableQuantity,
    discountedSellingPrice,
    inventory_value,
    product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY Category, product_rank;
WITH ranked_products AS (
    SELECT
        name,
        Category,
        availableQuantity,
        discountedSellingPrice,
        (availableQuantity * discountedSellingPrice) AS inventory_value,
        RANK() OVER (
            PARTITION BY Category
            ORDER BY (availableQuantity * discountedSellingPrice) DESC
        ) AS product_rank
    FROM zepto
)
SELECT
    name,
    Category,
    availableQuantity,
    discountedSellingPrice,
    inventory_value,
    product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY Category, product_rank;
SELECT
    Category,
    COUNT(*) AS total_products,
    SUM(availableQuantity) AS total_inventory_units,
    SUM(availableQuantity * discountedSellingPrice) AS total_inventory_value,
    ROUND(AVG(discountPercent), 2) AS avg_discount,
    SUM(CASE WHEN outOfStock = TRUE THEN 1 ELSE 0 END) AS out_of_stock_products
FROM zepto
GROUP BY Category
ORDER BY total_inventory_value DESC;
SELECT
    name,
    Category,
    availableQuantity,
    discountPercent,
    discountedSellingPrice,
    (availableQuantity * discountedSellingPrice) AS inventory_value
FROM zepto
WHERE discountPercent >= 30
ORDER BY inventory_value DESC
LIMIT 10;
WITH category_avg AS (
    SELECT
        Category,
        AVG(availableQuantity * discountedSellingPrice) AS avg_inventory_value
    FROM zepto
    GROUP BY Category
)
SELECT
    z.name,
    z.Category,
    (z.availableQuantity * z.discountedSellingPrice) AS inventory_value,
    ROUND(c.avg_inventory_value, 2) AS category_avg_inventory_value
FROM zepto z
JOIN category_avg c
    ON z.Category = c.Category
WHERE (z.availableQuantity * z.discountedSellingPrice) > c.avg_inventory_value
ORDER BY inventory_value DESC
LIMIT 20;
SELECT
    name,
    Category,
    availableQuantity,
    discountPercent,
    discountedSellingPrice
FROM zepto
WHERE discountPercent >= 30
  AND availableQuantity <= 10
  AND outOfStock = FALSE
ORDER BY discountPercent DESC, availableQuantity ASC;
SELECT
    Category,
    SUM(availableQuantity * discountedSellingPrice) AS inventory_value,
    RANK() OVER (
        ORDER BY SUM(availableQuantity * discountedSellingPrice) DESC
    ) AS inventory_value_rank
FROM zepto
GROUP BY Category
ORDER BY inventory_value_rank;
CREATE VIEW inventory_summary AS
SELECT
    name,
    Category,
    availableQuantity,
    discountedSellingPrice,
    (availableQuantity * discountedSellingPrice) AS inventory_value,
    discountPercent
FROM zepto;
SELECT *
FROM inventory_summary
LIMIT 10;
SELECT
    name,
    Category,
    availableQuantity,
    discountedSellingPrice,
    inventory_value
FROM inventory_summary
ORDER BY inventory_value DESC
LIMIT 10;
SELECT
    name,
    Category,
    availableQuantity,
    discountedSellingPrice,
    inventory_value
FROM inventory_summary
WHERE availableQuantity <= 2
ORDER BY availableQuantity ASC, inventory_value DESC;
SELECT
    Category,
    COUNT(*) AS out_of_stock_products
FROM inventory_summary
WHERE availableQuantity = 0
GROUP BY Category
ORDER BY out_of_stock_products DESC;
SELECT
    name,
    Category,
    availableQuantity,
    discountedSellingPrice,
    inventory_value
FROM inventory_summary
WHERE availableQuantity = 0
ORDER BY discountedSellingPrice DESC;
SELECT 
    Category,
    COUNT(*) AS out_of_stock_products
FROM inventory_summary
WHERE availableQuantity = 0
GROUP BY Category
ORDER BY out_of_stock_products DESC;
SELECT
    name,
    Category,
    discountPercent,
    discountedSellingPrice
FROM inventory_summary
ORDER BY discountPercent DESC
LIMIT 10;
SELECT
    Category,
    ROUND(AVG(inventory_value), 2) AS avg_inventory_value
FROM inventory_summary
GROUP BY Category
ORDER BY avg_inventory_value DESC;
