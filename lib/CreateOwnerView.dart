import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mlewis_fantasy_basketball/LoginView.dart';
import 'package:mlewis_fantasy_basketball/Utils.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

final Icon bballIcon = new Icon(
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

  List<LeagueListItem> leagues = [];//List<LeagueListItem>.generate(1, (index) => LeagueDataItem("Matthew's League for Hoopers", 'Commissioner: Matthew Barton', tempIcon));
  bool _gotLeagues = false;

  final _formKey = GlobalKey<FormState>();

  int _itemCount = 0;
  var jsonResponse;
  String _query = "leaguelist";

  Future<void> getLeagues() async {
    String url = "http://127.0.0.1:5000/" + _query;
    http.Response response = await http.get(url);
    if (response.statusCode == 200 || response.statusCode == 302) {
      setState(() {
        jsonResponse = convert.jsonDecode(response.body);
        //debugPrint(jsonResponse[1].toString());
        _itemCount = jsonResponse.length;
        for (var league in jsonResponse) {
          leagues.add(LeagueDataItem.fromJson(league));
        }
      });
      debugPrint("Number of leagues found : $_itemCount");
    } else {
      debugPrint("Request failed with status: ${response.statusCode}.");
    }
  }


  final usernameController = TextEditingController();
  final password1Controller = TextEditingController();
  final password2Controller = TextEditingController();
  final teamNameController = TextEditingController();


  @override
  void dispose() {
    usernameController.dispose();
    password1Controller.dispose();
    password2Controller.dispose();
    teamNameController.dispose();
    super.dispose();
  }

  void createAccount(String username, String password, String teamName, int leagueId) async {
    final http.Response response = await http.post(
      'http://127.0.0.1:5000/owner/create',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
        'team_name': teamName,
        'league_id': leagueId.toString(),
      }));
    if (response.statusCode == 201 || response.statusCode == 200) {
      print("Account successfully created");
    } else {
    throw Exception('Failed to create account');
    }
  }

  int leagueId;

  @override
  Widget build(BuildContext context) {
    if(!_gotLeagues) {
      getLeagues();
      _gotLeagues = true;
    }
    String us = "";
    String pw = "";
    String tn = "";
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
                helperText: 'WARNING: Do not use password you use somewhere else! As an app built for a databases class, we cannot guarantee optimal security.',
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
            // New Team Name Field.
            TextFormField(
                controller: teamNameController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.people),
                  labelText: 'New Team Name',
                  filled: true,
                ),
                validator: (value) {
                  if(value.isEmpty) {
                    return 'Please enter a team name';
                  }
                  return null;
                },
                onSaved: (String value) {
                  tn = value;
                }
            ),
            Container(
                padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Text('Select what league you would like to join'),
            ),
            // Possible Leagues to join
            Container(
              // TODO: adjust height according to size of screen
              height: leagues.length * 80.0,
              child:ListView.builder(
                  itemCount: leagues.length,
                  itemBuilder: (context, index) {
                    final league = leagues[index];
                    return Card(
                        child: RadioListTile(
                          secondary: bballIcon,
                          title: league.buildName(context),
                          subtitle: league.buildData(context),
                          value: league.getID(),
                          groupValue: leagueId,
                          onChanged: (int value) {
                            setState(() {
                              leagueId = value;
                            });
                          },
                        )
                    );
                  }),
            ),
            ElevatedButton(onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                createAccount(us, pw, tn, leagueId);
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
  int getID();
}

class LeagueDataItem implements LeagueListItem {
  const LeagueDataItem({
    this.name,
    this.commissioner,
    this.id,
  });

  final int id;
  final String name;
  final String commissioner;

  factory LeagueDataItem.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw FormatException("Null JSON provided to LeagueDataItem");
    }
    return LeagueDataItem(
      name: json['league_name'],
      commissioner: json['cname'],
      id: json['league_id'],
    );
  }

  Widget buildData(BuildContext buildContext) {
    return Text("Commissioner: " + this.commissioner.toString());
  }

  Widget buildName(BuildContext buildContext) {
    return Text(this.name);
  }
  int getID() {return id;}
}