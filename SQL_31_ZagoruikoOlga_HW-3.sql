-- Task-1. Всіх діючих співробітників розбийте на сегменти залежно від віку в момент прийому на роботу:
-- до 25, 25-44, 45-54, 55 і старше, для кожного сегменту виведіть максимальну зарплату. В результаті
-- потрібно отримати два поля сегмент, максимальну зарплату в сегменті.
-- 1-st variant
SELECT 
       "<25" AS AgeSegment,
       MAX(sal.salary) AS MaxSalary
FROM employees.employees AS emp
INNER JOIN employees.salaries AS sal
ON emp.emp_no=sal.emp_no AND (CURRENT_DATE() BETWEEN sal.from_date AND sal.to_date)
WHERE TIMESTAMPDIFF(YEAR, emp.birth_date, emp.hire_date)<25
UNION ALL
SELECT 
        "25-44" AS AgeSegment,
        MAX(sal.salary) AS MaxSalary
FROM employees.employees AS emp
INNER JOIN employees.salaries AS sal
ON emp.emp_no=sal.emp_no AND (CURRENT_DATE() BETWEEN sal.from_date AND sal.to_date)
WHERE TIMESTAMPDIFF(YEAR, emp.birth_date, emp.hire_date)>=25 AND TIMESTAMPDIFF(YEAR, emp.birth_date, emp.hire_date)<=44
UNION ALL
SELECT
         "45-54" AS AgeSegment,
          MAX(sal.salary) AS MaxSalary
FROM employees.employees AS emp
INNER JOIN employees.salaries AS sal
ON emp.emp_no=sal.emp_no AND (CURRENT_DATE() BETWEEN sal.from_date AND sal.to_date)
WHERE TIMESTAMPDIFF(YEAR, emp.birth_date, emp.hire_date)>=45 AND TIMESTAMPDIFF(YEAR, emp.birth_date, emp.hire_date)<=54
UNION ALL
SELECT 
       ">=55" AS AgeSegment,
       MAX(sal.salary) AS MaxSalary
FROM employees.employees AS emp
INNER JOIN employees.salaries AS sal
ON emp.emp_no=sal.emp_no AND (CURRENT_DATE() BETWEEN sal.from_date AND sal.to_date)
WHERE TIMESTAMPDIFF(YEAR, emp.birth_date, emp.hire_date)>=55;

-- 2-st variant  without CTE
SELECT 
       CASE
           WHEN TIMESTAMPDIFF(YEAR, emp.birth_date, emp.hire_date) BETWEEN 0 AND 24 THEN "<25"
           WHEN TIMESTAMPDIFF(YEAR, emp.birth_date, emp.hire_date) BETWEEN 25 AND 44 THEN "25-44"
           WHEN TIMESTAMPDIFF(YEAR, emp.birth_date, emp.hire_date) BETWEEN 45 AND 54 THEN "45-54"
           ELSE "55+"
       END AS AgeCategory,
       MAX(sal.salary) AS MaxSalaryByCategory
FROM employees.employees AS emp
INNER JOIN employees.salaries AS sal
ON emp.emp_no = sal.emp_no
WHERE NOW() BETWEEN sal.from_date AND sal.to_date
GROUP BY AgeCategory
ORDER BY AgeCategory;

-- 3-st variant with CTE
WITH cte_agesegment AS (
SELECT 
       emp.emp_no,
       TIMESTAMPDIFF(YEAR, emp.birth_date, emp.hire_date) AS AgeEmployee,
       CASE
           WHEN TIMESTAMPDIFF(YEAR, emp.birth_date, emp.hire_date) BETWEEN 0 AND 24 THEN "<25"
           WHEN TIMESTAMPDIFF(YEAR, emp.birth_date, emp.hire_date) BETWEEN 25 AND 44 THEN "25-44"
           WHEN TIMESTAMPDIFF(YEAR, emp.birth_date, emp.hire_date) BETWEEN 45 AND 54 THEN "45-54"
           ELSE "55+"
       END AS AgeCategory,
       sal.salary
FROM employees.employees AS emp
INNER JOIN employees.salaries AS sal
ON emp.emp_no=sal.emp_no
WHERE CURRENT_DATE() BETWEEN sal.from_date AND sal.to_date
)
 SELECT cte_agesegment.AgeCategory,
		MAX(cte_agesegment.salary) AS MaxSalaryByCategory
FROM cte_agesegment
GROUP BY AgeCategory
ORDER BY AgeCategory;

-- Task-2. Покажіть посаду та зарплату працівника з найвищою зарплатою більше не працюючого в
-- компанії.

SELECT  ttl.title,
		MAX(sal.salary) AS MaxSal  
FROM employees.titles AS ttl
INNER JOIN employees.dept_emp AS dept 
ON ttl.emp_no=dept.emp_no AND ttl.to_date<CURRENT_DATE() AND dept.to_date<CURRENT_DATE() 
INNER JOIN employees.salaries AS sal
ON ttl.emp_no=sal.emp_no AND sal.to_date<CURRENT_DATE()
INNER JOIN(
SELECT ttl2.emp_no,
        MAX(ttl2.to_date) as last_to_date
FROM employees.titles AS ttl2
GROUP BY ttl2.emp_no) AS t 
ON (t.emp_no = ttl.emp_no) AND (t.last_to_date = ttl.to_date)
GROUP BY ttl.title
ORDER BY MaxSal  DESC
LIMIT 1;


-- Task-3. Покажіть ТОР-10 діючих співробітників з найбільшою зарплатою.
SELECT emp.emp_no,
	   CONCAT(emp.first_name,' ',emp.last_name) AS full_name,
       sal.salary
FROM employees.employees AS emp
INNER JOIN employees.salaries AS sal
ON emp.emp_no=sal.emp_no 
WHERE CURRENT_DATE() BETWEEN sal.from_date AND sal.to_date
ORDER BY sal.salary DESC
LIMIT 10;

-- Task-4. Покажіть діючих співробітників зарплата яких вища ніж середня зарплата по діючим
-- співробітникам.
SELECT emp.emp_no,
	   CONCAT(emp.first_name,' ',emp.last_name) AS full_name,
       sal.salary
FROM employees.employees AS emp
INNER JOIN employees.salaries AS sal
ON emp.emp_no=sal.emp_no
WHERE CURRENT_DATE() BETWEEN sal.from_date AND sal.to_date AND sal.salary>
(SELECT  
      AVG(sal.salary)
FROM employees.salaries AS sal
WHERE CURRENT_DATE() BETWEEN sal.from_date AND sal.to_date);

-- Task-5. Покажіть співробітників, які працюють у відділах де працює більш ніж 20000 співробітників.
SELECT emp.emp_no,
       CONCAT(emp.first_name,' ',emp.last_name) AS full_name,
       dep.dept_no,
       dep.dept_name
FROM employees.employees AS emp
INNER JOIN employees.dept_emp AS dept
ON emp.emp_no=dept.emp_no
INNER JOIN employees.departments AS dep
ON dept.dept_no=dep.dept_no
INNER JOIN( 
SELECT  dept.dept_no		
FROM employees.dept_emp AS dept
WHERE CURRENT_DATE() BETWEEN dept.from_date AND dept.to_date 
GROUP BY dept.dept_no
HAVING COUNT(dept.emp_no)>20000)
 AS
dept2
ON dept2.dept_no=dept.dept_no
WHERE CURRENT_DATE() BETWEEN dept.from_date AND dept.to_date
ORDER BY emp.emp_no;

-- Task-6. Покажіть співробітників, які заробляють більше, ніж будь-який інший працівник відділу Finance.
SELECT sal.emp_no,
       sal.salary
FROM employees.salaries AS sal
WHERE CURRENT_DATE() BETWEEN sal.from_date AND sal.to_date AND sal.salary>(
SELECT sal.salary
FROM employees.dept_emp AS dept
INNER JOIN employees.departments AS dep
ON dept.dept_no=dep.dept_no
INNER JOIN employees.salaries AS sal
ON dept.emp_no=sal.emp_no AND CURRENT_DATE() BETWEEN sal.from_date AND sal.to_date
WHERE dep.dept_name="Finance" AND CURRENT_DATE() BETWEEN dept.from_date AND dept.to_date
ORDER BY sal.salary DESC
LIMIT 1)
ORDER BY sal.salary;

-- Task-7. Покажіть назви відділів, де колись працював хоча б один співробітник з зарплатою більше $150K.
SELECT dep.dept_name
FROM employees.dept_emp AS dept
INNER JOIN employees.departments AS dep
ON dept.dept_no=dep.dept_no
INNER JOIN employees.salaries AS sal
ON dept.emp_no=sal.emp_no 
WHERE sal.salary>150000
GROUP BY dep.dept_name;
