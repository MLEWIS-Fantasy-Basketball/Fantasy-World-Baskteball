import 'package:flutter/material.dart';
import 'package:mlewis_fantasy_basketball/AllPlayersListView.dart';
import 'package:mlewis_fantasy_basketball/CreateOwnerView.dart';
import 'package:mlewis_fantasy_basketball/CreateLeagueView.dart';
import 'package:mlewis_fantasy_basketball/Utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert' as convert;



void main() {
  runApp(LoginView());
}

class LoginView extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final String appTitle = 'MLEWIS Fantasy World Basketball';
    return MaterialApp(
      title: appTitle,
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
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
        home: Scaffold(
          appBar: AppBar(
            title: Text(appTitle),
          ),
          body: LoginForm(),
        ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {

  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  var jsonResponse;

  Future<bool> login(String username, String password) async {
    final http.Response response = await http.post(
        'http://127.0.0.1:5000/owner/login',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }));
    if (response.statusCode == 201 || response.statusCode == 200) {
      print("Login info sent");
      var json = convert.jsonDecode(response.body);
      debugPrint(json.toString());
      return json['success'];
    } else {
      return false;
      //throw Exception('Failed to send login info');
    }
  }


  @override
  Widget build(BuildContext context) {
    String us = "";
    String pw = "";
    return Container(
        margin: EdgeInsets.all(24),
        padding: EdgeInsets.only(top: 200),
        child: Form(
          key: _formKey,
          child: Column(
              children: <Widget>[
                // Username Field.
                TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person_outline),
                      labelText: 'Username',
                      filled: true,
                    ),
                    validator: (value) {
                      if (!validUsername(value)) {
                        return 'Please enter a valid username';
                      }
                      return null;
                    },
                    onSaved: (String value) {
                      us = value;
                    },
                ),
                // Password Field
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: 'Password',
                    filled: true,
                  ),
                  validator: (value) {
                    if (!validPassword(value)) {
                      return 'Please enter a valid password';
                    }
                    return null;
                  },
                  onSaved: (String value) {
                    pw = value;
                  },
                ),
                ButtonTheme(
                  minWidth: 250,
                  height: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        Scaffold.of(context).showSnackBar(SnackBar(content: Text('Logging in...')));
                        login(us,pw).then((value) => {
                          if(value) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AllPlayersListView()),
                            )
                          } else {
                            Scaffold.of(context).showSnackBar(SnackBar(content: Text('Login failed!')))
                          }
                          }
                        );
                      }
                    },
                    child: Text('Login'),
                  ),
                ),
                ButtonTheme(
                    minWidth: 250,
                    height: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CreateLeagueView()),
                        );
                      },
                      child: Text('Become a Commissioner'),
                    )
                ),
                ButtonTheme(
                    minWidth: 250,
                    height: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreateOwnerView()),
                      );
                    },
                    child: Text('Become an Owner'),
                  )
                ),
              ]
          )
      )
    );
  }
}
