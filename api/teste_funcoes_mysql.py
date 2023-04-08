import mysql.connector
from mysql.connector import errorcode
import os

user = os.environ["AWS_MYSQL_USR"]
password = os.environ["AWS_MYSQL_PWD"]
host = os.environ["AWS_MYSQL_END_POINT"]
port = os.environ["AWS_MYSQL_PORT"]
db_name = os.environ["AWS_MYSQL_DB_NAME"]

try:
    cnx = mysql.connector.connect(user = user,
                                password = password,
                                host = host,
                                port = port,
                                database = db_name)
except mysql.connector.Error as err:
    if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
        print("Something is wrong with your user name or password")
    elif err.errno == errorcode.ER_BAD_DB_ERROR:
        print("Database does not exist")
    else:
        print(err)

cursor = cnx.cursor(buffered = True)

# Como eu coloquei o id como "AUTO INCREMENT", n precisa passar ele como valor
def insert_db(cursor, cnx, data):
    query = ("INSERT INTO produtos"
             "(nome, quantidade)"
             "VALUES (%s, %s)")
    
    cursor.execute(query, data)
    cnx.commit()

# O select retorna os valores no cursor, acredito q soh precisa colocar um to json q da bom :v
def select_db(cursor):
    query = ("SELECT * FROM produtos")

    cursor.execute(query)
    
    return cursor

insert_db(cursor, cnx, ("Hello Another World", 50))

result = select_db(cursor)

print(type(result))
for r in result:
    print(r)

# Fecha a conexão e o cursor
cursor.close()
# conn.close()
cnx.close()