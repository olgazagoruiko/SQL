-- Task 1. Для поточної максимальної річної заробітної плати в компанії 
-- ПОКАЗАТИ ПІБ працівника, департамент, поточну посаду, 
-- тривалість перебування на поточній посаді та загальний стаж роботи в компанії
SELECT CONCAT(emp.first_name, ' ', emp.last_name) AS FullName,
	   dep.dept_name,
       ttl.title, 
	   TIMESTAMPDIFF(year, ttl.from_date, curdate()) AS ExperienceOfTitle,
	   TIMESTAMPDIFF(year, emp.hire_date, curdate()) AS TotalExperience     
FROM employees.employees AS emp
INNER JOIN employees.salaries AS sal
ON emp.emp_no=sal.emp_no AND (CURRENT_DATE() BETWEEN sal.from_date AND sal.to_date)
INNER JOIN employees.titles AS ttl
ON ttl.emp_no=emp.emp_no AND (CURRENT_DATE() BETWEEN ttl.from_date AND ttl.to_date)
INNER JOIN employees.dept_emp AS demp
ON emp.emp_no=demp.emp_no AND (CURRENT_DATE() BETWEEN  demp.from_date AND demp.to_date)
INNER JOIN employees.departments AS dep
ON demp.dept_no=dep.dept_no
ORDER BY sal.salary DESC
LIMIT 1;

-- Task 2. Для кожного департамента 
-- покажіть його назву, ім’я та прізвище поточного керівника та його поточну зарплату.
SELECT dep.dept_no,
	   dep.dept_name,
       emp.first_name,
       emp.last_name,
       sal.salary      
FROM employees.departments AS dep
LEFT JOIN employees.dept_manager AS dmng 
ON dep.dept_no=dmng.dept_no
LEFT JOIN employees.employees AS emp
ON dmng.emp_no=emp.emp_no
LEFT JOIN employees.salaries AS sal
ON emp.emp_no=sal.emp_no
WHERE (CURRENT_DATE() BETWEEN dmng.from_date AND dmng.to_date ) AND (CURRENT_DATE() BETWEEN sal.from_date AND sal.to_date );


-- Task 3.  Покажіть для кожного працівника їхню поточну зарплату 
-- та поточну зарплату поточного керівника
SELECT emp.emp_no AS workers_no,
	   emp.last_name,
       sal.salary AS workers_salary,
       emp2.emp_no AS managers_no,
       emp2.last_name,
       sal2.salary AS managers_salary
FROM employees.employees AS emp
INNER JOIN employees.salaries AS sal
ON emp.emp_no=sal.emp_no AND (CURRENT_DATE() BETWEEN sal.from_date AND sal.to_date )
INNER JOIN employees.dept_emp AS demp
ON emp.emp_no=demp.emp_no AND (CURRENT_DATE() BETWEEN demp.from_date AND demp.to_date )
INNER JOIN employees.departments AS dep
ON demp.dept_no=dep.dept_no
INNER JOIN employees.dept_manager AS dmng
ON dep.dept_no=dmng.dept_no AND (CURRENT_DATE() BETWEEN dmng.from_date AND dmng.to_date )
INNER JOIN employees AS emp2
ON dmng.emp_no=emp2.emp_no
INNER JOIN employees.salaries AS sal2
ON emp2.emp_no=sal2.emp_no AND (CURRENT_DATE() BETWEEN sal2.from_date AND sal2.to_date )
ORDER BY workers_no ASC;

-- Task 4. Покажіть всіх співробітників, які зараз заробляють більше, ніж їхні керівники
SELECT emp.emp_no,
       emp.first_name,
	   emp.last_name
FROM employees.employees AS emp
INNER JOIN employees.salaries AS sal
ON emp.emp_no=sal.emp_no AND (CURRENT_DATE() BETWEEN sal.from_date AND sal.to_date )
INNER JOIN employees.dept_emp AS demp
ON emp.emp_no=demp.emp_no AND (CURRENT_DATE() BETWEEN demp.from_date AND demp.to_date )
INNER JOIN employees.departments AS dep
ON demp.dept_no=dep.dept_no
INNER JOIN employees.dept_manager AS dmng
ON dep.dept_no=dmng.dept_no AND (CURRENT_DATE() BETWEEN dmng.from_date AND dmng.to_date )
INNER JOIN employees AS emp2
ON dmng.emp_no=emp2.emp_no
INNER JOIN employees.salaries AS sal2
ON emp2.emp_no=sal2.emp_no AND (CURRENT_DATE() BETWEEN sal2.from_date AND sal2.to_date )
WHERE sal.salary>sal2.salary
ORDER BY emp.emp_no ASC;

-- Task 5. Покажіть, скільки співробітників зараз мають кожну посаду. 
-- Відсортуйте в порядку спадання за кількістю співробітників.
SELECT ttl.title,
	   COUNT(emp_no) AS CountTitles
FROM employees.titles AS ttl
WHERE CURRENT_DATE() BETWEEN ttl.from_date AND ttl.to_date 
GROUP BY ttl.title
ORDER BY CountTitles DESC;

-- Task 6. Покажіть повні імена всіх співробітників, які працювали більш ніж в одному відділі.
SELECT emp.emp_no,
	   emp.first_name,
       emp.last_name,
	   COUNT(demp.dept_no) AS CountOfDepatments
FROM employees.employees AS emp
LEFT JOIN employees.dept_emp AS demp
ON emp.emp_no=demp.emp_no
GROUP BY emp.emp_no
HAVING COUNT(demp.dept_no)>1
ORDER BY emp.emp_no ASC;

-- Task 7. Покажіть середню та максимальну зарплату в тисячах доларів за кожен рік
SELECT  EXTRACT(YEAR FROM sal.from_date) AS YearOfSalary,
        ROUND(AVG(sal.salary),2) AS AverageSalary,
        MAX(sal.salary) AS MaxSalary
FROM employees.salaries AS sal
GROUP BY EXTRACT(YEAR FROM sal.from_date)
ORDER BY YearOfSalary ASC;

-- Task 8. Покажіть, 
-- скільки працівників було найнято у вихідні дні (субота + неділя), розділивши за статтю
SELECT emp.gender, 
       COUNT(emp.emp_no) AS CountHireEmployees
FROM employees.employees AS emp
WHERE DAYOFWEEK(emp.hire_date)=1 OR  DAYOFWEEK(emp.hire_date)=7
GROUP BY emp.gender;
