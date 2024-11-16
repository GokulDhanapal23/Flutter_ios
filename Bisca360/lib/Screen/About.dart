import 'package:flutter/material.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: const Text('Help and Support', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 500,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/bisca.png'), // Replace with your image asset
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 2,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/bisca.png'), // Replace with your image asset
                    ),
                    SizedBox(height: 20),
                    Image.asset(
                      'assets/bisca.png', // Replace with your image asset
                      width: 100,
                      height: 100,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Company Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/bisca.png'), // Replace with your image asset
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Hint Phone',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Column(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/bisca.png'), // Replace with your image asset
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Hint Email ID',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Column(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/bisca.png'), // Replace with your image asset
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Hint WhatsApp',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 40),
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WHO WE ARE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 25),
                // Text(
                //   'A web application, mobile apps development and software services company enable us to remain agile and responsive to customer needs.We excel in AI/ML, Blockchain, IOT, cloud and mobile technology solutions. We established in 2020 and headquartered in Bangalore, India. Abytz tech solution is a team that has a passion for developing and delivering enterprise-grade applications. We have dedicated groups of highly-skilled and creative programmers who all hungry for fresh perspective, technical innovations and rapid execution',
                //   style: TextStyle(
                //     color: Colors.grey,
                //     fontSize: 14,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
