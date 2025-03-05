import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../authentication/authenticate.dart';
import 'profile.dart';
import 'appearance.dart';
import 'settings.dart';

class AccountPage extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<Map<String, String>> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      return {'name': 'Guest', 'email': 'guest@example.com'};
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data();
      return {
        'name': data?['fullName'] ?? 'No Name',
        'email': data?['email'] ?? user.email ?? 'No Email',
      };
    }

    return {'name': 'No Name', 'email': user.email ?? 'No Email'};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account Settings"),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Donate Today banner card
            Card(
              color: Colors.blue[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.favorite, color: Colors.blue),
                title: Text("Donate Today", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Support us and make a difference."),
                trailing: Icon(Icons.arrow_forward, color: Colors.blue),
                onTap: () {
                  // Handle donation navigation here
                },
              ),
            ),
            SizedBox(height: 20),

            // User data card with FutureBuilder
            FutureBuilder<Map<String, String>>(
              future: _fetchUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error loading user data"));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text("No user data available"));
                }

                final userData = snapshot.data!;
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.person, color: Colors.white),
                      backgroundColor: Colors.teal,
                    ),
                    title: Text(userData['name']!,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(userData['email']!),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                  ),
                );
              },
            ),

            // Divider for separation
            Divider(thickness: 1, color: Colors.teal[100]),

            // Settings section
            Column(
              children: [
                _buildSettingsTile(
                    context,
                    Icons.palette,
                    "App appearance",
                    AppearancePage()
                ),
                _buildSettingsTile(
                    context,
                    Icons.group,
                    "Invite your friends",
                    null
                ),
                _buildSettingsTile(
                    context,
                    Icons.settings,
                    "Settings",
                    SettingsPage()
                ),
              ],
            ),

            // Divider for separation
            Divider(thickness: 1, color: Colors.teal[100]),

            // Log out card
            Card(
              color: Colors.red[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text(
                  "Log out",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold
                  ),
                ),
                onTap: () async {
                  try {
                    await _auth.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Authenticate(),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error logging out. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build settings tiles
  ListTile _buildSettingsTile(
      BuildContext context,
      IconData icon,
      String title,
      Widget? destinationPage
      ) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w500)
      ),
      trailing: Icon(Icons.arrow_forward, color: Colors.teal),
      onTap: () {
        if (destinationPage != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destinationPage),
          );
        }
      },
    );
  }
}