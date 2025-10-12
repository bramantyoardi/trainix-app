import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/program.dart';
import '../../models/user_team_role.dart';
import '../../providers/training_log_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/team_provider.dart';
import '../../utils/hrr_calculator.dart';

class TrainingLogInputPage extends StatefulWidget {
  final String teamId;
  final Program program;
  final String programId;

  const TrainingLogInputPage({
    Key? key,
    required this.teamId,
    required this.program,
    required this.programId,
  }) : super(key: key);

  @override
  _TrainingLogInputPageState createState() => _TrainingLogInputPageState();
}

class _TrainingLogInputPageState extends State<TrainingLogInputPage> {
  bool _isLoading = false;
  bool _isLoadingAthletes = true;
  final Map<String, Map<String, dynamic>> _athleteData = {};

  // Controllers for HRR-based input fields
  final Map<String, TextEditingController> _restingHRControllers = {};
  final Map<String, TextEditingController> _ageControllers = {};
  final Map<String, TextEditingController> _avgHRControllers = {};
  final Map<String, TextEditingController> _peakHRControllers = {};
  final Map<String, TextEditingController> _durationControllers = {};
  final Map<String, TextEditingController> _categoryControllers = {};
  final Map<String, String> _selectedTypes = {};

  // Real athlete data from team
  List<UserTeamRole> _teamAthletes = [];

  @override
  void initState() {
    super.initState();
    _loadTeamAthletes();
  }

  Future<void> _loadTeamAthletes() async {
    try {
      final teamProvider = Provider.of<TeamProvider>(context, listen: false);
      await teamProvider.loadTeamMembers(widget.teamId);

      setState(() {
        _teamAthletes = teamProvider.teamMembers
            .where((member) => member.role == 'Athlete')
            .toList();
        _isLoadingAthletes = false;
      });

      // Initialize controllers for each athlete
      for (var athlete in _teamAthletes) {
        _restingHRControllers[athlete.userId] =
            TextEditingController(text: '60');
        _ageControllers[athlete.userId] = TextEditingController(text: '25');
        _avgHRControllers[athlete.userId] = TextEditingController();
        _peakHRControllers[athlete.userId] = TextEditingController();
        _durationControllers[athlete.userId] = TextEditingController();
        _categoryControllers[athlete.userId] = TextEditingController();
        _selectedTypes[athlete.userId] = 'Cardio';

        // Initialize athlete data
        _athleteData[athlete.userId] = {
          'restingHR': 60,
          'age': 25,
          'avgHR': 0,
          'peakHR': 0,
          'duration': 0,
          'category': '',
          'type': 'Cardio',
          'hrrPercentage': 0.0,
          'zone': 'Zone 1',
          'targetRange': {'min': 0, 'max': 0},
          'minutesInBand': 0,
          'compliance': 0.0,
          'score': 0.0,
        };
      }
    } catch (e) {
      print('Error loading team athletes: $e');
      setState(() {
        _isLoadingAthletes = false;
      });
    }
  }

  void _calculateHRRPreview(String athleteId) {
    final restingHR =
        int.tryParse(_restingHRControllers[athleteId]?.text ?? '60') ?? 60;
    final age = int.tryParse(_ageControllers[athleteId]?.text ?? '25') ?? 25;
    final avgHR = int.tryParse(_avgHRControllers[athleteId]?.text ?? '0') ?? 0;
    final peakHR =
        int.tryParse(_peakHRControllers[athleteId]?.text ?? '0') ?? 0;
    final duration =
        int.tryParse(_durationControllers[athleteId]?.text ?? '0') ?? 0;
    final category = _categoryControllers[athleteId]?.text ?? '';
    final type = _selectedTypes[athleteId] ?? 'Cardio';

    if (avgHR > 0 && duration > 0) {
      // Calculate preview using HRRCalculator
      final preview = HRRCalculator.calculatePreview(
        hrRest: restingHR,
        age: age,
        hrAvg: avgHR,
        totalMinutes: duration,
      );

      // Calculate score preview
      final score = HRRCalculator.calculateHRRScore(
        hrRest: restingHR,
        age: age,
        hrAvg: avgHR,
        hrPeak: peakHR > 0 ? peakHR : avgHR,
        minutesInBand: preview['minutesInBand'],
        totalMinutes: duration,
        targetZone: preview['zone'],
      );

      setState(() {
        _athleteData[athleteId] = {
          'restingHR': restingHR,
          'age': age,
          'avgHR': avgHR,
          'peakHR': peakHR,
          'duration': duration,
          'category': category,
          'type': type,
          'hrrPercentage': preview['hrrPercentage'],
          'zone': preview['zone'],
          'targetRange': preview['targetRange'],
          'minutesInBand': preview['minutesInBand'],
          'compliance': preview['compliance'],
          'score': score,
        };
      });
    }
  }

  Future<void> _submitTrainingLogs() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final trainingLogProvider =
        Provider.of<TrainingLogProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      bool allSuccess = true;

      for (var athlete in _teamAthletes) {
        final data = _athleteData[athlete.userId];

        if (data != null && data['avgHR'] > 0 && data['duration'] > 0) {
          final success = await trainingLogProvider.createTrainingLogWithHRR(
            teamId: widget.teamId,
            programId: widget.programId,
            athleteId: athlete.userId,
            hrRest: data['restingHR'],
            age: data['age'],
            hrAvg: data['avgHR'],
            hrPeak: data['peakHR'] > 0 ? data['peakHR'] : data['avgHR'],
            totalMinutes: data['duration'],
            category: data['category'],
            type: data['type'],
            inputBy: authProvider.user?.uid ?? '',
          );

          if (!success) {
            allSuccess = false;
          }
        }
      }

      if (allSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Training logs berhasil disimpan!'),
            backgroundColor: Color(0xFF00BF63),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Beberapa training log gagal disimpan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _restingHRControllers.values) {
      controller.dispose();
    }
    for (var controller in _ageControllers.values) {
      controller.dispose();
    }
    for (var controller in _avgHRControllers.values) {
      controller.dispose();
    }
    for (var controller in _peakHRControllers.values) {
      controller.dispose();
    }
    for (var controller in _durationControllers.values) {
      controller.dispose();
    }
    for (var controller in _categoryControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final teamProvider = Provider.of<TeamProvider>(context);

    // Check if user is coach
    final userRole = teamProvider.userTeamRoles
        .where((role) =>
            role.teamId == widget.teamId &&
            role.userId == authProvider.user?.uid)
        .firstOrNull;

    final isCoach = userRole?.role == 'Coach';

    if (!isCoach) {
      return _buildUnauthorizedView(
          'Hanya pelatih yang dapat menginput training log');
    }

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
          'Input Training Log',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: _isLoadingAthletes
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BF63)),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _teamAthletes.length,
                    itemBuilder: (context, index) {
                      final athlete = _teamAthletes[index];
                      return _buildAthleteCard(athlete);
                    },
                  ),
                ),
                _buildSubmitButton(),
              ],
            ),
    );
  }

  Widget _buildAthleteCard(UserTeamRole athlete) {
    final data = _athleteData[athlete.userId] ?? {};

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A4A4B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00BF63).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Athlete Info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF00BF63),
                backgroundImage: athlete.userPhotoUrl != null
                    ? NetworkImage(athlete.userPhotoUrl!)
                    : null,
                child: athlete.userPhotoUrl == null
                    ? Text(
                        athlete.userName?.substring(0, 1).toUpperCase() ?? 'A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      athlete.userName ?? 'Unknown Athlete',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (athlete.userEmail != null)
                      Text(
                        athlete.userEmail!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Basic Info Row
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  'Resting HR (bpm)',
                  _restingHRControllers[athlete.userId]!,
                  TextInputType.number,
                  () => _calculateHRRPreview(athlete.userId),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  'Age',
                  _ageControllers[athlete.userId]!,
                  TextInputType.number,
                  () => _calculateHRRPreview(athlete.userId),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Heart Rate Row
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  'Avg HR (bpm)',
                  _avgHRControllers[athlete.userId]!,
                  TextInputType.number,
                  () => _calculateHRRPreview(athlete.userId),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  'Peak HR (bpm)',
                  _peakHRControllers[athlete.userId]!,
                  TextInputType.number,
                  () => _calculateHRRPreview(athlete.userId),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Duration and Category Row
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  'Duration (min)',
                  _durationControllers[athlete.userId]!,
                  TextInputType.number,
                  () => _calculateHRRPreview(athlete.userId),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  'Category',
                  _categoryControllers[athlete.userId]!,
                  TextInputType.text,
                  () => _calculateHRRPreview(athlete.userId),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Exercise Type Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF002122),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF00BF63).withOpacity(0.3),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTypes[athlete.userId],
                isExpanded: true,
                dropdownColor: const Color(0xFF002122),
                style:
                    const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                items: ['Cardio', 'Strength', 'HIIT', 'Recovery', 'Mixed']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTypes[athlete.userId] = value!;
                  });
                  _calculateHRRPreview(athlete.userId);
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // HRR Preview Results
          if (data['avgHR'] != null && data['avgHR'] > 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF002122),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: HRRCalculator.getHRRBandColor(data['zone'] ?? 'Zone 1')
                      .withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HRR Preview',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Zone: ${data['zone'] ?? 'Zone 1'}',
                            style: TextStyle(
                              color: HRRCalculator.getHRRBandColor(
                                  data['zone'] ?? 'Zone 1'),
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'HRR: ${(data['hrrPercentage'] ?? 0.0).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Compliance: ${((data['compliance'] ?? 0.0) * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Color(0xFF00BF63),
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Score: ${(data['score'] ?? 0.0).toStringAsFixed(1)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Target: ${data['targetRange']?['min'] ?? 0}-${data['targetRange']?['max'] ?? 0} bpm',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    'Time in Band: ${data['minutesInBand'] ?? 0}/${data['duration'] ?? 0} min',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
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

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    TextInputType keyboardType,
    VoidCallback onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: (_) => onChanged(),
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF002122),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: const Color(0xFF00BF63).withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: const Color(0xFF00BF63).withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF00BF63),
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitTrainingLogs,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BF63),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : const Text(
                  'Submit Training Logs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildUnauthorizedView(String message) {
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
          'Input Training Log',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock,
              size: 64,
              color: Color(0xFF00BF63),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
