import 'package:flutter/material.dart';

class TeamDetailsPage extends StatelessWidget {
  final String teamId;
  final String teamName;

  const TeamDetailsPage({
    Key? key,
    required this.teamId,
    required this.teamName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(teamName),
      ),
      body: const Center(
        child: Text('Team Details - Coming Soon'),
      ),
    );
  }
}