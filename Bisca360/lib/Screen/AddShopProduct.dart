import 'dart:convert';

import 'package:bisca360/Request/ShopProductRequest.dart';
import 'package:bisca360/Request/ShopProducts.dart';
import 'package:bisca360/Response/CategoryResponse.dart';
import 'package:bisca360/Response/Measurementresponse.dart';
import 'package:bisca360/Response/SubCategoryResponse.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:searchfield/searchfield.dart';

import '../ApiService/Apis.dart';
import '../Response/ShopProductResponse.dart';
import '../Response/ShopResponse.dart';
import '../Service/ShopService.dart';
import '../Widget/CustomSearchfieldWidget.dart';

class AddShopProduct extends StatefulWidget {
  final ShoppProductResponse? shopProducts;
  const AddShopProduct( {super.key,required this.shopProducts});

  @override
  State<AddShopProduct> createState() => _AddShopProductState();
}

class _AddShopProductState extends State<AddShopProduct> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _subCategoryController = TextEditingController();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  late List<Shopresponse> shopResponses = [];
  late List<MeasurementResponse> unitResponses = [];
  late List<CategoryResponse> categories = [];
  late List<SubCategoryResponse> subCategories = [];
  late List<ShoppProductResponse> shopProducts = [];
  List<ShopProducts> addedProducts = [];
  List<ShopProducts> updateProducts = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<SearchFieldListItem<String>> _productItems = [];

  void _addProduct() {
    var id = 0;
    if(widget.shopProducts != null){
      id = widget.shopProducts?.id;
    }
    final shopName = _shopNameController.text;
    final category = _categoryController.text;
    final subCategory = _subCategoryController.text;
    final product = _productController.text;
    final unit = _unitController.text;
    final quantity = _qtyController.text;
    final price = _priceController.text;

    if (shopName.isEmpty || category.isEmpty || subCategory.isEmpty || product.isEmpty || unit.isEmpty || quantity.isEmpty || price.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill All Field", toastLength: Toast.LENGTH_SHORT);
      return;
    }

    final newProduct = ShopProducts(id, product, unit, price, quantity);

    setState(() {
      addedProducts.add(newProduct);
    });

    // Clear input fields
    // _shopNameController.clear();
    // _categoryController.clear();
    // _subCategoryController.clear();
    _productController.clear();
    _unitController.clear();
    _qtyController.clear();
    _priceController.clear();
  }

  void _deleteProduct(int index) {
    setState(() {
      addedProducts.removeAt(index);
    });
  }

  int _getCategoryId() {
    // getAllCategories(_shopNameController.text);
    int categoryId = 0;
    if (_categoryController.text.isNotEmpty) {
      for (CategoryResponse category in categories) {
        if (_categoryController.text == category.categoryName) {
          categoryId = category.id;
          break;
        }
      }
    }
    return categoryId;
  }
  int _getSubCategoryId() {
    int categoryId = 0;
    if (_subCategoryController.text.isNotEmpty) {
      for (SubCategoryResponse subCategory in subCategories) {
        if (_subCategoryController.text == subCategory.subCategoryName) {
          categoryId = subCategory.id;
          break;
        }
      }
    }
    return categoryId;
  }


  void _saveProducts(){

    ShopProductRequest productRequest =  ShopProductRequest(
        _categoryController.text,
        _subCategoryController.text,
        _getCategoryId(),
        _getSubCategoryId(),
        _shopNameController.text,
        0,
        addedProducts);
    var data = jsonEncode(
        productRequest
            .toJson());
    ShopService.saveShopProduct(data,context);
  }
  void _updateProduct(){
    var id = 0;
    if(widget.shopProducts != null){
      id = widget.shopProducts?.id;
    }
    final shopName = _shopNameController.text;
    final category = _categoryController.text;
    final subCategory = _subCategoryController.text;
    final product = _productController.text;
    final unit = _unitController.text;
    final quantity = _qtyController.text;
    final price = _priceController.text;

    if (shopName.isEmpty || category.isEmpty || subCategory.isEmpty || product.isEmpty || unit.isEmpty || quantity.isEmpty || price.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill All Field", toastLength: Toast.LENGTH_SHORT);
      return;
    }

    final newProduct = ShopProducts(id, product, unit, price, quantity);

    setState(() {
      updateProducts.add(newProduct);
    });
    ShopProductRequest productRequest =  ShopProductRequest(
        _categoryController.text,
        _subCategoryController.text,
        _getCategoryId(),
        _getSubCategoryId(),
        _shopNameController.text,
        0,
        updateProducts);
    var data = jsonEncode(
        productRequest
            .toJson());
    ShopService.saveShopProduct(data,context);
  }

  @override
  void initState() {
    if (widget.shopProducts != null) {
      _shopNameController.text = widget.shopProducts!.shopName;
      _categoryController.text = widget.shopProducts!.categoryName;
      _subCategoryController.text = widget.shopProducts!.subcategoryName;
      _productController.text = widget.shopProducts!.product;
      _qtyController.text = widget.shopProducts!.quantity.toString();
      _unitController.text = widget.shopProducts!.unit.toString();
      _priceController.text = widget.shopProducts!.price.toString();
    }
    if(_shopNameController.text.isNotEmpty){
      getAllCategories(_shopNameController.text);
    }
    if(_categoryController.text.isNotEmpty){
      getAllSubCategories(_getCategoryId());
    }
    getAllShops().then((_) {
      if (shopResponses.isNotEmpty) {
        _shopNameController.text = shopResponses.first.shopName;
        getAllCategories(_shopNameController.text); // Fetch products after setting the shop name
        getAllSubCategories(_getCategoryId());
      }
    });
    getUnits();
    super.initState();
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
          shopResponses = data.map((item) => Shopresponse.fromJson(item)).toList();
        });
      } else {
        print('Failed to load shops');
      }
    } catch (e) {
      print('Error fetching shops: $e');
    }
  }

  Future<void> getUnits() async {
    try {
      final response = await Apis.getClient().get(
        Uri.parse(Apis.getUnits),
        headers: Apis.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          unitResponses = data.map((item) => MeasurementResponse.fromJson(item)).toList();
        });
      } else {
        print('Failed to load Units');
      }
    } catch (e) {
      print('Error fetching Units: $e');
    }
  }

  Future<void> getAllCategories(String shopName) async {
    try {
      final encodedData = Uri.encodeComponent(shopName);
      final url = Uri.parse('${Apis.getAllCategory}$encodedData');
      final response = await Apis.getClient().get(url, headers: Apis.getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          categories = data.map((item) => CategoryResponse.fromJson(item)).toList();
        });
        await getAllSubCategories(_getCategoryId());
      } else {
        print('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> getAllSubCategories(var categoryId) async {
    try {
      // final encodedData = Uri.encodeComponent(categoryName);
      final url = Uri.parse('${Apis.getAllSubCategory}$categoryId');
      final response = await Apis.getClient().get(url, headers: Apis.getHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          subCategories = data.map((item) => SubCategoryResponse.fromJson(item)).toList();
        });
      } else {
        print('Failed to load subCategories');
      }
    } catch (e) {
      print('Error fetching subCategories: $e');
    }
  }

  Future<void> getShopProducts(String data) async {
    try {
      final encodedData = Uri.encodeComponent(data);
      final url = Uri.parse('${Apis.getShopProduct}$encodedData');
      final response = await Apis.getClient().get(url, headers: Apis.getHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          shopProducts = data.map((item) => ShoppProductResponse.fromJson(item)).toList();
        });
      } else {
        print('Failed to load shopProducts');
      }
    } catch (e) {
      print('Error fetching shopProducts: $e');
    }
  }

  List<SearchFieldListItem<String>> get _shopItems {
    return shopResponses
        .map((shop) => SearchFieldListItem<String>(shop.shopName))
        .toList();
  }

  List<SearchFieldListItem<String>> get _categoryItems {
    return categories
        .map((category) => SearchFieldListItem<String>(category.categoryName))
        .toList();
  }

  List<SearchFieldListItem<String>> get _subCategoryItems {
    return subCategories
        .map((subCategory) => SearchFieldListItem<String>(subCategory.subCategoryName))
        .toList();
  }

  // List<SearchFieldListItem<String>> get _productItems {
  //   return shopProducts
  //       .map((product) => SearchFieldListItem<String>(product.product))
  //       .toList();
  // }

  List<SearchFieldListItem<String>> get _units {
    return unitResponses
        .map((unit) => SearchFieldListItem<String>(unit.measurementName))
        .toList();
  }

  void _handleShopSelection(String selectedShop) {
    _categoryController.clear();
    getAllCategories(selectedShop);
  }


  void _handleCategorySelection(String selectedCategory) {
    _productController.clear();
    var selectedCategoryItem = categories.firstWhere(
          (category) => category.categoryName == selectedCategory,
    );

    if (selectedCategoryItem != null) {
      updateProductItems(selectedCategory);
      int categoryId = _getCategoryId();
      getAllSubCategories(categoryId);
    }
  }

  void updateProductItems(String selectedCategory) {
    var selectedCategoryItem = categories.firstWhere(
          (category) => category.categoryName == selectedCategory,
    );
    if (selectedCategoryItem != null) {
      setState(() {
        _productItems = selectedCategoryItem.productName
            .map((name) => SearchFieldListItem<String>(name))
            .toList();
      });
    } else {
      setState(() {
        _productItems = [];
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        centerTitle: true,
        actions: addedProducts.isNotEmpty
            ? [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextButton(
              onPressed: () {
                _saveProducts();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ]
            : [],
        backgroundColor: Colors.green,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title:  Text(widget.shopProducts != null ? 'Update Product' : 'Add Product', style: TextStyle(color: Colors.white)),
      ),
      body: GestureDetector(
           onTap: () {
          FocusScope.of(context).unfocus();
        },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSearchField.buildSearchField(_shopNameController, 'Shop name', Icons.shop, _shopItems, _handleShopSelection,false,true, true,false),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomSearchField.buildSearchField(_categoryController, 'Category', Icons.category, _categoryItems, _handleCategorySelection,false,true, true,true),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomSearchField.buildSearchField(_subCategoryController, 'Sub Category', Icons.category, _subCategoryItems, (String value) {},false,true, true,true),
                ),
              ],
            ),
            const SizedBox(height: 10),
            CustomSearchField.buildSearchField(_productController, 'Product', Icons.fastfood,
                _productItems,
                (String value) {},false,true, false,true),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(_qtyController, 'Quantity', Icons.numbers, TextInputType.numberWithOptions(decimal: true)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomSearchField.buildSearchField(_unitController, 'Unit', Icons.ad_units, _units, (String value) {},false,true, true,true),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Spacer(),
                Expanded(
                  child: _buildTextField(_priceController, 'Price', Icons.attach_money, TextInputType.numberWithOptions(decimal: true)),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle cancel action
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red // Text color
                    ),
                    child: const Text('Cancel',style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (){
                    if (_formKey.currentState!.validate()) {
                       widget.shopProducts != null ? _updateProduct() : _addProduct() ;
                      }else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill in all fields correctly')),
                      );
                    }
                    },
                    style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.green // Text color
                    ),
                    child: Text(widget.shopProducts != null ?'Update' : 'Add',style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            addedProducts.isNotEmpty ? Text('Added Products', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)) : Text(''),
            Expanded(
              child: ListView.builder(
                itemCount: addedProducts.length,
                itemBuilder: (context, index) {
                  final product = addedProducts[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 3),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(5),
                      title: Text('${index+1}. Product: ${product.product}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      subtitle: Text('Price: ${product.price}    Quantity: ${product.quantity}', style: TextStyle(fontSize: 14)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      ),
      ),
    );
  }


  Widget _buildTextField(TextEditingController controller, String labelText, IconData icon, TextInputType keyboardType) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.green),
          prefixIcon: Icon(icon, color: Colors.green),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 14),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: keyboardType,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        ],
      ),
    );
  }
}
