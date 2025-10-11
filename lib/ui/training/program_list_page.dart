import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/program.dart'; // Update import ke model Program yang baru
import '../../providers/program_provider.dart';
import '../components/top_navbar.dart';
import 'create_program_page.dart';
import 'program_detail_page.dart';

class ProgramListPage extends StatefulWidget {
  final String teamId;
  final String teamName;
  final bool isCoach;

  const ProgramListPage({
    Key? key,
    required this.teamId,
    required this.teamName,
    required this.isCoach,
  }) : super(key: key);

  @override
  _ProgramListPageState createState() => _ProgramListPageState();
}

class _ProgramListPageState extends State<ProgramListPage> {
  @override
  void initState() {
    super.initState();
    // Load programs saat halaman dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProgramProvider>(context, listen: false)
          .loadTeamPrograms(widget.teamId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002122),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            const TopNavBar(),
            
            // Title Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Program Latihan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.teamName,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Consumer<ProgramProvider>(
                builder: (context, programProvider, child) {
                  if (programProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  }

                  final programs = programProvider.programs;

                  if (programs.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildProgramList(programs);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.isCoach
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateProgramPage(
                      teamId: widget.teamId,
                      teamName: widget.teamName,
                    ),
                  ),
                );
              },
              backgroundColor: const Color(0xFF00BF63),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada program latihan',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isCoach 
                ? 'Tap tombol + untuk membuat program baru'
                : 'Coach belum membuat program latihan',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgramList(List<Program> programs) { // Update parameter type
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: programs.length,
      itemBuilder: (context, index) {
        final program = programs[index];
        return _buildProgramCard(program);
      },
    );
  }

  Widget _buildProgramCard(Program program) { // Update parameter type
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A4A4B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00BF63).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          'Program Minggu ${_getWeekNumber(program.weekAnchor)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Target: ${program.targetDays} hari',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Kategori: ${program.categories.join(', ')}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF00BF63),
          size: 16,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProgramDetailPage(
                program: program,
                isCoach: widget.isCoach,
                teamId: widget.teamId,
              ),
            ),
          );
        },
      ),
    );
  }

  int _getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final daysSinceStart = date.difference(startOfYear).inDays;
    return (daysSinceStart / 7).ceil();
  }
}
