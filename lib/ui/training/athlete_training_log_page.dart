import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/training_log_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/training_log.dart';
import 'package:intl/intl.dart';

class AthleteTrainingLogPage extends StatefulWidget {
  final String athleteId;
  final String teamId;

  const AthleteTrainingLogPage({
    Key? key,
    required this.athleteId,
    required this.teamId,
  }) : super(key: key);

  @override
  _AthleteTrainingLogPageState createState() => _AthleteTrainingLogPageState();
}

class _AthleteTrainingLogPageState extends State<AthleteTrainingLogPage> {
  bool _isLoading = true;
  List<TrainingLog> _trainingLogs = [];
  String _selectedFilter = 'All';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadTrainingLogs();
  }

  Future<void> _loadTrainingLogs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final trainingLogProvider = Provider.of<TrainingLogProvider>(context, listen: false);
      List<TrainingLog> logs;

      if (_startDate != null && _endDate != null) {
        logs = await trainingLogProvider.getTrainingLogsByDateRange(
          widget.athleteId,
          _startDate!,
          _endDate!,
        );
      } else {
        logs = await trainingLogProvider.getTrainingLogsByAthlete(
          widget.teamId,
          widget.athleteId,
        );
      }

      // Apply HRR band filter
      if (_selectedFilter != 'All') {
        logs = logs.where((log) => log.hrrBand == _selectedFilter).toList();
      }

      // Sort by date (newest first)
      logs.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        _trainingLogs = logs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading training logs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002122),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilters(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BF63)),
                      ),
                    )
                  : _trainingLogs.isEmpty
                      ? _buildEmptyState()
                      : _buildTrainingLogsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A4A4B),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Training Log Saya',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Riwayat latihan dan performa',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // HRR Band Filter
          Row(
            children: [
              const Text(
                'Filter HRR Band:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Zone 1', 'Zone 2', 'Zone 3', 'Zone 4', 'Zone 5']
                        .map((filter) => _buildFilterChip(filter))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Date Range Filter
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  'Dari: ${_startDate != null ? DateFormat('dd/MM/yyyy').format(_startDate!) : 'Pilih'}',
                  () => _selectStartDate(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDateButton(
                  'Sampai: ${_endDate != null ? DateFormat('dd/MM/yyyy').format(_endDate!) : 'Pilih'}',
                  () => _selectEndDate(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                  });
                  _loadTrainingLogs();
                },
                icon: const Icon(Icons.clear, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          filter,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontFamily: 'Poppins',
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = filter;
          });
          _loadTrainingLogs();
        },
        backgroundColor: const Color(0xFF1A4747),
        selectedColor: const Color(0xFF00BF63),
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? const Color(0xFF00BF63) : Colors.white30,
        ),
      ),
    );
  }

  Widget _buildDateButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A4747),
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
      _loadTrainingLogs();
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
      _loadTrainingLogs();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada training log',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Training log akan muncul setelah pelatih menginput data latihan Anda',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingLogsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _trainingLogs.length,
      itemBuilder: (context, index) {
        final log = _trainingLogs[index];
        return _buildTrainingLogCard(log);
      },
    );
  }

  Widget _buildTrainingLogCard(TrainingLog log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A4747),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getHRRBandColor(log.hrrBand ?? 'Zone 1').withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd MMM yyyy, HH:mm').format(log.date),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getHRRBandColor(log.hrrBand ?? 'Zone 1').withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getHRRBandColor(log.hrrBand ?? 'Zone 1'),
                    width: 1,
                  ),
                ),
                child: Text(
                  log.hrrBand ?? 'Zone 1',
                  style: TextStyle(
                    color: _getHRRBandColor(log.hrrBand ?? 'Zone 1'),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Training Score',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${log.score}',
                    style: const TextStyle(
                      color: Color(0xFF00BF63),
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Program',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    log.programId.split('_').last, // Show simplified program ID
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              
          ),
        ],
      ),
        ],
      ),
    );
  }

  Color _getHRRBandColor(String hrrBand) {
    switch (hrrBand) {
      case 'Zone 1':
        return const Color(0xFF4CAF50); // Green
      case 'Zone 2':
        return const Color(0xFF8BC34A); // Light Green
      case 'Zone 3':
        return const Color(0xFFFFEB3B); // Yellow
      case 'Zone 4':
        return const Color(0xFFFF9800); // Orange
      case 'Zone 5':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF00BF63); // Default green
    }
  }
}