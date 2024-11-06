import os
import mysql.connector
from mysql.connector import errorcode

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
        databases = cursor.fetchall()
        
        cursor.execute("SELECT * FROM Person")
        persons = cursor.fetchall()
        for person in persons:
            print(person)
        for db in databases:
            print(db[0])

        # Close connections
        cursor.close()
        cnx.close()

    except mysql.connector.Error as err:
        print(f"Error: {err}")

if __name__ == '__main__':
    main()