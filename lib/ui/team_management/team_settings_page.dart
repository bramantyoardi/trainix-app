import 'package:flutter/material.dart';
import '../components/top_navbar.dart';

class TeamSettingsPage extends StatefulWidget {
  final String teamId;
  final String teamName;
  final bool isCoach;

  const TeamSettingsPage({
    Key? key,
    required this.teamId,
    required this.teamName,
    required this.isCoach,
  }) : super(key: key);

  @override
  _TeamSettingsPageState createState() => _TeamSettingsPageState();
}

class _TeamSettingsPageState extends State<TeamSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sportController = TextEditingController();

  bool _isPrivate = false;
  bool _allowJoinRequests = true;
  bool _notificationsEnabled = true;
  String _invitationCode = 'TRX2024ABC';

  @override
  void initState() {
    super.initState();
    _loadTeamSettings();
  }

  void _loadTeamSettings() {
    // Mock data - replace with actual Firebase call
    _teamNameController.text = widget.teamName;
    _descriptionController.text = 'Tim basket untuk kompetisi regional 2024';
    _sportController.text = 'Basketball';
    _isPrivate = false;
    _allowJoinRequests = true;
    _notificationsEnabled = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation
            TopNavBar(),
            const SizedBox(height: 20),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Team Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Team Information Section
                      _buildSectionTitle('Team Information'),
                      const SizedBox(height: 15),

                      if (widget.isCoach) ...[
                        _buildTextField(
                          controller: _teamNameController,
                          label: 'Team Name',
                          icon: Icons.group,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _sportController,
                          label: 'Sport',
                          icon: Icons.sports_basketball,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          icon: Icons.description,
                          maxLines: 3,
                        ),
                      ] else ...[
                        _buildReadOnlyField(
                            'Team Name', _teamNameController.text),
                        _buildReadOnlyField('Sport', _sportController.text),
                        _buildReadOnlyField(
                            'Description', _descriptionController.text),
                      ],

                      const SizedBox(height: 30),

                      // Privacy Settings Section
                      _buildSectionTitle('Privacy Settings'),
                      const SizedBox(height: 15),

                      _buildSwitchTile(
                        title: 'Private Team',
                        subtitle: 'Only invited members can join',
                        value: _isPrivate,
                        onChanged: widget.isCoach
                            ? (value) {
                                setState(() {
                                  _isPrivate = value;
                                });
                              }
                            : null,
                      ),

                      _buildSwitchTile(
                        title: 'Allow Join Requests',
                        subtitle: 'Members can request to join',
                        value: _allowJoinRequests,
                        onChanged: widget.isCoach
                            ? (value) {
                                setState(() {
                                  _allowJoinRequests = value;
                                });
                              }
                            : null,
                      ),

                      const SizedBox(height: 30),

                      // Invitation Code Section
                      _buildSectionTitle('Invitation Code'),
                      const SizedBox(height: 15),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFF3A3A3A),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Current Code',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      _invitationCode,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                                if (widget.isCoach)
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: _copyInvitationCode,
                                        icon: const Icon(
                                          Icons.copy,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: _regenerateInvitationCode,
                                        icon: const Icon(
                                          Icons.refresh,
                                          color: Colors.orange,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Notification Settings
                      _buildSectionTitle('Notifications'),
                      const SizedBox(height: 15),

                      _buildSwitchTile(
                        title: 'Team Notifications',
                        subtitle: 'Receive updates about team activities',
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),

                      const SizedBox(height: 30),

                      // Action Buttons
                      if (widget.isCoach) ...[
                        _buildSectionTitle('Team Management'),
                        const SizedBox(height: 15),
                        _buildActionButton(
                          title: 'Transfer Ownership',
                          subtitle: 'Transfer team ownership to another coach',
                          icon: Icons.swap_horiz,
                          color: Colors.orange,
                          onTap: _showTransferOwnershipDialog,
                        ),
                        const SizedBox(height: 15),
                        _buildActionButton(
                          title: 'Delete Team',
                          subtitle: 'Permanently delete this team',
                          icon: Icons.delete_forever,
                          color: Colors.red,
                          onTap: _showDeleteTeamDialog,
                        ),
                      ] else ...[
                        _buildSectionTitle('Team Actions'),
                        const SizedBox(height: 15),
                        _buildActionButton(
                          title: 'Leave Team',
                          subtitle: 'Leave this team permanently',
                          icon: Icons.exit_to_app,
                          color: Colors.red,
                          onTap: _showLeaveTeamDialog,
                        ),
                      ],

                      const SizedBox(height: 30),

                      // Save Button
                      if (widget.isCoach)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saveSettings,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'Save Settings',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: Colors.white,
        fontFamily: 'Poppins',
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.grey,
          fontFamily: 'Poppins',
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.grey,
        ),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFF3A3A3A),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFF3A3A3A),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.blue,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF3A3A3A),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF3A3A3A),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _copyInvitationCode() {
    // Copy to clipboard logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invitation code copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _regenerateInvitationCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Regenerate Code',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        content: const Text(
          'Are you sure you want to regenerate the invitation code? The old code will no longer work.',
          style: TextStyle(
            color: Colors.grey,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _invitationCode = 'TRX2024XYZ'; // Mock new code
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invitation code regenerated'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Regenerate',
              style: TextStyle(
                color: Colors.orange,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTransferOwnershipDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Transfer Ownership',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        content: const Text(
          'Select a coach to transfer team ownership to. You will lose admin privileges.',
          style: TextStyle(
            color: Colors.grey,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to coach selection page
            },
            child: const Text(
              'Select Coach',
              style: TextStyle(
                color: Colors.orange,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteTeamDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Delete Team',
          style: TextStyle(
            color: Colors.red,
            fontFamily: 'Poppins',
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this team? This action cannot be undone and all team data will be lost.',
          style: TextStyle(
            color: Colors.grey,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to teams list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Team deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLeaveTeamDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Leave Team',
          style: TextStyle(
            color: Colors.red,
            fontFamily: 'Poppins',
          ),
        ),
        content: const Text(
          'Are you sure you want to leave this team? You will need to be invited again to rejoin.',
          style: TextStyle(
            color: Colors.grey,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to teams list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Left team successfully'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text(
              'Leave',
              style: TextStyle(
                color: Colors.red,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      // Save settings logic - replace with Firebase call
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _descriptionController.dispose();
    _sportController.dispose();
    super.dispose();
  }
}
