import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mlewis_fantasy_basketball/Utils.dart';
import 'LoginView.dart';

class CreateLeagueView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String viewTitle = 'League Creation';
    return Scaffold(
      appBar: AppBar(
          title: Text(viewTitle)
      ),
      body: LeagueCreationForm(),
    );
  }
}

class LeagueCreationForm extends StatefulWidget {
  @override
  _LeagueCreationState createState() => _LeagueCreationState();
}


class _LeagueCreationState extends State<LeagueCreationForm> {

  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final password1Controller = TextEditingController();
  final password2Controller = TextEditingController();
  final leagueNameController = TextEditingController();
  final teamNameController = TextEditingController();

  int numTeams;


  @override
  void dispose() {
    usernameController.dispose();
    password1Controller.dispose();
    password2Controller.dispose();
    leagueNameController.dispose();
    teamNameController.dispose();
    super.dispose();
  }

  void createLeague(String username, String password, String teamName, String leagueName, int numTeams) async {
    final http.Response response = await http.post(
        'http://127.0.0.1:5000/league/create',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
          'team_name': teamName,
          'league_name': leagueName,
          'number_of_teams': numTeams.toString(),
        }));
    if (response.statusCode == 201 || response.statusCode == 200) {
      print("League successfully created");
    } else {
      throw Exception('Failed to create league');
    }
  }

  @override
  Widget build(BuildContext context) {
    String us = "";
    String pw = "";
    String tn = "";
    String ln = "";
    return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            // New League Name
            TextFormField(
                controller: leagueNameController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.business),
                  labelText: 'New League Name',
                  filled: true,
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a league name';
                  }
                  return null;
                },
                onSaved: (String value) {
                  ln = value;
                }
            ),
            // Number of Teams buttons
            RadioListTile<int>(
              title: const Text('4 Teams'),
              value: 4,
              groupValue: numTeams,
              onChanged: (int value) {
                setState(() {
                  numTeams = value;
                });
              },
            ),
            RadioListTile<int>(
              title: const Text('6 Teams'),
              value: 6,
              groupValue: numTeams,
              onChanged: (int value) {
                setState(() {
                  numTeams = value;
                });
              },
            ),
            RadioListTile<int>(
              title: const Text('8 Teams'),
              value: 8,
              groupValue: numTeams,
              onChanged: (int value) {
                setState(() {
                  numTeams = value;
                });
              },
            ),
            RadioListTile<int>(
              title: const Text('10 Teams'),
              value: 10,
              groupValue: numTeams,
              onChanged: (int value) {
                setState(() {
                  numTeams = value;
                });
              },
            ),
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
            ElevatedButton(onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                createLeague(us, pw, tn, ln, numTeams);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginView()),
                );
              }
            }, child: Text('Create League')
            )
          ],
        )
    );
  }

}