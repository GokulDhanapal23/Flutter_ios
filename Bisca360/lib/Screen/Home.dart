import 'package:bisca360/Screen/Login.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget{
  const Home({super.key});



  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home>{
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
      title: const Text('Home'),
        leading: IconButton(
          icon: const Icon(Icons.menu), onPressed: () {
        },
        ),
        actions: [
          IconButton(onPressed: (){

          }, icon: const Icon(Icons.account_circle_outlined)),
          IconButton(onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
          }, icon: const Icon(Icons.logout)),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to Home',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }

}