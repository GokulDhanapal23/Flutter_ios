import 'package:bisca360/Screen/SetupMPIN.dart';
import 'package:flutter/material.dart';

import '../Service/NavigationHelper.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<Settings> {
  bool _notificationsEnabled = false;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.green,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Text('Enable notifications'),
            subtitle: Text('Receive alerts for updates'),
            leading: Icon(Icons.notifications),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text('Dark Mode'),
            subtitle: Text('Switch between light and dark themes'),
            leading: Icon(Icons.brightness_2),
            trailing: Switch(
              value: _darkModeEnabled,
              onChanged: (bool value) {
                setState(() {
                  _darkModeEnabled = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text('Setup MPIN'),
            leading: Icon(Icons.password),
            onTap: (){
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SetUpMPIN()),
              );
                 },
              ),
              Divider(),
              ListTile(
              title: Text('Account'),
              subtitle: Text('Manage your account settings'),
              onTap: () {
              // Navigate to account settings
              },
              ),
              ListTile(
              title: Text('Privacy'),
              subtitle: Text('Control your privacy settings'),
              onTap: () {
              // Navigate to privacy settings

            },
          ),
          ListTile(
            title: Text('About'),
            subtitle: Text('Learn more about the app'),
            onTap: () {
              // Navigate to about page
            },
          ),
        ],
      ),
    );
  }
}
