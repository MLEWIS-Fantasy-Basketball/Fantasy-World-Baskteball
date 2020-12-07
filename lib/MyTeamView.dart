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

  var playerResponse;
  var statResponse;
  int _itemCount = 0;

  int wins = 0;
  int losses = 0;

  Future<void> getPlayers() async {
    String url = "http://127.0.0.1:5000/Team/" + info.teamId.toString();
    http.Response response = await http.get(url);
    if (response.statusCode == 200 || response.statusCode == 302) {
      setState(() {
        playerResponse = convert.jsonDecode(response.body);
        _itemCount = playerResponse.length;
        for (var player in playerResponse) {
          var p = PlayerDataItem.fromJson(player);
          players.add(p);
        }
        for (var p in players) {
          getStats(p.id, 2020);
        }
      });
      debugPrint("Number of players found : $_itemCount");
    } else {
      debugPrint("Player Request failed with status: ${response.statusCode}.");
    }
  }
  Future<void> getStats(int playerId, int year) async {
    String url = "http://127.0.0.1:5000/Stats/" + playerId.toString() + "/" + year.toString();
    http.Response response = await http.get(url);
    if (response.statusCode == 200 || response.statusCode == 302) {
      setState(() {
        statResponse = convert.jsonDecode(response.body);
        var player;
        for (var p in players) {
          if(p.id == playerId) {
            player = p;
          }
        }
        if(statResponse.length >= 17) {
          player.stats.add(Stats.fromJson(player.id, statResponse));
        }
      });
      debugPrint("Number of stats found : $_itemCount");
    } else {
      debugPrint("Stats Request failed with status: ${response.statusCode}.");
    }
  }

  void dropPlayerFromTeam(int teamId, int playerId) async {
    final http.Response response = await http.post(
        'http://127.0.0.1:5000/Team/drop/' + teamId.toString() + '/' + playerId.toString(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'player_id': playerId.toString(),
          'team_id': teamId.toString(),
        }));
    if (response.statusCode == 201 || response.statusCode == 200) {
      print("Player successfully dropped from team");
    } else {
      throw Exception('Failed to drop player from team');
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            TextButton(
                              child: const Text('DROP PLAYER'),
                              onPressed: () {
                                dropPlayerFromTeam(info.teamId, player.id);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MyTeamView(info: info)),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              child: const Text('SEE MORE STATS'),
                              onPressed: () {
                                /* ... */
                              },
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ]
                  )
              )
          );
        }
    );
  }
}
