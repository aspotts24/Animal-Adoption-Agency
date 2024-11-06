import os
import mysql.connector
from mysql.connector import errorcode
from tabulate import tabulate

def main():
    # Get environment variables
    MYSQL_HOST = os.getenv('MYSQL_HOST', 'localhost')
    MYSQL_PORT = int(os.getenv('MYSQL_PORT', 3306))
    MYSQL_USER = os.getenv('MYSQL_USER', 'root')
    MYSQL_PASSWORD = os.getenv('MYSQL_PASSWORD', '')
    MYSQL_DATABASE = os.getenv('MYSQL_DATABASE', '')

    # Connect to MySQL
    try:
        cnx = mysql.connector.connect(
            host=MYSQL_HOST,
            port=MYSQL_PORT,
            user=MYSQL_USER,
            password=MYSQL_PASSWORD,
            database=MYSQL_DATABASE
        )
        print("Successfully connected to MySQL database")
        # Use the connection
        cursor = cnx.cursor()

        cursor.execute("""
                INSERT INTO `Person` (`role`, `first_name`, `last_name`, `address`, `dob`, `phone_number`, `email`)
                VALUES ('Employee', 'John', 'Doe', '123 Main St, Anytown, USA', '1990-01-01', '555-1234', 'john.doe@example.com');
                   """)
        
        cursor.execute("SELECT * FROM Person")
        persons = cursor.fetchall()
        headers = [i[0] for i in cursor.description]
        print("Persons:")
        print(tabulate(persons, headers, tablefmt="pretty"))
        print()

        print("Information about adopters who have scheduled visits, including the adopter’s name, the animal they are visiting, and the scheduled visit time.")
        cursor.execute("""
            SELECT 
                p.first_name AS Adopter_First_Name,
                p.last_name AS Adopter_Last_Name,
                a.name AS Animal_Name,
                a.species AS Animal_Species,
                sv.time AS Scheduled_Time,
                sv.grace_period AS Grace_Period
            FROM 
                Adopter ad
            JOIN 
                Person p ON ad.person_id = p.person_id
            JOIN 
                Scheduled_Visits sv ON p.person_id = sv.person_id
            JOIN 
                Animal a ON sv.animal_id = a.animal_id
            ORDER BY 
                sv.time ASC;
               """)
        adopters = cursor.fetchall()
        headers = [i[0] for i in cursor.description]
        print(tabulate(adopters, headers, tablefmt="pretty"))
        print()

        print("Calculates the total amount donated by each donor based on the Ledger table, providing a summary of donations per donor.")
        cursor.execute("""
            SELECT 
                p.first_name AS Donor_First_Name,
                p.last_name AS Donor_Last_Name,
                COUNT(l.ledger_id) AS Number_of_Donations,
                SUM(l.change_balance) AS Total_Donated
            FROM 
                Donor d
            JOIN 
                Person p ON d.person_id = p.person_id
            JOIN 
                Ledger l ON d.person_id = l.person_id
            GROUP BY 
                d.person_id, p.first_name, p.last_name
            ORDER BY 
                Total_Donated DESC;
               """)
        donations = cursor.fetchall()
        headers = [i[0] for i in cursor.description]
        print(tabulate(donations, headers, tablefmt="pretty"))
        print()

        print("Provides a summary of each inventory item’s usage based on transactions, along with the current stock level.")
        cursor.execute("""
            SELECT 
                i.product_id,
                i.product_name,
                i.current_amount,
                IFNULL(SUM(it.transaction_amount), 0) AS Total_Used,
                (i.current_amount + IFNULL(SUM(it.transaction_amount), 0)) AS Total_Supplied
            FROM 
                Inventory i
            LEFT JOIN 
                Inventory_Transactions it ON i.product_id = it.product_id
            GROUP BY 
                i.product_id, i.product_name, i.current_amount
            ORDER BY 
                Total_Used DESC;
               """)
        inventory = cursor.fetchall()
        headers = [i[0] for i in cursor.description]
        print(tabulate(inventory, headers, tablefmt="pretty"))
        print()

        # Close connections
        cursor.close()
        cnx.close()

    except mysql.connector.Error as err:
        print(f"Error: {err}")

if __name__ == '__main__':
    main()