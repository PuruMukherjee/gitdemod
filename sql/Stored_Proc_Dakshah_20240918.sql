USE  sql_plsql_202409;
-- Nesting

GO
DECLARE @average_salary AS DECIMAL(10, 2)
SET @average_salary = (SELECT AVG(salary) FROM employees)

PRINT @average_salary --79204

IF @average_salary > 100000 -- level 1 nesting
	BEGIN
		SELECT * FROM employees WHERE salary > 10000
	END
ELSE
	BEGIN
			IF @average_salary > 80000  -- level 2 nesting
				BEGIN
					SELECT *, @average_salary FROM employees WHERE salary > 80000 ORDER BY salary DESC
				END
			ELSE
				BEGIN
					IF @average_salary > 70000  --- level 3 nesting
						BEGIN
							PRINT 'I am here at the @average_salary > 70000'
							SELECT *, @average_salary FROM employees WHERE salary > 70000 ORDER BY salary DESC
						END
					ELSE
						BEGIN
							SELECT *, @average_salary FROM employees WHERE salary < 70000 ORDER BY salary DESC
						END
				END

	END



---  Output parameter (SP that has output parameters)

USE sql_plsql_202409;
DROP PROC IF EXISTS sp_get_avg_sal_by_department;
GO
CREATE OR ALTER PROC sp_get_avg_sal_by_department
	(
		@department_id AS VARCHAR(10)
		,@avg_salary AS INT OUT  --- THE OUT keyword suggests that the Stored Proc will return this value as output
	)
AS
	BEGIN
		SELECT @avg_salary = CONVERT(INT, AVG(salary))
		FROM
		employees
		WHERE
			employee_dept = @department_id
	END

DECLARE @average_salary_dept AS DECIMAL(10, 2)
EXEC sp_get_avg_sal_by_department @department_id = 'SD-Web',
	@avg_salary = @average_salary_dept OUTPUT


-- FIND ALL the people in other departments apart from SD-Web
-- whose salary > than the avg salary of SD-WEB

SELECT *, @average_salary_dept AS 'avg_sal_web'
FROM
employees
WHERE
salary > @average_salary_dept
AND
employee_dept != 'SD-Web'
ORDER BY employee_dept,
		salary DESC;


PRINT 'The average salary for the "SD-WEB" is ' +	CAST(@average_salary_dept AS VARCHAR(15))
-- The average salary for the "SD-WEB" is 78047.00


GO  -- Start a new batch
USE sql_plsql_202409;
DROP PROC IF EXISTS sp_get_avg_sal_by_department;  -- drop the proc
GO
CREATE OR ALTER PROC sp_get_avg_sal_by_department  -- it will always be a CREATE command
	(
		@department_id AS VARCHAR(10)
		,@avg_salary AS INT OUT  --- THE OUT keyword suggests that the Stored Proc will return this value as output
		,@emp_count_abv_sal AS INT OUT
	)

AS
	BEGIN
		SELECT @avg_salary = CONVERT(INT, AVG(salary) )
		FROM
		employees
		WHERE
			employee_dept = @department_id


		SELECT @emp_count_abv_sal = COUNT(*)
		FROM
		employees
		WHERE
			employee_dept = @department_id
		AND
			salary > @avg_salary
	END

GO
DECLARE @average_salary_dept AS DECIMAL(10, 2)  -- Local variable (to stored the value of output)
DECLARE @emp_cnt_above_avg_sal AS INT

EXEC sp_get_avg_sal_by_department @department_id = 'SD-Web',
	@avg_salary = @average_salary_dept OUTPUT,
	@emp_count_abv_sal = @emp_cnt_above_avg_sal OUTPUT

SELECT  @average_salary_dept, 'SD-Web', @emp_cnt_above_avg_sal

-- Find  all the employees from other departments where salary > 120% of the average salary of sd web



SELECT *, @average_salary_dept *1.20 AS perc_120_avg_sal
, @average_salary_dept AS avg_sal
FROM
employees
WHERE
employee_dept != 'SD-Web'
AND
salary > @average_salary_dept * 1.20


--- Find the top 10 employee in each department (apart from SD-Web)
--- Whose salary is closest to the average salary
--- Of the SD-Web department


--- 100

-- 50
-- 98
-- 110
-- 101
-- 88

--- 50 - 100 = -50
--- 98 - 100 = -2 = ABS(-2) =	2
--- 110 - 100 = 10 = ABS(10) =	10
--- 101 - 100 = 1 = ABS(1) =	1
--- 88 - 100  = -12 = ABS(-12) =	12

-- 101
-- 98
-- 110

GO
DECLARE @average_salary_dept AS DECIMAL(10, 2)  -- Local variable (to stored the value of output)
DECLARE @emp_cnt_above_avg_sal AS INT

EXEC sp_get_avg_sal_by_department @department_id = 'SD-Web',
	@avg_salary = @average_salary_dept OUTPUT,
	@emp_count_abv_sal = @emp_cnt_above_avg_sal OUTPUT

SELECT  @average_salary_dept, 'SD-Web', @emp_cnt_above_avg_sal

WITH emp_sal_diff
AS
(
SELECT *, ABS(employees.salary - @average_salary_dept) AS sal_diff
FROM
employees
WHERE
employee_dept != 'SD-Web'
)

--- Use  DENSE RANK or RANK to get the top 10 person by department

-- How do we use the ABS function. 
SELECT ABS(-10)

---- Learn about stored proc that RETURN  a single value using the return statement
---- The SP will not have any OUT parameter

USE sql_plsql_202409
GO
CREATE OR ALTER PROC sp_get_cnt_high_earning_emps_by_department
	(
		@department_id AS VARCHAR(10)
	)
	AS
		BEGIN
			DECLARE @emp_count AS INT
			DECLARE @avg_sal AS INT

			--- Set the value of the @avg_sal of the department
			SELECT @avg_sal = AVG(salary)
			FROM
			employees
			WHERE
			employee_dept = @department_id


			SELECT @emp_count = COUNT(*)
			FROM
			employees
			WHERE salary >  2 * @avg_sal
			AND
			employee_dept = @department_id

			RETURN @emp_count

		END


--- we need to store the return value in a variable
DECLARE @high_earning_emp_cnt AS INT

EXEC @high_earning_emp_cnt = 
	sp_get_cnt_high_earning_emps_by_department @department_id = 'SD-db'

SELECT @high_earning_emp_cnt


--
USE sql_plsql_202409;
GO
CREATE OR ALTER PROC sp_get_avg_sal_by_dept
	(
		@department_id AS VARCHAR(10) = 'ALL'
	)
	AS
	BEGIN
			DECLARE @avg_salary AS DECIMAL(10, 2)
			IF @department_id = 'ALL'
				BEGIN
					PRINT 'I am in the if block of code'
					PRINT @department_id
					SET @avg_salary = (SELECT AVG(salary) FROM employees)
				END
			ELSE
				BEGIN
					PRINT 'I am in the else block of code'
					PRINT @department_id
					SET @avg_salary = (
											SELECT AVG(salary) FROM employees
											WHERE
											employee_dept = @department_id
									  )
				END

			RETURN @avg_salary
	END

SET NOCOUNT ON
DECLARE @avg_sal_dept AS INT
EXEC @avg_sal_dept = sp_get_avg_sal_by_dept 
SELECT @avg_sal_dept

GO
SET NOCOUNT ON
DECLARE @avg_sal_dept AS INT
EXEC @avg_sal_dept = sp_get_avg_sal_by_dept @department_id = 'SD-DB'

SELECT @avg_sal_dept

--- Average of an integer value will always be an integer value
SELECT 
		AVG(CAST(salary AS DECIMAL(12, 3)))
FROM employees

--- User Defined Functions ( NEXT Class ).
--- GIT Version Control Software.
--- Saturday 21st September 7 pm (IST).