import 'package:flutter/material.dart';
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
            'Tanggal: ${widget.program.weekAnchor.day}/${widget.program.weekAnchor.month}/${widget.program.weekAnchor.year}',
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
                radius: 20,
                child: Text(
                  athlete['name'].substring(0, 1),
                  style: const TextStyle(
                    color: Color(0xFF65EAE8),
                    fontSize: 16,
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
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getIntensityColor(currentValue),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  currentValue.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                '1',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
              Expanded(
                child: Slider(
                  value: currentValue.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: _getIntensityColor(currentValue),
                  inactiveColor: Colors.white24,
                  onChanged: (value) {
                    setState(() {
                      _intensityValues[athleteId] = value.round();
                    });
                  },
                ),
              ),
              const Text(
                '10',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getIntensityColor(int value) {
    if (value <= 3) {
      return Colors.green;
    } else if (value <= 7) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
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
          'Simpan Intensitas',
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

  Future<void> _saveIntensities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulasi delay untuk proses penyimpanan
      await Future.delayed(const Duration(seconds: 1));

      // Di sini nanti akan ada kode untuk menyimpan ke Firebase
      // Untuk sekarang, kita hanya simulasikan berhasil

      if (!mounted) return;
      Navigator.pop(context, true); // Kembali dengan status berhasil

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Intensitas latihan berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
