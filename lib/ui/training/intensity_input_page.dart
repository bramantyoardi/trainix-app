import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/program.dart';
import '../../models/training_intensity.dart';

class IntensityInputPage extends StatefulWidget {
  final Program program;
  final String teamId;

  const IntensityInputPage({
    Key? key,
    required this.program,
    required this.teamId,
  }) : super(key: key);

  @override
  _IntensityInputPageState createState() => _IntensityInputPageState();
}

class _IntensityInputPageState extends State<IntensityInputPage> {
  bool _isLoading = false;
  final Map<String, int> _intensityValues = {};

  // Mock data untuk atlet dalam tim
  final List<Map<String, dynamic>> _mockAthletes = [
    {
      'id': 'athlete1',
      'name': 'Budi Santoso',
      'photoUrl': '',
      'role': 'Atlet',
    },
    {
      'id': 'athlete2',
      'name': 'Dewi Putri',
      'photoUrl': '',
      'role': 'Atlet',
    },
    {
      'id': 'athlete3',
      'name': 'Eko Prasetyo',
      'photoUrl': '',
      'role': 'Atlet',
    },
    {
      'id': 'athlete4',
      'name': 'Fitri Handayani',
      'photoUrl': '',
      'role': 'Atlet',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Inisialisasi nilai intensitas untuk setiap atlet
    for (var athlete in _mockAthletes) {
      _intensityValues[athlete['id']] = 5; // Default nilai tengah (1-10)
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

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
        title: const Text(
          'Input Intensitas Latihan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF65EAE8)))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgramInfo(),
                    const SizedBox(height: 24),
                    const Text(
                      'Intensitas Latihan Atlet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Geser slider untuk menentukan nilai intensitas latihan (1-10)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildAthleteList(),
                    ),
                    const SizedBox(height: 16),
                    _buildSaveButton(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProgramInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A4747),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.program.template['name'] ?? 'Program Latihan',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tanggal: ${_formatDate(widget.program.weekAnchor)}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.program.categories
                .map((category) => _buildCategoryChip(category))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF65EAE8).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: const TextStyle(
          color: Color(0xFF65EAE8),
          fontSize: 12,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildAthleteList() {
    return ListView.builder(
      itemCount: _mockAthletes.length,
      itemBuilder: (context, index) {
        final athlete = _mockAthletes[index];
        return _buildAthleteIntensityItem(athlete);
      },
    );
  }

  Widget _buildAthleteIntensityItem(Map<String, dynamic> athlete) {
    final athleteId = athlete['id'];
    final currentValue = _intensityValues[athleteId] ?? 5;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A4747),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF65EAE8).withOpacity(0.2),
                child: Text(
                  athlete['name'].substring(0, 1),
                  style: const TextStyle(
                    color: Color(0xFF65EAE8),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      athlete['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      athlete['role'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Intensitas: $currentValue',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _getIntensityLabel(currentValue),
                style: TextStyle(
                  color: _getIntensityColor(currentValue),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF65EAE8),
              inactiveTrackColor: const Color(0xFF65EAE8).withOpacity(0.2),
              thumbColor: const Color(0xFF65EAE8),
              overlayColor: const Color(0xFF65EAE8).withOpacity(0.2),
              valueIndicatorColor: const Color(0xFF65EAE8),
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
            child: Slider(
              value: currentValue.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: currentValue.toString(),
              onChanged: (value) {
                setState(() {
                  _intensityValues[athleteId] = value.round();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getIntensityLabel(int value) {
    if (value <= 2) return 'Sangat Ringan';
    if (value <= 4) return 'Ringan';
    if (value <= 6) return 'Sedang';
    if (value <= 8) return 'Berat';
    return 'Sangat Berat';
  }

  Color _getIntensityColor(int value) {
    if (value <= 2) return Colors.green;
    if (value <= 4) return Colors.lightGreen;
    if (value <= 6) return Colors.yellow;
    if (value <= 8) return Colors.orange;
    return Colors.red;
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveIntensities,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF65EAE8),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Simpan',
          style: TextStyle(
            color: Color(0xFF002122),
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _saveIntensities() async {
    setState(() => _isLoading = true);

    try {
      final intensities = _intensityValues.entries.map((entry) {
        // Convert slider value (1-10) to HRR percentage (0-100)
        final hrrPercentage = (entry.value / 10) * 100;
        
        // Determine intensity zone based on HRR percentage
        String intensityZone;
        if (hrrPercentage <= 20) {
          intensityZone = 'Zone 1';
        } else if (hrrPercentage <= 40) {
          intensityZone = 'Zone 2';
        } else if (hrrPercentage <= 60) {
          intensityZone = 'Zone 3';
        } else if (hrrPercentage <= 80) {
          intensityZone = 'Zone 4';
        } else {
          intensityZone = 'Zone 5';
        }

        return TrainingIntensity(
          id: '',
          athleteId: entry.key,
          programId: widget.program.id,
          teamId: widget.teamId,
          hrrPercentage: hrrPercentage,
          intensityZone: intensityZone,
          recordedAt: Timestamp.now(),
          avgHeartRate: null,
          maxHeartRate: null,
          duration: null,
        );
      }).toList();

      // TODO: Implement save to Firestore
      print('Saving intensities: $intensities');

      Navigator.pop(context, intensities);
    } catch (e) {
      print('Error saving intensities: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan data intensitas latihan'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
