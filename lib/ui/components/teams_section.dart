import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/team_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/team.dart';
import '../team_management/create_team_page.dart';
import '../team_management/team_details_page.dart';

class TeamsSection extends StatelessWidget {
  final bool isCoach;
  final String userId;

  const TeamsSection({
    Key? key,
    required this.isCoach,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<TeamProvider, AuthProvider>(
      builder: (context, teamProvider, authProvider, child) {
        if (teamProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF00BF63),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Teams',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 230,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Team cards
                  ...teamProvider.teams.map((team) => _buildTeamCard(context, team)),
                  
                  // Add team card
                  _buildAddTeamCard(context, authProvider),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTeamCard(BuildContext context, Team team) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeamDetailsPage(team: team),
          ),
        );
      },
      child: Container(
        width: 180,
        height: 230,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A4747),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF00BF63).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team logo placeholder
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF00BF63),
                borderRadius: BorderRadius.circular(8),
              ),
              child: team.logoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        team.logoUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.group,
                      color: Colors.white,
                      size: 24,
                    ),
            ),
            const SizedBox(height: 12),
            
            // Team name
            Text(
              team.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            
            // Team info
            Text(
              team.cabor ?? 'Cabang Olahraga',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${team.memberCount ?? 0} anggota',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
            const Spacer(),
            
            // Team code
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00BF63).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                team.teamCode ?? 'N/A',
                style: const TextStyle(
                  color: Color(0xFF00BF63),
                  fontSize: 10,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTeamCard(BuildContext context, AuthProvider authProvider) {
    return Container(
      width: 180,
      height: 230,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Create Team Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BF63),
              minimumSize: const Size(double.infinity, 40),
            ),
            onPressed: () async {
              if (authProvider.user != null) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateTeamPage(),
                  ),
                );
                // Refresh teams if team was created successfully
                if (result == true) {
                  final teamProvider = Provider.of<TeamProvider>(context, listen: false);
                  await teamProvider.loadUserTeams();
                }
              }
            },
            child: const Text(
              'Buat Tim',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Join Team Button
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF00BF63)),
              minimumSize: const Size(double.infinity, 40),
            ),
            onPressed: () {
              _showJoinTeamDialog(context);
            },
            child: const Text(
              'Gabung Tim',
              style: TextStyle(
                color: Color(0xFF00BF63),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showJoinTeamDialog(BuildContext context) {
    final teamCodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A4747),
        title: const Text(
          'Gabung Tim',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: teamCodeController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Kode Tim',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00BF63)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BF63),
            ),
            onPressed: () async {
              final teamProvider = Provider.of<TeamProvider>(context, listen: false);
              final success = await teamProvider.joinTeam(teamCodeController.text);
              
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Berhasil bergabung dengan tim!'),
                    backgroundColor: Color(0xFF00BF63),
                  ),
                );
                await teamProvider.loadUserTeams();
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gagal bergabung dengan tim. Pastikan kode tim benar.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Gabung',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}