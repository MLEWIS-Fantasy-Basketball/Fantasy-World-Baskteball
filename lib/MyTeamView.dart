import 'package:flutter/material.dart';
import 'package:mlewis_fantasy_basketball/AllPlayersListView.dart';
import 'package:mlewis_fantasy_basketball/CreateOwnerView.dart';
import 'package:mlewis_fantasy_basketball/CreateLeagueView.dart';
import 'package:mlewis_fantasy_basketball/Utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert' as convert;

// View for owner's team
class MyTeamView extends StatelessWidget {

  //final int teamId;
  final String username;
  // final String teamName;
  // final String leagueName;

  MyTeamView({@required this.username}):super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Title'),
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
    throw UnimplementedError();
  }

}
