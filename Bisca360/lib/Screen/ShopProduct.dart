import 'dart:convert';

import 'package:bisca360/Request/ShopProducts.dart';
import 'package:bisca360/Response/ShopProductResponse.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:searchfield/searchfield.dart';


import '../ApiService/Apis.dart';
import '../Response/ShopResponse.dart';
import '../Service/LoginService.dart';
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
  final TextEditingController _searchController = TextEditingController();

  late List<ShoppProductResponse> filteredProducts = [];
  bool _isSearching = false;

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
  Future<bool> getChangeProductStatus(var id , bool status) async {
    try {
      final response = await Apis.getClient().get(
        Uri.parse('${Apis.getChangeProductStatus}?id=$id&status=$status'),
        headers: Apis.getHeaders(),
      );
      if (response.statusCode == 200) {
         LoginService.showBlurredSnackBar(context, 'Product Status Changed Successfully', type: SnackBarType.success);
          print('Success Change Product Status');
          return true;
      } else {
          LoginService.showBlurredSnackBar(context, 'Failed to change Status', type: SnackBarType.error);
        print('Failed to Change Product Status ');
        return false;
      }
    } catch (e) {
      print('Error fetching Change Product Status: $e');
      return false;
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

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      filteredProducts = shopProducts; // Reset to all shops
    });
  }
  void _filterShops(String query) {
    final filtered = shopProducts.where((product) {
      return product.product.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      filteredProducts = filtered;
    });
  }


  @override
  void initState() {
    super.initState(); // Always call super.initState() first
    getAllShops().then((_) {
      // Ensure this runs after the shops have been fetched
      if (shopResponses.isNotEmpty) {
        _shopNameController.text = shopResponses.first.shopName;
        getShopProducts(_shopNameController.text); // Fetch products after setting the shop name
      }
    });
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

            :const Text('Shop Product', style: TextStyle(color: Colors.white),),
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
        ],
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
            CustomSearchField.buildSearchField(_shopNameController, 'Shop name', Icons.shop, _shopItems, _handleShopSelection,false,false, true, false),
            const SizedBox(height: 10),
            // Expanded(
            //   child: shopProducts.isEmpty
            //       ? Center(child: Text('No products'))
            //       : ListView.builder(
            //     itemCount: shopProducts.length,
            //     itemBuilder: (context, index) {
            //       final product = shopProducts[index];
            //       return Card(
            //         color: Colors.white,
            //         shadowColor: Colors.green,
            //         elevation: 3,
            //         margin: const EdgeInsets.symmetric(vertical: 3),
            //         child: ListTile(
            //           contentPadding: const EdgeInsets.all(5),
            //           title: Text(
            //             '${index + 1}. Product: ${product.product}',
            //             style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            //           ),
            //           subtitle: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Text('Category: ${product.categoryName}', style: const TextStyle(fontSize: 14)),
            //               Text('Subcategory: ${product.subcategoryName}', style: const TextStyle(fontSize: 14)),
            //               Text('Price: ${product.price}', style: const TextStyle(fontSize: 14)),
            //               // Text('Unit: ${product.unit}', style: const TextStyle(fontSize: 14)),
            //               // Text('Quantity: ${product.quantity}', style: const TextStyle(fontSize: 14)),
            //             ],
            //           ),
            //           trailing: IconButton(
            //             icon: const Icon(Icons.edit, color: Colors.green),
            //             onPressed: (){
            //               Navigator.push(
            //                 context,
            //                 MaterialPageRoute(
            //                   builder: (context) => AddShopProduct(shopProducts:shopProducts[index]),
            //                 ),
            //               );
            //               //
            //             },
            //           ),
            //           // onTap: () {
            //           //   Navigator.push(
            //           //     context,
            //           //     MaterialPageRoute(
            //           //       builder: (context) => AddShopProduct(),
            //           //     ),
            //           //   );
            //           // },
            //         ),
            //       );
            //
            //
            //     },
            //   ),
            // ),
            Expanded(
              child: (shopProducts.isEmpty)
                  ? Center(child: Text('No products'))
                  : ListView.builder(
                itemCount: filteredProducts.isEmpty ? shopProducts.length : filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts.isEmpty ? shopProducts[index] : filteredProducts[index];
                  bool isActive = product.status; // Assuming isActive is a property of your product

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
                          Row(
                            children: [
                              Text('Price: ${product.price}', style: const TextStyle(fontSize: 14)),
                              SizedBox(width: 30),
                              Text('Unit: ${product.unit}', style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.indigoAccent),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddShopProduct(shopProducts: shopProducts[index]),
                                ),
                              );
                            },
                          ),
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              activeColor: Colors.indigoAccent,
                              value: isActive,
                              onChanged: (value) async {
                                if(await getChangeProductStatus(product.id,value)){
                                  setState(() {
                                    product.status = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )

          ],
        ),
      ),
    ),
    );
  }
}

