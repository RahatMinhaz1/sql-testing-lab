-- =====================================================================
-- SQL Testing Lab Database - Table Structures (redesigned & linked)
-- Run after 01_create_database.sql
--
-- Changes made from the original export, and why:
--
-- 1. employee      -> EmpCode is now the PRIMARY KEY (it had none before,
--                     so duplicate/blank employee codes could sneak in).
-- 2. department     -> Rebuilt as a real department table, keyed on
--                     DeptCode, with a DeptName and Location. This is
--                     what employee.DEPTCODE actually needs to point to.
-- 3. employee.DEPTCODE -> now a real FOREIGN KEY -> department.DeptCode.
-- 4. employee_contact -> the old "department" table's address/phone data
--                     (one row per EmpCode) is kept here instead, under a
--                     name that matches what it actually stores, linked
--                     to employee with a FOREIGN KEY.
-- 5. student_parents_information -> renamed from
--                     student_parents_imformation (typo fixed) and a
--                     student_id FOREIGN KEY was added so each parent
--                     record is now tied to a specific student.
-- =====================================================================

USE sql_testing_lab;

-- ---------------------------------------------------------------------
-- Table: student_information
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `student_parents_information`;
DROP TABLE IF EXISTS `student_information`;

CREATE TABLE `student_information` (
  `student_id` INT NOT NULL,
  `first_name` VARCHAR(20) DEFAULT NULL,
  `last_name`  VARCHAR(20) DEFAULT NULL,
  `address`    VARCHAR(20) DEFAULT NULL,
  PRIMARY KEY (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ---------------------------------------------------------------------
-- Table: student_parents_information  (now linked to student_information)
-- ---------------------------------------------------------------------
CREATE TABLE `student_parents_information` (
  `parent_id`               INT AUTO_INCREMENT PRIMARY KEY,
  `student_id`              INT NOT NULL,
  `student_fathers_name`    VARCHAR(25) DEFAULT NULL,
  `student_mothers_name`    VARCHAR(25) DEFAULT NULL,
  `student_guardian_address` VARCHAR(25) DEFAULT NULL,
  CONSTRAINT `fk_parents_student`
    FOREIGN KEY (`student_id`) REFERENCES `student_information` (`student_id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ---------------------------------------------------------------------
-- Table: persons
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `persons`;

CREATE TABLE `persons` (
  `ID`        INT NOT NULL,
  `LastName`  VARCHAR(255) NOT NULL,
  `FirstName` VARCHAR(255) DEFAULT NULL,
  `Age`       INT DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ---------------------------------------------------------------------
-- Table: orders  (references persons)
-- ---------------------------------------------------------------------
CREATE TABLE `orders` (
  `OrderID`     INT NOT NULL,
  `OrderNumber` INT NOT NULL,
  `PersonID`    INT DEFAULT NULL,
  PRIMARY KEY (`OrderID`),
  KEY `PersonID` (`PersonID`),
  CONSTRAINT `orders_ibfk_1`
    FOREIGN KEY (`PersonID`) REFERENCES `persons` (`ID`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ---------------------------------------------------------------------
-- Table: department  (rebuilt as a proper department table)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `employee_contact`;
DROP TABLE IF EXISTS `employee`;
DROP TABLE IF EXISTS `department`;

CREATE TABLE `department` (
  `DeptCode` INT NOT NULL,
  `DeptName` VARCHAR(50) NOT NULL,
  `Location` VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (`DeptCode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ---------------------------------------------------------------------
-- Table: employee  (EmpCode is now a real PRIMARY KEY,
-- DEPTCODE is now a real FOREIGN KEY -> department.DeptCode)
-- ---------------------------------------------------------------------
CREATE TABLE `employee` (
  `EmpCode`    INT NOT NULL,
  `EmpFName`   VARCHAR(255) DEFAULT NULL,
  `EmpLName`   VARCHAR(255) DEFAULT NULL,
  `Job`        VARCHAR(255) DEFAULT NULL,
  `Manager`    CHAR(4) DEFAULT NULL,
  `HireDate`   DATE DEFAULT NULL,
  `Salary`     INT DEFAULT NULL,
  `Commission` INT DEFAULT NULL,
  `DEPTCODE`   INT DEFAULT NULL,
  PRIMARY KEY (`EmpCode`),
  KEY `DEPTCODE` (`DEPTCODE`),
  CONSTRAINT `fk_employee_department`
    FOREIGN KEY (`DEPTCODE`) REFERENCES `department` (`DeptCode`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ---------------------------------------------------------------------
-- Table: employee_contact  (the address/phone data that used to live in
-- the old "department" table, now correctly linked to employee)
-- ---------------------------------------------------------------------
CREATE TABLE `employee_contact` (
  `EmpCode` INT NOT NULL,
  `Address` VARCHAR(100) DEFAULT NULL,
  `Number`  VARCHAR(15) DEFAULT NULL,
  PRIMARY KEY (`EmpCode`),
  CONSTRAINT `fk_contact_employee`
    FOREIGN KEY (`EmpCode`) REFERENCES `employee` (`EmpCode`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SHOW TABLES;
