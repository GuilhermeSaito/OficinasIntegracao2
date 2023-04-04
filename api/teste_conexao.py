import mysql.connector
import os

user = os.environ["AWS_MYSQL_USR"]
password = os.environ["AWS_MYSQL_PWD"]
host = os.environ["AWS_MYSQL_END_POINT"]
port = os.environ["AWS_MYSQL_PORT"]
db_name = os.environ["AWS_MYSQL_DB_NAME"]

# Configure as credenciais de acesso ao banco de dados
# config = {
#     "user": user,
#     "password": password,
#     "host": host,
#     "port": port,
#     "database": db_name
# }

cnx = mysql.connector.connect(user = user,
                              password = password,
                              host = host,
                              port = port,
                              database = db_name)

cursor = cnx.cursor(buffered = True)

# Cria a conexão com o banco de dados
# conn = mysql.connector.connect(**config)onfig = {
#     "user": user,
#     "password": password,
#     "host": host,
#     "port": port,
#     "database": db_name
# }

# Cria um cursor para executar comandos SQL
# cursor = conn.cursor()

# Define o comando SQL para criar a tabela
table_name = 'produtos'
# create_table_query = f"""
#     CREATE TABLE {table_name} (
#         id INT NOT NULL AUTO_INCREMENT,
#         nome VARCHAR(50) NOT NULL,
#         quantidade INT NOT NULL,
#         PRIMARY KEY (id)
#     );
# """

create_table_query = f"""
    SELECT * FROM {table_name};
"""

# create_table_query = f"""
#     INSERT INTO {table_name} (id, nome, quantidade)
#     VALUES (1, "teste", 10);
# """

try:
    # Executa o comando SQL
    cursor.execute(create_table_query)
except ValueError as err:
    print(err)

# Salva as alterações no banco de dados
# conn.commit()

# Fecha a conexão e o cursor
cursor.close()
# conn.close()
cnx.close()

print("rodo?")