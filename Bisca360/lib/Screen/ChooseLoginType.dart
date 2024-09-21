import 'dart:ui';

import 'package:bisca360/Response/UsersAccountsResponse.dart';
import 'package:bisca360/Screen/LoginMPIN.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Service/NavigationHelper.dart';
import 'LoginNew.dart';

class ChooseLoginType extends StatefulWidget {
  final UsersAccountsResponse userAccounts;
   const ChooseLoginType( this.userAccounts,{super.key});

  @override
  State<ChooseLoginType> createState() => _ChooseLoginTypeState();
}

class _ChooseLoginTypeState extends State<ChooseLoginType> {


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
        }, icon: const Icon(Icons.arrow_back,color: Colors.white,)),
        title: const Text('Login',style: TextStyle(color: Colors.white),),
      ),
      body:  Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Padding(
                padding: const EdgeInsets.fromLTRB(0, 80, 0, 0),
                child: RichText(
                  text: const TextSpan(
                    children: <TextSpan>[
                      // TextSpan(
                      //   text: 'Login\n',
                      //   style: TextStyle(
                      //     fontSize: 35,
                      //     color: Colors.black,
                      //   ),
                      // ),
                      TextSpan(
                        text: 'Choose Login Type',
                        style: TextStyle(
                          fontSize: 25, // Smaller font size
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 100,
              ),
              Image.asset(
                'assets/loginGreen.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(
                height: 80,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                    onPressed: () {

                    },
                    child: const Text("Get OTP",style: TextStyle(color: Colors.white),)),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                    onPressed: () {
                      print('Data: ${widget.userAccounts.toString()}');
                      NavigationHelper.navigateWithFadeSlide(
                        context,
                        LoginWithMPIN(
                          usersAccountsResponse: widget.userAccounts,
                        ),
                      );
                    },
                    child: const Text("Login with MPIN",style: TextStyle(color: Colors.white),)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
