import 'package:flutter/material.dart';
import 'package:mlewis_fantasy_basketball/AllPlayersListView.dart';
import 'package:mlewis_fantasy_basketball/CreateOwnerView.dart';
import 'package:mlewis_fantasy_basketball/CreateLeagueView.dart';
import 'package:mlewis_fantasy_basketball/LoginView.dart';
import 'package:mlewis_fantasy_basketball/Utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert' as convert;

// View for owner's team
class MyTeamView extends StatelessWidget {

  final TeamInfo info;

  MyTeamView({@required this.info}):super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Owner: ' + info.username + ' | Team Name: ' + info.teamName + ' | League Name: ' + info.leagueName),
      ),
      body: MyTeamViewState()
    );
  }
}

class MyTeamViewState extends StatefulWidget {
  @override
  _MyTeamViewState createState() => _MyTeamViewState();
}

class _MyTeamViewState extends State<MyTeamViewState> {

  int wins = 0;
  int losses = 0;

  @override
  Widget build(BuildContext context) {
    return Container();
  }

}
