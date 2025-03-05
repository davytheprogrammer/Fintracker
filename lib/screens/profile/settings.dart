import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool notificationsEnabled = true;
  bool _isLoading = false;
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      });

      // Also load from Firestore if available
      if (currentUser != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            notificationsEnabled = userDoc.data()?['notifications_enabled'] ?? true;
          });
        }
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> _updateNotificationSettings(bool value) async {
    try {
      setState(() {
        notificationsEnabled = value;
        _isLoading = true;
      });

      // Update local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', value);

      // Update Firestore
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser!.uid).update({
          'notifications_enabled': value,
          'last_updated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating notification settings')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePassword(String currentPassword, String newPassword) async {
    try {
      setState(() => _isLoading = true);

      // Reauthenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: currentPassword,
      );
      await currentUser!.reauthenticateWithCredential(credential);

      // Update password
      await currentUser!.updatePassword(newPassword);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password updated successfully')),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      if (e.code == 'wrong-password') {
        errorMessage = 'Current password is incorrect';
      } else if (e.code == 'weak-password') {
        errorMessage = 'New password is too weak';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAccount(String confirmText) async {
    if (confirmText != 'DELETE') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please type DELETE to confirm')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Delete user data from Firestore
      await _firestore.collection('users').doc(currentUser!.uid).delete();

      // Delete user authentication
      await currentUser!.delete();

      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        // Handle reauthentication
        _showReauthenticateDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: ${e.message}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showReauthenticateDialog() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Re-authenticate Required"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Please enter your password to continue"),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("CANCEL"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("CONFIRM"),
            onPressed: () async {
              try {
                AuthCredential credential = EmailAuthProvider.credential(
                  email: currentUser!.email!,
                  password: passwordController.text,
                );
                await currentUser!.reauthenticateWithCredential(credential);
                Navigator.pop(context);
                // Retry delete operation
                _deleteAccount('DELETE');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invalid password')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDarkMode
                    ? [Colors.grey[900]!, Colors.grey[850]!]
                    : [Colors.grey[50]!, Colors.white],
              ),
            ),
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                _buildUserInfo(),
                SizedBox(height: 24),
                _buildSection(
                  title: "Account & Privacy",
                  children: [
                    _buildSettingTile(
                      icon: Icons.notifications,
                      title: "Notification Settings",
                      subtitle: "Manage your notification preferences",
                      trailing: Switch(
                        value: notificationsEnabled,
                        onChanged: (value) => _updateNotificationSettings(value),
                      ),
                    ),
                    _buildSettingTile(
                      icon: Icons.vpn_key,
                      title: "Password Manager",
                      subtitle: "Update your password and security settings",
                      onTap: () => _showPasswordManager(),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                _buildSection(
                  title: "Danger Zone",
                  children: [
                    _buildSettingTile(
                      icon: Icons.person_remove,
                      title: "Delete Account",
                      subtitle: "Permanently remove your account and data",
                      iconColor: Colors.red,
                      onTap: () => _showDeleteAccountDialog(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    final user = FirebaseAuth.instance.currentUser;
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? Icon(Icons.person, size: 30)
                  : null,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? 'User',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? theme.colorScheme.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor ?? theme.colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        trailing: trailing ?? Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.iconTheme.color,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showPasswordManager() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Current Password",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("CANCEL"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("UPDATE"),
            onPressed: () => _updatePassword(
              currentPasswordController.text,
              newPasswordController.text,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Delete Account",
          style: TextStyle(color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Are you sure you want to delete your account? "
                  "This action cannot be undone and all your data will be permanently removed.",
            ),
            SizedBox(height: 16),
            TextField(
              controller: confirmController,
              decoration: InputDecoration(
                labelText: "Type 'DELETE' to confirm",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("CANCEL"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(
              "DELETE ACCOUNT",
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () => _deleteAccount(confirmController.text),
          ),
        ],
      ),
    );
  }
}