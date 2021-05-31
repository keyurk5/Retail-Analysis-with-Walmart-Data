/*
	Retail Analysis of Walmart sales data
	Data manipulation and expxloration using SQL
	Skills - Joins, CTE's, Temp Tables, Aggregate Functions, Converting Data Types, Creating Variables, TypeCasting, Math Functions
*/

SELECT *
  FROM WalmartSales.dbo.Walmart_sales

-- Creating Date_Converted from datetime column

Alter Table Walmart_sales
ADD Date_Converted Date;

Update Walmart_sales
SET Date_Converted =  CONVERT(Date,Date)

-- Creating events column from the holiday_dates

Alter table Walmart_sales
Add events nvarchar(100)

Update Walmart_sales
SET vents = Case 
				When CAST(Date_converted AS char) IN ('2010-02-12','2011-02-11','2012-02-10','2013-02-08') Then 'Super Bowl'
				WHEN CAST(Date_converted AS char) IN ('2010-09-10','2011-09-09','2012-09-07','2013-09-06') Then 'Labour Day'
				WHEN CAST(Date_converted AS char) IN ('2010-11-26','2011-11-25','2012-11-23','2013-11-29') Then 'Thanksgiving'
				WHEN CAST(Date_converted AS char) IN ('2010-12-31','2011-12-30','2012-12-28','2013-12-27') Then 'Christmas'
				ELSE 'Non Holiday'
			END

-- Lets answer some statistical questions

-- Which store has maximum sales?
SELECT Store,SUM(Weekly_Sales) as maxSales
FROM WalmartSales.dbo.Walmart_sales
Group by Store
Order by maxSales DESC

-- Which store has maximum standard devation and Coeff of Var (CV)?
SELECT Store, Round(Stdev(Weekly_Sales),2) as stddevSales, Round((Stdev(Weekly_Sales)/AVG(Weekly_Sales)),2) as CV
FROM WalmartSales.dbo.Walmart_sales
Group by Store
Order by stddevSales desc

-- Which store has quarterly growth rate in Q3, 2012?

Alter Table WalmartSales.dbo.Walmart_sales
ADD quarter_date int;

Update WalmartSales.dbo.Walmart_sales
SET quarter_date =  Datepart(quarter,Date_converted)

-- Creating CTE for Quarter 2 sales
With q2_sales AS (
Select Store, SUM(Weekly_Sales) as salesQ2
FROM WalmartSales.dbo.Walmart_sales
Where quarter_date = 2 AND Datepart(year,Date_converted) = 2012
GROUP BY Store),

-- Creating CTE for Quarter 3 sales
q3_sales AS (
Select Store, SUM(Weekly_Sales) as salesQ3
FROM WalmartSales.dbo.Walmart_sales
Where quarter_date = 3 AND Datepart(year,Date_converted) = 2012
GROUP BY Store
)

Select q2.Store, q2.salesQ2, q3.salesQ3, ROUND(((q3.salesQ3 - q2.salesQ2) / q2.salesQ2) * 100, 2) as percentageGrowthSales
FROM q2_sales q2
JOIN q3_sales q3
ON q2.Store = q3.Store
ORDER BY percentageGrowthSales desc

-- Which holidays has higher sales than the mean sales in non holiday season

Declare @non_holiday_mean_sales int
	SET @non_holiday_mean_sales = (SELECT avg(Weekly_Sales) From WalmartSales.dbo.Walmart_sales	Where Holiday_Flag = 0)
	Print @non_holiday_mean_sales

Select events, Round(Avg(Weekly_Sales),2) as HolidaySales
From WalmartSales.dbo.Walmart_sales
WHERE Holiday_Flag = 1
GROUP By events
Having Avg(Weekly_Sales) > @non_holiday_mean_sales
ORDER By HolidaySales desc

-- Monthly and semester wise sales

Select Date_converted,DATEPART(month,Date_converted) as month, Round(Sum(Weekly_Sales),2) as monthlySales
From WalmartSales.dbo.Walmart_sales
Group By DATEPART(month,Date_converted)

Select (Case when DATEPART(quarter,Date_converted) >= 3 Then 2 Else 1 End) as semester, Round(avg(Weekly_Sales),2) as semeterSales
From WalmartSales.dbo.Walmart_sales
Group By (Case when DATEPART(quarter,Date_converted) >= 3 Then 2 Else 1 End)
Order By semeterSales desc

-- Remove unused Date column
Alter Table WalmartSales.dbo.Walmart_sales
Drop Column Date