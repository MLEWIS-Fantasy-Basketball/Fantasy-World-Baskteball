import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mlewis_fantasy_basketball/LoginView.dart';
import 'package:mlewis_fantasy_basketball/Utils.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:http/http.dart' as http;

final Icon tempIcon = new Icon(
  Icons.sports_basketball,
  color: Colors.blue,
  size: 36.0,
);

class CreateOwnerView extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    final String viewTitle = 'Owner Creation';
    return Scaffold(
      appBar: AppBar(
        title: Text(viewTitle)
      ),
      body: OwnerCreationForm(),
    );
  }
}

class OwnerCreationForm extends StatefulWidget {
  @override
  _OwnerCreationState createState() => _OwnerCreationState();
}

class _OwnerCreationState extends State<OwnerCreationForm> {

  List<LeagueListItem> leagues = List<LeagueListItem>.generate(1, (index) => LeagueDataItem("Matthew's League for Hoopers", 'Commissioner: Matthew Barton', tempIcon));

  final _formKey = GlobalKey<FormState>();


  final usernameController = TextEditingController();
  final password1Controller = TextEditingController();
  final password2Controller = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    password1Controller.dispose();
    password2Controller.dispose();
    super.dispose();
  }

  void createAccount(String username, String password) async {
    final http.Response response = await http.post(
      'http://127.0.0.1:5000/owner/create',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }));
    if (response.statusCode == 201 || response.statusCode == 200) {
      print("Account successfully created");
    } else {
    throw Exception('Failed to create account');
    }
  }


  @override
  Widget build(BuildContext context) {
    String us = "";
    String pw = "";
    return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            // New Username Field.
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(
                icon: Icon(Icons.person_add_outlined),
                labelText: 'New Username',
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
              }
            ),
            // New Password Field.
            TextFormField(
              controller: password1Controller,
              obscureText: true,
              decoration: const InputDecoration(
                icon: Icon(Icons.person_add),
                labelText: 'New Password',
                filled: true,
              ),
              validator: (value) {
                if (!validPassword(value)) {
                  return 'Please enter a valid password';
                }
                return null;
              },
            ),
            // Confirm Password Field.
            TextFormField(
              controller: password2Controller,
              obscureText: true,
              decoration: const InputDecoration(
                icon: Icon(Icons.done),
                labelText: 'Confirm Password',
                filled: true,
              ),
              validator: (value) {
                if (!validPassword(value) || password1Controller.text != password2Controller.text) {
                  return 'Please make sure your passwords match';
                }
                return null;
              },
              onSaved: (String value) {
                pw = value;
              }
            ),
            Text('Select what leagues you would like to join'),
            // Possible Leagues to join
            Container(
              // TODO: adjust height according to size of screen
              height: leagues.length * 80.0,
              child:ListView.builder(
                  itemCount: leagues.length,
                  itemBuilder: (context, index) {
                    final league = leagues[index];
                    return Card(
                        child: CheckboxListTile(
                          secondary: league.buildLogo(context),
                          title: league.buildName(context),
                          subtitle: league.buildData(context),
                          value: timeDilation != 1.0,
                          onChanged: (bool value) {
                            setState(() {
                              timeDilation = value ? 2.0 : 1.0;
                            });
                          },
                        )
                    );
                  }),
            ),
            ElevatedButton(onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                createAccount(us, pw);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginView()),
                );
              }
            }, child: Text('Create Account')
            )
          ],
        )
    );
  }
}

abstract class LeagueListItem {
  Widget buildName(BuildContext buildContext);
  Widget buildData(BuildContext buildContext);
  Widget buildLogo(BuildContext buildContext);
}

class LeagueDataItem implements LeagueListItem {

  final String name;
  final Icon logo;
  final String commissioner;

  LeagueDataItem(this.name, this.commissioner, this.logo);

  Widget buildData(BuildContext buildContext) {
    return Text(commissioner);
  }

  @override
  Widget buildLogo(BuildContext buildContext) {
    return logo;
  }

  @override
  Widget buildName(BuildContext buildContext) {
    return Text(name);
  }

}