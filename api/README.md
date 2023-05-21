# Como instalar o flask

Se ja tiver o pipenv instalado, só venha nessa pasta e digite ```pipenv shell``` que carregará todas as bibliotecas necessárias para rodar o projeto
Se não tiver, de uma olhada nos aquivos Pipfile para ver quais bibliotecas serão necessárias e quais versões foram utilizadas para rodar.

## Para rodar localmente

Simplesmente ```flask --app nomeDoScriptPythonFlask run```

## Para rodar em um servidor

```flask --app main run --host=0.0.0.0 --port=8080```

# Para fazer o request em um navegador

- A api esta hospedada no heroku, para fazer os deploys, criei outro repositorio para fazer somente os deploys para la, mas todos os codigos devem ser iguais, o link do repositorio eh esse:

```https://github.com/GuilhermeSaito/api_heroku```

- Para fazer requisicao na api:

```https://hanbaiki-api.herokuapp.com/getDataPessoa```

# Variaveis de ambiente

Para não ficar mostrando os dados publicamente, estou usando variáveis de ambiente para os dados de acesso. Estão localizados no meu .bashrc


## Links que usei para configurar o app do heroku e fazer o deploy

- Para saber o que precisa para fazer o deploy e como o script em flask deve ser

```https://levelup.gitconnected.com/how-to-deploy-a-python-flask-api-on-heroku-2e5ddfd943ef```

- Como criar o Procfile

```https://geekyhumans.com/how-to-deploy-flask-api-on-heroku/```