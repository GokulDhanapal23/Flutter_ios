import 'dart:convert';
import 'dart:typed_data';

import 'package:bisca360/Screen/Measurements.dart';
import 'package:bisca360/Screen/ShopBillingHistory.dart';
import 'package:bisca360/Screen/ShopOrder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ApiService/Apis.dart';
import '../Response/SigninResponse.dart';
import '../Service/ImageService.dart';
import 'AddShop.dart';
import 'Customers.dart';
import 'LoginNew.dart';
import 'Profile.dart';
import 'Projects.dart';
import 'Settings.dart';
import 'ShopBilling.dart';
import 'ShopBillingReport.dart';
import 'ShopProduct.dart';
import 'Shops.dart';

class Home extends StatefulWidget {
  final SigninResponse? signinResponse;

  const Home({super.key, required this.signinResponse});

  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  late Future<Uint8List?> imageData;
  static final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    final user = widget.signinResponse!;
    final id = user.id!;
    String uId = 'U$id';
    imageData = ImageService.fetchImage(uId, 'profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.green,
            // leading: Icon(Icons.sort_sharp, color: Colors.white, size: 30),
            actions: [
              IconButton(
                onPressed: () {
                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        title: const Text(
                          'Logout',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        content: const Text(
                          'Are you sure you want to logout?',
                          style: TextStyle(fontSize: 16),
                        ),
                        actions: <Widget>[
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                            ),
                            child: const Text('No',
                                style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('Yes',
                                style: TextStyle(color: Colors.white)),
                            onPressed: () async {
                              SharedPreferences preferences =
                                  await SharedPreferences.getInstance();
                              await preferences.remove('');
                              await storage.delete(key: 'access_token');
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MyPhone()),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.logout_rounded),
                color: Colors.white,
              ),
            ],
            expandedHeight: 50.0, // Set the height of the expanded AppBar
            pinned: false, // Keep the AppBar pinned at the top
            floating: true, // Make the AppBar non-floating
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white, // Background color for the content area
              child: Column(
                children: [
                  _buildHeader(),
                  _buildGrid(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FutureBuilder<Uint8List?>(
      future: imageData,
      builder: (context, snapshot) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                title: Text(
                  '${widget.signinResponse!.userName}!',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${widget.signinResponse!.roleName}',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: CircleAvatar(
                  radius: 50,
                  backgroundImage: snapshot.connectionState ==
                          ConnectionState.waiting
                      ? const AssetImage(
                          'assets/images/loading.png') // Placeholder while loading
                      : (snapshot.hasData && snapshot.data != null)
                          ? MemoryImage(snapshot.data!)
                          : const AssetImage('assets/user_png.png'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrid() {
    return Container(
      color: Colors.green,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(50)),
        ),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 5,
          children: [
            itemDashboard('Shops', CupertinoIcons.shopping_cart,
                Colors.deepOrange, Shop()),
            // itemDashboardImg('Shops', "https://cdn.pixabay.com/photo/2013/07/13/11/31/shop-158317_640.png", Colors.grey, Shop()),
            itemDashboard('Products', CupertinoIcons.graph_circle, Colors.green,
                ShopProduct()),
            itemDashboard(
                'Order', CupertinoIcons.repeat, Colors.green, ShopOrder()),
            itemDashboard('Billing', CupertinoIcons.money_dollar, Colors.purple,
                ShopBilling()),
            itemDashboard(
                'Project', Icons.home_work_outlined, Colors.orange, Projects()),
            // itemDashboard('Customers', CupertinoIcons.person, Colors.teal, Customers()),
            // itemDashboard('Bill History', CupertinoIcons.clock, Colors.brown, ShopBillingHistory()),
            itemDashboard('History', CupertinoIcons.chart_bar, Colors.indigo,
                ShopBillingReport()),
            itemDashboard('Measurements', Icons.ad_units_sharp, Colors.brown,
                Measurements()),
            itemDashboard(
                'Settings', CupertinoIcons.settings, Colors.blue, Settings()),
            itemDashboard(
                'Profile',
                CupertinoIcons.person_alt_circle,
                Colors.pinkAccent,
                ProfileScreen(
                  signInResponse: widget.signinResponse!,
                )),
          ],
        ),
      ),
    );
  }

  Widget itemDashboard(
      String title, IconData iconData, Color background, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                offset: const Offset(1, 2),
                color: Colors.green,
                spreadRadius: 0.3,
                blurRadius: 2,
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: background,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 10),
              Text(
                title.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget itemDashboardImg(
      String title, String imageUrl, Color background, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                offset: const Offset(1, 2),
                color: Colors.green,
                spreadRadius: 0.3,
                blurRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: background,
                  shape: BoxShape.circle,
                ),
                child: ClipPath(
                  // Ensure the image is circular
                  child: Image.network(
                    imageUrl,
                    width: 50, // Set width of the image
                    height: 50, // Set height of the image
                    fit: BoxFit.cover, // Cover the entire circular area
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
