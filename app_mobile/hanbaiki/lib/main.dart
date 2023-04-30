import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // ------------ Container do email, senha e "Nao tem Loguin cadastre-se"
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
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
                        color:
                            Colors.white, // set the color of the label to white
                      ),
                      border: InputBorder.none,
                      // Da pra colocar uns frurus aqui
                    ),
                    onSaved: (String? value) {
                      _email = value;
                    },
                    validator: (String? value) {
                      return (value != null && value.contains('@'))
                          ? 'Do not use the @ char.'
                          : null;
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
                        color:
                            Colors.white, // set the color of the label to white
                      ),
                      border: InputBorder.none,
                    ),
                    obscureText: true,
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return 'Please enter your password';
                    //   } else if (value.length < 8) {
                    //     return 'Password must be at least 8 characters long';
                    //   }
                    //   return null;
                    // },
                    validator: (String? value) {
                      return (value != null && value.contains('@'))
                          ? 'Do not use the @ char.'
                          : null;
                    },
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
                      print('Email: $_email');
                      print('Password: $_password');
                      // TODO: Implement login logic here
                    }
                  },
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // navigate to another page
                  },
                  child: Text(
                    'NÃO TEM LOGUIN? CADASTRE-SE',
                    style: TextStyle(
                      color: Colors
                          .pink[200], // set the color of the text to light pink
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
