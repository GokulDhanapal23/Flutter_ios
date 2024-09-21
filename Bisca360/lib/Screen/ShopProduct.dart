import 'dart:convert';

import 'package:bisca360/Request/ShopProducts.dart';
import 'package:bisca360/Response/ShopProductResponse.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:searchfield/searchfield.dart';


import '../ApiService/Apis.dart';
import '../Response/ShopResponse.dart';
import '../Widget/CustomSearchfieldWidget.dart';
import 'AddShopProduct.dart';

class ShopProduct extends StatefulWidget {
  const ShopProduct({super.key});

  @override
  State<ShopProduct> createState() => _ShopProductState();
}


class _ShopProductState extends State<ShopProduct> {

  late List<Shopresponse> shopResponses = [];
  late List<ShoppProductResponse> shopProducts = [];
  final SingleValueDropDownController _dropDownController = SingleValueDropDownController();
  final TextEditingController _shopController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();

  getAllShops() async {
    try {
      final response = await Apis.getClient().get(
        Uri.parse(Apis.getAllShop),
        headers: Apis.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          shopResponses = data.map((item) => Shopresponse.fromJson(item)).toList();
          print('shops: $shopResponses.toString');
        });
      } else {
        print('Failed to load shops');
      }
    } catch (e) {
      print('Error fetching shops: $e');
    }
  }
  List<SearchFieldListItem<String>> get _shopItems {
    return shopResponses
        .map((shop) => SearchFieldListItem<String>(shop.shopName))
        .toList();
  }
  getShopProducts(var data) async{
    try{
      final encodedData = Uri.encodeComponent(data);

      // Construct the URL with the path variable
      final url = Uri.parse('${Apis.getShopProduct}$encodedData');
      final response = await Apis.getClient()
          .get(url, headers: Apis.getHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          shopProducts = data.map((item) => ShoppProductResponse.fromJson(item)).toList();
          print('shopProducts: $shopProducts.toString');
        });
      } else {
        print('Failed to load shops');
      }
    } catch (e) {
      print('Error fetching shops: $e');
    }
  }
  void _handleShopSelection(String selectedShop) {
    getShopProducts(selectedShop);
  }
  @override
  void initState(){
    super.initState();
    getAllShops();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.green,
        leading: IconButton(onPressed: () {
          Navigator.of(context).pop();
        }, icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white,)),
        title: const Text('Shop Product', style: TextStyle(color: Colors.white),),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>AddShopProduct( shopProducts: null,)));
        },
        backgroundColor: Colors.green,
        child: const Icon(
          Icons.add,color: Colors.white,
        ),
      ),
      body:GestureDetector(
    onTap: () {
    FocusScope.of(context).unfocus();
    },
    child : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomSearchField.buildSearchField(_shopNameController, 'Shop name', Icons.shop, _shopItems, _handleShopSelection,false),
            const SizedBox(height: 10),
            Expanded(
              child: shopProducts.isEmpty
                  ? Center(child: Text('No products'))
                  : ListView.builder(
                itemCount: shopProducts.length,
                itemBuilder: (context, index) {
                  final product = shopProducts[index];
                  return Card(
                    color: Colors.white,
                    shadowColor: Colors.green,
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(5),
                      title: Text(
                        '${index + 1}. Product: ${product.product}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Category: ${product.categoryName}', style: const TextStyle(fontSize: 14)),
                          Text('Subcategory: ${product.subcategoryName}', style: const TextStyle(fontSize: 14)),
                          Text('Price: ${product.price}', style: const TextStyle(fontSize: 14)),
                          // Text('Unit: ${product.unit}', style: const TextStyle(fontSize: 14)),
                          // Text('Quantity: ${product.quantity}', style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddShopProduct(shopProducts:shopProducts[index]),
                            ),
                          );
                          //
                        },
                      ),
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

