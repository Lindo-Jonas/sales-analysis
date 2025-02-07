	     ---------- Product Profitability --------

SELECT * FROM retailsales;

 UPDATE retailsales
 SET discounts = REPLACE(discounts, '-', ' '),
 sales_returns = REPLACE(sales_returns, '-', ' '),
 net_quantity = REPLACE(discounts, '-', ' ');

SELECT * from retailsales;

UPDATE retailsales
set gross_sales = Round(gross_sales, 0),
	discounts = Round(discounts, 0),
    sales_returns = Round(sales_returns, 0),
    total_net_sales = Round(total_net_sales, 0);
    
 SELECT 
    product_type,
    SUM(net_quantity) AS Total_Quantity,
    SUM(gross_sales) AS Total_Gross_Sales,
    SUM(discounts) AS Total_Discount,
    SUM(sales_returns) AS Total_Sales_Returns,
    SUM(total_net_sales) AS Total_Net_Sales,
    (SUM(total_net_sales) / NULLIF(SUM(gross_sales), 0)) * 100 AS Profitability_Percentage
FROM 
    retailsales
GROUP BY 
    product_type
ORDER BY 
    total_net_sales DESC;
    
 CREATE TABLE Product_Profitability (
    Product_Type VARCHAR(255),
    Total_Quantity INT,
    Total_Gross_Sales INT ,
    Total_Discount INT,
    Total_Sales_Returns INT,
    Total_Net_Sales INT,
    ProfitabilityPercentage INT );
    
INSERT INTO Product_Profitability (product_type, total_quantity, total_gross_sales, total_discount, 
                                   total_sales_returns, total_net_sales, profitabilitypercentage)
    SELECT 
    product_type,
    SUM(net_quantity) AS Total_Quantity,
    SUM(gross_sales) AS Total_Gross_Sales,
    SUM(discounts) AS Total_Discount,
    SUM(sales_returns) AS Total_Sales_Returns,
    SUM(total_net_sales) AS Total_Net_Sales,
    (SUM(total_net_sales) / NULLIF(SUM(gross_sales), 0)) * 100 AS Profitability_Percentage
FROM 
    retailsales
GROUP BY 
    product_type
ORDER BY 
    total_net_sales DESC;
        
        
 SELECT * FROM Product_Profitability
 
 UPDATE Product_Profitability
 Set profitabilitypercentage = Round (profitabilitypercentage, 0);
 
 UPDATE Product_Profitability
 SET product_type = 'Unkown'
 WHERE product_type = '';
 
 ALTER TABLE Product_Profitability
 RENAME COLUMN profitabilitypercentage TO profitability_percentage
 
 SELECT * FROM Product_Profitability;
 
 
       ---------- Sales trends over time ----------------
       
 SELECT * FROM businessretailsales2
 
 UPDATE businessretailsales2
 SET discounts = REPLACE(discounts, '-', ' '),
 returns = REPLACE(returns, '-', ' ');
 
UPDATE businessretailsales2
set gross_sales = Round(gross_sales, 0),
	discounts = Round(discounts, 0),
    returns = Round(returns, 0),
    net_sales = Round(net_sales, 0),
    shipping = Round(shipping, 0),
    total_sales = Round(total_sales, 0);
    
    
    ---------Exploratory data Analysis----------
    
  SELECT * FROM Product_Profitability  
  
  SELECT Product_Type, SUM(Total_Net_Sales) AS Total_Net_Sales
FROM Product_Profitability
GROUP BY Product_Type
ORDER BY Total_Net_Sales DESC;

WITH TotalSales AS (
    SELECT SUM(Total_Net_Sales) AS Total_Net_Sales
    FROM ProductPerformance
)
SELECT 
    Product_Type,
    SUM(Total_Net_Sales) AS Product_Net_Sales,
    (SUM(Total_Net_Sales) / Total_Net_Sales) * 100 AS Percentage_Contribution
FROM 
    Product_Profitability
GROUP BY 
    Product_Type, Total_Net_Sales
ORDER BY 
    Percentage_Contribution DESC;


SELECT Product_Type, SUM(Total_Sales_Returns) AS Total_Sales_Returns
FROM Product_Profitability
GROUP BY Product_Type
ORDER BY Total_Sales_Returns DESC;

SELECT 
    Product_Type,
    SUM(Total_Sales_Returns) AS Total_Returns,
    SUM(Total_Net_Sales) AS Total_Net_Sales,
    (SUM(Total_Sales_Returns) / SUM(Total_Net_Sales)) * 100 AS Return_Rate_Percentage
FROM 
    Product_Profitability
GROUP BY 
    Product_Type
ORDER BY 
    Return_Rate_Percentage ASC
LIMIT 5;

SELECT  Product_Type FROM Product_Profitability
WHERE  Total_Sales_Returns = 0;

SELECT * FROM businessretailsales2

SELECT 
    Year,
    SUM(Net_Sales) AS Total_Net_Sales,
    SUM(Returns) AS Total_Returns
FROM 
    businessretailsales2
GROUP BY 
    Year
ORDER BY 
    Year;

WITH YearlySales AS (
    SELECT 
        Year,
        Net_Sales,
        LAG(Net_Sales) OVER (ORDER BY Year) AS Previous_Year_Net_Sales
    FROM 
        businessretailsales2
)
SELECT 
    Year,
    Net_Sales,
    Previous_Year_Net_Sales,
    CASE
        WHEN Previous_Year_Net_Sales IS NULL THEN NULL
        ELSE ((Net_Sales - Previous_Year_Net_Sales) / Previous_Year_Net_Sales) * 100
    END AS Year_on_Year_Performance_Percentage
FROM 
    YearlySales
ORDER BY 
    Year

   