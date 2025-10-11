import 'package:flutter/material.dart';

class TeamMembersPage extends StatelessWidget {
  final String teamId;
  final String teamName;

  const TeamMembersPage({
    Key? key,
    required this.teamId,
    required this.teamName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$teamName Members'),
      ),
      body: const Center(
        child: Text('Team Members - Coming Soon'),
      ),
    );
  }
}