# Como instalar o flask

Se ja tiver o pipenv instalado, só venha nessa pasta e digite ```pipenv shell``` que carregará todas as bibliotecas necessárias para rodar o projeto
Se não tiver, de uma olhada nos aquivos Pipfile para ver quais bibliotecas serão necessárias e quais versões foram utilizadas para rodar.

## Para rodar localmente

Simplesmente ```flask --app nomeDoScriptPythonFlask run```

## Para rodar em um servidor

```flask --app main run --host=0.0.0.0 --port=8080```

# Para fazer o request em um navegador

- Como a api ta rodando em uma instancia do EC2 da AWS, por enquanto precisa deixar o cli vivo (preciso ver como fazer pra manter a aplicacao viva mesmo saindo do cli mas sem terminar o ec2)

- Faz a chamada do ipv4 publico, com o metodo http, e especifica a porta e a rota, por exemplo

```http://18.230.195.136:8080/getDataProdutos```

# Variaveis de ambiente

Para não ficar mostrando os dados publicamente, estou usando variáveis de ambiente para os dados de acesso. Estão localizados no meu .bashrc


## Links que usei para configurar o rds da aws

- Para deixar o banco de dados disponível para todos (n recomendavel pq todo mundo pode acessar, mas vai precisar dos dados de acesso :v)
https://stackoverflow.com/questions/31867896/aws-rds-public-access