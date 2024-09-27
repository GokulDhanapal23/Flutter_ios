
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:searchfield/searchfield.dart';

import '../ApiService/Apis.dart';
import '../Response/ShopCustomerResponse.dart';
import '../Response/ShopResponse.dart';
import '../Service/ImageService.dart';
import '../Widget/CustomSearchfieldWidget.dart';
import 'AddShop.dart';

class Customers extends StatefulWidget {
  const Customers({super.key});

  @override
  State<Customers> createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {

  final TextEditingController _shopNameController = TextEditingController();
  late List<Shopresponse> shopResponses = [];
  late List<ShopCustomerResponse> shopCustomer = [];

  Future<void> getAllShops() async {
    try {
      final response = await Apis.getClient().get(
        Uri.parse(Apis.getAllShop),
        headers: Apis.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          shopResponses = data.map((item) => Shopresponse.fromJson(item)).toList();
        });
      } else {
        print('Failed to load shops');
      }
    } catch (e) {
      print('Error fetching shops: $e');
    }
  }
  static String geShopCustomer = '${dotenv.env['BASE_URL'] ?? ""}/shopcustomer/getby/shopname';
  Future<void> getShopCustomer(String shopName) async {
    try {
      final encodedShopName = Uri.encodeComponent(shopName);

      final url = Uri.parse('$geShopCustomer?shopName=$encodedShopName');
      final response = await Apis.getClient().get(url, headers: Apis.getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          shopCustomer = data.map((item) => ShopCustomerResponse.fromJson(item)).toList();
          print('shopCustomer: $shopCustomer');
        });
      } else {
        print('Failed to load shop customers');
      }
    } catch (e) {
      print('Error fetching shop customers: $e');
    }
  }
  List<SearchFieldListItem<String>> get _shopItems {
    return shopResponses.map((shop) => SearchFieldListItem<String>(shop.shopName)).toList();
  }

  late final Shopresponse selectedShopData;
  void _handleShopSelection(String selectedShop) {
    getShopCustomer(selectedShop);
    selectedShopData = shopResponses.firstWhere(
            (shop) => shop.shopName == selectedShop
    );
  }

  @override
  void initState() {
    getAllShops();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Customers', style: TextStyle(color: Colors.white)),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Navigator.push(
      //     //   context,
      //     //   MaterialPageRoute(
      //     //     builder: (context) => const AddShop(shopResponse: null),
      //     //   ),
      //     // );
      //   },
      //   backgroundColor: Colors.green,
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
      body:GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomSearchField.buildSearchField(_shopNameController, 'Shop Name', Icons.shop, _shopItems, _handleShopSelection,false),
              const SizedBox(height: 10),
              Expanded(
                child: shopCustomer.isEmpty
                    ? Center(child: Text('No Customers'))
                    : ListView.builder(
                  itemCount: shopCustomer.length,
                  itemBuilder: (context, index) {
                    final customer = shopCustomer[index];
                    return Card(
                      color: Colors.white,
                      shadowColor: Colors.green,
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(5),
                        title: Text(
                          '${index + 1}. Customer Name:  ${customer.customerName}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text('Customer Name: ${customer.mobileNumber}', style: const TextStyle(fontSize: 14)),
                            Text('     Mobile Number: ${customer.mobileNumber}', style: const TextStyle(fontSize: 14)),
                            // Text('Price: ${customer.price}', style: const TextStyle(fontSize: 14)),
                            // Text('Unit: ${customer.unit}', style: const TextStyle(fontSize: 14)),
                            // Text('Quantity: ${customer.quantity}', style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                        // trailing: IconButton(
                        //   icon: const Icon(Icons.edit, color: Colors.green),
                        //   onPressed: (){
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => AddShopProduct(shopProducts:shopProducts[index]),
                        //       ),
                        //     );
                        //     //
                        //   },
                        // ),
                        // onTap: () {
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => AddShopProduct(),
                        //     ),
                        //   );
                        // },
                      ),
                    );


                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
