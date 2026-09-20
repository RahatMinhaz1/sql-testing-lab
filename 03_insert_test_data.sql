-- =====================================================================
-- SQL Testing Lab Database - Insert Test Data
-- Run after 02_create_tables.sql
-- Insert order matters because of the foreign keys:
--   department -> employee -> employee_contact
--   student_information -> student_parents_information
--   persons -> orders
-- =====================================================================

USE sql_testing_lab;

-- ---------------------------------------------------------------------
-- department
-- (DeptCode values match the DEPTCODE values already used in the
-- original employee data: 10, 20, 30, 50)
-- ---------------------------------------------------------------------
INSERT INTO `department` (DeptCode, DeptName, Location) VALUES
(10, 'Executive',   'Denver'),
(20, 'Engineering', 'New York'),
(30, 'Sales',       'Chicago'),
(50, 'Research',    'Portland');

-- ---------------------------------------------------------------------
-- employee (original data, now inserted against a real department FK)
-- ---------------------------------------------------------------------
INSERT INTO `employee`
(EmpCode, EmpFName, EmpLName, Job, Manager, HireDate, Salary, Commission, DEPTCODE)
VALUES
(9369,'TONY','STARK','SOFTWARE ENGINEER','7902','1980-12-17',2800,0,20),
(9499,'TIM','ADOLF','SALESMAN','7698','1981-02-20',1600,300,30),
(9566,'KIM','JARVIS','MANAGER','7839','1981-04-02',3570,0,20),
(9654,'SAM','MILES','SALESMAN','7698','1981-09-28',1250,1400,30),
(9782,'KEVIN','HILL','MANAGER','7839','1981-06-09',2940,0,10),
(9788,'CONNIE','SMITH','ANALYST','7566','1982-12-09',3000,0,20),
(9839,'ALFRED','KINSLEY','PRESIDENT','7566','1981-11-17',5000,0,10),
(9844,'PAUL','TIMOTHY','SALESMAN','7698','1981-09-08',1500,0,30),
(9876,'JOHN','ASGHAR','SOFTWARE ENGINEER','7788','1983-01-12',3100,0,20),
(9900,'ROSE','SUMMERS','TECHNICAL LEAD','7698','1981-12-03',2950,0,20),
(9902,'ANDREW','FAULKNER','ANAYLYST','7566','1981-12-03',3000,0,10),
(9934,'KAREN','MATTHEWS','SOFTWARE ENGINEER','7782','1982-01-23',3300,0,20),
(9591,'WENDY','SHAWN','SALESMAN','7698','1981-02-22',500,0,30),
(9698,'BELLA','SWAN','MANAGER','7839','1981-05-01',3420,0,30),
(9777,'MADII','HIMBURY','ANALYST','7839','1981-05-01',2000,200,NULL),
(9860,'ATHENA','WILSON','ANALYST','7839','1992-06-21',7000,100,50),
(9861,'JENNIFER','HUETTE','ANALYST','7839','1996-07-01',5000,100,50);

-- ---------------------------------------------------------------------
-- employee_contact
-- (address/phone data from the original "department" export, kept only
--  for EmpCodes that actually exist in employee -- the EXTRA1-EXTRA8
--  rows from the original export did not match any real employee and
--  have been dropped)
-- ---------------------------------------------------------------------
INSERT INTO `employee_contact` (EmpCode, Address, Number) VALUES
(9369,'New York','1111111111'),
(9499,'Chicago','2222222222'),
(9566,'Dallas','3333333333'),
(9654,'Boston','4444444444'),
(9782,'Seattle','5555555555'),
(9788,'Austin','6666666666'),
(9839,'Denver','7777777777'),
(9844,'Houston','8888888888'),
(9876,'Phoenix','9999999999'),
(9900,'Miami','1010101010'),
(9902,'Atlanta','1111222233'),
(9934,'San Diego','2222333344'),
(9591,'San Jose','3333444455'),
(9698,'Las Vegas','4444555566'),
(9777,'Orlando','5555666677'),
(9860,'Portland','6666777788'),
(9861,'Charlotte','7777888899');

-- ---------------------------------------------------------------------
-- student_information (original data)
-- ---------------------------------------------------------------------
INSERT INTO `student_information` (student_id, first_name, last_name, address) VALUES
(1,'Rakib','Minhaz','Dhaka'),
(2,'Miskatul','Sunvy','Khulna'),
(3,'Babu','Ahamed','cumilla'),
(4,'Asif','Saiful','Laxmipur');

-- ---------------------------------------------------------------------
-- student_parents_information
-- (test data -- table was empty in the original export and had no
--  student_id column; it is now linked to a real student_id)
-- ---------------------------------------------------------------------
INSERT INTO `student_parents_information`
(student_id, student_fathers_name, student_mothers_name, student_guardian_address)
VALUES
(1, 'Karim Uddin',      'Rahima Begum',   'Dhaka'),
(2, 'Jalal Ahmed',       'Selina Akter',   'Khulna'),
(3, 'Nurul Islam',       'Fatema Khatun',  'Cumilla'),
(4, 'Siddiqur Rahman',   'Rokeya Begum',   'Laxmipur');

-- ---------------------------------------------------------------------
-- persons (test data -- table was empty in the original export)
-- ---------------------------------------------------------------------
INSERT INTO `persons` (ID, LastName, FirstName, Age) VALUES
(1, 'Hansen', 'Ola', 30),
(2, 'Svendson', 'Tove', 23),
(3, 'Pettersen', 'Kari', 45);

-- ---------------------------------------------------------------------
-- orders (test data -- table was empty in the original export)
-- ---------------------------------------------------------------------
INSERT INTO `orders` (OrderID, OrderNumber, PersonID) VALUES
(1, 77895, 3),
(2, 44678, 3),
(3, 22456, 1),
(4, 24562, 1),
(5, 34764, 2);

-- ---------------------------------------------------------------------
-- Verification
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS total_departments FROM department;
SELECT COUNT(*) AS total_employees FROM employee;
SELECT COUNT(*) AS total_employee_contacts FROM employee_contact;
SELECT COUNT(*) AS total_students FROM student_information;
SELECT COUNT(*) AS total_parent_records FROM student_parents_information;
SELECT COUNT(*) AS total_persons FROM persons;
SELECT COUNT(*) AS total_orders FROM orders;
