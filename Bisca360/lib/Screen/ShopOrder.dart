import 'dart:convert';
import 'dart:io';

import 'package:bisca360/Request/ShopOrderRequest.dart';
import 'package:bisca360/Response/ShopOrderClosedBill.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pinput/pinput.dart';
import 'package:searchfield/searchfield.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ApiService/Apis.dart';
import '../Request/ShopBillProducts.dart';
import '../Request/ShopSalesDetailsRequest.dart';
import '../Response/DefaultResponse.dart';
import '../Response/EmployeeAndSeatingResponse.dart';
import '../Response/OwnerTaxResponse.dart';
import '../Response/ShopCustomerResponse.dart';
import '../Response/ShopProductResponse.dart';
import '../Response/ShopResponse.dart';
import '../Response/ShopSalesDetailsResponse.dart';
import '../Service/LoginService.dart';
import '../Widget/AppTextFormField.dart';
import '../Widget/CustomSearchfieldWidget.dart';
import '../Widget/TextDatewidget.dart';

class ShopOrder extends StatefulWidget {
  const ShopOrder({super.key});

  @override
  State<ShopOrder> createState() => _ShopOrderState();
}

class _ShopOrderState extends State<ShopOrder> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _orderNoController = TextEditingController();

  final TextEditingController _customerController = TextEditingController();

  final TextEditingController _CustomerCountController =
      TextEditingController();
  late TextEditingController _qtyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  late TextEditingController _datePickerController = TextEditingController();
  final TextEditingController _mealTimeController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _paymentTypeController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _grandTotalController = TextEditingController();
  final TextEditingController _tableOrChairController = TextEditingController();
  final TextEditingController _supplierOrHairStylistController =
      TextEditingController();
  final TextEditingController _tableChairController = TextEditingController();
  final TextEditingController _supplierHairStylistController =
      TextEditingController();

  late List<Shopresponse> shopResponses = [];
  ShopSalesDetailsResponse? lastBillResponse;
  EmployeeAndSeatingResponse? employeeAndSeatingResponse;
  late List<ShoppProductResponse> shopProducts = [];
  late List<ShopCustomerResponse> shopCustomer = [];
  late List<ShopOrderClosedBill> shopOrderClosedBill = [];

  ShopOrderRequest? shopOrderResponse;
  List<ShopBillProducts> billedProducts = [];
  List<OwnerTaxResponse> taxItems = [];
  List<String> deleteRemarks = [];
  List<SearchFieldListItem<String>> _supplierName = [];
  List<SearchFieldListItem<String>> _chairNo = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late ShopSalesDetailsRequest shopSalesDetailsRequest;

  late ShopOrderRequest shopOrderRequest;
  static late final DefaultResponse response;
  late var cardTotalPrice;
  late double totalPriceS;
  late double totalTaxS;
  late double netTotalS;
  late double discount;
  late double grandTotal;

  double totalTaxRate = 0;
  double taxAmount = 0;

  bool _isProductSelected = false;

  late List<String> mealTime = ['Break Fast', 'Lunch', 'Dinner'];
  late List<String> orderStatus = ['Placed Order', 'Cooking', 'Delivered'];

  List<SearchFieldListItem<String>> get _mealTime {
    return mealTime.map((meal) => SearchFieldListItem<String>(meal)).toList();
  }

  List<SearchFieldListItem<String>> get _orderStatus {
    return orderStatus
        .map((status) => SearchFieldListItem<String>(status))
        .toList();
  }

  List<SearchFieldListItem<String>> get _shopItems {
    return shopResponses
        .map((shop) => SearchFieldListItem<String>(shop.shopName))
        .toList();
  }

  late List<SearchFieldListItem<String>> productList;
  List<SearchFieldListItem<String>> get _productItems {
    productList = shopProducts
        .map((shop) => SearchFieldListItem<String>(
            '#${shop.productUid} ${shop.product}(${shop.subcategoryName})(${shop.unit})'))
        .toList();
    return productList;
  }

  late List<SearchFieldListItem<String>> OrderNoList;
  List<SearchFieldListItem<String>> get _OrderNo {
    OrderNoList = shopOrderClosedBill
        .map((order) => SearchFieldListItem<String>(
            '#${order.tableNo} (${order.orderNumber})'))
        .toList();
    return OrderNoList;
  }

  // List<SearchFieldListItem<String>> get _OrderNo {
  //   return shopOrderClosedBill.map((order) => SearchFieldListItem<String>(order.orderNumber)).toList();
  // }
  List<SearchFieldListItem<String>> get _shopCustomerNumber {
    return shopCustomer
        .where((shop) =>
            shop.mobileNumber != 0) // Exclude shops with mobileNumber = 0
        .map(
            (shop) => SearchFieldListItem<String>(shop.mobileNumber.toString()))
        .toList();
  }

  Future<void> deleteLastBill(
      BuildContext context, String remarks, int id) async {
    try {
      final encodedData = Uri.encodeComponent(remarks);
      final url =
          Uri.parse('${Apis.deleteLastBill}?id=$id&remarks=$encodedData');
      print(url.toString());
      final res =
          await Apis.getClient().delete(url, headers: Apis.getHeaders());
      final response = jsonDecode(res.body);
      if (response['status'] == "OK") {
        LoginService.showBlurredSnackBar(context, response['message'],
            type: SnackBarType.success);
        Navigator.of(context).pop();
        print("Success");
      } else {
        LoginService.showBlurredSnackBar(context, response['message'],
            type: SnackBarType.error);
        print('Failed to Last Bill delete');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> getAllShops() async {
    try {
      final response = await Apis.getClient().get(
        Uri.parse(Apis.getActiveShop),
        headers: Apis.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          shopResponses =
              data.map((item) => Shopresponse.fromJson(item)).toList();
        });
      } else {
        print('Failed to load shops');
      }
    } catch (e) {
      print('Error fetching shops: $e');
    }
  }

  Future<void> getSupplierAndChairNo(var shopId) async {
    try {
      final res = await Apis.getClient().get(
        Uri.parse('${Apis.getSupplierAndChairNo}?shopId=$shopId'),
        headers: Apis.getHeaders(),
      );
      if (res.statusCode == 200) {
        final response = jsonDecode(res.body);
        setState(() {
          employeeAndSeatingResponse =
              EmployeeAndSeatingResponse.fromJson(response);
          print('employeeAndSeatingResponse: $employeeAndSeatingResponse');
        });
      } else {
        print('Failed to load EmployeeAndSeatingResponse');
      }
    } catch (e) {
      print('Error fetching EmployeeAndSeatingResponse: $e');
    }
  }

  Future<void> getShopProducts(String shopName) async {
    try {
      final encodedData = Uri.encodeComponent(shopName);

      final url = Uri.parse('${Apis.getShopProduct}$encodedData');
      final response =
          await Apis.getClient().get(url, headers: Apis.getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          shopProducts =
              data.map((item) => ShoppProductResponse.fromJson(item)).toList();
          print('shopProducts: $shopProducts');
        });
      } else {
        print('Failed to load shop products');
      }
    } catch (e) {
      print('Error fetching shop products: $e');
    }
  }

  Future<void> getShopOrderStatus(var shopId, String status) async {
    try {
      final encodedData = Uri.encodeComponent(status);
      final url = Uri.parse(
          '${Apis.getShopOrderStatus}?shopId=$shopId&status=$encodedData');
      final response =
          await Apis.getClient().get(url, headers: Apis.getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          shopOrderClosedBill =
              data.map((item) => ShopOrderClosedBill.fromJson(item)).toList();
          print('shopOrderClosedBill: $shopOrderClosedBill');
        });
      } else {
        print('Failed to load shop Order ClosedBill');
      }
    } catch (e) {
      print('Error fetching shop Order ClosedBill: $e');
    }
  }

  Future<void> getShopOrderDetails(var shopId, String orderId) async {
    try {
      final encodedData = Uri.encodeComponent(orderId);
      final url = Uri.parse(
          '${Apis.getShopOrderDetails}?shopId=$shopId&orderId=$encodedData');
      final res = await Apis.getClient().get(url, headers: Apis.getHeaders());

      final response = jsonDecode(res.body);
      if (response != null) {
        setState(() {
          shopOrderResponse = ShopOrderRequest.fromJson(response);
          billedProducts = shopOrderResponse!.orderItemData;
          _setProps();
          print('shopOrderResponse: $shopOrderResponse');
        });
      } else {
        print('Failed to load shopOrderResponse');
      }
    } catch (e) {
      print('Error fetching shop Order: $e');
    }
  }

  Future<void> updateShopOrderStatus(
      var shopId, String orderId, String status) async {
    try {
      final encodedData = Uri.encodeComponent(orderId);
      final encodedStatus = Uri.encodeComponent(status);
      final url = Uri.parse(
          '${Apis.updateShopOrderStatus}?shopId=$shopId&orderId=$encodedData&status=$encodedStatus');
      final res = await Apis.getClient().get(url, headers: Apis.getHeaders());
      final response = jsonDecode(res.body);
      if (response['status'] == "OK") {
        LoginService.showBlurredSnackBar(context, response['message'],
            type: SnackBarType.success);
        _clear();
        getShopOrderStatus(selectedShopData!.id, 'PREPARED');
        setState(() {
          billedProducts = [];
          shopOrderResponse = null;
        });
        print("Success");
      } else {
        LoginService.showBlurredSnackBar(context, response['message'],
            type: SnackBarType.error);
        print('Failed to load data');
      }
    } catch (e) {
      print('Error fetching shop Order: $e');
    }
  }

  void _setProps() {
    setState(() {
      _tableOrChairController.text = shopOrderResponse!.tableNo;
      _supplierOrHairStylistController.text = shopOrderResponse!.supplier;
      _CustomerCountController.text =
          shopOrderResponse!.customerCount.toString();
    });
  }

  void _clear() {
    _CustomerCountController.clear();
    _productController.clear();
    _qtyController.setText('0');
    _CustomerCountController.clear();

    _tableOrChairController.clear();
    _tableChairController.clear();
    _supplierOrHairStylistController.clear();
    _supplierHairStylistController.clear();
    _orderNoController.clear();
    _grandTotalController.clear();
    setState(() {
      selectedProductData = null;
      selectedShopOrder = null;
    });
  }

  Future<void> saveSalesOrder(ShopOrderRequest shopOrderRequest) async {
    try {
      var res = await Apis.getClient().post(Uri.parse(Apis.saveShopOrder),
          body: jsonEncode(shopOrderRequest.toJson()),
          headers: Apis.getHeaders());
      final response = jsonDecode(res.body);
      if (response['status'] == "OK") {
        // String billNumber = response['shopBillNo'];
        // _downloadBill(context, shopSalesDetailsRequest.shopName,billNumber);
        LoginService.showBlurredSnackBar(context, response['message'],
            type: SnackBarType.success);
        _clear();
        getShopOrderStatus(selectedShopData!.id, 'PREPARED');
        setState(() {
          billedProducts.clear();
          selectedShopOrder = null;
        });
        print('Success to save shop Order : $response');
      } else {
        LoginService.showBlurredSnackBar(context, response['message'],
            type: SnackBarType.error);
        print('Failed to save shop Order ');
      }
    } catch (e) {
      print('data : ${jsonEncode(shopOrderRequest.toJson())}');
      print('Error fetching save Order: $e');
    }
  }

  void _downloadOrder(BuildContext context, var shopId, String orderNumber) {
    final encodedOrderNumber = Uri.encodeComponent(orderNumber);
    final url = Uri.parse(
        '${Apis.shopOrderBill}?shopId=$shopId&orderId=$encodedOrderNumber');
    String fileName = '$orderNumber-${DateTime.now()}';
    downloadPdf(context, url, fileName);
  }

  String? _downloadPath;

  Future<void> downloadPdf(
      BuildContext context, final url, String fileName) async {
    try {
      print('URL ; $url');
      final response =
          await Apis.getClient().get(url, headers: Apis.getHeaders());
      final bytes = response.bodyBytes;
      Directory? directory;
      if (Platform.isAndroid) {
        // directory = Directory('/storage/emulated/0/Download');
        directory = (await getExternalStorageDirectories(
                type: StorageDirectory.downloads))
            ?.first;
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }
      _downloadPath = directory?.path ?? '';
      final filePath = '$_downloadPath/$fileName.pdf';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      if (filePath != null) {
        await printPdf(filePath);
      } else {
        print("Failed to download PDF");
      }
      // LoginService.showBlurredSnackBarFile(context, 'Bill Downloaded Successfully ', filePath, type: SnackBarType.success);
      print('File Service : Bill download Success $filePath');
    } catch (e) {
      print('File Service : Error on Bill download failed $e');
    }
  }

  Future<void> printPdf(String filePath) async {
    final file = File(filePath);
    print(filePath);
    if (await file.exists()) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => file.readAsBytes(),
      );
    } else {
      print("File does not exist");
    }
  }

  late Shopresponse? selectedShopData;

  void _handleShopSelection(String selectedShop) {
    setState(() {
      selectedShopData = null;
    });
    _productController.clear();
    _orderNoController.clear();
    _tableOrChairController.clear();
    _supplierOrHairStylistController.clear();
    billedProducts.clear();
    _OrderNo.clear();
    _shopCustomerNumber.clear();
    _productItems.clear();
    _supplierName.clear();
    _chairNo.clear();
    getShopProducts(selectedShop);
    selectedShopData =
        shopResponses.firstWhere((shop) => shop.shopName == selectedShop);
    getShopOrderStatus(selectedShopData!.id, 'PREPARED');
    getSupplierAndChairNo(selectedShopData!.id).then((_) {
      updateProductItems();
    });
  }

  _getShopId() {
    // getAllCategories(_shopNameController.text);
    var shopId = 0;
    if (_shopNameController.text.isNotEmpty) {
      for (Shopresponse shop in shopResponses) {
        if (_shopNameController.text == shop.shopName) {
          shopId = shop.id;
          break;
        }
      }
    }
    return shopId;
  }

  void updateProductItems() {
    if (employeeAndSeatingResponse != null) {
      setState(() {
        _supplierName = employeeAndSeatingResponse!.employees
            .map((name) => SearchFieldListItem<String>(name))
            .toList();
        _chairNo = employeeAndSeatingResponse!.seating
            .map((number) => SearchFieldListItem<String>(number))
            .toList();
      });
    }
  }

  late ShopCustomerResponse selectedCustomerData;

  ShopOrderClosedBill? selectedShopOrder;
  void _handleOrderNoSelection(String selectedOrder) {
    // Use a more general regular expression to capture any order number pattern in parentheses
    RegExp regex = RegExp(r'\(([^)]+)\)');
    Match? match = regex.firstMatch(selectedOrder);

    if (match != null) {
      String orderNumber =
          match.group(1)!; // This will be the extracted order number

      billedProducts = [];
      selectedShopOrder = shopOrderClosedBill
          .firstWhere((order) => order.orderNumber == orderNumber);
      getShopOrderDetails(selectedShopData!.id, selectedShopOrder!.orderNumber);
    } else {
      // Handle the case where the order number is not found
      print('Order number not found in selectedOrder.');
    }
  }

  void _handleCustomerNumberSelection(String selectedCustomer) {
    int customerNo = int.parse(selectedCustomer);
    selectedCustomerData = shopCustomer
        .firstWhere((customer) => customer.mobileNumber == customerNo);
    if (selectedCustomerData.customerName.isNotEmpty) {
      _customerController.setText(selectedCustomerData.customerName);
    }
  }

  late var selectedProductData;

  void _handleProductSelection(String selectedProduct) {
    String productName = selectedProduct
        .trim()
        .split('(')[0]
        .trim()
        .split(' ')
        .skip(1)
        .join(' ');
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

  void _recalculateGrandTotal() {
    final discount = double.tryParse(_discountController.text) ?? 0;
    final netAmt;
    if (selectedShopData!.includedTax) {
      netAmt = _cardTotalPrice ?? 0.00;
    } else {
      netAmt = _cardTotalPrice + _cardTotalTax ?? 0.0;
    }
    final discountAmount = discount > netAmt
        ? netAmt
        : discount; // Ensure discount doesn't exceed net amount
    grandTotal = netAmt - discountAmount;
    setState(() {
      _grandTotalController.text = grandTotal
          .toStringAsFixed(2); // Display grand total with two decimal places
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
    if (selectedShopData != null) {
      taxItems = selectedShopData!.listOwnerTaxResponse;
    }
    double totalTaxPercentage = taxItems.fold(
      0.0,
      (sum, item) => sum + (item.taxPercentage ?? 0.0),
    );
    totalTaxS = (totalWoT * totalTaxPercentage) / 100;
    return totalTaxS;
  }

  double get _netTotalAmtInTax {
    double netAMT = _cardTotalTax + _cardTotalPrice;

    // Check for 'Round Up' condition
    if (selectedShopData!.rounding == 'Round Up') {
      if (netAMT % 1 < 0.5) {
        return netAMT.floorToDouble(); // Round down
      } else {
        return netAMT.ceilToDouble(); // Round up
      }
    } else {
      return netAMT.floorToDouble(); // Round down
    }
  }

  double get _netTotalAmtOutTax {
    double netAMT = _cardTotalPrice;

    // Check for 'Round Up' condition
    if (selectedShopData!.rounding == 'Round Up') {
      if (netAMT % 1 < 0.5) {
        return netAMT.floorToDouble(); // Round down
      } else {
        return netAMT.ceilToDouble(); // Round up
      }
    } else {
      return netAMT.floorToDouble(); // Round down
    }
  }

  @override
  void initState() {
    super.initState();
    getAllShops().then((_) {
      // Ensure this runs after the shops have been fetched
      if (shopResponses.isNotEmpty) {
        _shopNameController.text = shopResponses.first.shopName;
        _handleShopSelection(_shopNameController.text);
        getShopProducts(_shopNameController
            .text); // Fetch products after setting the shop name
        getShopOrderStatus(shopResponses.first.id, 'PREPARED');
      }
    });
    _clear();
    _qtyController.text = '0';
    _datePickerController.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    _qtyController.addListener(_recalculateTotalPrice);
    _discountController.addListener(_recalculateGrandTotal);
    selectedShopData = null;
  }

  @override
  void dispose() {
    _qtyController
        .dispose(); // Clean up the controller when the widget is disposed
    super.dispose();
  }

  void _saveOrder() {
    var id = 0;
    if (shopOrderResponse != null) {
      id = shopOrderResponse!.id;
    }
    totalTaxS = 0;
    if (selectedShopData!.includedTax && selectedShopData!.taxEnable) {
      netTotalS = totalPriceS;
      totalTaxS = double.parse(
          (_cardTotalPrice * totalTaxRate / (100 + totalTaxRate))
              .toStringAsFixed(2));
    } else if (selectedShopData!.taxEnable && !selectedShopData!.includedTax) {
      netTotalS = totalTaxS + totalPriceS;
    } else {
      netTotalS = totalPriceS;
    }
    String tableNo = '';
    String chairNo = '';
    String hairStylist = '';
    String supplier = '';
    if (selectedShopData!.shopType == 'Hotel') {
      tableNo = _tableOrChairController.text;
      supplier = _supplierOrHairStylistController.text;
    } else if (selectedShopData!.shopType == 'Saloon') {
      chairNo = _tableOrChairController.text;
      hairStylist = _supplierOrHairStylistController.text;
    }

    shopOrderRequest = ShopOrderRequest(
      id: id,
      shopName: selectedShopData!.shopName,
      orderItemData: billedProducts,
      totalPrice: totalPriceS,
      totalTax: totalTaxS,
      shopType: selectedShopData!.shopType,
      netTotalPrice: netTotalS,
      orderDate: _datePickerController.text,
      dayTime: _mealTimeController.text,
      tableNo: tableNo,
      orderNumber: '',
      orderStatus: '',
      supplier: supplier,
      taxEnable: selectedShopData!.taxEnable,
      listTaxResponse: selectedShopData!.listOwnerTaxResponse,
      shopId: selectedShopData!.id,
      customerCount: int.parse(_CustomerCountController.text),
      includedTax: selectedShopData!.includedTax,
    );

    saveSalesOrder(shopOrderRequest);
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
    var selectedShop = _shopNameController.text;
    selectedShopData = shopResponses.firstWhere(
      (shop) => shop.shopName == selectedShop,
    );
    if (selectedShopData != null) {
      taxItems = selectedShopData!.listOwnerTaxResponse;
    }
    if (selectedShopData!.includedTax) {
      totalTaxRate =
          taxItems.fold(0, (total, tax) => total + tax.taxPercentage);
      taxAmount = _cardTotalPrice * totalTaxRate / (100 + totalTaxRate);
    }
    final String item =
        _productController.text.trim().split(' ').skip(1).join(' ');
    ; // Trim whitespace
    final int quantity = int.tryParse(_qtyController.text) ?? 0;
    final double price =
        double.tryParse(selectedProductData.price.toString()) ?? 0.0;
    final double totalPrice = price * quantity;
    final productData = shopProducts.firstWhere(
      (product) => product.product == selectedProductData.product,
    );
    if (productData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected product does not exist')),
      );
      return;
    }
    if (item.isEmpty || quantity <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields correctly')),
      );
      print('Please fill in all fields correctly');
      return;
    }
    final newProduct = ShopBillProducts(item, productData.unit.toString(),
        price, quantity, totalPrice, 'Placed Order');
    bool productExists =
        billedProducts.any((product) => product.item == newProduct.item);
    if (!productExists) {
      setState(() {
        billedProducts.add(newProduct);
        _recalculateGrandTotal();
      });
    } else {
      LoginService.showBlurredSnackBar(
          context, 'This product is already added!',
          type: SnackBarType.error);
    }
    _productController.clear();
    _qtyController.text = '0';
    _priceController.clear();
  }

  void _deleteProduct(int index) {
    setState(() {
      billedProducts.removeAt(index);
      _recalculateGrandTotal();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth =
        screenWidth * 0.28; // Adjust as needed (e.g., 20% of screen width)
    final textSize = screenWidth * 0.027; // Adjust as needed for text size
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: const Text('Shop Order', style: TextStyle(color: Colors.white)),
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
                    false,
                    true,
                    true,
                    true),
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
                    if (selectedShopData?.shopType == 'Hotel')
                      Expanded(
                        child: CustomSearchField.buildSearchField(
                            _mealTimeController,
                            'Meal Time',
                            Icons.category,
                            _mealTime,
                            (String value) {},
                            false,
                            true,
                            true,
                            false),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomSearchField.buildSearchField(
                    _orderNoController,
                    'Order No',
                    Icons.abc,
                    _OrderNo,
                    _handleOrderNoSelection,
                    false,
                    false,
                    true,
                    true),
                if (selectedShopData?.shopType == 'Hotel' ||
                    selectedShopData?.shopType == 'Saloon') ...[
                  const SizedBox(height: 10),
                  if (selectedShopOrder == null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: CustomSearchField.buildSearchField(
                            _tableOrChairController,
                            selectedShopData?.shopType == 'Hotel'
                                ? 'Table'
                                : 'Chair No',
                            selectedShopData?.shopType == 'Hotel'
                                ? Icons.table_restaurant
                                : Icons.chair,
                            _chairNo,
                            (String value) {},
                            false,
                            selectedShopOrder == null ? true : false,
                            true,
                            true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomSearchField.buildSearchField(
                            _supplierOrHairStylistController,
                            selectedShopData?.shopType == 'Hotel'
                                ? 'Waiter'
                                : 'Hair Stylist',
                            selectedShopData?.shopType == 'Hotel'
                                ? Icons.supervised_user_circle
                                : Icons.supervised_user_circle,
                            _supplierName,
                            (String value) {},
                            false,
                            selectedShopOrder == null ? true : false,
                            true,
                            true,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (selectedShopOrder != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: AppTextFieldForm(
                            _tableOrChairController,
                            selectedShopData?.shopType == 'Hotel'
                                ? 'Table'
                                : 'Chair No',
                            selectedShopData?.shopType == 'Hotel'
                                ? Icon(Icons.table_restaurant)
                                : Icon(Icons.chair),
                            TextInputAction.next,
                            TextInputType.text,
                            false,
                            selectedShopOrder != null ? true : false,
                            maxLines: null,
                            textAlignVertical: TextAlignVertical.center,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppTextFieldForm(
                            _supplierOrHairStylistController,
                            selectedShopData?.shopType == 'Hotel'
                                ? 'Waiter'
                                : 'Hair Stylist',
                            selectedShopData?.shopType == 'Hotel'
                                ? Icon(Icons.supervised_user_circle)
                                : Icon(Icons.supervised_user_circle),
                            TextInputAction.next,
                            TextInputType.text,
                            false,
                              selectedShopOrder != null ? true : false,
                            maxLines: null,
                            textAlignVertical: TextAlignVertical.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
                const SizedBox(height: 10),
                AppTextFieldForm(
                  _CustomerCountController,
                  'Customer Count',
                  Icon(Icons.numbers, color: Colors.green),
                  TextInputAction.next,
                  TextInputType.number,
                  true,
                  true,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.center,
                ),
                const SizedBox(height: 10),
                CustomSearchField.buildSearchField(
                    _productController,
                    'Product',
                    Icons.fastfood,
                    _productItems,
                    _handleProductSelection,
                    false,
                    true,
                    false,
                    true),
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
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.black),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _qtyController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
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
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.black),
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
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _billProduct();
                            setState(() {
                              _isProductSelected = false;
                            }); // Trigger a rebuild
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please fill in all fields correctly')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text('Add',
                            style: TextStyle(color: Colors.white)),
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
                        Expanded(
                            child: Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Text('S.No',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        )),
                        Expanded(
                            child: Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: Text('Products',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        )),
                        Expanded(
                            child: Padding(
                          padding: EdgeInsets.only(left: 30),
                          child: Text('Qty',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        )),
                        Expanded(
                            child: Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: Text('Price',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Column(
                    children: billedProducts.map((product) {
                      final index = billedProducts.indexOf(product);
                      return GestureDetector(
                        onTap: () =>
                            _showEditProductDialog(context, product, index),
                        child: Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('${index + 1}',
                                      style: TextStyle(fontSize: 15)),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(product.item,
                                      style: TextStyle(fontSize: 15)),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('${product.quantity}',
                                      style: TextStyle(fontSize: 15)),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      '${product.totalPriceList.toStringAsFixed(0)}',
                                      style: TextStyle(fontSize: 15)),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteProduct(index),
                              ),
                            ],
                          ),
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
                          _buildRow('Total Price', '', '₹',
                              _cardTotalPrice.toStringAsFixed(2)),
                          if (selectedShopData!.taxEnable &&
                              selectedShopData!.includedTax) ...[
                            ...taxItems.map((tax) => _buildRow(
                                '${tax.taxType} (${tax.taxPercentage})',
                                '',
                                '₹',
                                (tax.taxPercentage *
                                        _cardTotalPrice /
                                        (100 + totalTaxRate))
                                    .toStringAsFixed(2))),
                            _buildRow(
                                'Total Tax',
                                '',
                                '₹',
                                (_cardTotalPrice *
                                        totalTaxRate /
                                        (100 + totalTaxRate))
                                    .toStringAsFixed(2))
                          ],
                          if (selectedShopData!.taxEnable &&
                              !selectedShopData!.includedTax) ...[
                            ...taxItems.map((tax) => _buildRow(
                                '${tax.taxType} (${tax.taxPercentage})',
                                '',
                                '₹',
                                (tax.taxPercentage * _cardTotalPrice / 100)
                                    .toString())),
                            _buildRow('Total Tax', '', '₹',
                                (_cardTotalTax).toStringAsFixed(2)),
                            _buildDivider(),
                          ],
                          if (selectedShopData!.taxEnable &&
                              selectedShopData!.includedTax) ...[
                            _buildRow('Grand Total Amount', '', '₹',
                                _netTotalAmtOutTax.toStringAsFixed(2)),
                          ],
                          if (selectedShopData!.taxEnable &&
                              !selectedShopData!.includedTax) ...[
                            _buildRow('Grand Total Amount', '', '₹',
                                _netTotalAmtInTax.toStringAsFixed(2)),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 5),
                      SizedBox(
                        width: buttonWidth,
                        child: ElevatedButton(
                          onPressed: () {
                            _clear();
                            setState(() {
                              billedProducts.clear();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text('Clear',
                              style: TextStyle(
                                  color: Colors.white, fontSize: textSize)),
                        ),
                      ),
                        const SizedBox(width: 5),
                        SizedBox(
                          width: buttonWidth,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_CustomerCountController.text.isNotEmpty && _supplierOrHairStylistController.text.isNotEmpty && _tableOrChairController.text.isNotEmpty) {
                                _saveOrder();
                                setState(() {
                                  _isProductSelected = false;
                                });
                              } else {
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
                            child: Text(
                              shopOrderResponse == null
                                  ? 'Save'
                                  : 'Update',
                              style: TextStyle(
                                  color: Colors.white, fontSize: textSize),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (selectedShopOrder != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 5),
                      SizedBox(
                        width: buttonWidth,
                        child: ElevatedButton(
                          onPressed: () {
                            updateShopOrderStatus(_getShopId(),
                                selectedShopOrder!.orderNumber, 'CANCELED');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: Colors.white, fontSize: textSize)),
                        ),
                      ),
                      const SizedBox(width: 5),
                      SizedBox(
                        width: buttonWidth,
                        child: ElevatedButton(
                          onPressed: () {
                            updateShopOrderStatus(_getShopId(),
                                selectedShopOrder!.orderNumber, 'CLOSED');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text('Close',
                              style: TextStyle(
                                  color: Colors.white, fontSize: textSize)),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextButton.icon(
                          icon: const Icon(Icons.print, color: Colors.indigo),
                          label: Text('Print Order',
                              style: TextStyle(
                                  color: Colors.black, fontSize: textSize)),
                          onPressed: () {
                            var id = selectedShopData!.id;
                            String orderNumber =
                                selectedShopOrder!.orderNumber;
                            _downloadOrder(context, id, orderNumber);
                          },
                        ),
                      ),
                    ],
                  ),
                  ],
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     ElevatedButton(
                  //       onPressed: () {
                  //         _clear();
                  //       },
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: Colors.red,
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(25),
                  //         ),
                  //       ),
                  //       child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                  //     ),
                  //     const SizedBox(width: 10),
                  //     ElevatedButton(
                  //       onPressed: _saveOrder,
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: Colors.green,
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(25),
                  //         ),
                  //       ),
                  //       child: const Text('Save', style: TextStyle(color: Colors.white)),
                  //     ),
                  //   ],
                  // ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      TextInputType keyboardType) {
    final borderRadius = BorderRadius.circular(20);
    return Align(
      alignment: Alignment.centerRight, // Align to the right
      child: Container(
        width:
            MediaQuery.of(context).size.width * 0.3, // Half of the screen width
        child: SizedBox(
          height: 30,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              isDense: true,
              errorStyle: const TextStyle(
                fontSize: 10,
                color: Colors.redAccent,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.green, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                borderRadius: borderRadius,
              ),
              errorBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Colors.redAccent, width: 1.0),
                borderRadius: borderRadius,
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Colors.redAccent, width: 1.0),
                borderRadius: borderRadius,
              ),
              filled: true,
              fillColor: Colors.white,
              floatingLabelAlignment: FloatingLabelAlignment.start,
              label: Text(
                labelText,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            keyboardType: keyboardType,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField1(TextEditingController controller, String labelText,
      IconData icon, TextInputType keyboardType) {
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

  Widget _buildRow(
      String label, String title, String currencySymbol, String amount) {
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

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey[300],
      thickness: 1,
      height: 10,
    );
  }

  Future<void> showDeleteBillDialog(
      BuildContext context, String billNo, List<String> deleteRemarks) async {
    String? selectedRemark; // To hold the selected remark

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Bill( $billNo )',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 50, // Set your desired height here
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Remark',
                    border: OutlineInputBorder(),
                  ),
                  items: deleteRemarks.map((remark) {
                    return DropdownMenuItem<String>(
                      value: remark,
                      child: Text(remark),
                    );
                  }).toList(),
                  value: selectedRemark,
                  onChanged: (String? value) {
                    setState(() {
                      selectedRemark = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a remark' : null,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blueGrey,
              ),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child:
                  const Text('Delete', style: TextStyle(color: Colors.white)),
              onPressed: () {
                if (selectedRemark != null) {
                  deleteLastBill(context, selectedRemark!,
                      lastBillResponse!.id); // Pass selected remark
                } else {
                  // Show a snackbar or alert if no remark is selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Please select a remark before deleting')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditProductDialog(
      BuildContext context, ShopBillProducts product, int index) {
    // Create controllers for the input fields
    TextEditingController itemController =
        TextEditingController(text: product.item);
    TextEditingController quantityController =
        TextEditingController(text: product.quantity.toString());
    TextEditingController priceController =
        TextEditingController(text: product.totalPriceList.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Center(
            child: const Text(
              'Change Status',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                enabled: false,
                controller: itemController,
                decoration: InputDecoration(labelText: 'Item'),
              ),
              CustomSearchField.buildSearchField(
                    _statusController,
                    'Status',
                    Icons.access_alarms,
                    _orderStatus,
                        (String value) {},
                    false,
                    true,
                    true,
                    false),
              // TextField(
              //   controller: quantityController,
              //   decoration: InputDecoration(labelText: 'Quantity'),
              //   keyboardType: TextInputType.number,
              // ),
              // TextField(
              //   controller: priceController,
              //   decoration: InputDecoration(labelText: 'Total Price'),
              //   keyboardType: TextInputType.number,
              // ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blueGrey,
              ),
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Update', style: TextStyle(color: Colors.white)),
              onPressed: () {
                // Update the product with new values
                setState(() {
                  product.item = itemController.text;
                  // product.quantity = int.parse(quantityController.text);
                  // product.totalPriceList = double.parse(priceController.text);
                  product.status = _statusController.text;
                });
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     return AlertDialog(
    //       title: Center(child: Text('Change Status')),
    //       content: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           TextField(
    //             style:
    //                 TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    //             enabled: false,
    //             controller: itemController,
    //             decoration: InputDecoration(labelText: 'Item'),
    //           ),
    //           Expanded(
    //             child: CustomSearchField.buildSearchField(
    //                 _statusController,
    //                 'Status',
    //                 Icons.access_alarms,
    //                 _orderStatus,
    //                 (String value) {},
    //                 false,
    //                 true,
    //                 true,
    //                 false),
    //           ),
    //           // TextField(
    //           //   controller: quantityController,
    //           //   decoration: InputDecoration(labelText: 'Quantity'),
    //           //   keyboardType: TextInputType.number,
    //           // ),
    //           // TextField(
    //           //   controller: priceController,
    //           //   decoration: InputDecoration(labelText: 'Total Price'),
    //           //   keyboardType: TextInputType.number,
    //           // ),
    //         ],
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () {
    //             // Update the product with new values
    //             setState(() {
    //               product.item = itemController.text;
    //               // product.quantity = int.parse(quantityController.text);
    //               // product.totalPriceList = double.parse(priceController.text);
    //               product.status = _statusController.text;
    //             });
    //             Navigator.of(context).pop(); // Close the dialog
    //           },
    //           child: Text('Update'),
    //         ),
    //         TextButton(
    //           onPressed: () {
    //             Navigator.of(context).pop(); // Close the dialog without saving
    //           },
    //           child: Text('Cancel'),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }
}
