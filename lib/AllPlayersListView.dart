import 'package:flutter/material.dart';

// View for all free agent players
class AllPlayersListView extends StatelessWidget {
  List<PlayerListItem> players = List<PlayerListItem>.generate(100, (index) => PlayerDataItem('name', 'team', List.empty()));

  @override
  Widget build(BuildContext context) {
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