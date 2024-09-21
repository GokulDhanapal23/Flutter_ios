import 'dart:convert';

import 'package:flutter/material.dart';

import '../ApiService/Apis.dart';
import 'package:http/http.dart' as http;
import '../Response/CheckMobileNumberResponse.dart';
import 'Home.dart';


void main(){
  runApp(const Login());
}

TextEditingController loginMobileNumberController = TextEditingController();
final _loginForm = GlobalKey<FormState>();
late CheckMobileNumberResponse saveDateRes;



class Login extends StatelessWidget{
  const Login({super.key});


    // Future<void> _signIn(var data, context) async {
    //   // const url = 'http://192.168.0.17:9092/user/check/mobilenumber'; // Example for Android Emulator
    //     await Apis.getClient()
    //         .post(Uri.parse(Apis.checkMobileNumber) ,body: data ,headers: {"Content-Type": "application/json"})
    //         .then((res) async => {
    //     saveDateRes = CheckMobileNumberResponse.fromJson(jsonDecode(res.body)),
    //     if (saveDateRes.status == "OK") {
    //       Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(builder: (context) => const Home()),
    //       ),
    //       print('Data: ${saveDateRes.toString()}'),
    //     } else {
    //       // Error
    //       print('Failed to load data'),
    //     }
    // });
    // }



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
        // bottomNavigationBar: footer(),
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
                        // Image.asset(
                        //   'assets/bisca.png',
                        //   height: 100,
                        //   width: 100,
                        // ),
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
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(0.0),
                                child: Icon(
                                  Icons.mobile_friendly,
                                  color: Colors.blue,
                                ), // icon is 48px widget.
                              ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color:  Colors.lightBlue)
                                ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color:  Colors.lightBlue)
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));
                        //       var signInData ={"mobileNumber": loginMobileNumberController.text};
                        //       _signIn(jsonEncode(signInData),context);
                        //   },
                        //   style: ElevatedButton.styleFrom(
                        //     foregroundColor: Colors.white, backgroundColor: Colors.blue,
                        //     padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(8.0),
                        //     ),
                        //   ),
                        //   child: const Text(
                        //     'Continue',
                        //     style: TextStyle(fontSize: 18),
                        //   ),
                        // ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40.0), // Adjust the value as needed
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: () {
                              var signInData ={"mobileNumber": loginMobileNumberController.text};
                              // _signIn(jsonEncode(signInData),context);

                            },
                            child: Text(
                              'Continue',
                              style: const TextStyle(fontSize: 18).copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                        ,
                      ],
                    )
                ),
              ),
            ]
        )
    );

  }

}

