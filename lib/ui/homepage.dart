import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'components/welcome_section.dart';
import 'components/teams_section.dart';
import 'components/reminders_section.dart';
import 'components/bottom_navbar.dart';
import 'components/top_navbar.dart';
import '../providers/auth_provider.dart';
import '../providers/team_provider.dart';
import 'widgets/email_verification_guard.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isCoach = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    await teamProvider.loadUserTeams();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      bool isCoach = false;
      if (teamProvider.teams.isNotEmpty) {
        isCoach = await teamProvider.isCoachInTeam(
          teamId: teamProvider.teams.first.id,
          userId: authProvider.user!.uid,
        );
      }
      
      if (mounted) {
        setState(() {
          _isCoach = isCoach;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return EmailVerificationGuard(
      child: Scaffold(
      backgroundColor: const Color(0xFF002122),
      body: SafeArea(
        child: Column(
          children: [
            const TopNavBar(),
            Expanded(
              child: Consumer2<AuthProvider, TeamProvider>(
                builder: (context, authProvider, teamProvider, child) {
                  final user = authProvider.user;
                  
                  if (user == null) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00BF63),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const WelcomeSection(),
                        const SizedBox(height: 20),
                        if (_isLoading)
                          const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF00BF63),
                            ),
                          )
                        else
                          TeamsSection(
                            isCoach: _isCoach,
                            userId: user.uid,
                          ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}