import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

// View for all free agent players
class AllPlayersListView extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return ListViewState();
  }
}

class ListViewState extends StatefulWidget {
  @override
  _ListViewState createState() => _ListViewState();
}

class _ListViewState extends State<ListViewState> {
  List<PlayerDataItem> players = [];//List<PlayerListItem>.generate(100, (index) => PlayerDataItem('name', 'team', List.empty()));

  var jsonResponse;
  bool _gotPlayers = false;
  int _itemCount = 0;

  String _query = "playerlists/1";

  Future<void> getPlayers(query) async {
    String url = "http://127.0.0.1:5000/" + query;
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
      getPlayers(_query);
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
                          onPressed: () {/* ... */},
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          child: const Text('SEE MORE STATS'),
                          onPressed: () {/* ... */},
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
            );
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
  final List<double> stats;

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