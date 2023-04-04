# Como instalar o flask

Se ja tiver o pipenv instalado, só venha nessa pasta e digite ```pipenv shell``` que carregará todas as bibliotecas necessárias para rodar o projeto
Se não tiver, de uma olhada nos aquivos Pipfile para ver quais bibliotecas serão necessárias e quais versões foram utilizadas para rodar.

## Para rodar localmente

Simplesmente ```flask --app nomeDoAppQQuerDar run```

# Variaveis de ambiente

Para não ficar mostrando os dados publicamente, estou usando variáveis de ambiente para os dados de acesso. Estão localizados no meu .bashrc


## Links que usei para configurar o rds da aws

- Para deixar o banco de dados disponível para todos (n recomendavel pq todo mundo pode acessar, mas vai precisar dos dados de acesso :v)
https://stackoverflow.com/questions/31867896/aws-rds-public-access