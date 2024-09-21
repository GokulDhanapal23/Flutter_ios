import 'package:flutter/material.dart';

class Navdrawer extends StatelessWidget{
  const Navdrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(decoration: BoxDecoration(
                color: Colors.green
              ),child:
            Text(
              'Drawer',
              style: TextStyle(color: Colors.black,fontSize: 30),
            ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text('Profile'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {},
            ),

          ],
        ),
    );
  }


}