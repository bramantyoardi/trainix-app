import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/program.dart'; // Update import ke model Program yang baru
import 'create_program_page.dart';
import 'intensity_input_page.dart';
import 'training_log_input_page.dart';
import 'training_log_list_page.dart';

class ProgramDetailPage extends StatefulWidget {
  final Program program; // Update parameter type
  final bool isCoach;
  final String teamId;

  const ProgramDetailPage({
    Key? key,
    required this.program,
    required this.isCoach,
    required this.teamId,
  }) : super(key: key);

  @override
  _ProgramDetailPageState createState() => _ProgramDetailPageState();
}

class _ProgramDetailPageState extends State<ProgramDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002122),
      appBar: AppBar(
        backgroundColor: const Color(0xFF002122),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Program Minggu ${_getWeekNumber(widget.program.weekAnchor)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: widget.isCoach
            ? [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF00BF63)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateProgramPage(
                          teamId: widget.teamId,
                          teamName: 'Edit Program',
                          programToEdit: widget.program,
                        ),
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgramInfo(),
            const SizedBox(height: 24),
            _buildCategoriesSection(),
            const SizedBox(height: 24),
            _buildTemplateSection(),
            if (widget.isCoach) ...[
              const SizedBox(height: 24),
              _buildCoachActions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgramInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A4A4B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00BF63).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Program',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Minggu Anchor', _formatDate(widget.program.weekAnchor)),
          _buildInfoRow('Target Hari', '${widget.program.targetDays} hari'),
          _buildInfoRow('Total Kategori', '${widget.program.categories.length} kategori'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A4A4B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00BF63).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kategori Latihan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.program.categories.map((category) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BF63).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00BF63),
                    width: 1,
                  ),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    color: Color(0xFF00BF63),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A4A4B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00BF63).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Template Program',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Tampilkan template dalam format yang mudah dibaca
          ...widget.program.template.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key}:',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCoachActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IntensityInputPage(
                    program: widget.program,
                    teamId: widget.teamId,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BF63),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Input Intensitas Atlet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrainingLogInputPage(
                    program: widget.program,
                    teamId: widget.teamId,
                    programId: widget.program.id,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Input Training Log',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrainingLogListPage(
                    program: widget.program,
                    teamId: widget.teamId,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Lihat Training Logs',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  int _getWeekNumber(Timestamp timestamp) {
    final date = timestamp.toDate();
    final startOfYear = DateTime(date.year, 1, 1);
    final daysSinceStart = date.difference(startOfYear).inDays;
    return (daysSinceStart / 7).ceil();
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}