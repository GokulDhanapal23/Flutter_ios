import 'dart:convert';

import 'package:flutter/material.dart';

import 'Home.dart';


void main(){
  runApp(const Login());
}

TextEditingController loginMobileNumberController = TextEditingController();
final _loginForm = GlobalKey<FormState>();
// late CheckMobileNumberResponse saveDateRes;



class Login extends StatelessWidget{
  const Login({super.key});



  static Widget footer() {
    return Container(
      height: 35,
      padding: const EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 5),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '                            All rights reserved @',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          Text('bisca.com                            ', style: TextStyle(fontSize: 13, color: Colors.blueAccent))
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        bottomNavigationBar: footer(),
        body: Stack(
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF00B0FF),
                      Color(0xFF0D47A1),

                    ],
                  ),
                ),
                child:  Padding(
                  padding: const EdgeInsets.fromLTRB(22, 150, 0, 20),
                  child: RichText(
                    text: const TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Welcome\n',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: 'Thanks for choosing Bisca',
                          style: TextStyle(
                            fontSize: 20, // Smaller font size
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 270),
                child: Container(
                    decoration:  const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30)
                        ),
                        color: Colors.white
                    ),
                    height: double.infinity,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         SizedBox(
                          width: 350,
                          child: TextFormField(
                            maxLength: 10,
                            obscureText: false,
                            controller: loginMobileNumberController,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Mobile Number',
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color:  Colors.lightBlue)
                                ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color:  Colors.lightBlue)
                              ),
                            ),
                          ),
                        ),
                        // TextFormField(
                        //   maxLength: 10,
                        //   textInputAction: TextInputAction.next,
                        //   controller: loginMobileNumberController,
                        //   autovalidateMode: AutovalidateMode.onUserInteraction,
                        //   style: const TextStyle(fontSize: 14),
                        //   decoration: InputDecoration(
                        //     hintText: 'Mobile Number',
                        //     counterText: "",
                        //     filled: true,
                        //     suffixIcon: IconButton(
                        //       icon: const Icon(Icons.clear),
                        //       splashRadius: 10,
                        //       onPressed: () {
                        //         loginMobileNumberController.clear();
                        //       },
                        //     ),
                        //     fillColor: Colors.white70,
                        //     enabledBorder: OutlineInputBorder(
                        //       borderSide: const BorderSide(color: Colors.black),
                        //       borderRadius: BorderRadius.circular(15),
                        //     ),
                        //     focusedBorder: OutlineInputBorder(
                        //       borderSide: BorderSide(color: Colors.blueGrey.shade50),
                        //       borderRadius: BorderRadius.circular(15),
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));

                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    )
                ),
              ),
            ]
        )
    );

  }

}