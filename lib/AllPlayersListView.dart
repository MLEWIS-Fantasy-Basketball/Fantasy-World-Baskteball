import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mlewis_fantasy_basketball/LoginView.dart';
import 'package:mlewis_fantasy_basketball/MyTeamView.dart';
import 'dart:convert' as convert;
import 'dart:convert';
import 'package:http/http.dart' as http;

// View for all free agent players
class AllPlayersListView extends StatelessWidget {

  final TeamInfo info;
  AllPlayersListView({@required this.info});

  @override
  Widget build(BuildContext context) {
    return ListViewState(info: info);
  }
}

class ListViewState extends StatefulWidget {
  final TeamInfo info;
  ListViewState({@required this.info});
  @override
  _ListViewState createState() => _ListViewState(info: info);
}

class _ListViewState extends State<ListViewState> {
  final TeamInfo info;
  _ListViewState({@required this.info});

  List<PlayerDataItem> players = [];//List<PlayerListItem>.generate(100, (index) => PlayerDataItem('name', 'team', List.empty()));

  var jsonResponse;
  bool _gotPlayers = false;
  int _itemCount = 0;

  void addPlayerToTeam(int teamId, int playerId) async {
    final http.Response response = await http.post(
        'http://127.0.0.1:5000/Team/' + teamId.toString() + '/' + playerId.toString(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'player_id': playerId.toString(),
          'team_id': teamId.toString(),
        }));
    if (response.statusCode == 201 || response.statusCode == 200) {
      print("Player successfully added to team");
    } else {
      throw Exception('Failed to add player to team');
    }
  }


  Future<void> getPlayers() async {
    String url = "http://127.0.0.1:5000/playerlists/1";
    http.Response response = await http.get(url);
    if (response.statusCode == 200 || response.statusCode == 302) {
      setState(() {
        jsonResponse = convert.jsonDecode(response.body);
        debugPrint(jsonResponse[1].toString());
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
    final String viewTitle = 'Free Agents';
    return Scaffold(
      appBar: AppBar(
        title: Text(viewTitle),
      ),
      body: ListView.builder(
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            if(!player.onTeam) {
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
                            child: const Text('ADD PLAYER'),
                            onPressed: () {
                              addPlayerToTeam(info.teamId, player.id);
                              Navigator.push(
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
                    ],
                  ),
                ),
              );
            }
            return Container();
          }),
    );
  }
}

abstract class PlayerListItem {
  Widget buildName(BuildContext buildContext);
  Widget buildData(BuildContext buildContext);
}

class PlayerDataItem implements PlayerListItem {
  const PlayerDataItem({
  this.name,
  this.onTeam,
  this.position,
  this.realTeam,
  this.realLeague,
  this.fantasyTeam,
    this.id,
    this.stats,
  });

  final int id;
  final String name;
  final bool onTeam;
  final String position;
  final String realTeam;
  final String realLeague;
  final String fantasyTeam;
  final List<Stats> stats;

  factory PlayerDataItem.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw FormatException("Null JSON provided to PlayerDataItem");
    }

    return PlayerDataItem(
      id: json['id'],
      name: json['name'],
      onTeam: json['on_team'],
      position: json['position'],
      realTeam: json['real_team_name'],
      realLeague: json['real_league_name'],
      fantasyTeam: 'Unassigned',
      stats: List.empty(),
    );
  }

  Widget buildData(BuildContext buildContext) {
    return Text(this.realTeam + ", " + this.position + ", ");
  }

  Widget buildName(BuildContext buildContext) {
    return Text(this.name);
  }
}

class Stats {
  final int ppg;
  final int apg;
  final int rpg;
  final int bpg;
  final int spg;
  final int playerId;
  final int year;
  Stats(this.playerId, this.year, this.ppg, this.apg, this. rpg, this.bpg, this.spg);
}