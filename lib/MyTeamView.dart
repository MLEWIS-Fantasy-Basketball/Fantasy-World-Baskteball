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
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.group_add),
              tooltip: 'Add Free Agents',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AllPlayersListView(info: info)),
                );
              },
          ),
        ]
      ),
      body: MyTeamViewState(info: info)
    );
  }
}

class MyTeamViewState extends StatefulWidget {
  final TeamInfo info;
  MyTeamViewState({@required this.info});
  @override
  _MyTeamViewState createState() => _MyTeamViewState(info: info);
}

class _MyTeamViewState extends State<MyTeamViewState> {

  final TeamInfo info;

  _MyTeamViewState({@required this.info});

  List<PlayerDataItem> players = [];
  bool _gotPlayers = false;

  var jsonResponse;
  int _itemCount = 0;

  int wins = 0;
  int losses = 0;

  Future<void> getPlayers() async {
    String url = "http://127.0.0.1:5000/Team/" + info.teamId.toString();
    http.Response response = await http.get(url);
    if (response.statusCode == 200 || response.statusCode == 302) {
      setState(() {
        jsonResponse = convert.jsonDecode(response.body);
        //debugPrint(jsonResponse[1].toString());
        _itemCount = jsonResponse.length;
        for (var player in jsonResponse) {
          players.add(PlayerDataItem.fromJson(player));
        }
      });
      debugPrint("Number of players found : $_itemCount");
    } else {
      debugPrint("Request failed with status: ${response.statusCode}.");
    }
  }

  @override
  Widget build(BuildContext context) {
    if(!_gotPlayers) {
      getPlayers();
      _gotPlayers = true;
    }
    return ListView.builder(
        itemCount: players.length,
        itemBuilder: (context, index) {
          final player = players[index];
          return Container(
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.only(left: 400, right: 400),
              child: Card(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.assignment_ind),
                          title: player.buildName(context),
                          subtitle: player.buildData(context),
                        ),
                      ]
                  )
              )
          );
        }
    );
  }
}
