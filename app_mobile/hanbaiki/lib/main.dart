import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import 'package:web_socket_channel/io.dart';

// ---------------------- PRECISA MUDAR DO LOCALHOST PARA O SERVIDOR!!!!

// Conta como Vendedor
// Teste
// Teste

// Conta como NAO Vendedor
// no
// no

void main() {
  runApp(const MyApp());
}

// Variaveis globais para ficar mais facil o acesso dos dados
class GlobalVariable {
  static final GlobalVariable _instance = GlobalVariable._internal();

  factory GlobalVariable() {
    return _instance;
  }

  GlobalVariable._internal();

  String? _email;
  String? _password;
  int? _vendedor;
  int? _quadranteSelecionado;

  List<String>? nomesCliente;
  List<String>? emailsCliente;
  List<String>? nomesProduto;
  List<int>? quantidadesProdutos;
  List<int>? quadrantesProdutos;
  List<String>? senhasCliente;

  List<int>? _quadrantes_disponiveis;
}

Future<void> callESPToWork(Map<String, dynamic> jsonData) async {
  final channel = IOWebSocketChannel.connect('ws://192.168.0.101:81');

  channel.sink.add(jsonData.toString());

  channel.sink.close();
}

// ---------------------------------- FUNCAO PARA VALIDAR O LOGIN
Future<void> validateLoginApi(
    String? email, String? password, BuildContext context) async {
  var apiUrl = 'https://hanbaiki-api.herokuapp.com/validateLogin';
  var parameters = {
    'email': email,
    'password': password,
  };

  var uri = Uri.parse(apiUrl).replace(queryParameters: parameters);

  try {
    var response = await http.get(uri);

    var responseData = jsonDecode(response.body);

    if (responseData == null || responseData.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erro na validação do login'),
          content: Text("Resposta vazia da API"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      Map<String, dynamic> data_json = responseData[0];

      GlobalVariable()._vendedor = data_json['vendedor'] as int;

      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(seconds: 1),
          pageBuilder: (_, __, ___) => MainPage(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    }
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erro na validação do login'),
        content: Text(e.toString()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Funcao para mostrar todos os produtos na pagina do cliente
Future<void> getProdutosQuadrante(BuildContext context) async {
  var apiUrl = 'https://hanbaiki-api.herokuapp.com/getProdutosQuadrante';

  var uri = Uri.parse(apiUrl);

  try {
    var response = await http.get(uri);

    var responseData = jsonDecode(response.body);

    if (responseData == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Problema na hora de mostrar os produtos disponiveis!'),
          content: Text(
              "Alguma coisa está errada meu amigo... Me contate o mais rápido possível"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      GlobalVariable().nomesCliente =
          responseData.map<String>((map) => map['nome'] as String).toList();
      GlobalVariable().emailsCliente =
          responseData.map<String>((map) => map['email'] as String).toList();
      GlobalVariable().nomesProduto = responseData
          .map<String>((map) => map['nome_produto'] as String)
          .toList();
      GlobalVariable().quantidadesProdutos = responseData
          .map<int>((map) => map['quantidade_produto'] as int)
          .toList();
      GlobalVariable().quadrantesProdutos = responseData
          .map<int>((map) => map['quadrante_produto'] as int)
          .toList();
      GlobalVariable().senhasCliente =
          responseData.map<String>((map) => map['password'] as String).toList();
    }
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erro na aquisição dos dados dos produtos dos quadrantes'),
        content: Text(e.toString()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------- FUNCAO PARA PERMITIR OU NAO O CADASTRO DE ITENS
Future<bool> canInsertProduct(BuildContext context) async {
  var apiUrl = 'https://hanbaiki-api.herokuapp.com/canInsertProduct';

  var uri = Uri.parse(apiUrl);

  try {
    var response = await http.get(uri);

    var responseData = jsonDecode(response.body);

    if (responseData == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Máquina zuada!'),
          content: Text(
              "Alguma coisa está errada meu amigo... Me contate o mais rápido possível"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // GlobalVariable()._quadrantes_disponiveis =
      //     responseData.map<int>((map) => map['quadrante'] as int).toList();

      List<int> quadrantes_ocupados =
          responseData.map<int>((map) => map['quadrante'] as int).toList();
      List<String?>? email_ocupando =
          responseData.map<String>((map) => map['email'] as String).toList();
      List<String?>? password_ocupando =
          responseData.map<String>((map) => map['password'] as String).toList();

      bool emailThere =
          email_ocupando?.contains(GlobalVariable()._email) ?? false;
      bool passwordThere =
          password_ocupando?.contains(GlobalVariable()._password) ?? false;

      if (emailThere == true && passwordThere) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Você não pode colocar seus doces!!'),
            content: Text(
                'Calma lá amigão, não seja ganancioso, ainda tem doces seus na máquina!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          ),
        );

        return false;
      }

      if (quadrantes_ocupados.length >= 4) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Infelizmente a máquina está cheia'),
            content: Text(
                'Aguarde algum coleguinha conseguir vender todos os doces para liberar a máquina'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          ),
        );

        return false;
      }

      List<int> quadrantesDisponiveis = [];

      if (!quadrantes_ocupados.contains(1)) {
        quadrantesDisponiveis.add(1);
      }
      if (!quadrantes_ocupados.contains(2)) {
        quadrantesDisponiveis.add(2);
      }
      if (!quadrantes_ocupados.contains(3)) {
        quadrantesDisponiveis.add(3);
      }
      if (!quadrantes_ocupados.contains(4)) {
        quadrantesDisponiveis.add(4);
      }

      GlobalVariable()._quadrantes_disponiveis = quadrantesDisponiveis;

      return true;
    }
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erro na verificação dos quadrantes disponíveis'),
        content: Text(e.toString()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  return false;
}

Future<void> comprarProduto(
    List<int> quantidadeProdutoComprado, BuildContext context) async {
  List<int>? resultado_quantidade = List.generate(
      GlobalVariable().quantidadesProdutos?.length ?? 0,
      (index) =>
          (GlobalVariable().quantidadesProdutos?[index] ?? 0) -
          quantidadeProdutoComprado[index]);

  // Atualiza o quadrante para 0 caso n tenha nenhum produto
  for (int i = 0; i < resultado_quantidade.length; i++) {
    if (resultado_quantidade[i] == 0) {
      GlobalVariable().quadrantesProdutos?[i] = 0;
    }
  }

  Map<String, dynamic> data = {
    'email_app': GlobalVariable().emailsCliente,
    'password_app': GlobalVariable().senhasCliente,
    'nome_produtos_app': GlobalVariable().nomesProduto,
    'quantidade_produtos_app': resultado_quantidade,
    'quadrante_produtos_app': GlobalVariable().quadrantesProdutos
  };

  var apiUrl = 'https://hanbaiki-api.herokuapp.com/updateProduct';

  var uri = Uri.parse(apiUrl);

  try {
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Parabéns, você conseguiu comprar um doce!'),
          content: Text(
              'Agora espere a máquina funcionar para você adquirir seu doce'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ow no, tem um erro na API'),
          content: Text(response.statusCode.toString() + response.body),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Aconteceu alguma coisa de ruim... Me avise!!'),
        content: Text(e.toString()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------- FUNCAO PARA CADASTRAR UM NOVO PRODUTO
Future<void> cadastrarProduto(
  String? nomeProduto,
  String? quantidadeProduto,
  int? quadranteProduto,
  BuildContext context,
  Function(bool) dialogCallback,
) async {
  // Atualiza o quadrante para 0 caso n tenha nenhum produto
  if (quantidadeProduto == '0') {
    quadranteProduto = 0;
  }

  Map<String, dynamic> data = {
    'email_app': GlobalVariable()._email,
    'password_app': GlobalVariable()._password,
    'nome_produtos_app': nomeProduto,
    'quantidade_produtos_app': quantidadeProduto,
    'quadrante_produtos_app': quadranteProduto
  };

  // var apiUrl = 'http://127.0.0.1:5000/updateProduct';
  var apiUrl = 'https://hanbaiki-api.herokuapp.com/updateProduct';

  var uri = Uri.parse(apiUrl);

  try {
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    var responseData = jsonDecode(response.body);
    print(responseData);
    if (responseData == null || responseData.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erro no cadastro do produto'),
          content: Text(
              "Erro ao cadastrar o produto, retorno null da api, tente novamente mais tarde"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Cadastro Concluido com Sucesso!'),
          content: Text(
              "Seu produto foi cadastrado com sucesso, agora só espere um desavisado cair na sua armadilha de ganhar dinheir fácil!" +
                  responseData.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erro no cadastro'),
        content: Text(e.toString()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Espera um pouco...'),
      content: Text(''),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true); // Close the dialog
          },
          child: Text('OK'),
        ),
      ],
    ),
  );

  dialogCallback(true);
}

// ---------------------------------- FUNCAO PARA CADASTRAR NOVO ACESSO
Future<void> signUp(
  String? nome,
  String? email,
  String? password,
  int? _vendedor,
  BuildContext context,
  Function(bool) dialogCallback,
) async {
  var apiUrl = 'https://hanbaiki-api.herokuapp.com/insertDataPessoa';
  var parameters = {
    'nome': nome,
    'email': email,
    'password': password,
    'vendedor': _vendedor.toString(),
  };

  var uri = Uri.parse(apiUrl).replace(queryParameters: parameters);

  final GlobalKey<State> _key = GlobalKey<State>();

  try {
    var response = await http.get(uri);

    var responseData = jsonDecode(response.body);
    if (responseData == null || responseData.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erro no cadastro'),
          content:
              Text("Erro ao cadastrar o novo usuario, retorno null da api"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Cadastro Concluido com Sucesso!'),
          content: Text(
              "Seu cadastro foi concluido com sucesso, agora podera seguir na aplicacao com o email e a senha informados, utilize o botao voltar para seguir na pagina de login." +
                  responseData.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erro no cadastro'),
        content: Text(e.toString()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Espera um pouco...'),
      content: Text(''),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true); // Close the dialog
          },
          child: Text('OK'),
        ),
      ],
    ),
  );

  dialogCallback(true);
}

Future<void> sendMailParaCliente(
    List<int> quantidadeProduto, BuildContext context) async {
  // var apiUrl = 'http://127.0.0.1:5000/sendEmail';
  var apiUrl = 'https://hanbaiki-api.herokuapp.com/sendEmail';

  String title = 'Compra efetuada por ${GlobalVariable()._email}';
  String content = 'Produtos comprados: ';

  List<int>? resultado_quantidade = List.generate(
      GlobalVariable().quantidadesProdutos?.length ?? 0,
      (index) =>
          (GlobalVariable().quantidadesProdutos?[index] ?? 0) -
          quantidadeProduto[index]);

  // Coloca todos os produtos comprados
  for (int i = 0; i < resultado_quantidade.length; i++) {
    if (resultado_quantidade[i] != GlobalVariable().quantidadesProdutos?[i]) {
      content += GlobalVariable().nomesProduto?[i] ?? '' + ' ';
    }
  }
  content += ' Com suas respectivas quantidades: ';

  for (int i = 0; i < resultado_quantidade.length; i++) {
    if (resultado_quantidade[i] != GlobalVariable().quantidadesProdutos?[i]) {
      content += quantidadeProduto[i].toString() + ' ';
    }
  }

  var parameters = {
    'email': GlobalVariable()._email,
    'title': title,
    'content': content
  };

  var uri = Uri.parse(apiUrl).replace(queryParameters: parameters);

  try {
    var response = await http.get(uri);

    var responseData = jsonDecode(response.body);
    if (responseData == null || responseData.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erro ao mandar o email'),
          content: Text(
              "Deu um erro na hora de mandar o email, é possível que o email não seja válido"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      print("Seu email foi mandado com sucesso! Viva o SPAM!!! " +
          responseData.toString());
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Email mandado com sucesso!'),
          content: Text("Seu email foi mandado com sucesso! Viva o SPAM!!! " +
              responseData.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Deu algum probleminha na hora de mandar o email'),
        content: Text(e.toString()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Espera um pouco...'),
      content: Text(''),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('OK'),
        ),
      ],
    ),
  );
}

// Future<void> sendMail(List<int> quantidadeProduto, BuildContext context) async {
//   var apiUrl = 'http://127.0.0.1:5000/sendEmail';
//   // var apiUrl = 'https://hanbaiki-api.herokuapp.com/sendEmail';

//   String title = 'Compra efetuada por ${GlobalVariable()._email}';

//   List<int>? resultado_quantidade = List.generate(
//       GlobalVariable().quantidadesProdutos?.length ?? 0,
//       (index) =>
//           (GlobalVariable().quantidadesProdutos?[index] ?? 0) -
//           quantidadeProduto[index]);

//   List<int> index = [];

//   // Verifica todos os indices indicando quais produtos foram comprados
//   for (int i = 0; i < resultado_quantidade.length; i++) {
//     if (resultado_quantidade[i] != GlobalVariable().quantidadesProdutos?[i]) {
//       index.add(i);
//     }
//   }

//   for (int i = 0; i < index.length; i++) {
//     String content = 'Produtos comprados: ';

//     content +=
//   }

//   var parameters = {'email': email, 'title': title, 'content': content};

//   var uri = Uri.parse(apiUrl).replace(queryParameters: parameters);

//   final GlobalKey<State> _key = GlobalKey<State>();

//   try {
//     var response = await http.get(uri);

//     var responseData = jsonDecode(response.body);
//     if (responseData == null || responseData.isEmpty) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Erro no cadastro'),
//           content:
//               Text("Erro ao cadastrar o novo usuario, retorno null da api"),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(true); // Close the dialog
//               },
//               child: Text('OK'),
//             ),
//           ],
//         ),
//       );
//     } else {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Cadastro Concluido com Sucesso!'),
//           content: Text(
//               "Seu cadastro foi concluido com sucesso, agora podera seguir na aplicacao com o email e a senha informados, utilize o botao voltar para seguir na pagina de login." +
//                   responseData.toString()),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(true); // Close the dialog
//               },
//               child: Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   } catch (e) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Erro no cadastro'),
//         content: Text(e.toString()),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(true); // Close the dialog
//             },
//             child: Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: Text('Espera um pouco...'),
//       content: Text(''),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop(true); // Close the dialog
//           },
//           child: Text('OK'),
//         ),
//       ],
//     ),
//   );

//   dialogCallback(true);
// }

// ---------------------------------- FUNCAO PARA DAR REFRESH NA PROPRIA PAGINA ( -------- PRECISA TESTAR ESSA FUNCAO -------- )
void reloadPage(BuildContext context) async {
  await getProdutosQuadrante(context);

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (BuildContext context) => MainPage()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hanbaiki',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              LoginPage(),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------- LOGUIN PAGE
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  // String? _email;
  // String? _password;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(0.2),
        image: const DecorationImage(
          image: AssetImage("assets/back_ground.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Opacity(
        opacity: 0.8,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Transform.translate(
                offset: Offset(0, -100),
                child: Text(
                  "HA N BA I KI",
                  style: TextStyle(
                    color: Colors.pink[100],
                    fontSize: 70,
                  ),
                ),
              ),
              // ------------ Container do email, senha e "Nao tem Loguin cadastre-se"
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.7),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(45.0),
                        color: Colors.pink[100],
                      ),
                      width: MediaQuery.of(context).size.width * 2 / 3,
                      // ---------------------- EMAIL BOX
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'E-MAIL',
                          labelStyle: TextStyle(
                            color: Colors
                                .white, // set the color of the label to white
                          ),
                          border: InputBorder.none,
                          // Da pra colocar uns frurus aqui
                        ),
                        onSaved: (String? value) {
                          GlobalVariable()._email = value;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.pink[100],
                      ),
                      width: MediaQuery.of(context).size.width * 2 / 3,
                      // ---------------------- PASSWORD BOX
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'SENHA',
                          labelStyle: TextStyle(
                            color: Colors
                                .white, // set the color of the label to white
                          ),
                          border: InputBorder.none,
                        ),
                        obscureText: true,
                        onSaved: (String? value) {
                          GlobalVariable()._password = value;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    // ---------------------- CONFIRM BUTTON
                    ElevatedButton(
                      child: const Text('Login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[100],
                      ),
                      onPressed: () {
                        final form = _formKey.currentState;
                        if (form != null) {
                          form.save();
                          validateLoginApi(GlobalVariable()._email,
                              GlobalVariable()._password, context);

                          FutureBuilder(
                              future: getProdutosQuadrante(context),
                              builder: (BuildContext context,
                                  AsyncSnapshot<void> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  // Handle any errors that occurred during the API call
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return Text('');
                                }
                              });
                        }
                      },
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    // ---------------------- CONFIRM BUTTON
                    ElevatedButton(
                      child: const Text('Mandar Dado ESP'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[100],
                      ),
                      onPressed: () {
                        final form = _formKey.currentState;
                        if (form != null) {
                          form.save();
                          var jsonData = {
                            "email": GlobalVariable()._email,
                            "password": GlobalVariable()._password
                          };
                          callESPToWork(jsonData);
                        }
                      },
                    ),
                    Text(
                        '(Paciência é uma virtude, após apertar o botão, espere alguns segundos até acontecer alguma coisa no app)'),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        // --------------- Transicao de tela para a tela de cadastro
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: Duration(seconds: 1),
                            pageBuilder: (_, __, ___) => CadastroPage(),
                            transitionsBuilder: (_, animation, __, child) =>
                                FadeTransition(
                                    opacity: animation, child: child),
                          ),
                        );
                      },
                      child: Text(
                        'NÃO TEM LOGUIN? CADASTRE-SE',
                        style: TextStyle(
                          color: Colors.pink[
                              200], // set the color of the text to light pink
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => _MainPage();
}

// ----------------------- Pag Principal
class _MainPage extends State<MainPage> {
  // ----------------------- SE PARAR DE FUNCIONAR, EH POR CAUSA DESSA MUDANCA
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<int> buttonPresses =
      List<int>.filled(GlobalVariable().quadrantesProdutos?.length ?? 0, 0);

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void onButton1Pressed(int index) {
    if ((buttonPresses[index]) <
        (GlobalVariable().quantidadesProdutos?[index] ?? 0)) {
      setState(() {
        buttonPresses[index]++;
      });
    }
  }

  void onButton2Pressed(int index) {
    if (buttonPresses[index] > 0) {
      setState(() {
        buttonPresses[index]--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Main Page'),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text(
                  'Menu',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              // Linha horizontal para separar o header com as opcoes
              Container(
                height: 1,
                color: Colors.grey,
                margin: EdgeInsets.symmetric(horizontal: 16),
              ),
              // 1 topico
              const ListTile(
                title: Text(
                  'Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
              // ------ Editar o perfil
              ListTile(
                leading: Icon(Icons.edit),
                title: Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                onTap: () {
                  // Handle option 1 press
                },
              ),
              // ------ Username
              ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  'Username',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                onTap: () {
                  // Handle option 2 press
                },
              ),
              // ------ Email
              ListTile(
                leading: Icon(Icons.email), // Add the email icon here
                title: Text(
                  'E-mail',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                onTap: () {
                  // Handle option 3 press
                },
              ),
              // ------ Senha
              ListTile(
                leading: Icon(Icons.lock),
                title: Text(
                  'Password',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                onTap: () {
                  // Handle option 3 press
                },
              ),
              // Linha horizontal para separar o header com as opcoes
              Container(
                height: 1,
                color: Colors.grey,
                margin: EdgeInsets.symmetric(horizontal: 16),
              ),
              // 2 topico
              const ListTile(
                title: Text(
                  'Menu',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
              // ------ Produtos
              ListTile(
                leading: Icon(Icons.block),
                title: Text(
                  'Produtos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                onTap: () {
                  // Handle option 1 press
                },
              ),
              // ------ Vendedores
              ListTile(
                leading: Icon(Icons.person_2),
                title: Text(
                  'Vendedores',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                onTap: () {
                  canInsertProduct(context).then((canInsertProductResponse) {
                    if (GlobalVariable()._vendedor == 1) {
                      if (canInsertProductResponse == true) {
                        print(GlobalVariable()._email);
                        print(GlobalVariable()._password);

                        // --------------- Transicao de tela para a tela de cadastro
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: Duration(seconds: 1),
                            pageBuilder: (_, __, ___) => VendedorPageCadastro(),
                            transitionsBuilder: (_, animation, __, child) =>
                                FadeTransition(
                                    opacity: animation, child: child),
                          ),
                        );
                      }
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Você não é um vendedor!'),
                          content: Text(
                              'Cadastre uma conta como vendedor para acessar essa página!'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  });
                },
              ),
              // ------ Historico
              ListTile(
                leading: Icon(Icons.history), // Add the email icon here
                title: Text(
                  'Historico',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                onTap: () {
                  // Handle option 3 press
                },
              ),
              // ------ Carrinho
              ListTile(
                leading: Icon(Icons.shopping_basket),
                title: Text(
                  'Carrinho',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                onTap: () {
                  // Handle option 3 press
                },
              ),
            ],
          ),
        ),
        // --------------- Termino dos icones da barra
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: GlobalVariable().nomesCliente?.length,
                itemBuilder: (context, index) {
                  final buttonPress = buttonPresses[index];
                  // final teste_index = index;
                  return Container(
                    padding: EdgeInsets.all(16.0),
                    margin: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name: ${GlobalVariable().nomesProduto?[index].toString()}',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Quantity: ${GlobalVariable().quantidadesProdutos?[index].toString()}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                onButton1Pressed(index);
                              },
                              child: Text('+'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                onButton2Pressed(index);
                              },
                              child: Text('-'),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Button Presses: $buttonPress',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 8.0),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await comprarProduto(buttonPresses, context);
                // --------------------------------------------------------------- AQUI Q VAI CHAMAR O ESP
                reloadPage(context);
                sendMailParaCliente(buttonPresses, context);
              },
              child: Text('COMPRAR'),
            ),
          ],
        ));
    // }
  }
  // );
  // }
}

// ----------------------- Pag de cadastro
class CadastroPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  // Nome, email, password, vendedor
  String? _nome;
  String? _email;
  String? _password;
  int? _vendedor;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: Container(
              child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20.0,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(45.0),
                color: Colors.pink[100],
              ),
              width: MediaQuery.of(context).size.width * 2 / 3,
              // ---------------------- EMAIL BOX
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'NOME',
                  labelStyle: TextStyle(
                    color: Colors.white, // set the color of the label to white
                  ),
                  border: InputBorder.none,
                  // Da pra colocar uns frurus aqui
                ),
                onSaved: (String? value) {
                  _nome = value;
                },
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(45.0),
                color: Colors.pink[100],
              ),
              width: MediaQuery.of(context).size.width * 2 / 3,
              // ---------------------- EMAIL BOX
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'E-MAIL',
                  labelStyle: TextStyle(
                    color: Colors.white, // set the color of the label to white
                  ),
                  border: InputBorder.none,
                  // Da pra colocar uns frurus aqui
                ),
                onSaved: (String? value) {
                  _email = value;
                },
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.pink[100],
              ),
              width: MediaQuery.of(context).size.width * 2 / 3,
              // ---------------------- PASSWORD BOX
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'SENHA',
                  labelStyle: TextStyle(
                    color: Colors.white, // set the color of the label to white
                  ),
                  border: InputBorder.none,
                ),
                obscureText: true,
                onSaved: (String? value) {
                  _password = value;
                },
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            SimpleDialog(
              title: const Text("Quer ser Vendedor?"),
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: () {
                    _vendedor = 1;
                  },
                  child: const Text('Yes'),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    _vendedor = 0;
                  },
                  child: const Text('No'),
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            // ---------------------- CONFIRM BUTTON
            ElevatedButton(
              child: const Text('Cadastrar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[100],
              ),
              onPressed: () {
                final form = _formKey.currentState;
                if (form != null && form.validate()) {
                  form.save();
                  signUp(_nome, _email, _password, _vendedor, context,
                      (dialogResult) {
                    if (dialogResult) {
                      // Dialog closed with OK button pressed
                      // Perform any additional logic here
                      Navigator.of(context).pop();
                    }
                  });
                }
              },
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
                '(Paciência é uma virtude, após apertar em algum dos botões, espere alguns segundos até acontecer alguma coisa no app)'),
            SizedBox(
              height: 20.0,
            ),
            ElevatedButton(
              child: const Text('Voltar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[100],
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ))),
    );
  }
}

class VendedorPageCadastro extends StatefulWidget {
  @override
  _VendedorPageCadastroState createState() => _VendedorPageCadastroState();
}

// ----------------------- Pag do Vendedor Cadastrar Item
class _VendedorPageCadastroState extends State<VendedorPageCadastro> {
  final _formKey = GlobalKey<FormState>();

  // Nome, email, password, vendedor
  String? _nomeProduto;
  String? _quantidadeProduto;
  int? _quadranteProduto;

  // Variavel para atualizar o valor da tela, soh para ajudar
  int? selectedValue = GlobalVariable()._quadrantes_disponiveis?[0];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: Container(
              child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20.0,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(45.0),
                color: Colors.pink[100],
              ),
              width: MediaQuery.of(context).size.width * 2 / 3,
              // ---------------------- EMAIL BOX
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'NOME DO PRODUTO',
                  labelStyle: TextStyle(
                    color: Colors.white, // set the color of the label to white
                  ),
                  border: InputBorder.none,
                  // Da pra colocar uns frurus aqui
                ),
                onSaved: (String? value) {
                  _nomeProduto = value;
                },
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(45.0),
                color: Colors.pink[100],
              ),
              width: MediaQuery.of(context).size.width * 2 / 3,
              // ---------------------- EMAIL BOX
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'QUANTIDADE DO PRODUTO',
                  labelStyle: TextStyle(
                    color: Colors.white, // set the color of the label to white
                  ),
                  border: InputBorder.none,
                  // Da pra colocar uns frurus aqui
                ),
                onSaved: (String? value) {
                  _quantidadeProduto = value;
                },
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.pink[100],
              ),
              width: MediaQuery.of(context).size.width * 2 / 3,
              child: DropdownButton<int>(
                value: selectedValue,
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedValue = newValue;
                      GlobalVariable()._quadranteSelecionado = selectedValue;
                    });
                  }
                },
                items: GlobalVariable()
                    ._quadrantes_disponiveis
                    ?.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('Quadrante $value'),
                  );
                }).toList(),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            // ---------------------- CONFIRM BUTTON
            ElevatedButton(
              child: const Text('Cadastrar Produto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[100],
              ),
              onPressed: () {
                final form = _formKey.currentState;
                if (form != null && form.validate()) {
                  form.save();
                  if (GlobalVariable()._quadranteSelecionado == null) {
                    GlobalVariable()._quadranteSelecionado =
                        GlobalVariable()._quadrantes_disponiveis?[0];
                  }
                  print(GlobalVariable()._quadranteSelecionado);
                  cadastrarProduto(
                      _nomeProduto,
                      _quantidadeProduto,
                      GlobalVariable()._quadranteSelecionado,
                      context, (dialogResult) {
                    if (dialogResult) {
                      // Dialog closed with OK button pressed
                      // Perform any additional logic here
                      // Navigator.of(context).pop();
                      reloadPage(context);
                    }
                  });
                }
              },
            ),
            SizedBox(
              height: 20.0,
            ),
            ElevatedButton(
              child: const Text('Voltar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[100],
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ))),
    );
  }
}
