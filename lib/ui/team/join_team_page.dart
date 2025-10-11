import 'package:flutter/material.dart';

class JoinTeamPage extends StatefulWidget {
  const JoinTeamPage({Key? key}) : super(key: key);

  @override
  State<JoinTeamPage> createState() => _JoinTeamPageState();
}

class _JoinTeamPageState extends State<JoinTeamPage> {
  final _teamCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Team'),
      ),
      body: const Center(
        child: Text('Join Team - Coming Soon'),
      ),
    );
  }

  @override
  void dispose() {
    _teamCodeController.dispose();
    super.dispose();
  }
}