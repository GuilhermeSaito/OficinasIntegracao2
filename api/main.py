from minio import Minio
from flask import Flask, request, abort, jsonify
from werkzeug.exceptions import HTTPException
import json
import csv

import os

app = Flask(__name__)

@app.errorhandler(400)
def bad_request(e):
    print(e)
    return jsonify(error=str(e)), 400

#transforma todos os erros padrões de html para json
@app.errorhandler(HTTPException)
def handle_exception(e):
    """Return JSON instead of HTML for HTTP errors."""
    # start with the correct headers and status code from the error
    response = e.get_response()
    # replace the body with JSON
    response.data = json.dumps({
        "code": e.code,
        "name": e.name,
        "description": e.description,
    })
    response.content_type = "application/json"
    return response

@app.route("/getMinioObject")
def get_minio_object():
    bucket_download = request.args.get('bucket', 'valorPadraoSeNaoInserirNenhumDadoNaAPI')
    object_download = request.args.get('object', '')

    # Seta o access para o Minio
    client = Minio(
        endpoint =
        access_key =
        secret_key =
        secure = False
    )

    # Eh nesse bucket name passado por parametro no request em que vai procuprar o arquivo
    bucket_name = bucket_download
    file_return_name = ""

    # data_path = os.path.join(os.path.dirname(os.path.abspath(__file__)) + "/data/miniodata")

    # Verifica se o bucket com o nome passado existe
    found = client.bucket_exists(bucket_name)
    if not found:
        raise Exception("Nao existe o bucket com nome " + bucket_name)

    # Para disponibilizar os dados, ele vai baixar no diretorio local e depois disponibilizar em json
    objects = client.list_objects(bucket_name = bucket_name, recursive = True)
    for obj in objects:
        # Se o nome do objeto achado no minio for "parecido" com o inserido, baixa ele
        if object_download in obj.object_name:
            # Esse file_path eh o nome do arquivo em que sera baixado, eh baixado em .txt
            client.fget_object(bucket_name = obj.bucket_name, object_name = obj.object_name, file_path = obj.object_name)
            # Nome do arquivo em que vai retornar, teoricamente teria somente 1...
            file_return_name = obj.object_name

    # Retornando um unico arquivo do tipo csv
    # ISSO AQUI PODE MUDAR, PORQUE O ARQUIVO DO MINIO PODE JA ESTAR EM CSV OU OUTRO ARQUIVO FACIL DE SER MANDADO!!!!!!!!
    jsonString = ""
    with open(file_return_name, encoding = "latin1") as csvf:
        jsonArray = []
        csvReader = csv.DictReader(csvf)
        for row in csvReader:
            jsonArray.append(row)

        jsonString = json.dumps(jsonArray, indent = 4)

    return jsonString
