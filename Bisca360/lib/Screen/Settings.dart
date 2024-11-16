import 'package:bisca360/Screen/About.dart';
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
          // ListTile(
          //   title: Text('Enable notifications'),
          //   subtitle: Text('Receive alerts for updates'),
          //   leading: Icon(Icons.notifications),
          //   trailing: Switch(
          //     value: _notificationsEnabled,
          //     onChanged: (bool value) {
          //       setState(() {
          //         _notificationsEnabled = value;
          //       });
          //     },
          //   ),
          // ),
          // ListTile(
          //   title: Text('Dark Mode'),
          //   subtitle: Text('Switch between light and dark themes'),
          //   leading: Icon(Icons.brightness_2),
          //   trailing: Switch(
          //     value: _darkModeEnabled,
          //     onChanged: (bool value) {
          //       setState(() {
          //         _darkModeEnabled = value;
          //       });
          //     },
          //   ),
          // ),
          ListTile(
            title: Text('Setup MPIN'),
            leading: Icon(Icons.password),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SetUpMPIN()),
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text('App version Code'),
            leading: Icon(Icons.code),
            subtitle: Text('2024102520'),
            onTap: () {
              // Navigate to account settings
            },
          ),
          Divider(),
          ListTile(
            title: Text('App Version'),
            leading: Icon(Icons.app_settings_alt),
            subtitle: Text('1.0.0+1'),
            onTap: () {
              // Navigate to account settings
            },
          ),
          // Divider(),
          // ListTile(
          //     title: Text('Account'),
          //     subtitle: Text('Manage your account settings'),
          //     onTap: () {
          //     // Navigate to account settings
          //     },
          //     ),
          // Divider(),
          //     ListTile(
          //     title: Text('Privacy'),
          //     subtitle: Text('Control your privacy settings'),
          //     onTap: () {
          //     // Navigate to privacy settings
          //
          //   },
          // ),
          Divider(),
          ListTile(
            title: Text('About'),
            leading: Icon(Icons.info_outline),
            subtitle: Text('Learn more about the app'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) =>  About()),
              );
            },
          ),
        ],
      ),
    );
  }
}
