import mysql.connector
from dotenv import load_dotenv
import os
load_dotenv()

password = os.getenv("database_password")
mydb = mysql.connector.connect(
    host="localhost",
    user="root",
    password=password,
    database="inventory"
)
#interact with the database using mydb
mycursor = mydb.cursor()
mycursor.execute("SELECT * FROM City")

for x in mycursor:
    print(x)

mydb.close()