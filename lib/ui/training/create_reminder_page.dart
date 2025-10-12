import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/reminder.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reminder_provider.dart';
import 'package:trainix_app/utils/datetime_x.dart';

class CreateReminderPage extends StatefulWidget {
  final String teamId;
  final String teamName;
  final bool isCoach;
  final String userId;
  final Reminder? reminderToEdit;

  const CreateReminderPage({
    super.key,
    required this.teamId,
    required this.teamName,
    required this.isCoach,
    required this.userId,
    this.reminderToEdit,
  });

  @override
  _CreateReminderPageState createState() => _CreateReminderPageState();
}

class _CreateReminderPageState extends State<CreateReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedAthleteId;
  bool _isLoading = false;

  // Mock data untuk atlet dalam tim
  final List<Map<String, dynamic>> _mockAthletes = [
    {
      'id': 'athlete1',
      'name': 'Budi Santoso',
      'role': 'Atlet',
    },
    {
      'id': 'athlete2',
      'name': 'Dewi Putri',
      'role': 'Atlet',
    },
    {
      'id': 'athlete3',
      'name': 'Eko Prasetyo',
      'role': 'Atlet',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.reminderToEdit != null) {
      // Mengisi form dengan data yang ada jika mode edit
      _titleController.text = widget.reminderToEdit!.title;
      _descriptionController.text = widget.reminderToEdit!.description;
      _selectedDate = widget.reminderToEdit!.targetDate?.toDate() ?? DateTime.now().add(const Duration(days: 1));
      _selectedAthleteId = widget.reminderToEdit!.athleteId;
    } else if (!widget.isCoach) {
      // Jika user adalah atlet, set athleteId ke userId mereka
      _selectedAthleteId = widget.userId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF65EAE8),
              onPrimary: Color(0xFF002122),
              surface: Color(0xFF1A4747),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF002122),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.isCoach && _selectedAthleteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih atlet terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user!;

      // Add team context to the title and description
      final titleWithTeam = _titleController.text.contains(widget.teamName) 
          ? _titleController.text 
          : '${_titleController.text} - ${widget.teamName}';
      
      final descriptionWithTeam = _descriptionController.text.contains(widget.teamName)
          ? _descriptionController.text
          : '${_descriptionController.text}\n\nTim: ${widget.teamName}';

      final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
      
      bool success = false;
      if (widget.reminderToEdit != null) {
        // Update existing reminder
        success = await reminderProvider.updateReminder(
          widget.reminderToEdit!.id,
          {
            'title': titleWithTeam,
            'description': descriptionWithTeam,
            'scheduledAt': asTimestamp(_selectedDate),
            'targetDate': asTimestamp(_selectedDate),
            'athleteId': widget.isCoach ? _selectedAthleteId : currentUser.uid,
            'status': 'pending',
            'updatedAt': asTimestamp(DateTime.now()),
          }
        );
      } else {
        // Create new reminder
        success = await reminderProvider.createReminder({
          'title': titleWithTeam,
          'description': descriptionWithTeam,
          'dateTime': asTimestamp(_selectedDate),
          'scheduledAt': asTimestamp(_selectedDate),
          'targetDate': asTimestamp(_selectedDate),
          'teamId': widget.teamId,
          'createdBy': currentUser.uid,
          'athleteId': widget.isCoach ? _selectedAthleteId : currentUser.uid,
          'status': 'pending',
          'isCompleted': false,
          'createdAt': asTimestamp(DateTime.now()),
        });
      }

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.reminderToEdit == null
                  ? 'Reminder berhasil dibuat'
                  : 'Reminder berhasil diperbarui',
            ),
            backgroundColor: const Color(0xFF00BF63),
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception(widget.reminderToEdit == null 
            ? 'Gagal membuat reminder' 
            : 'Gagal memperbarui reminder');
      }
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.reminderToEdit != null;

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
          isEditing ? 'Edit Pengingat' : 'Buat Pengingat',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF65EAE8)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tim: ${widget.teamName}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (widget.isCoach) _buildAthleteSelector(),
                      const SizedBox(height: 24),
                      _buildTitleField(),
                      const SizedBox(height: 24),
                      _buildDescriptionField(),
                      const SizedBox(height: 24),
                      _buildDateSelector(),
                      const SizedBox(height: 32),
                      _buildSaveButton(isEditing),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAthleteSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Atlet',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A4747),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedAthleteId,
              hint: const Text(
                'Pilih Atlet',
                style: TextStyle(color: Colors.white70),
              ),
              dropdownColor: const Color(0xFF1A4747),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  _selectedAthleteId = value;
                });
              },
              items: _mockAthletes.map((athlete) {
                return DropdownMenuItem<String>(
                  value: athlete['id'],
                  child: Text(athlete['name']),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Judul Reminder',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1A4747),
            hintText: 'Contoh: Latihan Rutin - ${widget.teamName}',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF65EAE8)),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Judul tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deskripsi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1A4747),
            hintText: 'Deskripsi reminder untuk tim ${widget.teamName}...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF65EAE8)),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Deskripsi tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal Target',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A4747),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isEditing) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveReminder,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF65EAE8),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          isEditing ? 'Perbarui Reminder' : 'Simpan Reminder',
          style: const TextStyle(
            color: Color(0xFF002122),
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}