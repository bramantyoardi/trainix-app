import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/reminder.dart';
import '../../providers/reminder_provider.dart';
import '../training/reminder_list_page.dart';

class RemindersSection extends StatefulWidget {
  final String teamId;
  final String teamName;
  final bool isCoach;
  final String userId;

  const RemindersSection({
    super.key,
    required this.teamId,
    required this.teamName,
    required this.isCoach,
    required this.userId,
  });

  @override
  State<RemindersSection> createState() => _RemindersSectionState();
}

class _RemindersSectionState extends State<RemindersSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
      if (widget.teamId.isNotEmpty) {
        reminderProvider.loadTeamReminders(widget.teamId);
      } else {
        reminderProvider.loadAthleteReminders(widget.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reminders',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReminderListPage(
                      teamId: widget.teamId,
                      teamName: widget.teamName,
                    ),
                  ),
                );
              },
              child: const Text(
                'See All',
                style: TextStyle(
                  color: Color(0xFF65EAE8),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Consumer<ReminderProvider>(
          builder: (context, reminderProvider, child) {
            if (reminderProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00BF63),
                ),
              );
            }

            final reminders = reminderProvider.reminders
                .where((reminder) => reminder.status == 'pending')
                .take(3)
                .toList();

            if (reminders.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: reminders.map((reminder) => _buildReminderCard(reminder)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF032B2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.notifications_none,
            color: Colors.white54,
            size: 48,
          ),
          SizedBox(height: 12),
          Text(
            'No reminders yet',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Create your first reminder to get started',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    final targetDate = reminder.targetDate?.toDate();
    final isOverdue = targetDate?.isBefore(DateTime.now()) ?? false;
    
    return GestureDetector(
      onTap: () => _navigateToReminderDetail(reminder), // Added onTap handler
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Overdue',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 10,
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
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: const Color(0xFF65EAE8),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(reminder.targetDate?.toDate() ?? reminder.dateTime.toDate()),
                  style: const TextStyle(
                    color: Color(0xFF65EAE8),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToReminderDetail(Reminder reminder) {
    // Navigate to ReminderListPage with specific reminder highlighted
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReminderListPage(
          teamId: reminder.teamId,
          teamName: 'Team', // You might want to pass actual team name
        ),
      ),
    );
    
    // Also show detail dialog
    _showReminderDetailDialog(reminder);
  }

  void _showReminderDetailDialog(Reminder reminder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A4747),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            reminder.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reminder.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    color: Color(0xFF65EAE8),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(reminder.targetDate?.toDate() ?? reminder.dateTime.toDate()),
                    style: const TextStyle(
                      color: Color(0xFF65EAE8),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            if (widget.isCoach && reminder.status == 'pending')
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _markAsCompleted(reminder);
                },
                child: const Text(
                  'Mark as Completed',
                  style: TextStyle(
                    color: Color(0xFF00BF63),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        );
      },
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

  String _formatDate(DateTime date) {
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