import 'package:flutter/material.dart';
import 'package:mlewis_fantasy_basketball/AllPlayersListView.dart';
import 'package:mlewis_fantasy_basketball/CreateOwnerView.dart';
import 'package:mlewis_fantasy_basketball/Utils.dart';

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

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
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
                ),
                // Password Field
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: 'Password',
                    helperText: 'WARNING: Do not use password you use somewhere else! As an app built for a databases class, we cannot guarantee optimal security.',
                    filled: true,
                  ),
                  validator: (value) {
                    if (!validPassword(value)) {
                      return 'Please enter a valid password';
                    }
                    return null;
                  },
                ),
                ButtonTheme(
                  minWidth: 250,
                  height: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate returns true if the form is valid, otherwise false.
                      if (_formKey.currentState.validate()) {
                        // If the form is valid, display a snackbar. In the real world
                        // you'd often call a server or save the information in a database.
                        Scaffold.of(context).showSnackBar(SnackBar(content: Text('Logging in...')));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AllPlayersListView()),
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
