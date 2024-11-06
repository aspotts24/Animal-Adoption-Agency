SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS;
SET UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- Create schema
CREATE SCHEMA IF NOT EXISTS `mydatabase` DEFAULT CHARACTER SET utf8;
USE `mydatabase`;

-- Drop tables if they exist
DROP TABLE IF EXISTS `Ledger`;
DROP TABLE IF EXISTS `Inventory_Transactions`;
DROP TABLE IF EXISTS `Inventory`;
DROP TABLE IF EXISTS `Employee_Schedule`;
DROP TABLE IF EXISTS `Scheduled_Visits`;
DROP TABLE IF EXISTS `Donor`;
DROP TABLE IF EXISTS `Adopter`;
DROP TABLE IF EXISTS `Employee`;
DROP TABLE IF EXISTS `Manager`;
DROP TABLE IF EXISTS `Animal`;
DROP TABLE IF EXISTS `Person`;

-- Create Person table
CREATE TABLE IF NOT EXISTS `Person` (
  `person_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `role` ENUM('Employee', 'Adopter', 'Donor', 'Manager') NOT NULL,
  `first_name` VARCHAR(50) DEFAULT NULL,
  `last_name` VARCHAR(50) DEFAULT NULL,
  `address` VARCHAR(255) DEFAULT NULL,
  `dob` DATE DEFAULT NULL,
  `phone_number` VARCHAR(20) DEFAULT NULL,
  `email` VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (`person_id`)
);

-- Create Animal table
CREATE TABLE IF NOT EXISTS `Animal` (
  `animal_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) DEFAULT NULL,
  `species` VARCHAR(50) NOT NULL,
  `type` VARCHAR(50) DEFAULT NULL,
  `age` TINYINT UNSIGNED DEFAULT NULL,
  `vaccinated` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`animal_id`)
);

-- Create Manager table
CREATE TABLE IF NOT EXISTS `Manager` (
  `person_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`person_id`),
  CONSTRAINT `fk_manager_person`
    FOREIGN KEY (`person_id`)
    REFERENCES `Person` (`person_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- Create Employee table
CREATE TABLE IF NOT EXISTS `Employee` (
  `person_id` INT UNSIGNED NOT NULL,
  `salary` DECIMAL(10,2) DEFAULT NULL,
  PRIMARY KEY (`person_id`),
  CONSTRAINT `fk_employee_person`
    FOREIGN KEY (`person_id`)
    REFERENCES `Person` (`person_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- Create Adopter table
CREATE TABLE IF NOT EXISTS `Adopter` (
  `person_id` INT UNSIGNED NOT NULL,
  `application_status` TINYINT NOT NULL DEFAULT 0,
  `preferred_species` VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (`person_id`),
  CONSTRAINT `fk_adopter_person`
    FOREIGN KEY (`person_id`)
    REFERENCES `Person` (`person_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- Create Donor table
CREATE TABLE IF NOT EXISTS `Donor` (
  `person_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`person_id`),
  CONSTRAINT `fk_donor_person`
    FOREIGN KEY (`person_id`)
    REFERENCES `Person` (`person_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
); 

CREATE TABLE IF NOT EXISTS `Scheduled_Visits` (
  `animal_id` INT UNSIGNED NOT NULL,
  `person_id` INT UNSIGNED NOT NULL,
  `time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `grace_period` DATETIME AS (`time` + INTERVAL 24 HOUR) STORED,

  PRIMARY KEY (`animal_id`, `person_id`),
  CONSTRAINT `fk_scheduled_visits_animal`
    FOREIGN KEY (`animal_id`)
    REFERENCES `Animal` (`animal_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_scheduled_visits_person`
    FOREIGN KEY (`person_id`)
    REFERENCES `Person` (`person_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- Create Employee_Schedule table
CREATE TABLE IF NOT EXISTS `Employee_Schedule` (
  `person_id` INT UNSIGNED NOT NULL,
  `timeslot` TIMESTAMP NOT NULL,
  PRIMARY KEY (`person_id`, `timeslot`),
  CONSTRAINT `fk_employee_schedule_employee`
    FOREIGN KEY (`person_id`)
    REFERENCES `Employee` (`person_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- Create Inventory table
CREATE TABLE IF NOT EXISTS `Inventory` (
  `product_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_name` VARCHAR(50) NOT NULL,
  `current_amount` SMALLINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`product_id`)
);

-- Create Inventory_Transactions table
CREATE TABLE IF NOT EXISTS `Inventory_Transactions` (
  `transaction_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `person_id` INT UNSIGNED NOT NULL,
  `product_id` INT UNSIGNED NOT NULL,
  `transaction_amount` SMALLINT NOT NULL DEFAULT 0,
  `description` VARCHAR(200) DEFAULT NULL,
  PRIMARY KEY (`transaction_id`),
  CONSTRAINT `fk_inventory_transactions_person`
    FOREIGN KEY (`person_id`)
    REFERENCES `Person` (`person_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_inventory_transactions_product`
    FOREIGN KEY (`product_id`)
    REFERENCES `Inventory` (`product_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

-- Create Ledger table
CREATE TABLE IF NOT EXISTS `Ledger` (
  `ledger_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `current_balance` DECIMAL(10,2) NOT NULL DEFAULT 0,
  `change_balance` DECIMAL(10,2) NOT NULL DEFAULT 0,
  `person_id` INT UNSIGNED NOT NULL,
  `description` VARCHAR(200) DEFAULT NULL,
  PRIMARY KEY (`ledger_id`),
  CONSTRAINT `fk_ledger_person`
    FOREIGN KEY (`person_id`)
    REFERENCES `Person` (`person_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

-- Re-enable checks
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- Insert data into Person table
INSERT INTO `Person` (`role`, `first_name`, `last_name`, `address`, `dob`, `phone_number`, `email`) VALUES
('Manager', 'Alice', 'Smith', '123 Main St', '1980-05-15', '555-1234', 'alice.smith@example.com'),
('Employee', 'Bob', 'Johnson', '456 Oak Ave', '1990-08-20', '555-2345', 'bob.johnson@example.com'),
('Employee', 'Charlie', 'Brown', '789 Pine Rd', '1985-12-30', '555-3456', 'charlie.brown@example.com'),
('Employee', 'Dana', 'White', '321 Maple St', '1992-11-05', '555-4567', 'dana.white@example.com'),
('Adopter', 'Eve', 'Davis', '654 Spruce Ln', '1978-03-22', '555-5678', 'eve.davis@example.com'),
('Adopter', 'Frank', 'Miller', '987 Birch Blvd', '1983-07-19', '555-6789', 'frank.miller@example.com'),
('Adopter', 'Grace', 'Wilson', '159 Cedar Dr', '1995-01-10', '555-7890', 'grace.wilson@example.com'),
('Adopter', 'Heidi', 'Taylor', '753 Elm St', '1988-09-14', '555-8901', 'heidi.taylor@example.com'),
('Adopter', 'Ivan', 'Anderson', '852 Walnut Way', '1991-04-27', '555-9012', 'ivan.anderson@example.com'),
('Donor', 'Judy', 'Thomas', '951 Cherry Ct', '1975-02-05', '555-0123', 'judy.thomas@example.com'),
('Donor', 'Karl', 'Jackson', '147 Willow Pl', '1982-06-30', '555-1230', 'karl.jackson@example.com'),
('Donor', 'Liam', 'Lee', '369 Aspen Rd', '1989-10-15', '555-2341', 'liam.lee@example.com'),
('Donor', 'Mallory', 'Harris', '258 Poplar Ln', '1977-12-08', '555-3452', 'mallory.harris@example.com'),
('Employee', 'Nina', 'Clark', '357 Fir St', '1986-03-05', '555-4563', 'nina.clark@example.com'),
('Employee', 'Oscar', 'Lewis', '468 Palm Ave', '1993-07-18', '555-5674', 'oscar.lewis@example.com');

-- Insert data into Manager table
INSERT INTO `Manager` (`person_id`) VALUES
(1);

-- Insert data into Employee table
INSERT INTO `Employee` (`person_id`, `salary`) VALUES
(2, 40000.00),
(3, 42000.00),
(4, 39000.00),
(14, 41000.00),
(15, 38000.00);

-- Insert data into Adopter table
INSERT INTO `Adopter` (`person_id`, `application_status`, `preferred_species`) VALUES
(5, 1, 'Dog'),
(6, 0, 'Cat'),
(7, 1, 'Rabbit'),
(8, 2, 'Dog'),
(9, 1, 'Bird');

-- Insert data into Donor table
INSERT INTO `Donor` (`person_id`) VALUES
(10),
(11),
(12),
(13);

-- Insert data into Animal table
INSERT INTO `Animal` (`name`, `species`, `type`, `age`, `vaccinated`) VALUES
('Buddy', 'Dog', 'Golden Retriever', 3, 1),
('Mittens', 'Cat', 'Siamese', 2, 1),
('Thumper', 'Rabbit', 'Dutch', 1, 0),
('Polly', 'Bird', 'Parrot', 4, 1),
('Rex', 'Dog', 'German Shepherd', 5, 1),
('Whiskers', 'Cat', 'Persian', 2, 1),
('Floppy', 'Rabbit', 'Lop', 3, 0),
('Tweety', 'Bird', 'Canary', 1, 0);

-- Insert data into Scheduled_Visits table
INSERT INTO `Scheduled_Visits` (`animal_id`, `person_id`, `time`) VALUES
(1, 5, '2023-11-01 10:00:00'),
(2, 6, '2023-11-02 14:00:00'),
(3, 7, '2023-11-03 09:30:00'),
(4, 9, '2023-11-04 15:00:00'),
(5, 5, '2023-11-05 11:00:00');

-- Insert data into Employee_Schedule table
INSERT INTO `Employee_Schedule` (`person_id`, `timeslot`) VALUES
(2, '2023-11-01 08:00:00'),
(2, '2023-11-02 08:00:00'),
(2, '2023-11-03 08:00:00'),
(3, '2023-11-01 12:00:00'),
(3, '2023-11-02 12:00:00'),
(3, '2023-11-03 12:00:00'),
(4, '2023-11-01 16:00:00'),
(4, '2023-11-02 16:00:00'),
(4, '2023-11-03 16:00:00'),
(14, '2023-11-04 08:00:00'),
(14, '2023-11-05 08:00:00'),
(15, '2023-11-04 12:00:00'),
(15, '2023-11-05 12:00:00');

-- Insert data into Inventory table
INSERT INTO `Inventory` (`product_name`, `current_amount`) VALUES
('Dog Food', 100),
('Cat Food', 80),
('Rabbit Food', 50),
('Bird Seed', 60),
('Cleaning Supplies', 30);

-- Insert data into Inventory_Transactions table
INSERT INTO `Inventory_Transactions` (`person_id`, `product_id`, `transaction_amount`, `description`) VALUES
(2, 1, -20, 'Feeding dogs'),
(3, 2, -15, 'Feeding cats'),
(4, 5, -5, 'Cleaning kennels'),
(14, 3, -10, 'Feeding rabbits'),
(15, 4, -8, 'Feeding birds');

-- Insert data into Ledger table
INSERT INTO `Ledger` (`current_balance`, `change_balance`, `person_id`, `description`) VALUES
(500.00, 500.00, 10, 'Donation from Judy Thomas'),
(700.00, 200.00, 11, 'Donation from Karl Jackson'),
(1000.00, 300.00, 12, 'Donation from Liam Lee'),
(1400.00, 400.00, 13, 'Donation from Mallory Harris');