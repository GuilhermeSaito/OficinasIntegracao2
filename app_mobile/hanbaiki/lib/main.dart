import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
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

// ---------------------------------- FUNCAO PARA DAR REFRESH NA PROPRIA PAGINA ( -------- PRECISA TESTAR ESSA FUNCAO -------- )
void reloadPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (BuildContext context) => MyCurrentClass()),
  );

  // Como chamar a funcao na classe
//   ElevatedButton(
//   onPressed: () {
//     reloadPage(context);
//   },
//   child: Text('Reload'),
// ),

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
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

  String? _email;
  String? _password;

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
                            color: Colors
                                .white, // set the color of the label to white
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
                          validateLoginApi(_email, _password, context);
                        }
                      },
                    ),
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

// ----------------------- Pag Principal
class MainPage extends StatefulWidget {   // ----------------------- SE PARAR DE FUNCIONAR, EH POR CAUSA DESSA MUDANCA
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Main Page'),
      ),
      body: Center(
        child: Text('Main Page Content'),
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
                // Handle option 2 press
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
    );
  }
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



// ------------------------------- Exemplo de como daria pra fazer o MainPage na visao do cliente

// class MyContainerScreen extends StatefulWidget {
//   @override
//   _MyContainerScreenState createState() => _MyContainerScreenState();
// }

// class _MyContainerScreenState extends State<MyContainerScreen> {
//   List<dynamic> jsonData = [];
//   List<int> buttonPresses = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }

//   void fetchData() async {
//     final data = await fetchJsonData();
//     setState(() {
//       jsonData = data;
//       buttonPresses = List<int>.filled(data.length, 0);
//     });
//   }

//   Future<List<dynamic>> fetchJsonData() async {
//     final response = await http.get(Uri.parse('your_api_endpoint_here'));
//     if (response.statusCode == 200) {
//       final jsonData = json.decode(response.body);
//       return jsonData;
//     } else {
//       throw Exception('Failed to fetch JSON data');
//     }
//   }

//   void onButton1Pressed(int index) {
//     setState(() {
//       buttonPresses[index]++;
//     });
//     print('Button 1 pressed in container $index');
//   }

//   void onButton2Pressed(int index) {
//     setState(() {
//       buttonPresses[index]--;
//     });
//     print('Button 2 pressed in container $index');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Dynamic Containers'),
//       ),
//       body: ListView.builder(
//         itemCount: jsonData.length,
//         itemBuilder: (context, index) {
//           final item = jsonData[index];
//           final buttonPress = buttonPresses[index];
//           return Container(
//             padding: EdgeInsets.all(16.0),
//             margin: EdgeInsets.all(8.0),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(8.0),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Name: ${item['name']}',
//                   style: TextStyle(fontSize: 18.0),
//                 ),
//                 SizedBox(height: 8.0),
//                 Text(
//                   'Quantity: ${item['quantity']}',
//                   style: TextStyle(fontSize: 16.0),
//                 ),
//                 SizedBox(height: 16.0),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {
//                         onButton1Pressed(index);
//                       },
//                       child: Text('Button 1'),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         onButton2Pressed(index);
//                       },
//                       child: Text('Button 2'),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 8.0),
//                 Text(
//                   'Button Presses: $buttonPress',
//                   style: TextStyle(fontSize: 16.0),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     home: MyContainerScreen(),
//   ));
// }