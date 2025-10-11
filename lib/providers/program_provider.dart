import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/program.dart';
import '../services/program_service.dart';

class ProgramProvider extends ChangeNotifier {
  ProgramProvider({
    ProgramService? programService,
    FirebaseAuth? auth,
  })  : _programService = programService ?? ProgramService(),
        _auth = auth ?? FirebaseAuth.instance;

  final ProgramService _programService;
  final FirebaseAuth _auth;

  bool _isLoading = false;
  List<Program> _programs = <Program>[];

  bool get isLoading => _isLoading;
  List<Program> get programs => List.unmodifiable(_programs);

  Future<void> loadPrograms({required bool isCoach}) async {
    final uid = _auth.currentUser?.uid ?? '';
    _isLoading = true;
    notifyListeners();
    try {
      if (uid.isEmpty) {
        _programs = <Program>[];
      } else {
        final items =
            await _programService.getPrograms(userId: uid, isCoach: isCoach);
        _programs = items;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}