import 'package:flutter/material.dart';
import '../../models/program.dart';

class CreateProgramPage extends StatefulWidget {
  final String teamId;
  final String teamName;
  final Program? programToEdit; // Null jika membuat baru, berisi data jika mengedit

  const CreateProgramPage({
    Key? key,
    required this.teamId,
    required this.teamName,
    this.programToEdit,
  }) : super(key: key);

  @override
  _CreateProgramPageState createState() => _CreateProgramPageState();
}

class _CreateProgramPageState extends State<CreateProgramPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  List<String> _selectedCategories = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.programToEdit != null) {
      // Mengisi form dengan data yang ada jika mode edit
      // Program model baru tidak punya description, gunakan template atau kosongkan
      _selectedCategories = List.from(widget.programToEdit!.categories);
      _selectedDate = widget.programToEdit!.weekAnchor.toDate();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _addCategory() {
    final category = _categoryController.text.trim();
    if (category.isNotEmpty && !_selectedCategories.contains(category)) {
      setState(() {
        _selectedCategories.add(category);
        _categoryController.clear();
      });
    }
  }

  void _removeCategory(String category) {
    setState(() {
      _selectedCategories.remove(category);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
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

  Future<void> _saveProgram() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tambahkan minimal satu kategori'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

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
          SnackBar(
            content: Text(
              widget.programToEdit == null
                  ? 'Program latihan berhasil dibuat'
                  : 'Program latihan berhasil diperbarui',
            ),
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.programToEdit != null;

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
          isEditing ? 'Edit Program Latihan' : 'Buat Program Latihan',
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
                      _buildDateSelector(),
                      const SizedBox(height: 24),
                      _buildDescriptionField(),
                      const SizedBox(height: 24),
                      _buildCategoriesSection(),
                      const SizedBox(height: 32),
                      _buildSaveButton(isEditing),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal Program',
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

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deskripsi Program',
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
            hintText: 'Masukkan deskripsi program latihan',
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

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _categoryController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1A4747),
                  hintText: 'Tambahkan kategori',
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
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addCategory,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF65EAE8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Tambah',
                style: TextStyle(
                  color: Color(0xFF002122),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedCategories.map((category) {
            return Chip(
              label: Text(
                category,
                style: const TextStyle(
                  color: Color(0xFF002122),
                  fontFamily: 'Poppins',
                ),
              ),
              backgroundColor: const Color(0xFF65EAE8),
              deleteIconColor: const Color(0xFF002122),
              onDeleted: () => _removeCategory(category),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isEditing) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveProgram,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF65EAE8),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          isEditing ? 'Perbarui Program' : 'Simpan Program',
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