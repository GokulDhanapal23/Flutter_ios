import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bisca360/Request/ShopBillProducts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pinput/pinput.dart';
import 'package:searchfield/searchfield.dart';

import '../ApiService/Apis.dart';
import '../Request/ShopSalesDetailsRequest.dart';
import '../Response/DefaultResponse.dart';
import '../Response/OwnerTaxResponse.dart';
import '../Response/ShopCustomerResponse.dart';
import '../Response/ShopProductResponse.dart';
import '../Response/ShopResponse.dart';
import '../Service/LoginService.dart';
import '../Widget/CustomSearchfieldWidget.dart';
import '../Widget/TextDatewidget.dart';

class ShopBilling extends StatefulWidget {
  const ShopBilling({Key? key}) : super(key: key);

  @override
  State<ShopBilling> createState() => _ShopBillingState();
}

class _ShopBillingState extends State<ShopBilling> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  late TextEditingController _qtyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  late TextEditingController _datePickerController = TextEditingController();
  final TextEditingController _mealTimeController = TextEditingController();
  final TextEditingController _paymentTypeController = TextEditingController();

  late List<Shopresponse> shopResponses = [];
  late List<ShoppProductResponse> shopProducts = [];
  late List<ShopCustomerResponse> shopCustomer = [];
  List<ShopBillProducts> billedProducts = [];
  List<OwnerTaxResponse> taxItems = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late ShopSalesDetailsRequest shopSalesDetailsRequest;
  static late final DefaultResponse response;
  late var cardTotalPrice;
  late double totalPriceS;
  late double totalTaxS;
  late double netTotalS;

  bool _isProductSelected = false;


  late List<String> mealTime = ['Break Fast', 'Lunch', 'Dinner'];
  late List<String> paymentType = ['Credit', 'Debit', 'Cash'];

  List<SearchFieldListItem<String>> get _paymentType {
    return paymentType.map((type) => SearchFieldListItem<String>(type)).toList();
  }
  List<SearchFieldListItem<String>> get _mealTime {
    return mealTime.map((meal) => SearchFieldListItem<String>(meal)).toList();
  }

  List<SearchFieldListItem<String>> get _shopItems {
    return shopResponses.map((shop) => SearchFieldListItem<String>(shop.shopName)).toList();
  }

  late List<SearchFieldListItem<String>> productList;
  List<SearchFieldListItem<String>> get _productItems {
    productList = shopProducts.map((shop) =>
        SearchFieldListItem<String>(
            '${shop.product}(${shop.subcategoryName})(${shop.unit})'
        )
    ).toList();
    return productList;
  }

  List<SearchFieldListItem<String>> get _shopCustomer {
    return shopCustomer.map((shop) => SearchFieldListItem<String>(shop.customerName)).toList();
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

  Future<void> getShopProducts(String shopName) async {
    try {
      final encodedData = Uri.encodeComponent(shopName);

      final url = Uri.parse('${Apis.getShopProduct}$encodedData');
      final response = await Apis.getClient().get(url, headers: Apis.getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          shopProducts = data.map((item) => ShoppProductResponse.fromJson(item)).toList();
          print('shopProducts: $shopProducts');
        });
      } else {
        print('Failed to load shop products');
      }
    } catch (e) {
      print('Error fetching shop products: $e');
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

  void _clear(){
    _customerController.clear();
    _productController.clear();
    _qtyController.setText('0');
    billedProducts.clear();
  }

  Future<void> saveSalesBill(ShopSalesDetailsRequest shopSalesDetailsRequest) async {
    try{
      var res = await Apis.getClient().post(
          Uri.parse(Apis.saveShopSales),
          body : jsonEncode(shopSalesDetailsRequest.toJson()),
          headers: Apis.getHeaders());
      final response = jsonDecode(res.body);
      if (response['status']== "OK") {
        String billNumber = response['shopBillNo'];
        _downloadBill(shopSalesDetailsRequest.shopName,billNumber);
        LoginService.showBlurredSnackBar(context, response['message'], type: SnackBarType.success);
        _clear();
        print('Success to save shop billing : $response');
      }
      else {
        LoginService.showBlurredSnackBar(context, response['message'] , type: SnackBarType.error);
        print('Failed to save shop billing ');
      }
    }catch (e){
      print('data : ${jsonEncode(shopSalesDetailsRequest.toJson())}');
      print('Error fetching save billing: $e');
    }
  }

  void _downloadBill(String shopName, String billNumber){
    final encodedShopName = Uri.encodeComponent(shopName);
    final encodedBillNumber = Uri.encodeComponent(billNumber);
      final url = Uri.parse('${Apis.shopBillPdf}?shopName=$encodedShopName&billNumber=$encodedBillNumber');
      String fileName = '$billNumber-${DateTime.now()}';
      downloadPdf(context,url,fileName);
    }

  String? _downloadPath;

  Future<void> downloadPdf(BuildContext context, final url, String fileName) async {
    try{
      print('URL ; $url');
      final response = await Apis.getClient().get(url, headers: Apis.getHeaders());
      final bytes = response.bodyBytes;
      Directory? directory;
      if (Platform.isAndroid) {
        // directory = Directory('/storage/emulated/0/Download');
        directory = (await getExternalStorageDirectories(type: StorageDirectory.downloads))?.first;

      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }
      _downloadPath = directory?.path ?? '';
      final filePath = '$_downloadPath/$fileName.pdf';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      LoginService.showBlurredSnackBarFile(context, 'Bill Downloaded Successfully ', filePath, type: SnackBarType.success);
      print('File Service : Bill download Success $filePath');
    } catch(e){
      print('File Service : Error on Bill download failed $e');
    }
  }

  late  Shopresponse selectedShopData;

  void _handleShopSelection(String selectedShop) {
    _productController.clear();
    billedProducts.clear();
    getShopProducts(selectedShop);
    getShopCustomer(selectedShop);
    selectedShopData = shopResponses.firstWhere(
            (shop) => shop.shopName == selectedShop
    );
  }

  late var selectedProductData;

  void _handleProductSelection(String selectedProduct) {
    String productName = selectedProduct.trim().split('(')[0];
    print('ProductName: $productName');
    selectedProductData = shopProducts.firstWhere(
          (product) => product.product.trim() == productName.trim(),
      );
    if (selectedProductData != null) {
      _priceController.text = selectedProductData.price.toString();
      _qtyController.text = '1';
      setState(() {
        _isProductSelected = true; // Mark the product as selected
      });
    } else {
      _priceController.clear();
      _qtyController.clear();
      setState(() {
        _isProductSelected = false; // Mark the product as selected
      });
    }
    _recalculateTotalPrice();
  }

  void _recalculateTotalPrice() {
    final quantity = int.tryParse(_qtyController.text) ?? 0;
    final price = double.tryParse(selectedProductData.price.toString()) ?? 0.0;
    double totalPrice;
      totalPrice = price * quantity;
    setState(() {
      _priceController.text = totalPrice.toStringAsFixed(2);
    });
  }

  double get _cardTotalPrice {
    totalPriceS = billedProducts
        .map((product) => product.totalPriceList)
        .fold(0.0, (previousValue, totalPrice) => previousValue + totalPrice);
    return totalPriceS;
  }

  double get _cardTotalTax {
    double totalWoT = billedProducts
        .map((product) => product.totalPriceList)
        .fold(0.0, (previousValue, totalPrice) => previousValue + totalPrice);
      taxItems = selectedShopData.listOwnerTaxResponse;
      double totalTaxPercentage = taxItems.fold(
        0.0,
            (sum, item) => sum + (item.taxPercentage ?? 0.0),
      );
      totalTaxS = (totalWoT * totalTaxPercentage) / 100;

      return totalTaxS;
  }

  @override
  void initState() {
    super.initState();
    getAllShops().then((_) {
      // Ensure this runs after the shops have been fetched
      if (shopResponses.isNotEmpty) {
        _shopNameController.text = shopResponses.first.shopName;
        getShopProducts(_shopNameController.text); // Fetch products after setting the shop name
        getShopCustomer(_shopNameController.text);
      }
    });
    _clear();
    _qtyController.text = '0';
    _datePickerController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _qtyController.addListener(_recalculateTotalPrice);
  }

  @override
  void dispose() {
    _qtyController.dispose(); // Clean up the controller when the widget is disposed
    super.dispose();
  }

  void _saveBill() {
    netTotalS = totalTaxS + totalPriceS;
    String customerNameS = _customerController.text;
    int customerId = 0;
    int customerNumber = 0; // Keep this as int

    if (customerNameS.isNotEmpty && shopCustomer.isNotEmpty) {
      ShopCustomerResponse? customerData = shopCustomer.firstWhere(
              (customer) => customer.customerName.trim() == customerNameS.trim(),
          );
      if (customerData != null) {
        customerId = customerData.id;
        customerNumber = customerData.mobileNumber;
      }
    }

    shopSalesDetailsRequest = ShopSalesDetailsRequest(
      0,
      selectedShopData.shopName,
      _paymentTypeController.text,
      billedProducts,
      totalPriceS,
      totalTaxS,
      netTotalS,
      netTotalS,
      _datePickerController.text,
      _mealTimeController.text,
      _customerController.text,
      customerNumber, // Ensure this is an int
      customerId,
    );

    saveSalesBill(shopSalesDetailsRequest);
  }

    // void _billProduct() {
    //   final String item = _productController.text;
    //   final int  quantity = int.tryParse(_qtyController.text) ?? 0;
    //   final double price = double.tryParse(selectedProductData.price.toString()) ?? 0.0;
    //   final double totalPrice = price * quantity;
    //   final productData = shopProducts.firstWhere(
    //       (product) => product.product == selectedProductData.product);
    //
    //   if (item.isEmpty || quantity <= 0 || price <= 0) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Please fill in all fields correctly')),
    //     );
    //     return;
    //   }
    //
    //   final newProduct = ShopBillProducts(item, productData.unit.toString(), price, quantity, totalPrice);
    //
    //   setState(() {
    //     billedProducts.add(newProduct);
    //   });
    //
    //   _productController.clear();
    //   _qtyController.setText('1');
    //   _priceController.clear();
    // }
  void _billProduct() {
    var selectedShop=_shopNameController.text;
    selectedShopData = shopResponses.firstWhere(
          (shop) => shop.shopName == selectedShop,
    );
    final String item = _productController.text.trim(); // Trim whitespace
    final int quantity = int.tryParse(_qtyController.text) ?? 0;
    final double price = double.tryParse(selectedProductData.price.toString()) ?? 0.0;
    final double totalPrice = price * quantity;

    // Check if the product exists in the shopProducts list
    final productData = shopProducts.firstWhere(
            (product) => product.product == selectedProductData.product,
    );

    // Show error if the product does not exist
    if (productData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected product does not exist')),
      );
      return;
    }

    // Validate inputs
    if (item.isEmpty || quantity <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields correctly')),
      );
      print('Please fill in all fields correctly');
      return;
    }

    // Create a new product entry
    final newProduct = ShopBillProducts(item, productData.unit.toString(), price, quantity, totalPrice);

    // Update the state
    setState(() {
      billedProducts.add(newProduct);
    });

    // Clear the input fields
    _productController.clear();
    _qtyController.text = '0'; // Use text instead of setText for consistency
    _priceController.clear();
  }


  void _deleteProduct(int index) {
    setState(() {
      billedProducts.removeAt(index);
    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.grey[200],
  //     appBar: AppBar(
  //       centerTitle: true,
  //       backgroundColor: Colors.green,
  //       leading: IconButton(
  //         onPressed: () => Navigator.of(context).pop(),
  //         icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
  //       ),
  //       title: const Text('Shop Billing', style: TextStyle(color: Colors.white)),
  //     ),
  //     body:
  //   GestureDetector(
  //   onTap: () {
  //   FocusScope.of(context).unfocus();
  //   },
  //   child : Form(
  //   key: _formKey,
  //   child:SingleChildScrollView(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           CustomSearchField.buildSearchField(_shopNameController, 'Shop Name', Icons.shop, _shopItems, _handleShopSelection,true),
  //           const SizedBox(height: 10),
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: TextFieldDateWidget(
  //                   _datePickerController,
  //                   "Bill Date",
  //                   const Icon(Icons.date_range, color: Colors.green),
  //                   TextInputAction.next,
  //                   TextInputType.text,
  //                   "PAST",
  //                 ),
  //               ),
  //               const SizedBox(width: 10),
  //               Expanded(
  //                 child:  CustomSearchField.buildSearchField(_mealTimeController, 'Meal Time', Icons.category, _mealTime, (String value) {},true),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 10),
  //           CustomSearchField.buildSearchField(_customerController, 'Customer', Icons.person, _shopCustomer, (String value) {},false),
  //           const SizedBox(height: 10),
  //           CustomSearchField.buildSearchField(_productController, 'Product', Icons.fastfood, _productItems, _handleProductSelection,true),
  //           const SizedBox(height: 10),
  //           Row(
  //             children: [
  //                       const Expanded(
  //                         flex: 3,
  //                         child: Padding(
  //                           padding: EdgeInsets.symmetric(horizontal: 8.0),
  //                           child: Text(
  //                             'Quantity:',
  //                             style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
  //                           ),
  //                         ),
  //                       ),
  //                       Expanded(
  //                         flex: 3,
  //                         child: TextField(
  //                           controller: _qtyController,
  //                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
  //                           cursorColor: Colors.black,
  //                           onChanged: (_) => _recalculateTotalPrice(),
  //                         ),
  //                       ),
  //                       const Expanded(
  //                         flex: 3,
  //                         child: Padding(
  //                           padding: EdgeInsets.symmetric(horizontal: 8.0),
  //                           child: Text(
  //                             'Price (₹):',
  //                             style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
  //                           ),
  //                         ),
  //                       ),
  //                       Expanded(
  //                         flex: 3,
  //                         child: TextField(
  //                           controller: _priceController,
  //                           readOnly: true,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //           const SizedBox(height: 10),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.end,
  //             children: [
  //               // Align(
  //               //   alignment: Alignment.bottomLeft,
  //               //   child: ElevatedButton(
  //               //     onPressed: () {
  //               //       Navigator.of(context).pop();
  //               //     },
  //               //     style: ElevatedButton.styleFrom(
  //               //       backgroundColor: Colors.red,
  //               //       shape: RoundedRectangleBorder(
  //               //         borderRadius: BorderRadius.circular(25),
  //               //       ),
  //               //     ),
  //               //     child: const Text('Clear', style: TextStyle(color: Colors.white)),
  //               //   ),
  //               // ),
  //               const SizedBox(width: 10),
  //               Align(
  //                 alignment: Alignment.bottomRight,
  //                 child: ElevatedButton(
  //                   onPressed:(){ if(_formKey.currentState!.validate()){_billProduct();}},
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Colors.green,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(25),
  //                     ),
  //                   ),
  //                   child: const Text('Add', style: TextStyle(color: Colors.white)),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 10),
  //           if (billedProducts.isNotEmpty) ...[
  //             const Text(
  //               'Added Products',
  //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(height: 10),
  //             Container(
  //               height: 24,
  //               color: Colors.green,
  //               child: const Row(
  //                 children: [
  //                   Padding(
  //                     padding: EdgeInsets.only(left: 6),
  //                     child: Expanded(child: Text('S.No', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
  //                   ),
  //                   Padding(
  //                     padding: EdgeInsets.only(left: 30),
  //                     child: Expanded(child: Text('Products', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
  //                   ),
  //                   Padding(
  //                     padding: EdgeInsets.only(left: 90),
  //                     child: Expanded(child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
  //                   ),
  //                   Padding(
  //                     padding: EdgeInsets.only(left: 40),
  //                     child: Expanded(child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             const SizedBox(height: 5),
  //             Column(
  //               children: billedProducts.map((product) {
  //                 final index = billedProducts.indexOf(product);
  //                 return Card(
  //                   elevation: 3,
  //                   margin: const EdgeInsets.symmetric(vertical: 3),
  //                   child: Row(
  //                     children: [
  //                       Expanded(
  //                         child: Padding(
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: Text('${index + 1}', style: TextStyle(fontSize: 15)),
  //                         ),
  //                       ),
  //                       Expanded(
  //                         flex: 3,
  //                         child: Padding(
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: Text(product.items, style: TextStyle(fontSize: 15)),
  //                         ),
  //                       ),
  //                       Expanded(
  //                         child: Padding(
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: Text('${product.quantity}', style: TextStyle(fontSize: 15)),
  //                         ),
  //                       ),
  //                       Expanded(
  //                         child: Padding(
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: Text('${product.totalPriceList.toStringAsFixed(0)}', style: TextStyle(fontSize: 15)),
  //                         ),
  //                       ),
  //                       IconButton(
  //                         icon: Icon(Icons.highlight_remove_outlined, color: Colors.red),
  //                         onPressed: () => _deleteProduct(index),
  //                       ),
  //                     ],
  //                   ),
  //                 );
  //               }).toList(),
  //             ),
  //             const SizedBox(height: 10),
  //             Card(
  //               elevation: 3,
  //               child: Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     ...taxItems.map((tax) => _buildRow('${tax.taxType} (${tax.taxPercentage})', '', '₹', (tax.taxPercentage * _cardTotalPrice / 100).toString())),
  //                     _buildRow('Total Tax', '', '₹', _cardTotalTax.toString()),
  //                     _buildDivider(),
  //                     _buildRow('Total Price', '', '₹', _cardTotalPrice.toString()),
  //                     _buildDivider(),
  //                     _buildRow('Net Amount', '', '₹', (_cardTotalTax + _cardTotalPrice).toString()),
  //                     _buildDivider(),
  //                     _buildPaymentTypeRow(),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.end,
  //               children: [
  //                 Align(
  //                   alignment: Alignment.bottomLeft,
  //                   child: ElevatedButton(
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.red,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(25),
  //                       ),
  //                     ),
  //                     child: const Text('Cancel', style: TextStyle(color: Colors.white)),
  //                   ),
  //                 ),
  //                 const SizedBox(width: 10),
  //                 Align(
  //                   alignment: Alignment.bottomRight,
  //                   child: ElevatedButton(
  //                     onPressed: _saveBill,
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.green,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(25),
  //                       ),
  //                     ),
  //                     child: const Text('Save', style: TextStyle(color: Colors.white)),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //
  //         ],
  //       ),
  //     ),
  //   ),
  //   ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.green,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: const Text('Shop Billing', style: TextStyle(color: Colors.white)),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSearchField.buildSearchField(
                    _shopNameController,
                    'Shop Name',
                    Icons.shop,
                    _shopItems,
                    _handleShopSelection,
                    true, true
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFieldDateWidget(
                        _datePickerController,
                        "Bill Date",
                        const Icon(Icons.date_range, color: Colors.green),
                        TextInputAction.next,
                        TextInputType.text,
                        "PAST",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomSearchField.buildSearchField(
                          _mealTimeController,
                          'Meal Time',
                          Icons.category,
                          _mealTime,
                              (String value) {},
                          true, true
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomSearchField.buildSearchField(
                    _customerController,
                    'Customer',
                    Icons.person,
                    _shopCustomer,
                        (String value) {},
                    false, true
                ),
                const SizedBox(height: 10),
                CustomSearchField.buildSearchField(
                    _productController,
                    'Product',
                    Icons.fastfood,
                    _productItems,
                    _handleProductSelection,
                    true, false
                ),
              if (_isProductSelected) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Expanded(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Quantity:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _qtyController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        cursorColor: Colors.black,
                        onChanged: (_) => _recalculateTotalPrice(),
                      ),
                    ),
                    const Expanded(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Price (₹):',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _priceController,
                        readOnly: true,
                      ),
                    ),
                  ],
                ),],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(width: 10),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _billProduct();
                            setState(() {
                              _isProductSelected = false;
                            }); // Trigger a rebuild
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill in all fields correctly')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text('Add', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (billedProducts.isNotEmpty) ...[
                  const Text(
                    'Added Products',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 24,
                    color: Colors.green,
                    child: const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Expanded(child: Text('S.No', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 30),
                            child: Expanded(child: Text('Products', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 90),
                            child: Expanded(child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 40),
                            child: Expanded(child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          ),
                        ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Column(
                    children: billedProducts.map((product) {
                      final index = billedProducts.indexOf(product);
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('${index + 1}', style: TextStyle(fontSize: 15)),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(product.item, style: TextStyle(fontSize: 15)),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('${product.quantity}', style: TextStyle(fontSize: 15)),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('${product.totalPriceList.toStringAsFixed(0)}', style: TextStyle(fontSize: 15)),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.highlight_remove_outlined, color: Colors.red),
                              onPressed: () => _deleteProduct(index),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...taxItems.map((tax) => _buildRow('${tax.taxType} (${tax.taxPercentage})', '', '₹', (tax.taxPercentage * _cardTotalPrice / 100).toString())),
                          _buildRow('Total Tax', '', '₹', _cardTotalTax.toString()),
                          _buildDivider(),
                          _buildRow('Total Price', '', '₹', _cardTotalPrice.toString()),
                          _buildDivider(),
                          _buildRow('Net Amount', '', '₹', (_cardTotalTax + _cardTotalPrice).toString()),
                          _buildDivider(),
                          _buildRow('Grand Total', '', '₹', (_cardTotalTax + _cardTotalPrice).toString()),
                          _buildDivider(),
                          _buildPaymentTypeRow(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _saveBill,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text('Save', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
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
          labelStyle: TextStyle(color: Colors.black),
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

  Widget _buildRow(String label, String title, String currencySymbol, String amount) {
    return Row(
      children: [
        Expanded(
          flex: 8,
          child: Text(
            title.isNotEmpty ? title : label,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Text(
          ': ',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.0,
          ),
        ),
        Text(
          currencySymbol,
          style: const TextStyle(
            color: Colors.green,
            fontSize: 14.0,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.green,
            fontSize: 14.0,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTypeRow() {
    return Row(
      children: [
        const Expanded(
          flex: 8,
          child: Text(
            'Payment Type',
            textAlign: TextAlign.end,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Text(
          ': ',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.0,
          ),
        ),
        Expanded(
          flex: 6,
          child:CustomSearchField.buildSearchField(_paymentTypeController, 'Select', null, _paymentType, (String value) {},true, true),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey[300],
      thickness: 1,
      height: 10,
    );
  }


}
