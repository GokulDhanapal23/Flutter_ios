import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../Response/SigninResponse.dart';
import 'package:flutter/cupertino.dart';
import '../Service/ImageService.dart';

class ProfileScreen extends StatefulWidget {
  final SigninResponse signInResponse;

  const ProfileScreen({
    Key? key,
    required this.signInResponse,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Uint8List?> imageData;

  @override
  void initState() {
    super.initState();
    final user = widget.signInResponse;
    final id = user.id!;
    String uId = 'U$id';
    imageData = ImageService.fetchImage(uId, 'profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.green,
        title:
            const Text('User Account', style: TextStyle(color: Colors.white)),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder<Uint8List?>(
              future: imageData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                        'assets/images/loading.png'), // Placeholder while loading
                  );
                } else if (snapshot.hasError || snapshot.data == null) {
                  return const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                        'https://cdn-icons-png.flaticon.com/512/3607/3607444.png'),
                  );
                } else {
                  return CircleAvatar(
                    radius: 50,
                    backgroundImage: MemoryImage(snapshot.data!),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              widget.signInResponse.userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.signInResponse.roleName,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black45,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Organization Details',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InfoRow(
                        icon: Icons.business,
                        value: widget.signInResponse.companyName ?? 'N/A'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Information',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InfoRow(
                        icon: Icons.phone,
                        value: widget.signInResponse.mobileNumber.toString()),
                    const SizedBox(height: 8),
                    InfoRow(
                        icon: Icons.email, value: widget.signInResponse.email),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const InfoRow({
    Key? key,
    required this.icon,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.green), // Change color as needed
        const SizedBox(width: 8), // Space between icon and text
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}
