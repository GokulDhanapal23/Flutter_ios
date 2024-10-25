import 'dart:convert';
import 'dart:typed_data';

import 'package:bisca360/Service/ImageService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../ApiService/Apis.dart';
import '../Response/ShopResponse.dart';
import 'AddShop.dart';

class Shop extends StatefulWidget {
  const Shop({super.key});

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  late List<Shopresponse> shopResponses = [];
  late List<Shopresponse> filteredShops = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  int updateProfile = 0;
  @override
  void initState() {
    super.initState();
    getAllShops();
  }

  void _filterShops(String query) {
    final filtered = shopResponses.where((shop) {
      return shop.shopName.toLowerCase().contains(query.toLowerCase()) ||
          shop.shopType.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      filteredShops = filtered;
    });
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      filteredShops = shopResponses; // Reset to all shops
    });
  }

  void setUpdateProfile(int value) {
    print("Updated Profile count: $value");
    setState(() {
      updateProfile = value;
    });
  }

  void refresh() {
    if (updateProfile == 1) {
      getAllShops();
      updateProfile = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white),
                ),
                onChanged: (value) {
                  _filterShops(value);
                },
              )
            : const Text('Shops', style: TextStyle(color: Colors.white)),
        actions: [
          _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: _stopSearch,
                )
              : IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: _startSearch,
                ),
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddShop(
                      shopResponse: null,
                    ),
                  ),
                );
              },
              icon: Icon(CupertinoIcons.plus_app_fill, color: Colors.white)),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const AddShop(shopResponse: null),
      //       ),
      //     );
      //   },
      //   backgroundColor: Colors.green,
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
      body: filteredShops.isEmpty && shopResponses.isEmpty
          ? const Center(
              child: Text('No Shops',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
          : ListView.builder(
              itemCount: filteredShops.isEmpty
                  ? shopResponses.length
                  : filteredShops.length,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              itemBuilder: (context, index) {
                final shop = filteredShops.isEmpty
                    ? shopResponses[index]
                    : filteredShops[index];
                final id = shop.id!;
                String uId = 'S$id';
                const docType = 'profile';
                return FutureBuilder<Uint8List?>(
                  future: ImageService.fetchImage(uId, docType),
                  builder: (context, snapshot) {
                    final imageData = snapshot.data;
                    return Card(
                      color: Colors.white,
                      shadowColor: Colors.green,
                      margin: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddShop(shopResponse: shop),
                            ),
                          );
                        },
                        title: Text(
                          shop.shopName,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          shop.shopType,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black54),
                        ),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: imageData != null
                              ? MemoryImage(imageData)
                              : const AssetImage('assets/user_png.png'),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.phone, color: Colors.green),
                          onPressed: () {
                            // Handle call action
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Future<void> getAllShops() async {
    try {
      final response = await Apis.getClient().get(
        Uri.parse(Apis.getAllShop),
        headers: Apis.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          shopResponses =
              data.map((item) => Shopresponse.fromJson(item)).toList();
          filteredShops = shopResponses; // Initially, show all shops
        });
      } else {
        print('Failed to load shops');
      }
    } catch (e) {
      print('Error fetching shops: $e');
    }
  }

  void showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Shops'),
          content: TextField(
            controller: _searchController,
            decoration:
                const InputDecoration(hintText: 'Enter shop name or type'),
            onChanged: (value) {
              _filterShops(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
