import 'dart:convert';
import 'dart:typed_data';

import 'package:bisca360/ApiService/Apis.dart';
import 'package:bisca360/Response/CheckMobileNumberResponse.dart';
import 'package:bisca360/Service/ImageService.dart';
import 'package:flutter/material.dart';

import '../Service/NavigationHelper.dart';
import 'ChooseLoginType.dart';
import 'Login.dart';
import 'LoginNew.dart';

class UserAccounts extends StatefulWidget {
  final CheckMobileNumberResponse saveDateRes;
  const UserAccounts(this.saveDateRes, {super.key});

  @override
  State<UserAccounts> createState() => _UserAccountsState();
}

class _UserAccountsState extends State<UserAccounts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          onPressed: () {
            NavigationHelper.navigateWithFadeSlide(
              context,
              MyPhone(),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyPhone()),
            );
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Accounts',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SizedBox(
        child: widget.saveDateRes.usersAccounts.isNotEmpty
            ? ListView.builder(
          itemCount: widget.saveDateRes.usersAccounts.length,
          itemBuilder: (context, index) {
            final userAccount = widget.saveDateRes.usersAccounts[index];
            final uId = 'U${userAccount.id}';
            const docType = 'profile';

            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: FutureBuilder<Uint8List?>(
                future: ImageService.fetchImage(uId, docType),
                builder: (context, snapshot) {
                  final imageData = snapshot.data;

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: imageData != null
                          ? MemoryImage(imageData)
                          : const AssetImage('assets/user_png.png') as ImageProvider,
                    ),
                    title: Text(
                      userAccount.userName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      userAccount.organizationName,
                      style: TextStyle(color: Colors.black54),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        userAccount.roleName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      print('Data: ${userAccount.toString()}');
                      NavigationHelper.navigateWithFadeSlide(
                        context,
                        ChooseLoginType(userAccount),
                      );
                    },
                  );
                },
              ),
            );
          },
        )
            : const Center(
          child: Text(
            'No Records',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
