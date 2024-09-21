SELECT TOP 10 * FROM employees;

-- What is the MAX salary in each department?
SELECT employee_dept, MAX(salary) AS max_salary
FROM
employees
GROUP BY employee_dept
ORDER BY max_salary DESC
--- In the order of execution ORDER BY happens at the very hence

--- Who are the people who get the MAX salary in their respective depts?

USE [sql_plsql_202409]
GO -- The GO command creates a new batch
CREATE PROC sp_employee_max_salary_department
AS
BEGIN


WITH max_sal_by_dept  -- CTE
AS
(
SELECT employee_dept, MAX(salary) AS max_salary
FROM
employees
GROUP BY employee_dept
----ORDER BY max_salary DESC (ORDER BY CLAUSE is an expensive operation)
)

SELECT employees.*
FROM
employees
INNER JOIN
max_sal_by_dept  -- CTE
ON
employees.employee_dept = max_sal_by_dept.employee_dept
AND
employees.salary = max_sal_by_dept.max_salary
ORDER BY employees.salary DESC

END

EXEC sp_employee_max_salary_department


-- Stored proc to search result based on STRING SUBSTRING of the employee name
SELECT *
FROM employees
WHERE
employee_name LIKE '%Kumar%'


USE sql_plsql_202409
GO
CREATE OR ALTER PROC sp_get_employee_by_name
	(
		@employee_name_substring AS VARCHAR(100)
	)
	AS
		BEGIN
				
				SELECT * FROM employees
				WHERE
				employee_name LIKE '%'+@employee_name_substring+'%'
				ORDER BY employee_dept,
				salary DESC --- within each department the output is sorted by the salary in descending order

		END

EXEC sp_get_employee_by_name @employee_name_substring='Kumar';


EXEC sp_get_employee_by_name @employee_name_substring='Sai';

USE [sql_plsql_202409]
GO

-- The ALTER Command is used to ALTER THE stored procedure
CREATE OR ALTER PROC [dbo].[sp_employee_max_salary_department]
AS
BEGIN


WITH max_sal_by_dept  -- CTE
AS
(
SELECT employee_dept, MAX(salary) AS max_salary
FROM
employees
GROUP BY employee_dept
----ORDER BY max_salary DESC (ORDER BY CLAUSE is an expensive operation)
)

SELECT employees.*
FROM
employees
INNER JOIN
max_sal_by_dept  -- CTE
ON
employees.employee_dept = max_sal_by_dept.employee_dept
AND
employees.salary = max_sal_by_dept.max_salary
ORDER BY employees.salary ASC

END
GO

EXEC [dbo].[sp_employee_max_salary_department]



--- The stored proc takes an input, the input is the name of the department
--- gives an record which is the person who gets the highest salary in that department
USE sql_plsql_202409
GO
CREATE OR ALTER PROC
sp_employee_max_salary_department
			(
				@department_id AS VARCHAR(10)--- @department_id = 'SD-Report'
			)
	AS
	BEGIN
			WITH max_sal_by_dept  -- CTE
			AS
			(
SELECT employee_dept, MAX(salary) AS max_salary
FROM
employees
WHERE
employee_dept = @department_id 
GROUP BY employee_dept
----ORDER BY max_salary DESC (ORDER BY CLAUSE is an expensive operation)
)

SELECT employees.*
FROM
employees
INNER JOIN
max_sal_by_dept  -- CTE
ON
employees.employee_dept = max_sal_by_dept.employee_dept
AND
employees.salary = max_sal_by_dept.max_salary
ORDER BY employees.salary DESC
	END

EXEC [dbo].[sp_employee_max_salary_department] @department_id = 'SD-DB';
EXEC [dbo].[sp_employee_max_salary_department] @department_id = 'SD-Report'

DROP PROC IF EXISTS [dbo].[sp_employee_max_salary_department] 


GO
USE sql_plsql_202409
GO
CREATE OR ALTER PROC sp_top_n_salary_by_dept ---mnemonic
		(
				@department_id AS VARCHAR(10)
				,@top_n AS INT
		)
AS
	BEGIN
			
			WITH emp_sal_rank
			AS
			(
			SELECT *,
			DENSE_RANK() OVER(PARTITION BY employee_dept 
										ORDER BY salary DESC) AS salary_rank
			FROM 
			employees
			WHERE
			employee_dept = @department_id
			)

			SELECT *
			FROM
			emp_sal_rank
			WHERE
			salary_rank <= @top_n
	END


EXEC 
[dbo].[sp_top_n_salary_by_dept] @department_id = 'SD-Web',
@top_n = 10


--- what is a variable
-- GET All the employees who work in a particular department
GO
DECLARE @department_id AS VARCHAR(10) --- declaring a variable
SET @department_id = 'SD-Infra'

SELECT *
FROM
employees
WHERE
employee_dept = @department_id
ORDER BY salary DESC;

-- I want all the employess from SD-INFRA and SD-WEb
--- whose salary is greater than a value

GO
DECLARE @salary_cutoff AS INT
SET @salary_cutoff = 100000

SELECT *
FROM
employees
WHERE
employee_dept = 'SD-Infra'
AND
salary >=  @salary_cutoff

UNION ALL

SELECT *
FROM
employees
WHERE
employee_dept = 'SD-WEB'
AND
salary >=  @salary_cutoff

--- get me all the employee from a 
--- specific department who earn more than the average salary of that department
SELECT *
FROM
	employees
WHERE
salary >
(
	SELECT AVG(salary) FROM employees WHERE employee_dept = 'SD-Web'
)
AND
	employee_dept = 'SD-Web';

GO
DECLARE		@avg_salary AS DECIMAL(10, 2)
DECLARE     @employee_dept AS VARCHAR(10)

SET @employee_dept = 'SD-Web'
SET @avg_salary = (	
						SELECT AVG(salary) FROM employees 
						WHERE employee_dept = @employee_dept
				  )


SELECT *, @avg_salary AS average_salary
FROM
employees
WHERE
	employee_dept = @employee_dept
AND
	salary > @avg_salary

---
SET NOCOUNT ON  -- Remove the count message in the message tab of the output
GO
DECLARE		@avg_salary AS DECIMAL(10, 2)
DECLARE     @max_salary AS INT
DECLARE     @min_salary AS INT
DECLARE     @employee_count AS INT
DECLARE     @employee_dept AS VARCHAR(10)

SET @employee_dept = 'SD-Infra'

SELECT @avg_salary = AVG(salary),
		@max_salary = MAX(salary),
		@min_salary = MIN(salary),
		@employee_count = COUNT(employee_id)
FROM employees 
WHERE employee_dept = @employee_dept
				  
--SELECT @employee_dept, @avg_salary, @max_salary, @min_salary, @employee_count
PRINT 
	'The max salary of the ' + @employee_dept + ' is ' +
	CAST(@max_salary AS VARCHAR(10)) + ' and the number of employees is ' +
	CONVERT(VARCHAR(10) , @employee_count)

SELECT *, @avg_salary AS average_salary
FROM
employees
WHERE
	employee_dept = @employee_dept
AND
	salary > @avg_salary


--- SYSTEM defined variables


SELECT * FROM employees
WHERE
employee_dept = 'SD-Infra'


PRINT 'The number of rows selected from the previous query is ' +
		CAST(@@ROWCOUNT AS VARCHAR(5))


--- conditional statements
--- IF ELSE
 SET NOCOUNT ON
 DECLARE @number AS INT
 SET @number = -10

 IF @number > 0 --- -10 > 0 False
	BEGIN
		PRINT CONVERT(VARCHAR(3), @number) + ' is greater than zero'
		SELECT * FROM employees WHERE employee_dept = 'SD-Web'
	END
ELSE
	BEGIN
		PRINT CONVERT(VARCHAR(3), @number) + ' is less than or equal to zero' -- -10 is less than or equal to zero
		SELECT * FROM employees WHERE employee_dept = 'SD-Infra'
	END

