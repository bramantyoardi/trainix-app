import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/team_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/program_provider.dart';
import '../../models/program.dart';
import '../../models/team.dart';
import '../components/top_navbar.dart';
import 'program_list_page.dart';
import 'reminder_list_page.dart';
import 'leaderboard_page.dart';
import 'training_log_list_page.dart';
import 'training_log_input_page.dart';
import 'athlete_training_log_page.dart';

class TrainingDashboardPage extends StatelessWidget {
  const TrainingDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<TeamProvider, AuthProvider>(
      builder: (context, teamProvider, authProvider, child) {
        final currentTeam = teamProvider.currentTeam;
        
        if (currentTeam == null) {
          return _buildNoTeamSelected(context);
        }

        // Get user role in current team
        final userRole = teamProvider.userTeamRoles
            .where((role) => role.teamId == currentTeam.id && role.userId == authProvider.user?.uid)
            .firstOrNull;
        
        final isCoach = userRole?.role == 'Coach';

        return Scaffold(
          backgroundColor: const Color(0xFF002122),
          body: SafeArea(
            child: Column(
              children: [
                const TopNavBar(),
                Expanded(
                  child: _buildDashboardContent(context, currentTeam, isCoach),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoTeamSelected(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002122),
      body: SafeArea(
        child: Column(
          children: [
            const TopNavBar(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.group_outlined,
                      size: 80,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pilih Tim Terlebih Dahulu',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pergi ke halaman Teams untuk memilih tim',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Switch to teams tab
                        // This would need to be handled by parent widget
                      },
                      icon: const Icon(Icons.group, color: Colors.white),
                      label: const Text('Pilih Tim', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00565A),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, Team team, bool isCoach) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(team, isCoach),
          const SizedBox(height: 20),
          _buildQuickActions(context, team, isCoach),
          const SizedBox(height: 20),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(Team team, bool isCoach) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A4A4B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00BF63).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF65EAE8).withOpacity(0.2),
                radius: 25,
                child: Text(
                  team.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF65EAE8),
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat datang, ${isCoach ? 'Coach' : 'Athlete'}!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      team.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            team.cabor ?? 'Unknown Sport',
            style: TextStyle(
              color: const Color(0xFF00BF63),
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Team team, bool isCoach) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            // Training Log - different behavior for coach vs athlete
            _buildActionCard(
              context,
              isCoach ? 'Input Training Log' : 'Lihat Training Log',
              Icons.assignment,
              const Color(0xFF00BF63),
              () => _navigateToTrainingLog(context, team, isCoach),
            ),
            _buildActionCard(
              context,
              'Reminder',
              Icons.notifications,
              const Color(0xFF65EAE8),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReminderListPage(
                      teamId: team.id,
                      teamName: team.name,
                    ),
                  ),
                );
              },
            ),
            _buildActionCard(
              context,
              'Leaderboard',
              Icons.leaderboard,
              const Color(0xFFFFB800),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LeaderboardPage(
                      teamId: team.id,
                      teamName: team.name,
                    ),
                  ),
                );
              },
            ),
            _buildActionCard(
              context,
              'Program',
              Icons.list,
              const Color(0xFF9C27B0),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProgramListPage(
                      teamId: team.id,
                      teamName: team.name,
                      isCoach: isCoach,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToTrainingLog(BuildContext context, Team team, bool isCoach) {
    final programProvider = Provider.of<ProgramProvider>(context, listen: false);
    
    if (isCoach) {
      // Coach can input training logs
      if (programProvider.programs.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrainingLogInputPage(
              program: programProvider.programs.first,
              teamId: team.id,
            ),
          ),
        );
      } else {
        // Create a default program for training logs
        final defaultProgram = Program(
          id: 'default_${team.id}',
          name: 'Program Training ${team.name}',
          teamId: team.id,
          weekAnchor: DateTime.now(),
          template: {},
          categories: ['General'],
          targetDays: 6,
          createdBy: Provider.of<AuthProvider>(context, listen: false).user?.uid ?? '',
        );
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrainingLogInputPage(
              program: defaultProgram,
              teamId: team.id,
            ),
          ),
        );
      }
    } else {
      // Athlete can only view their training logs
      final currentUserId = Provider.of<AuthProvider>(context, listen: false).user?.uid;
      if (currentUserId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AthleteTrainingLogPage(
              athleteId: currentUserId,
              teamId: team.id,
            ),
          ),
        );
      }
    }
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A4747),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A4747),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'No recent activity',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ],
    );
  }
}