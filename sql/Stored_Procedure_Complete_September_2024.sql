USE  sql_wkday_20240228;

SELECT TOP 10 * FROM employees

SELECT COUNT(*) FROM employees;

--- Basics to work with STORED PROCEDURE
--- The sections are
--- What a stored procedure actually is
---		Create a Basic Stored Procedure.
---		Executing Stored Procedures
---		Making changes to a stored procedure
---		Deleting a STORED PROCEDURE.

-- What is a stored procedure
-- A group of sql statements grouped together
-- similar to a method and sub routine in other programming language


-- get the hIGHEST salary by department and the employee in each department
-- who gets the highest salary
WITH max_sal_dept
AS
(
SELECT 
	employee_dept, MAX(salary) as highest_salary
FROM
	employees
GROUP BY
	employee_dept
) 
SELECT * FROM max_sal_dept
INNER JOIN
employees
ON
	employees.employee_dept = max_sal_dept.employee_dept
AND
	employees.salary = max_sal_dept.highest_salary
ORDER BY employees.salary DESC;

--- With the stored procedure, I can execute the stored procedure
--- I can reuse this piece of code over and over again
--- without writing the stored procedure
USE [sql_wkday_20240228]
DROP PROC IF EXISTS [dbo].[sp_emp_max_sal_by_dept]

-- use the Above
USE  sql_wkday_20240228; --- The use statement will ensure
--- that the stored procedure will be created in the correct DATABASE.
GO --- Begin's a new BATCH of statement
CREATE OR ALTER PROCEDURE sp_emp_max_sal_by_dept --- CREATE PROC should be the first stament
AS
BEGIN --- The BEGIN and END block will contain all the statements of the SP
WITH max_sal_dept
AS
(
SELECT 
	employee_dept, MAX(salary) as highest_salary
FROM
	employees
GROUP BY
	employee_dept
) 
SELECT * FROM max_sal_dept
INNER JOIN
employees
ON
	employees.employee_dept = max_sal_dept.employee_dept
AND
	employees.salary = max_sal_dept.highest_salary
ORDER BY employees.salary ASC;

END

--- You will not see the result of the SELECT statament itself

--- This is the code to execute the STORED procedure.
EXEC [dbo].[sp_emp_max_sal_by_dept];

USE [sql_wkday_20240228]

---Execute the store procedure
EXEC [dbo].[sp_emp_max_sal_by_dept]


--- To refresh the cache in INTELLISENSE
--- Run CTRL + SHIFT + R



--- How to modify a SP -- right click and ALTER STORED PROCEDURE

--- remove the STORED PROCEDURE
DROP PROC IF EXISTS [dbo].[sp_emp_max_sal_by_dept]

--- PRESS CTRL +SHIFT + R to refersh the cache and INTELLISENSE
-- use the Above
USE  sql_wkday_20240228; --- The use statement will ensure
--- that the stored procedure will be created in the correct DATABASE.
GO --- Begin's a new BATCH of statement
CREATE OR ALTER PROCEDURE sp_emp_max_sal_by_dept --- CREATE PROC should be the first stament
AS
BEGIN --- The BEGIN and END block will contain all the statements of the SP
WITH max_sal_dept
AS
(
SELECT 
	employee_dept, MAX(salary) as highest_salary
FROM
	employees
GROUP BY
	employee_dept
) 
SELECT * FROM max_sal_dept
INNER JOIN
employees
ON
	employees.employee_dept = max_sal_dept.employee_dept
AND
	employees.salary = max_sal_dept.highest_salary
ORDER BY employees.salary ASC;

END
-- PUT THE APPLY KEYWORD to alter a STORED PROCEDURE.
---- To modify the STORED PROCEDURE we need to PUT THE alter keyword

--- USE Paramaters in a STORED PROCEDURE
--- Working with PARAMETERS
--- CREATING PARAMETERS
--- EXECUTING PROCEDURES WITH PARAMETERS
--- OPTIONAL PARAMETERS AND DEFAULT VALUE
--- 


--- what are parameters?
--- you can pass one or more piece of information

GO --- Begin's a new BATCH of statement
CREATE OR
ALTER PROCEDURE sp_emp_max_sal_by_dept(@department_id AS VARCHAR(10)) --- CREATE PROC should be the first stament
AS
BEGIN --- The BEGIN and END block will contain all the statements of the SP
WITH max_sal_dept
AS
(
SELECT 
	employee_dept, MAX(salary) as highest_salary
FROM
	employees
WHERE
	employee_dept = @department_id
GROUP BY
	employee_dept
) 
SELECT * FROM max_sal_dept
INNER JOIN
employees
ON
	employees.employee_dept = max_sal_dept.employee_dept
AND
	employees.salary = max_sal_dept.highest_salary

END

---- EXECUTE  a stored procedure with PARAMETERS
EXEC sp_emp_max_sal_by_dept @department_id = 'SD-Web';

-- This is how we execute the PROCEDURE that takes a parameter

--- Stored procedure with Multiple parameters
USE [sql_wkday_20240228];
GO
CREATE OR ALTER PROC sp_get_top_n_emps_dept
	(
		@top_n AS INT
		,@department_id AS NVARCHAR(10)
	)
AS
	BEGIN
		SELECT
		TOP (@top_n) *
		FROM
			employees
		WHERE
			employees.employee_dept = @department_id
		ORDER BY salary DESC
	END

EXEC sp_get_top_n_emps_dept @top_n=10, @department_id = 'SD-WEB';

--- Rank employees in each department (within each department)
--- Rank each employee based on the salary (DESCENDING ORDER)
SELECT *
,DENSE_RANK() OVER(PARTITION BY employee_dept order by salary DESC) as rank_val
FROM
employees;


--- Procedure that takes in a piece of text and returns all employees whose
--- name has that piece of text

USE [sql_wkday_20240228]
GO --- Go will start a new BATCH as SP should be the first executable statement in a batch
CREATE OR ALTER PROC sp_get_emp_by_name
	(
		@emp_name_substr AS VARCHAR(50)
	)
AS
	BEGIN
		SELECT * FROM employees
		WHERE
			employee_name LIKE '%'+@emp_name_substr+'%'
		ORDER BY  employee_dept, salary DESC
	END

EXEC sp_get_emp_by_name @emp_name_substr='Jha';

-- modify the above STORED PROCEDURE TO get the average salary
-- of all employees whose name has the SUBSTRING JHA
USE [sql_wkday_20240228]
GO --- Go will start a new BATCH as SP should be the first executable statement in a batch
CREATE OR ALTER PROC sp_get_emp_by_name
	(
		@emp_name_substr AS VARCHAR(50)
	)
AS
	BEGIN
		SELECT AVG(salary) FROM employees
		WHERE
			employee_name LIKE '%'+@emp_name_substr+'%'
		
	END

EXEC sp_get_emp_by_name @emp_name_substr='Jha';

--- optional parameters
-- we can make some parameters options
-- the first step to make a parameter option is to give the parameter DEFAULT value

USE [sql_wkday_20240228];
GO
CREATE OR ALTER PROC sp_get_top_n_emps_dept
	(
		@top_n  AS INT = 10
		,@department_id AS NVARCHAR(10)
	)
AS
	BEGIN
		SELECT
		TOP (@top_n) *
		FROM
			employees
		WHERE
			employees.employee_dept = @department_id
		ORDER BY salary DESC
	END
--- by default the the value of the @top_n parameter is 10.	
EXEC sp_get_top_n_emps_dept  @department_id = 'SD-WEB';


-- How to use variables in Microsoft SQL SERVER
-- Three main things to do with variables
--- How to store the result of a query in a variable
--- How you can accumulate information in a variable
--- a variable is a space in memory


SELECT *
FROM employees
WHERE salary > 150000
AND
employee_dept = 'SD-Web'

UNION ALL


SELECT *
FROM employees
WHERE salary > 150000
AND
employee_dept = 'SD-DB'

UNION ALL

SELECT *
FROM
	employees
WHERE
	salary > 150000
AND
	employee_dept = 'SD-Infra'

-- In the above query save the salary as a variable
GO
DECLARE @salary_cutoff AS INT
SET @salary_cutoff = 150000

SELECT *
FROM employees
WHERE salary > @salary_cutoff
AND
employee_dept = 'SD-Web'

UNION ALL


SELECT *
FROM employees
WHERE salary > @salary_cutoff
AND
employee_dept = 'SD-DB'

UNION ALL

SELECT *
FROM
	employees
WHERE
	salary > @salary_cutoff
AND
	employee_dept = 'SD-Infra'

-- Storing the output of a select in a variable
SET NOCOUNT ON --- To remove the rowcount in the print statement
DECLARE @avg_sal AS DECIMAL(10, 2)
DECLARE @department_id AS VARCHAR(20)
SET @department_id = 'SD-WEB'

SELECT @avg_sal = avg(salary)

FROM
	employees
WHERE
	employee_dept = @department_id;


SET @avg_sal = (SELECT AVG(salary) FROM employees WHERE
					employee_dept = @department_id)
SELECT @avg_sal;
PRINT 'The Average Salary of department ' + @department_id + ' is = '+
	CAST(@avg_sal AS VARCHAR(12))

--- THE ROW COUNT


--- declare three sets of variables
GO
SET NOCOUNT ON --- To remove the rowcount in the print statement
DECLARE @avg_sal AS DECIMAL(10, 2)
DECLARE @max_sal AS DECIMAL(10, 2)
DECLARE @min_sal AS DECIMAL(10, 2)
DECLARE @emp_count AS INT
DECLARE @department_id AS VARCHAR(20)
SET @department_id = 'SD-WEB'

SELECT @avg_sal = AVG(salary)
		,@max_sal = MAX(salary)
		,@min_sal = MIN(salary)
		,@emp_count = COUNT(*)
FROM
	employees
WHERE
	employee_dept = @department_id;


print 'The number of employees in department ' +
	CAST(@emp_count AS NVARCHAR(4)) + '. And The average Salary is '+
	CAST(@avg_sal AS NVARCHAR(10))

-- The names of all the departments in a variable

DECLARE @all_department_name AS VARCHAR(200)
SET @all_department_name = ''

SELECT @all_department_name = @all_department_name +  employee_dept + ', '
FROM
(
SELECT DISTINCT employee_dept
FROM
employees
) AS inn_qry

PRINT @all_department_name;

-- CHAR(13) --- CARIAGE RETURN

SELECT CHAR(13) -- This is the RETURN CARRIAGE.

--- GLOBAL VARIABLE are system variables
SELECT @@ROWCOUNT --- This is what we suprressed the row count

SELECT * FROM employees
PRINT 'Number of rows selected is '+ CAST( @@ROWCOUNT AS VARCHAR(8))

--- Output parameters and return value in STORED PROCEDURES.
--- OUTPUT Parameters and RETURN Values in STORED PROCEDURES.
--- Output parameters and RETURN Values from Stored procedures
-- input parameters in STORED PROCEDURE
USE [sql_wkday_20240228]
SET NOCOUNT ON
DROP PROC IF EXISTS sp_get_avg_sal_based_dept
GO
CREATE OR ALTER PROC sp_get_avg_sal_based_dept(
	@department_id AS NVARCHAR(10)
	,@avg_salary AS DECIMAL(10, 2) OUT
	,@student_count AS INT OUT
	)
AS
	BEGIN
			SELECT		@avg_salary = AVG(salary)
						,@student_count = COUNT(*)
			FROM employees
			WHERE
				employee_dept = @department_id
	END


DECLARE @average_salary AS DECIMAL(10, 2)
DECLARE @employee_count AS INT
EXEC sp_get_avg_sal_based_dept @department_id = 'SD-Web',
@avg_salary = @average_salary OUTPUT,
@student_count = @employee_count OUTPUT

PRINT 'The average salary for SD-WEB is ' +
		CAST(@average_salary AS VARCHAR(12))+'.'+
		' The number of students is= '+
		CAST(@employee_count AS VARCHAR(6))
-- At this point I 


-- To show how return value works
-- the stored proc can have only one return value
-- and the return value should always be of type INT
USE [sql_wkday_20240228]
SET NOCOUNT ON
DROP PROC IF EXISTS sp_get_emp_count_based_dept
GO
CREATE OR ALTER PROC sp_get_emp_count_based_dept(
	@department_id AS NVARCHAR(10)
	
	)
AS
	BEGIN
			DECLARE @student_count AS INT
			SELECT		
					@student_count = COUNT(*)
			FROM employees
			WHERE
				employee_dept = @department_id

			RETURN @student_count
	END


DECLARE @employee_count_dept AS INT

EXEC @employee_count_dept = 
			sp_get_emp_count_based_dept @department_id = 'SD-WEB'

SELECT @employee_count_dept

-- How to use IF statements in Microsoft SQL Server
-- In this section we learn IF syntax in Microsoft SQL Server
-- We will learn how to test condition in SQL SERVER
-- Using the ELSE Clause
-- Nested If Statement

USE [sql_wkday_20240228]
SET NOCOUNT ON
DECLARE @average_salary AS DECIMAL(10, 2)
SET @average_salary = (SELECT AVG(salary) FROM employees)
PRINT @average_salary

-- Check if the number of 
IF @average_salary > 10000
	PRINT '	Salary is greater than 10000'

-- what happens when the condition is not being meet
-- I can put an else clause along with the IF statement
IF @average_salary > 100000
	PRINT 'Average Salary above Rs 1 Lakh'
ELSE
	PRINT 'Average Salary below Rs 1 Lakh'

--- more than one statement, then those statements should be inside
--- The BEGIN and END block of code.

IF @average_salary > 100000
	BEGIN
		PRINT 'Average Salary above Rs 1 Lakh'
		PRINT 'More than one '
	END
ELSE
	BEGIN
		PRINT 'Average Salary below Rs 1 Lakh'
		PRINT 'Else Block of code'
	END


--- Nested IF statement
--- when you want to test multiple conditions, we can place one
--- if statement within another
-- This is called as Nested if
GO
DECLARE @average_salary AS DECIMAL(10, 2)
SET @average_salary = (SELECT AVG(salary) FROM employees)
PRINT @average_salary


IF @average_salary > 100000
	BEGIN
		PRINT 'Average Salary is greater than 1 lakh'
	END
ELSE
	BEGIN

		IF @average_salary > 80000
			BEGIN
				PRINT 'Average Salary is greater than 80000 Rs'
			END
		ELSE
			BEGIN
			IF @average_salary > 60000
				BEGIN
					PRINT 'Average Salary is greater than 60000 Rs'
				END
			ELSE
				BEGIN
					PRINT 'Average Salary is less than 60000 Rs.'
				END
			END
	END

--- Create a Stored Procedure that will return the number of employees
--- who get more than the average salary, More than the average salary
--- Based on the input provided to the stored procedure
USE sql_wkday_20240228;
SET NOCOUNT ON;
GO
CREATE OR ALTER PROC sp_get_count_gt_avg_sal(
			@department_id AS VARCHAR(50) = 'ALL'
			)
			AS
			BEGIN
				DECLARE @average_salary AS DECIMAL(10, 2)
				IF @department_id = 'ALL'
					BEGIN
						SET @average_salary =  (
												SELECT AVG(salary)
												FROM
												employees
												)
					END
				ELSE
					BEGIN
						SET @average_salary =  (
												SELECT AVG(salary)
												FROM
												employees
												WHERE
												employee_dept = @department_id
												)
					END
				PRINT CONVERT(VARCHAR(10), @average_salary) + ' for '+
										@department_id

				RETURN @average_salary
			END
				
DECLARE @avg_s AS DECIMAL(10, 2)
EXEC @avg_s = sp_get_count_gt_avg_sal @department_id = 'SD-INFRA'
PRINT 'The average salary for department "SD-INFRA" is ' +CONVERT(VARCHAR(10), @avg_s)

--- USER DEFINED SCALAR FUNCTIONS
--- creating custom functions
--- What are the different scalar functions
--- Defining a function
--- Adding code to a function
--- Using Functions in Queries
--- Altering Functions
SELECT * FROM [dbo].[orders]
-- We have been using some SYSTEM functions so far
-- to see the system functions that we are using
-- go to DATABASE --> Programmability --> Function --> System Function
-- here the functions are grouped based on category
-- example of a category would be a DATE and TIME function

SELECT purchase_date
		,DATEPART(DW, purchase_date)
		,DATEPART(D, purchase_date)
		,DATENAME(DW, purchase_date)
		,DATENAME(M, purchase_date)
		,DATENAME(D, purchase_date)
		,DATEPART(YYYY, purchase_date)
FROM orders

SELECT purchase_date,
		DATENAME(DW, purchase_date) + ' '+
		DATENAME(D, purchase_date)+ ' '+
		DATENAME(M, purchase_date) + ' ' +
		DATENAME(YYYY, purchase_date)
FROM
orders

-- I do not want to write this expression every time
-- I will encapsulate the logic of this expression in a User Defined Function
GO
USE sql_wkday_20240228
-- The code to create a function
-- define the function
-- we will start the function name with the letters fn
-- this way we can defrentiate our functions with SYSTEM functions
-- The create function is the first statement in the next batch
GO
CREATE OR ALTER FUNCTION fn_getLongDate
	(
		@fulldate AS DATETIME
	)
	RETURNS VARCHAR(100) -- This will tell us what is the RETURN datatype of the function
	AS
		BEGIN
			-- The RETURN statement will be the final line of code.
			RETURN	DATENAME(DW, @fulldate) + ' '+
					DATENAME(D, @fulldate)+ ' '+
					DATENAME(M, @fulldate) + ' ' +
					DATENAME(YYYY, @fulldate) -- THIS WILL BE A FINAL LINE
		END

-- This is how a case statement works
SELECT
	purchase_date,
	DATEPART(D, purchase_date) AS date_part
	,CASE 

		WHEN DATEPART(D,purchase_date) IN (1, 21, 31) THEN 'st'
		WHEN DATEPART(D, purchase_date) IN (2, 22) THEN 'nd'
		WHEN DATEPART(D, purchase_date) IN (3, 23) THEN 'rd'
		ELSE 'th'
	END AS suffix_val
FROM
orders
ORDER BY date_part

-- Always use the dbo when using a scalar function
SELECT purchase_date
,[dbo].[fn_getLongDate](purchase_date)
FROM
ORDERS

USE sql_wkday_20240228
GO
CREATE OR ALTER FUNCTION fn_getLongDate
	(
		@fulldate AS DATETIME
	)
	RETURNS VARCHAR(100) -- This will tell us what is the RETURN datatype of the function
	AS
		BEGIN
		
			DECLARE @suffix_val AS CHAR(2)

			SELECT @suffix_val = 
					CASE
					    WHEN DATEPART(D,@fulldate) IN (1, 21, 31) THEN 'st'
						WHEN DATEPART(D, @fulldate) IN (2, 22) THEN 'nd'
						WHEN DATEPART(D, @fulldate) IN (3, 23) THEN 'rd'
						ELSE 'th'
					END

			-- The RETURN statement will be the final line of code.
			RETURN	DATENAME(DW, @fulldate) + ', ' +
					DATENAME(D, @fulldate)+ @suffix_val + ' ' +
					DATENAME(M, @fulldate) + ' ' +
					DATENAME(YYYY, @fulldate) -- THIS WILL BE A FINAL LINE
		END



-- Always use the dbo when using a scalar function
SELECT purchase_date
,[dbo].[fn_getLongDate](purchase_date)
FROM
ORDERS

-- SQL Query to create a DATABASE.
CREATE DATABASE sp_prog_20240907
USE sp_prog_20240907