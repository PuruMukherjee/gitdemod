--- USER DEFINED FUNCTIONS

--- Scalar Valued Functions

--- Find the name of the person who earns the highest salary

SELECT *
FROM employees
WHERE
salary =
(
SELECT MAX(salary) FROM employees -- the output of sub-query is scalar because it is a single value
)


-- Scalar Valued functions

USE sql_plsql_202409;



SELECT DATENAME(DW,purchase_date),
	   DATENAME(MONTH,purchase_date),
	   DATENAME(dayofyear, purchase_date),
	   purchase_date FROM orders


--- Sunday, 24 December 2022
SELECT DATENAME(DW, purchase_date)+ ', ' +
		DATENAME(D, purchase_date)+ ' '+
		DATENAME(MONTH, purchase_date) + ' '+
		DATENAME(YYYY, purchase_date)
FROM
orders

SELECT * FROM customers


SELECT DATENAME(DW, customer_dob)+ ', ' +
		DATENAME(D, customer_dob)+ ' '+
		DATENAME(MONTH, customer_dob) + ' '+
		DATENAME(YYYY, customer_dob)
FROM
customers


USE sql_plsql_202409;
GO
CREATE OR ALTER FUNCTION fn_getLongDateValue
	(
		@fulldate AS DATETIME -- This is the input parameter to the UDF
	)
	RETURNS VARCHAR(200) --- This will tell us what is the RETURN datatype of the function
	AS
		BEGIN
					-- the RETURN will be the last statement before the END statement
					RETURN	DATENAME(DW, @fulldate)+ ', ' +
							DATENAME(D, @fulldate)+ ' '+
							DATENAME(MONTH, @fulldate) + ' '+
							DATENAME(YYYY, @fulldate)
		END




--- Saturday, 21 September 2024


-- always call the function prefixed with dbo (DATABASE OBJECT)
SELECT *, [dbo].[fn_getLongDateValue](purchase_date) FROM orders;

-- always call the function prefixed with dbo (DATABASE OBJECT)
SELECT customer_dob , [dbo].[fn_getLongDateValue](customer_dob) AS dob_ FROM customers;


--- Alter a function

CREATE OR ALTER FUNCTION [dbo].[fn_getLongDateValue]
	(
		@fulldate AS DATETIME -- This is the input parameter to the UDF
	)
	RETURNS VARCHAR(200) --- This will tell us what is the RETURN datatype of the function
	AS
		BEGIN

					DECLARE @suffix_val AS CHAR(2)

					SELECT @suffix_val =
									CASE
										WHEN DATEPART(D, @fulldate) IN (1, 21, 31) THEN 'st'
										WHEN DATEPART(D, @fulldate) IN (2, 22) THEN 'nd'
										WHEN DATEPART(D, @fulldate) IN (3, 23) THEN 'rd'
										ELSE 'th'
									END


					-- the RETURN will be the last statement before the END statement
					RETURN	TRIM(UPPER(DATENAME(DW, @fulldate)+ ', ' +
							DATENAME(D, @fulldate)+ @suffix_val + ' '+
							DATENAME(MONTH, @fulldate) + ' '+
							DATENAME(YYYY, @fulldate)))
		END
GO


DECLARE @dummy_date AS DATETIME = '2025-01-01'
SELECT [dbo].[fn_getLongDateValue](@dummy_date)