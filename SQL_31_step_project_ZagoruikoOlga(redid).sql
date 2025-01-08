-- 1.QUERIES

-- TASK 1. 
-- Покажіть середню зарплату співробітників за кожен рік, до 2005 року.
SELECT YEAR(sal.from_date) AS calendar_year,
	   ROUND(AVG(sal.salary),2) AS AvgSalary
FROM employees.salaries AS sal
GROUP BY YEAR(sal.from_date)
HAVING calendar_year BETWEEN MIN(calendar_year) AND 2005
ORDER BY calendar_year;

-- TASK 2.
-- Покажіть середню зарплату співробітників по кожному відділу. 
-- Примітка: потрібно розрахувати по поточній зарплаті, та поточному відділу співробітників
SELECT  dept.dept_no,
		dep.dept_name,
        ROUND(AVG(sal.salary),2) AS AvgSalary
FROM employees.dept_emp AS dept
INNER JOIN employees.departments AS dep
ON dept.dept_no=dep.dept_no AND (CURRENT_DATE() BETWEEN dept.from_date AND dept.to_date)
INNER JOIN employees.salaries AS sal
ON dept.emp_no=sal.emp_no AND (CURRENT_DATE() BETWEEN sal.from_date AND sal.to_date)
GROUP BY dept.dept_no,
		 dep.dept_name
ORDER BY dept.dept_no;

-- TASK 3. 
-- Покажіть середню зарплату співробітників по кожному відділу за кожний рік

SELECT  YEAR(sal.from_date) AS calendar_year,
        dept.dept_no,
		dep.dept_name,      
		ROUND(AVG(sal.salary),2) AS AvgSalary
FROM employees.dept_emp AS dept
INNER JOIN employees.departments AS dep
ON dept.dept_no=dep.dept_no
INNER JOIN employees.salaries AS sal
ON dept.emp_no=sal.emp_no
GROUP BY calendar_year,
		  dept.dept_no,
		  dep.dept_name   
ORDER BY calendar_year ;

-- TASK 4. 
-- Покажіть відділи в яких зараз працює більше 15000 співробітників.
SELECT dept.dept_no,
       dep.dept_name
FROM employees.dept_emp AS dept
INNER JOIN employees.departments AS dep
ON dept.dept_no=dep.dept_no
WHERE CURRENT_DATE() BETWEEN dept.from_date AND dept.to_date
GROUP BY dept.dept_no
HAVING COUNT(dept.emp_no)>15000
ORDER BY dept.dept_no;

-- TASK 5. 
-- Для менеджера який працює найдовше покажіть його номер, відділ, дату прийому на роботу, прізвище
SELECT dmng.emp_no,
	   emp.last_name,
       dep.dept_name,
       emp.hire_date
FROM employees.employees AS emp
INNER JOIN employees.dept_manager AS dmng
ON emp.emp_no=dmng.emp_no AND CURRENT_DATE() BETWEEN dmng.from_date AND dmng.to_date
INNER JOIN employees.departments AS dep
ON dmng.dept_no=dep.dept_no
ORDER BY TIMESTAMPDIFF(DAY,emp.hire_date,CURRENT_DATE()) DESC
LIMIT 1;

-- TASK 6.
-- Покажіть топ-10 діючих співробітників компанії з найбільшою різницею між їх зарплатою і середньою зарплатою в їх відділі. 
WITH cte_avg_sal AS(
SELECT dept.dept_no,
       ROUND(AVG(sal.salary),2) AS AvgSalary
FROM employees.salaries AS sal
INNER JOIN employees.dept_emp AS dept
ON sal.emp_no=dept.emp_no
WHERE (CURRENT_DATE BETWEEN dept.from_date AND dept.to_date) AND  (CURRENT_DATE BETWEEN sal.from_date AND sal.to_date)
GROUP BY dept.dept_no
)
SELECT emp.emp_no,
	   CONCAT(emp.first_name," ", emp.last_name) AS full_name,
       dep.dept_name,
       sal.salary,
       cte.AvgSalary,
       ABS(sal.salary-cte.AvgSalary) AS diff_in_salary
FROM employees.employees AS emp
INNER JOIN employees.dept_emp AS dept
ON emp.emp_no=dept.emp_no AND (CURRENT_DATE() BETWEEN dept.from_date AND dept.to_date)
INNER JOIN employees.departments AS dep
ON dept.dept_no=dep.dept_no
INNER JOIN employees.salaries AS sal
ON emp.emp_no = sal.emp_no AND (CURRENT_DATE() BETWEEN sal.from_date AND sal.to_date)
INNER JOIN cte_avg_sal AS cte
ON dept.dept_no=cte.dept_no
ORDER BY diff_in_salary DESC
LIMIT 10;

-- TASK 7.
-- Для кожного відділу покажіть другого по порядку менеджера. 
-- Необхідно вивести відділ, прізвище ім’я менеджера, дату прийому на роботу менеджера і дату коли він став менеджером відділу

--  With use cte
WITH cte_managers AS(
SELECT  dep.dept_no,
		dep.dept_name,
		CONCAT(emp.first_name," ", emp.last_name) AS full_name,
        emp.hire_date,
        dmng.from_date,
        ROW_NUMBER() OVER(PARTITION BY dmng.dept_no ORDER BY dmng.dept_no, dmng.from_date) AS RowNumber
FROM employees.employees AS emp
INNER JOIN employees.dept_manager AS dmng
ON emp.emp_no=dmng.emp_no
INNER JOIN employees.departments AS dep
ON dmng.dept_no=dep.dept_no
)
SELECT cte_managers.dept_no,
	   cte_managers.dept_name,
	   cte_managers.full_name,
       cte_managers.hire_date,
       cte_managers.from_date
FROM cte_managers
WHERE cte_managers.RowNumber=2;


-- With subquery 

SELECT tbl_all_managers.dept_no,
	   tbl_all_managers.dept_name,
	   tbl_all_managers.full_name,
       tbl_all_managers.hire_date,
       tbl_all_managers.from_date
FROM(
SELECT  dep.dept_no,
		dep.dept_name,
		CONCAT(emp.first_name," ", emp.last_name) AS full_name,
        emp.hire_date,
        dmng.from_date,
        ROW_NUMBER() OVER(PARTITION BY dmng.dept_no ORDER BY dmng.dept_no, dmng.from_date) AS RowNumber
FROM employees.employees AS emp
INNER JOIN employees.dept_manager AS dmng
ON emp.emp_no=dmng.emp_no
INNER JOIN employees.departments AS dep
ON dmng.dept_no=dep.dept_no
) AS tbl_all_managers
WHERE tbl_all_managers.RowNumber=2;


-- 2. DESIGN DATABASE

-- TASK 1. 
-- Створіть базу даних для управління курсами. База має включати наступні таблиці:
-- students: student_no, teacher_no, course_no, student_name, email, birth_date.
-- teachers: teacher_no, teacher_name, phone_no
-- courses: course_no, course_name, start_date, end_date

DROP DATABASE IF EXISTS it_courses_db;
CREATE DATABASE IF NOT EXISTS it_courses_db;
SHOW DATABASES;
USE it_courses_db;

DROP TABLE IF EXISTS courses;

CREATE TABLE IF NOT EXISTS courses(
	course_no INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(255) NOT NULL,
    start_date DATE,
    end_date DATE
);
DESCRIBE courses;

DROP TABLE IF EXISTS teachers;

CREATE TABLE IF NOT EXISTS teachers(
	teacher_no INT AUTO_INCREMENT PRIMARY KEY,
    teacher_name VARCHAR(255) NOT NULL,
    phone_no VARCHAR(255) NOT NULL
);
DESCRIBE teachers;

DROP TABLE IF EXISTS students;
CREATE TABLE IF NOT EXISTS students(
student_no INT AUTO_INCREMENT,
teacher_no INT NOT NULL,
course_no INT NOT NULL,
student_name VARCHAR(255) NOT NULL,
email VARCHAR(255) NOT NULL,
birth_date DATE NOT NULL,
PRIMARY KEY (student_no, course_no, teacher_no),
FOREIGN KEY(course_no) REFERENCES courses(course_no) ON UPDATE RESTRICT ON DELETE CASCADE,
FOREIGN KEY(teacher_no) REFERENCES teachers(teacher_no) ON UPDATE RESTRICT ON DELETE CASCADE
);
DESCRIBE students;


-- TASK 2. Додайте будь-які данні (7-10 рядків) в кожну таблицю.
START TRANSACTION;
INSERT INTO courses (course_name, start_date, end_date)
VALUES 
		('Data Analyst','2024-10-08', '2025-03-31'),
        ('Front-end developer','2024-09-10', '2025-01-17'),
        ('UX/UI Design','2024-09-24', '2025-01-31'),
        ('Java Beginner','2024-02-26', '2025-06-26'),
        ('QA Engineer','2025-01-21', '2025-06-21'),
        ('Python developer','2025-01-14', '2025-05-14'),
        ('Digital marketer','2024-10-08', '2025-02-25');
        
INSERT INTO teachers (teacher_name, phone_no)
VALUES 
		('Georgi Facello','+380974567827'),
        ('Chirstian Koblick','+380986567727'),     
        ('Charmane Grisworld','+380981567425'),  
        ('Lidong Meriste','+380953561867'),  
        ('Bezalei Simmel','+380684447827'),  
        ('Honesty Mukaidono','+380994567812'),  
        ('Andrienko Natali','+380973455678'),  
        ('Krusuk Nadia','+380974567111'),  
        ('Ivanova Olga','+380963581245') ;

SELECT*
FROM it_courses_db.courses;
       
SELECT*
FROM it_courses_db.teachers; 


INSERT INTO students (teacher_no, course_no, student_name, email, birth_date)
VALUES 
		('2', '1', 'Sydorenko Poman', 'syd_pom@gmail.com', '1990-06-09'),
        ('1', '6', 'Somov Anton', 'som_an@gmail.com', '1992-08-19'),
        ('3', '4', 'Fedorenko Anna', 'fedorenko123@gmail.com', '2000-01-08'),
        ('5', '7', 'Stasiuk Eva', 'st234@gmail.com', '1991-04-29'),
        ('4', '5', 'Stasiuk Vlad', 'stas2015@gmail.com', '1989-11-20'),
        ('6', '2', 'Martynenko Ivana', 'mar_ivana@gmail.com', '1992-02-15'),
        ('7', '3', 'Kozlov Victor', 'victor1235@gmail.com', '1993-05-09'),
        ('8', '3', 'Buryakov Dmutro', 'bur-dmutro67@gmail.com', '1988-03-04'),
        ('9', '7', 'Lunevi Inna', 'inna234@gmail.com', '1991-07-17'),
        ('2', '1', 'Burkin Maria', 'burkina6788@gmail.com', '1995-06-08'),
        ('2', '1', 'Danylenko Oksana', 'oksana-dan23@gmail.com', '1992-12-10'),
        ('5', '7', 'Histomin Poman', 'hist_poma56@gmail.com', '1994-09-11'),
        ('3', '4', 'Tobilevich Polina', 'tob_polina89@gmail.com', '1991-10-13'),
        ('7', '3', 'Shevtsova Luba', 'shevtsovs_luba.com', '1994-02-14'),
        ('4', '5', 'Makarov Pavlo', 'makarov_pavlo@gmail.com', '1992-07-09'),
        ('2', '1', 'Ivanova Eva', 'ivanova_eva345@gmail.com', '1991-05-06');
COMMIT;
         
SELECT*
FROM it_courses_db.students;     
	
        
-- TASK 3.По кожному викладачу покажіть кількість студентів з якими він працює
SELECT t.teacher_no,
       t.teacher_name,
       COUNT(st.student_no) AS count_student
FROM it_courses_db.teachers AS t
INNER JOIN it_courses_db.students AS st
ON t.teacher_no=st.teacher_no 
INNER JOIN it_courses_db.courses AS c
ON c.course_no=st.course_no 
WHERE CURRENT_DATE() BETWEEN c.start_date AND c.end_date
GROUP BY t.teacher_no
ORDER BY t.teacher_no;

-- TASK 4. Спеціально зробіть 3 дубляжі в таблиці students (додайте ще 3 однакові рядки) 

INSERT INTO it_courses_db.students(teacher_no, course_no, student_name, email, birth_date)
SELECT teacher_no,
       course_no, 
       student_name, 
       email, 
       birth_date
FROM it_courses_db.students
LIMIT 3;

SELECT*
FROM it_courses_db.students;   

-- TASK 5. Напишіть запит який виведе дублюючі рядки в таблиці students
-- 1st  right option
SELECT st.student_no,
	   st.teacher_no,
       st.course_no, 
       st.student_name, 
       st.email, 
       st.birth_date
FROM it_courses_db.students AS st
INNER JOIN it_courses_db.students AS st2
ON st.email=st2.email
WHERE st.student_no!=st2.student_no;


-- 2nd right option
WITH cte_dublicate_students AS (
SELECT student_name
FROM it_courses_db.students
GROUP BY student_name
HAVING COUNT(student_name)>1
)
SELECT st.student_no,
	   st.teacher_no,
       st.course_no, 
       st.student_name, 
       st.email, 
       st.birth_date
FROM it_courses_db.students AS st
INNER JOIN cte_dublicate_students AS cte_dublicate
ON (st.student_name=cte_dublicate.student_name);


-- not so correct option

SELECT st.student_no,
	   st.teacher_no,
       st.course_no, 
       st.student_name, 
       st.email, 
       st.birth_date
FROM it_courses_db.students AS st
WHERE student_no IN(
SELECT MAX(student_no) AS id_student
FROM it_courses_db.students AS st
GROUP BY st.teacher_no,
         st.course_no, 
         st.student_name 
HAVING COUNT(*)>1
);
