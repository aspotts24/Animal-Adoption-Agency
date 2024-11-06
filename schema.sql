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
