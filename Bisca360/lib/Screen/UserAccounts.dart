import 'package:bisca360/ApiService/Apis.dart';
import 'package:bisca360/Response/CheckMobileNumberResponse.dart';
import 'package:bisca360/Screen/Home.dart';
import 'package:bisca360/Service/ImageService.dart';
import 'package:bisca360/Service/LoginService.dart';
import 'package:flutter/material.dart';

import '../Service/NavigationHelper.dart';
import 'ChooseLoginType.dart';
import 'Login.dart';
import 'LoginNew.dart';

class UserAccounts extends StatefulWidget {
  final CheckMobileNumberResponse saveDateRes;
  const UserAccounts( this.saveDateRes,{super.key});

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
        leading: IconButton(onPressed: (){
          NavigationHelper.navigateWithFadeSlide(
            context,
            MyPhone(),
          );
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyPhone()));
        }, icon: const Icon(Icons.arrow_back,color: Colors.white,)),
        title: const Text('Accounts',style: TextStyle(color: Colors.white),),
      ),
      body: SizedBox(
      child: saveDateRes.usersAccounts.isNotEmpty
      ?  ListView.builder(
          itemCount: saveDateRes.usersAccounts.length,
          itemBuilder: (context,index){
            String uId = '${saveDateRes.usersAccounts[index].id}';
            // var imageUrl = ImageService.fetchImage('profile',uId);
            return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Margin around the card
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
            leading: CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage('assets/user_png.png'),
            ),
            title: Text(
            saveDateRes.usersAccounts[index].userName,
            style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
            saveDateRes.usersAccounts[index].organizationName,
            style: TextStyle(color: Colors.black54),
            ),
            trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
            saveDateRes.usersAccounts[index].roleName,
            style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            ),
            ),
            ),
            onTap: () {
            print('Data: ${saveDateRes.usersAccounts[index].toString()}');
            NavigationHelper.navigateWithFadeSlide(
              context,
              ChooseLoginType(saveDateRes.usersAccounts[index]),
            );
            },
            ),
            );
          })
        : const Text(
    'No Records',
    style: TextStyle(color: Colors.red),
    )

    ),
    );
  }
}

