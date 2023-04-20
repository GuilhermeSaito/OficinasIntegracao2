import mysql.connector
from mysql.connector import errorcode
import os
import json
import configparser

def connect_db():
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

    return cnx

cnx = connect_db()
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
    
    list_tuple = cursor.fetchall()

    list_dict = []
    for tuple in list_tuple:
        # Da para fazer assim no dic pq as colunas da tabela n mudam, mas se mudar vai ter q mudar aqui tbm
        dict = {
            "id": tuple[0],
            "nome": tuple[1],
            "quantidade": tuple[2]
        }
        list_dict.append(dict)
    
    return json.dumps(list_dict, indent = 4)

# insert_db(cursor, cnx, ("Hello Another World", 50))

# data = select_db(cursor = cursor)

config = configparser.ConfigParser()
config.read("config.cfg")

print(config["db_access"]["AWS_MYSQL_USR"])
print(config["db_access"]["AWS_MYSQL_PWD"])
print(config["db_access"]["AWS_MYSQL_END_POINT"])
print(config["db_access"]["AWS_MYSQL_PORT"])
print(config["db_access"]["AWS_MYSQL_DB_NAME"])

# Fecha a conexão e o cursor
cursor.close()
# conn.close()
cnx.close()












# 1 - Create the requirements for python librarys