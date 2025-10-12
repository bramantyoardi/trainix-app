import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/reminder.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/team_provider.dart';
import '../components/bottom_navbar.dart';
import '../homepage.dart';
import '../settings_page.dart';
import 'create_reminder_page.dart';

class ReminderListPage extends StatefulWidget {
  final String teamId;
  final String teamName;

  const ReminderListPage({
    Key? key,
    required this.teamId,
    required this.teamName,
  }) : super(key: key);

  @override
  _ReminderListPageState createState() => _ReminderListPageState();
}

class _ReminderListPageState extends State<ReminderListPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load reminders when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
      reminderProvider.loadTeamReminders(widget.teamId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002122),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button and Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reminder',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.teamName,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      final teamProvider = Provider.of<TeamProvider>(context, listen: false);
                      
                      // Check if user is coach in the team
                      final isCoach = teamProvider.isUserCoach(widget.teamId);
                      
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateReminderPage(
                            teamId: widget.teamId,
                            teamName: widget.teamName,
                            isCoach: isCoach,
                            userId: authProvider.user?.uid ?? '',
                          ),
                        ),
                      );
                      
                      if (result == true) {
                        // Refresh reminders
                        final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
                        reminderProvider.loadTeamReminders(widget.teamId);
                      }
                    },
                    backgroundColor: const Color(0xFF65EAE8),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Tab Bar
              _buildTabBar(),
              
              const SizedBox(height: 20),
              
              // Tab Bar View
              Expanded(
                child: Consumer<ReminderProvider>(
                  builder: (context, reminderProvider, child) {
                    if (reminderProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF65EAE8),
                        ),
                      );
                    }

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildReminderList(reminderProvider.reminders, false),
                        _buildReminderList(reminderProvider.reminders, true),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1, // Training tab (index 1 untuk training)
        onTap: (index) {
          switch (index) {
            case 0: // Home
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
              break;
            case 1: // Training (current page, do nothing)
              break;
            case 3: // Settings
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFF1A4747),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: const Color(0xFF65EAE8),
        ),
        labelColor: const Color(0xFF002122),
        unselectedLabelColor: Colors.white,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Aktif'),
          Tab(text: 'Selesai'),
        ],
      ),
    );
  }

  Widget _buildReminderList(List<Reminder> allReminders, bool isCompleted) {
    final filteredReminders = allReminders.where(
      (reminder) => isCompleted
          ? reminder.status == 'completed'
          : reminder.status == 'pending',
    ).toList();

    if (filteredReminders.isEmpty) {
      return _buildEmptyState(isCompleted);
    }

    return ListView.builder(
      itemCount: filteredReminders.length,
      itemBuilder: (context, index) {
        final reminder = filteredReminders[index];
        return _buildReminderCard(reminder);
      },
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    final targetDate = (reminder.targetDate ?? reminder.dateTime).toDate();
    final isOverdue = targetDate.isBefore(DateTime.now()) && reminder.status == 'pending';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A4747),
        borderRadius: BorderRadius.circular(12),
        border: isOverdue 
            ? Border.all(color: Colors.red.withOpacity(0.5), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  reminder.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isOverdue)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Overdue',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reminder.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: Colors.white.withOpacity(0.5),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(Timestamp.fromDate(targetDate)),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              if (reminder.status == 'pending')
                ElevatedButton(
                  onPressed: () => _markAsCompleted(reminder),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BF63),
                    minimumSize: const Size(80, 32),
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isCompleted) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCompleted ? Icons.task_alt : Icons.assignment,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            isCompleted
                ? 'Belum ada reminder yang selesai'
                : 'Belum ada reminder aktif',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap tombol + untuk membuat reminder baru',
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

  void _markAsCompleted(Reminder reminder) async {
    final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
    final success = await reminderProvider.updateReminderStatus(reminder.id, 'completed');
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder marked as completed'),
          backgroundColor: Color(0xFF00BF63),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update reminder'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Hari ini';
    } else if (difference == 1) {
      return 'Besok';
    } else if (difference == -1) {
      return 'Kemarin';
    } else if (difference > 1) {
      return '${difference} hari lagi';
    } else {
      return '${difference.abs()} hari yang lalu';
    }
  }
}