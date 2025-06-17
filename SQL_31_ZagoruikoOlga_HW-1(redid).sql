-- Task-1. Виведіть список усіх співробітниць, які приєдналися 01.01.1990 або після 01.01.2000 
SELECT *
FROM employees.employees AS emp
WHERE emp.gender="F" AND (emp.hire_date="1990-01-01" OR emp.hire_date>"2000-01-01");

-- Task-2. Покажіть імена всіх співробітників, які мають однакові ім’я та прізвище 
SELECT emp.first_name,
	   emp.last_name
FROM employees.employees AS emp
WHERE emp.first_name=emp.last_name;

-- Task-3. Покажіть номери співробітників 10001, 10002, 10003 і 10004. Виберіть стовпці: first_name, last_name, gender, hire_date.
SELECT emp.first_name,
	   emp.last_name,
       emp.gender,
       emp.hire_date
FROM employees.employees AS emp
WHERE emp.emp_no BETWEEN "10001" AND "10004";

-- Task-4. Виберіть назви всіх департаментів, назви яких мають букву «а» на будь-якій позиції або «е» на другому місці.
SELECT dep.dept_name
FROM employees.departments AS dep
WHERE dep.dept_name LIKE('%a%') OR dep.dept_name LIKE('_e%');

-- Task-5. Покажіть співробітників, які відповідають наступному опису: Йому було 45 років, коли його прийняли на роботу, він народився в жовтні і був прийнятий на роботу в неділю
SELECT emp.emp_no,
	   emp.first_name,
       emp.last_name,
       emp.gender,
       emp.birth_date,
       TIMESTAMPDIFF(YEAR, emp.birth_date, emp.hire_date) AS AgeEmployee,
       DAYOFWEEK(emp.hire_date) As DayHire
FROM employees.employees AS emp
WHERE TIMESTAMPDIFF(YEAR, emp.birth_date, emp.hire_date)=45 
AND MONTH(emp.birth_date)=10
AND DAYOFWEEK(emp.hire_date)=1
AND emp.gender="M";

-- Task-6. Покажіть максимальну річну зарплату в компанії після 01.06.1995.
SELECT MAX(sal.salary) AS MaxSalary
FROM employees.salaries AS sal
WHERE sal.from_date>"1995-06-01";

-- Task-7. У таблиці dept_emp покажіть кількість співробітників за департаментами (dept_no). To_date має бути більшим за current_date. Покажіть департаменти з понад 13 000 співробітників. Відсотртуйте за кількістю працівників
SELECT dept.dept_no,
	   COUNT(dept.emp_no) AS CountEmployees
FROM employees.dept_emp AS dept
WHERE CURRENT_DATE() BETWEEN dept.from_date AND dept.to_date
GROUP BY dept.dept_no
HAVING COUNT(dept.emp_no)>13000
ORDER BY CountEmployees DESC;

-- Task-8. Покажіть мінімальну та максимальну зарплати по працівникам
SELECT sal.emp_no,
		MIN(sal.salary) AS MinSalary,
	    MAX(sal.salary) AS MaxSalary
FROM employees.salaries AS sal
GROUP BY sal.emp_no;