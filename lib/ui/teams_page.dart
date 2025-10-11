import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../providers/auth_provider.dart';
import '../models/team.dart';
import 'components/top_navbar.dart';
import 'team_management/create_team_page.dart';
import 'team_management/join_team_page.dart';
import 'team_management/team_details_page.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({Key? key}) : super(key: key);

  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeamProvider>(context, listen: false).loadUserTeams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002122),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          child: Column(
            children: [
              const TopNavBar(),
              const SizedBox(height: 20),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tim Saya',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateTeamPage(),
                            ),
                          ).then((_) {
                            // Refresh teams list after creating team
                            Provider.of<TeamProvider>(context, listen: false)
                                .loadUserTeams();
                          });
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Buat Tim',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00565A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const JoinTeamPage(),
                            ),
                          ).then((_) {
                            // Refresh teams list after joining team
                            Provider.of<TeamProvider>(context, listen: false)
                                .loadUserTeams();
                          });
                        },
                        icon: const Icon(Icons.group_add, color: Colors.white),
                        label: const Text('Gabung',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00565A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Teams List
              Expanded(
                child: Consumer<TeamProvider>(
                  builder: (context, teamProvider, child) {
                    if (teamProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (teamProvider.teams.isEmpty) {
                      return const Center(
                        child: Text(
                          'Belum ada tim. Buat atau gabung tim untuk memulai!',
                          style: TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: teamProvider.teams.length,
                      itemBuilder: (context, index) {
                        final team = teamProvider.teams[index];
                        return _buildTeamCard(team);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamCard(Team team) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF00565A),
      child: ListTile(
        title: Text(
          team.name,
          style: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${team.memberCount} anggota • ${team.cabor ?? 'Tidak diketahui'}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              team.event ?? 'Tidak ada event',
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamDetailsPage(team: team),
            ),
          );
        },
      ),
    );
  }
}
