import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/program.dart';
import '../../models/training_log.dart';
import '../../providers/training_log_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/hrr_calculator.dart';

class TrainingLogListPage extends StatefulWidget {
  final Program program;
  final String teamId;

  const TrainingLogListPage({
    Key? key,
    required this.program,
    required this.teamId,
  }) : super(key: key);

  @override
  _TrainingLogListPageState createState() => _TrainingLogListPageState();
}

class _TrainingLogListPageState extends State<TrainingLogListPage> {
  String _selectedFilter = 'all';
  String? _selectedAthleteId;
  int? _selectedWeek;
  String? _selectedHrrBand;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadTrainingLogs();
  }

  void _loadTrainingLogs() {
    final provider = Provider.of<TrainingLogProvider>(context, listen: false);
    provider.loadLogsByProgram(widget.program.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2E2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A2E2A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Training Logs',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          _buildStatistics(),
          Expanded(
            child: _buildTrainingLogsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Semua', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('Minggu Ini', 'week'),
            const SizedBox(width: 8),
            _buildFilterChip('HRR 1', 'hrr1'),
            const SizedBox(width: 8),
            _buildFilterChip('HRR 2', 'hrr2'),
            const SizedBox(width: 8),
            _buildFilterChip('HRR 3', 'hrr3'),
            const SizedBox(width: 8),
            _buildFilterChip('HRR 4', 'hrr4'),
            const SizedBox(width: 8),
            _buildFilterChip('HRR 5', 'hrr5'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF00BF63),
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        _applyFilter();
      },
      backgroundColor: const Color(0xFF1A4A4B),
      selectedColor: const Color(0xFF00BF63),
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: const Color(0xFF00BF63).withOpacity(0.3),
      ),
    );
  }

  Widget _buildStatistics() {
    return Consumer<TrainingLogProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SizedBox.shrink();
        }

        final logs = provider.logs;
        if (logs.isEmpty) {
          return const SizedBox.shrink();
        }

        final totalLogs = logs.length;
        final averageScore = logs.map((log) => log.score).reduce((a, b) => a + b) / totalLogs;
        final uniqueAthletes = logs.map((log) => log.athleteId).toSet().length;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A4A4B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF00BF63).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total Logs', totalLogs.toString()),
              _buildStatItem('Rata-rata Skor', averageScore.toStringAsFixed(1)),
              _buildStatItem('Atlet Aktif', uniqueAthletes.toString()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF00BF63),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingLogsList() {
    return Consumer<TrainingLogProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BF63)),
            ),
          );
        }

        final logs = provider.logs;
        if (logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada training log',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return _buildTrainingLogCard(log);
          },
        );
      },
    );
  }

  Widget _buildTrainingLogCard(TrainingLog log) {
    final hrrColor = HRRCalculator.getHRRBandColor(log.hrrBand ?? 'Zone 1');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A4A4B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hrrColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Atlet ID: ${log.athleteId}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hrrColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: hrrColor, width: 1),
                ),
                child: Text(
                  'HRR ${log.hrrBand ?? 'Zone 1'}',
                  style: TextStyle(
                    color: hrrColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Skor: ${log.score.toStringAsFixed(1)}',
                style: const TextStyle(
                  color: Color(0xFF00BF63),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatDate(log.date),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Input oleh: ${log.inputBy}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A4A4B),
        title: const Text(
          'Filter Training Logs',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Filter options can be added here
            const Text(
              'Filter options akan ditambahkan di sini',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_startDate != null && _endDate != null) {
                final provider = Provider.of<TrainingLogProvider>(context, listen: false);
                provider.filterTrainingLogsByDateRange(
                  widget.program.id,
                  _startDate!,
                  _endDate!,
                );
              }
            },
            child: const Text(
              'Tutup',
              style: TextStyle(color: Color(0xFF00BF63)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDateRangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A4747),
        title: const Text(
          'Pilih Rentang Tanggal',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                _startDate == null 
                  ? 'Pilih Tanggal Mulai' 
                  : 'Mulai: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                style: const TextStyle(color: Colors.white),
              ),
              trailing: const Icon(Icons.calendar_today, color: Colors.white),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _startDate = date;
                  });
                }
              },
            ),
            ListTile(
              title: Text(
                _endDate == null 
                  ? 'Pilih Tanggal Akhir' 
                  : 'Akhir: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                style: const TextStyle(color: Colors.white),
              ),
              trailing: const Icon(Icons.calendar_today, color: Colors.white),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? DateTime.now(),
                  firstDate: _startDate ?? DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _endDate = date;
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_startDate != null && _endDate != null) {
                final provider = Provider.of<TrainingLogProvider>(context, listen: false);
                provider.filterTrainingLogsByDateRange(
                  widget.program.id,
                  _startDate!,
                  _endDate!,
                );
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Terapkan',
              style: TextStyle(color: Color(0xFF00BF63)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tutup',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilter() {
    final provider = Provider.of<TrainingLogProvider>(context, listen: false);
    
    switch (_selectedFilter) {
      case 'week':
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        provider.filterTrainingLogsByDateRange(
          widget.program.id,
          startOfWeek,
          endOfWeek,
        );
        break;
      case 'hrr1':
      case 'hrr2':
      case 'hrr3':
      case 'hrr4':
      case 'hrr5':
        final hrrBand = int.parse(_selectedFilter.substring(3));
        provider.getTrainingLogsByHRRBand(widget.program.id, hrrBand);
        break;
      case 'date_range':
        _showDateRangeDialog();
        break;
      default:
        provider.loadLogsByProgram(widget.program.id);
    }
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