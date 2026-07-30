######################################## Q ##########################


create database project;                                            #created database
use project;
show tables;

select * from fact_internet_sales_new;
 select count(*)  from fact_internet_sales_new;
select * from factinternetsales;
 select count(*)  from factinternetsales;    
 
 
######################################   Q0 ##########################
 
 select * from dimcustomer;
select * from dimproduct;
select * from dimproductcategory;
select * from dimproductsubcategory;
select * from dimsalesterritory;
select * from sales;

######################################   Q0 ##########################


 create table sales as
 select * from factinternetsales                                      #created table as sales and append both fact tables
 union all
 select * from fact_internet_sales_new;                               #Q0

select * from sales;


############################### Q1  ###########################3

set sql_safe_updates=0;                                              #safe updates

alter table sales                                                     # created column in sales table for productname 
add column productname varchar(150);

 alter table sales drop column productname;      

select * from dimproduct;
select * from sales;

update
sales s join dimproduct p on s.productkey= p.productkey set s.productname = p.EnglishProductName;     


############################## Q2 ###########################
 
 
set sql_safe_updates=0;                                               # for safe updates 

UPDATE dimcustomer                                                     #used for cancate the names Q2
SET FullName = 
TRIM(CONCAT(FirstName, ' ', COALESCE(MiddleName, ''), ' ',LastName));

alter table sales add column fullname varchar(50);                      #added fullname column Q2

update sales s join dimcustomer c on s.customerkey = c.customerkey set s.fullname = c.fullname;

create index idx_sales_customerKey on Sales(customerKey);




alter table sales change column productstandardcost  prodctioncost varchar(60);              #renaming
alter table sales drop column totalproductcost;                                             #dropping
alter table sales drop column extendedamount;                                            #dropping



####################################### Q3 ##########################

select* from sales;

alter table sales                                           # created date column
add column date_ date;

set sql_safe_updates=0;  

UPDATE sales                                                           #date from datekey
SET date_ = STR_TO_DATE(OrderDateKey, '%Y%m%d');

ALTER TABLE sales
ADD COLUMN Year INT,
ADD COLUMN Monthno INT,
ADD COLUMN Monthfullname VARCHAR(20),
ADD COLUMN Quarter VARCHAR(5),                                           #created tables for date to Q wise
ADD COLUMN YearMonth VARCHAR(10),
ADD COLUMN Weekdayno INT,
ADD COLUMN Weekdayname VARCHAR(20),
ADD COLUMN FinancialMonth VARCHAR(20),
ADD COLUMN FinancialQuarter VARCHAR(10);



UPDATE sales
SET 
Year = YEAR(date_),

Monthno = MONTH(date_),

Monthfullname = MONTHNAME(date_),

Quarter = CONCAT('Q', QUARTER(date_)),

YearMonth = DATE_FORMAT(date_, '%Y-%b'),

Weekdayno = WEEKDAY(date_) + 1,

Weekdayname = DAYNAME(date_),
                                                                                    #updated values from date 
FinancialMonth = CASE
    WHEN MONTH(date_) >= 4 THEN CONCAT('FM', MONTH(date_)-3)
    ELSE CONCAT('FM', MONTH(date_)+9)
END,

FinancialQuarter = CASE
    WHEN MONTH(date_) BETWEEN 4 AND 6 THEN 'Q1'
    WHEN MONTH(date_) BETWEEN 7 AND 9 THEN 'Q2'
    WHEN MONTH(date_) BETWEEN 10 AND 12 THEN 'Q3'
    ELSE 'Q4'
END;

#################################### Q4 #######################


select* from sales;

ALTER TABLE sales
ADD COLUMN SalesAmountt DECIMAL(10,2);

UPDATE sales
SET SalesAmountt = UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct/100);


###########################  Q5  ##################


ALTER TABLE sales
ADD COLUMN ProductionCost DECIMAL(10,2);
                                                                        # we already have

UPDATE sales
SET ProductionCost = prodctioncost * OrderQuantity;


#########################################  Q6  #################


select * from sales;

ALTER TABLE sales
ADD COLUMN Profit DECIMAL(10,2);

UPDATE sales
SET Profit = SalesAmountt - prodctioncost;

################################## Q7 #################

call year_wise_sales; 

################################## Q8 #################

call month_wise_sales(2011);

#############.......................................###############













#############...........total sales.........###############


SELECT SUM(SalesAmount) AS Total_Sales
FROM Sales;


#############...........total production cost.........###############

SELECT SUM(ProductionCost) AS Total_Production_Cost
FROM Sales;


#############...........total profit.........###############

SELECT SUM(Profit) AS Total_Profit
FROM Sales;


#############...........profit margin.........###############

SELECT
ROUND(
(SUM(Profit) / SUM(SalesAmount)) * 100,
2
) AS Profit_Margin_Percentage
FROM Sales;


#############...........total orders.........###############

SELECT COUNT(SalesOrderNumber) AS Total_Orders
FROM Sales;




















#############...........top 10 products by sales.........###############


SELECT
    P.EnglishProductName,
    SUM(S.SalesAmount) AS Total_Sales
FROM Sales S
JOIN DimProduct P
ON S.ProductKey = P.ProductKey
GROUP BY P.EnglishProductName
ORDER BY Total_Sales DESC
LIMIT 10;


#############...........top 10 customers by sales.........###############

SELECT
    CONCAT(C.FirstName,' ',C.LastName) AS Customer_Name,
    SUM(S.SalesAmount) AS Total_Sales
FROM Sales S
JOIN DimCustomer C
ON S.CustomerKey = C.CustomerKey
GROUP BY Customer_Name
ORDER BY Total_Sales DESC
LIMIT 10;

 