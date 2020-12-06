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
  List<PlayerListItem> players = List<PlayerListItem>.generate(100, (index) => PlayerDataItem('name', 'team', List.empty()));

  var jsonResponse;
  bool gotPlayers = false;
  int _itemCount = 0;

  String _Query = "playerlists/1";

  Future<void> getPlayers(query) async {
    String url = "http://127.0.0.1:5000/" + query;
    http.Response response = await http.get(url);
    if (response.statusCode == 200 || response.statusCode == 302) {
      setState(() {
        jsonResponse = convert.jsonDecode(response.body);
        debugPrint(response.body[1]);
        _itemCount = jsonResponse.length;
      });
      debugPrint("Number of players found : $_itemCount");
    } else {
      print("Request failed with status: ${response.statusCode}.");
    }
  }

  // void getPlayers() async {
  //   var connection = PostgreSQLConnection("localhost", 5432, "fantasy_basketball");
  //   await connection.open();
  //   List<List<dynamic>> results = await connection.query("SELECT * FROM public.player");
  //
  //   for (final row in results) {
  //     print(row[0]);
  //     print(row[1]);
  //
  //   }
  // }



  @override
  Widget build(BuildContext context) {
    if(!gotPlayers) {
      getPlayers(_Query);
      gotPlayers = true;
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
            return Card(
                child: ListTile(
                  title: player.buildName(context),
                  subtitle: player.buildData(context),
                )
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
  final String name;
  final String team;
  final List<double> stats;

  PlayerDataItem(this.name, this.team, this.stats);

  Widget buildData(BuildContext buildContext) {
    return Text(team);
  }

  Widget buildName(BuildContext buildContext) {
    return Text(name);
  }
}