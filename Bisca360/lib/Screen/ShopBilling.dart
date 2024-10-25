import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bisca360/Request/ShopBillProducts.dart';
import 'package:bisca360/Response/BiilingResponse.dart';
import 'package:bisca360/Response/EmployeeAndSeatingResponse.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pinput/pinput.dart';
import 'package:searchfield/searchfield.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';


import '../ApiService/Apis.dart';
import '../Request/ShopOrderRequest.dart';
import '../Request/ShopSalesDetailsRequest.dart';
import '../Response/DefaultResponse.dart';
import '../Response/OwnerTaxResponse.dart';
import '../Response/ShopCustomerResponse.dart';
import '../Response/ShopOrderClosedBill.dart';
import '../Response/ShopProductResponse.dart';
import '../Response/ShopResponse.dart';
import '../Response/ShopSalesDetailsResponse.dart';
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
  final TextEditingController _orderNoController = TextEditingController();
  final TextEditingController _customerMobileNumberController = TextEditingController();
  late TextEditingController _qtyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  late TextEditingController _datePickerController = TextEditingController();
  final TextEditingController _mealTimeController = TextEditingController();
  final TextEditingController _paymentTypeController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _grandTotalController = TextEditingController();
  final TextEditingController _tableOrChairController = TextEditingController();
  final TextEditingController _supplierOrHairStylistController = TextEditingController();

  late List<Shopresponse> shopResponses = [];
  ShopSalesDetailsResponse? lastBillResponse;
  EmployeeAndSeatingResponse? employeeAndSeatingResponse;
  late List<ShoppProductResponse> shopProducts = [];
  late List<ShopCustomerResponse> shopCustomer = [];

  late ShopOrderRequest shopOrderResponse;

  late List<ShopOrderClosedBill> shopOrderClosedBill = [];
  List<ShopBillProducts> billedProducts = [];
  List<OwnerTaxResponse> taxItems = [];
  List<String> deleteRemarks = [];
  List<SearchFieldListItem<String>> _supplierName = [];
  List<SearchFieldListItem<String>> _chairNo = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late ShopSalesDetailsRequest shopSalesDetailsRequest;
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
  late List<String> paymentType = [ 'Cash', 'UPI','Credit Card', 'Debit Card',];

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
            '#${shop.productUid} ${shop.product}(${shop.subcategoryName})(${shop.unit})'
        )
    ).toList();
    return productList;
  }

  List<SearchFieldListItem<String>> get _shopCustomer {
    return shopCustomer.map((shop) => SearchFieldListItem<String>(shop.customerName)).toList();
  }
  List<SearchFieldListItem<String>> get _shopCustomerNumber {
    return shopCustomer
        .where((shop) => shop.mobileNumber != 0) // Exclude shops with mobileNumber = 0
        .map((shop) => SearchFieldListItem<String>(shop.mobileNumber.toString()))
        .toList();
  }

  Future<void> deleteLastBill( BuildContext context,String remarks, int id) async {
    try {
      final encodedData = Uri.encodeComponent(remarks);
      final url = Uri.parse('${Apis.deleteLastBill}?id=$id&remarks=$encodedData');
      print(url.toString());
      final res = await Apis.getClient().delete(url, headers: Apis.getHeaders());
      final response = jsonDecode(res.body);
      if (response['status'] == "OK") {
        LoginService.showBlurredSnackBar(context, response['message'] , type: SnackBarType.success);
        Navigator.of(context).pop();
        print("Success");
      } else {
        LoginService.showBlurredSnackBar(context, response['message'] , type: SnackBarType.error);
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
          shopResponses = data.map((item) => Shopresponse.fromJson(item)).toList();
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
          employeeAndSeatingResponse = EmployeeAndSeatingResponse.fromJson(response);
          print('employeeAndSeatingResponse: $employeeAndSeatingResponse');
        });
      } else {
        print('Failed to load EmployeeAndSeatingResponse');
      }
    } catch (e) {
      print('Error fetching EmployeeAndSeatingResponse: $e');
    }
  }

  Future<void> getDeleteRemarks() async {
    try {
      final response = await Apis.getClient().get(
        Uri.parse(Apis.getDeleteRemarks),
        headers: Apis.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          deleteRemarks = List<String>.from(data.map((item) => item.toString()));
        });
      } else {
        print('Failed to load delete remarks, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching delete remarks: $e');
    }
  }


  Future<void> getLastBillNo() async {
    try {
      final res = await Apis.getClient().get(
        Uri.parse(Apis.getLastBillNo),
        headers: Apis.getHeaders(),
      );
       final response = jsonDecode(res.body);
      if (response != null) {
        setState(() {
          lastBillResponse = ShopSalesDetailsResponse.fromJson(response);
          print('lastBillResponse: $lastBillResponse');
        });
      } else {
        print('Failed to load lastBillResponse');
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
    _customerMobileNumberController.clear();
    _productController.clear();
    _supplierOrHairStylistController.clear();
    _tableOrChairController.clear();
    _qtyController.setText('0');
    setState(() {
      billedProducts = [];
    });
    _discountController.clear();
    _grandTotalController.clear();
    _orderNoController.clear();
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
        _downloadBill(context, shopSalesDetailsRequest.shopName,billNumber);
        // LoginService.showBlurredSnackBar(context, response['message'], type: SnackBarType.success);
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


  void _downloadBill(BuildContext context, String shopName, String billNumber){
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
      if (filePath != null) {
        await printPdf(filePath);
      } else {
        print("Failed to download PDF");
      }
      // LoginService.showBlurredSnackBarFile(context, 'Bill Downloaded Successfully ', filePath, type: SnackBarType.success);
      print('File Service : Bill download Success $filePath');
    } catch(e){
      print('File Service : Error on Bill download failed $e');
    }
  }

  Future<void> getShopOrderDetails(var shopId, String orderId) async{
    try{
      final encodedData = Uri.encodeComponent(orderId);
      final url = Uri.parse('${Apis.getShopOrderDetails}?shopId=$shopId&orderId=$encodedData');
      final res = await Apis.getClient().get(url, headers: Apis.getHeaders());

      final response = jsonDecode(res.body);
      if (response != null) {
        setState(() {
          shopOrderResponse = ShopOrderRequest.fromJson(response);
          billedProducts = shopOrderResponse.orderItemData;
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

  Future<void> getShopOrderStatus(var shopId,String status ) async {
    try {
      final encodedData = Uri.encodeComponent(status);
      final url = Uri.parse('${Apis.getShopOrderStatus}?shopId=$shopId&status=$encodedData');
      final response = await Apis.getClient().get(url, headers: Apis.getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          shopOrderClosedBill = data.map((item) => ShopOrderClosedBill.fromJson(item)).toList();
          print('shopOrderClosedBill: $shopOrderClosedBill');
        });
      } else {
        print('shopOrderClosedBill: Failed to load shop Order ClosedBill');
      }
    } catch (e) {
      print('shopOrderClosedBill:  Error fetching shop Order ClosedBill: $e');
    }
  }

  void _setProps(){
    setState(() {
      _tableOrChairController.text = shopOrderResponse.tableNo;
      _supplierOrHairStylistController.text = shopOrderResponse.supplier;
      _recalculateGrandTotal();
    });
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

  late  Shopresponse? selectedShopData;

  void _handleShopSelection(String selectedShop) {
    setState(() {
      selectedShopData = null;
      selectedShopData = shopResponses.firstWhere(
              (shop) => shop.shopName == selectedShop
      );
    });
    _productController.clear();
    _customerController.clear();
    _tableOrChairController.clear();
    _supplierOrHairStylistController.clear();
    billedProducts.clear();
    shopOrderClosedBill = [];
    _shopCustomer.clear();
    _shopCustomerNumber.clear();
    _productItems.clear();
    _supplierName.clear();
    _chairNo.clear();
    getShopProducts(selectedShop);
    getShopCustomer(selectedShop);
    selectedShopData = shopResponses.firstWhere(
            (shop) => shop.shopName == selectedShop
    );
    getShopOrderStatus(selectedShopData!.id, 'CLOSED');
    getSupplierAndChairNo(selectedShopData!.id).then((_) {
      updateProductItems();
    });
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

  List<SearchFieldListItem<String>> get _OrderNo {
    return shopOrderClosedBill.map((order) => SearchFieldListItem<String>(order.orderNumber)).toList();
  }


  late  ShopCustomerResponse selectedCustomerData;
  void _handleCustomerNameSelection(String selectedCustomer) {
    _customerMobileNumberController.clear();
    selectedCustomerData = shopCustomer.firstWhere(
            (customer) => customer.customerName == selectedCustomer
    );
    if(selectedCustomerData.mobileNumber !=0) {
      _customerMobileNumberController.setText(
          selectedCustomerData.mobileNumber.toString());
    }
  }

  ShopOrderClosedBill? selectedShopOrder;
  void _handleOrderNoSelection(String selectedOrder) {
    billedProducts=[];
    selectedShopOrder = shopOrderClosedBill.firstWhere(
            (order) => order.orderNumber == selectedOrder);
    getShopOrderDetails(selectedShopData!.id, selectedShopOrder!.orderNumber);
  }
  void _handleCustomerNumberSelection(String selectedCustomer) {
   int customerNo = int.parse(selectedCustomer);
    selectedCustomerData = shopCustomer.firstWhere(
            (customer) => customer.mobileNumber == customerNo
    );
    if(selectedCustomerData.customerName.isNotEmpty) {
      _customerController.setText(selectedCustomerData.customerName);
    }
  }


  late var selectedProductData;

  void _handleProductSelection(String selectedProduct) {
    String productName = selectedProduct.trim().split('(')[0].trim().split(' ').skip(1).join(' ');
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
    if(selectedShopData!.includedTax){
       netAmt = _cardTotalPrice ?? 0.00;
    }else {
       netAmt = _cardTotalPrice + _cardTotalTax ?? 0.0;
    }
    final discountAmount = discount > netAmt ? netAmt : discount; // Ensure discount doesn't exceed net amount
    grandTotal = netAmt - discountAmount;
    setState(() {
      _grandTotalController.text = grandTotal.toStringAsFixed(2); // Display grand total with two decimal places
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
    if(selectedShopData!=null){
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
    double netAMT =_cardTotalPrice;

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
        getShopProducts(_shopNameController.text); // Fetch products after setting the shop name
        getShopCustomer(_shopNameController.text);
        getShopOrderStatus(shopResponses.first.id, 'CLOSED');
      }
      getLastBillNo();
    });
    _clear();
    _qtyController.text = '0';
    _datePickerController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _qtyController.addListener(_recalculateTotalPrice);
    _discountController.addListener(_recalculateGrandTotal);
    selectedShopData = null;
  }

  @override
  void dispose() {
    _qtyController.dispose(); // Clean up the controller when the widget is disposed
    _discountController.dispose(); // Clean up the controller when the widget is disposed
    super.dispose();
  }

  void _saveBill() {

    discount = 0;
    totalTaxS = 0;
    if(_discountController.text.isNotEmpty) {
      discount = double.parse(_discountController.text);
    }
    if(selectedShopData!.includedTax && selectedShopData!.taxEnable){
      netTotalS = totalPriceS;
      totalTaxS= double.parse((_cardTotalPrice * totalTaxRate / (100 + totalTaxRate)).toStringAsFixed(2));
    }else if(selectedShopData!.taxEnable && !selectedShopData!.includedTax){
    netTotalS =  totalTaxS + totalPriceS;
    }
    else{
      netTotalS =  totalPriceS;
    }
    String customerNameS = _customerController.text;
    int customerId = 0;
    int customerNumber = 0; // Keep this as int
    if (customerNameS.isNotEmpty && shopCustomer.isNotEmpty) {
      ShopCustomerResponse customerData = shopCustomer.firstWhere(
            (customer) => customer.customerName.trim() == customerNameS.trim(),
        orElse: () => ShopCustomerResponse(id: -1, mobileNumber: 0, customerName: _customerController.text, shopName: selectedShopData!.shopName,gstNumber: ''), // Provide a default instance
      );

      if (customerData.id != -1) { // Check if it’s a valid customer
        customerId = customerData.id;
        customerNumber = customerData.mobileNumber;
      } else {
        customerId = 0;
        if(_customerMobileNumberController.text.isNotEmpty){
          customerNumber = int.parse(_customerMobileNumberController.text);
        }
      }
    }
    String tableNo ='';
    String chairNo ='';
    String hairStylist ='';
    String supplier ='';
    if(selectedShopData!.shopType == 'Hotel'){
      tableNo = _tableOrChairController.text;
      supplier = _supplierOrHairStylistController.text;
    }else if(selectedShopData!.shopType == 'Saloon'){
      chairNo = _tableOrChairController.text;
      hairStylist = _supplierOrHairStylistController.text;
    }

    String orderId ='';
    if(selectedShopOrder != null){
      orderId = selectedShopOrder!.orderNumber;
    }else{
      orderId ='';
    }

    shopSalesDetailsRequest = ShopSalesDetailsRequest(
      0,
      selectedShopData!.shopName,
      _paymentTypeController.text,
      billedProducts,
      totalPriceS,
      totalTaxS,
      netTotalS,
      discount,
      grandTotal,
      _datePickerController.text,
      _mealTimeController.text,
      customerNameS,
      customerNumber, // Ensure this is an int
      customerId,tableNo,chairNo,hairStylist,supplier,orderId

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
    if(selectedShopData!=null){
      taxItems = selectedShopData!.listOwnerTaxResponse;
    }
    if (selectedShopData!.includedTax) {
      totalTaxRate = taxItems.fold(0, (total, tax) => total + tax.taxPercentage);
      taxAmount = _cardTotalPrice * totalTaxRate / (100 + totalTaxRate);
    }
    final String item = _productController.text.trim().split(' ').skip(1).join(' ');; // Trim whitespace
    final int quantity = int.tryParse(_qtyController.text) ?? 0;
    final double price = double.tryParse(selectedProductData.price.toString()) ?? 0.0;
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
    final newProduct = ShopBillProducts(item, productData.unit.toString(), price, quantity, totalPrice,'');
    bool productExists = billedProducts.any((product) => product.item == newProduct.item);
    if (!productExists) {
      setState(() {
        billedProducts.add(newProduct);
        _recalculateGrandTotal();
      });
    } else {
      LoginService.showBlurredSnackBar(context, 'This product is already added!' , type: SnackBarType.error);
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
    // double netAmount = _cardTotalTax + _cardTotalPrice;
    // grandTotal = netAmount;
    // setState(() {
    //   _grandTotalController.text = grandTotal.toStringAsFixed(2);
    // });
    // if (grandTotal < 0) {
    //   grandTotal = 0;
    // }
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
                    _handleShopSelection,false,
                    true, true,true
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
                    if (selectedShopData?.shopType == 'Hotel')
                      Expanded(
                        child: CustomSearchField.buildSearchField(
                            _mealTimeController,
                            'Meal Time',
                            Icons.category,
                            _mealTime,
                                (String value) {},false,
                            true,
                            true,
                            false
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomSearchField.buildSearchField(
                    _orderNoController,
                    'Order Number',
                    Icons.person,
                    _OrderNo,
                    _handleOrderNoSelection,false,
                    false, true ,true
                ),
                if (selectedShopData?.shopType == 'Hotel' || selectedShopData?.shopType == 'Saloon') ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CustomSearchField.buildSearchField(
                          _tableOrChairController,
                          selectedShopData?.shopType == 'Hotel' ? 'Table No' : 'Chair No',
                          selectedShopData?.shopType == 'Hotel' ? Icons.table_restaurant : Icons.chair,
                          _chairNo,
                              (String value) {},
                          false,
                          false,
                          true,
                          true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomSearchField.buildSearchField(
                          _supplierOrHairStylistController,
                          selectedShopData?.shopType == 'Hotel' ? 'Supplier' : 'Hair Stylist',
                          selectedShopData?.shopType == 'Hotel' ? Icons.supervised_user_circle : Icons.supervised_user_circle,
                          _supplierName,
                              (String value) {},
                          false,
                          false,
                          true,
                          true,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                CustomSearchField.buildSearchField(
                    _customerController,
                    'Customer Name',
                    Icons.person,
                    _shopCustomer,
                    _handleCustomerNameSelection,false,
                    false, true ,true
                ),
                const SizedBox(height: 10),
                CustomSearchField.buildSearchField(
                    _customerMobileNumberController,
                    'Customer Mobile Number',
                    Icons.phone_android,
                    _shopCustomerNumber,
                    _handleCustomerNumberSelection,false,
                    false, true ,true
                ),
                const SizedBox(height: 10),
                CustomSearchField.buildSearchField(
                    _productController,
                    'Product',
                    Icons.fastfood,
                    _productItems,
                    _handleProductSelection,false,
                    true, false ,true
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
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton.icon(
                        icon: const Icon(Icons.print, color: Colors.indigo),
                        label: const Text('Last Bill', style: TextStyle(color: Colors.black)),
                        onPressed: () {
                          getLastBillNo().then((_) {
                            _downloadBill(context, lastBillResponse!.shopName,
                                lastBillResponse!.billNumber);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    lastBillResponse?.status == 'Active'?
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.redAccent.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Last Bill', style: TextStyle(color: Colors.black)),
                        onPressed: () {
                          getLastBillNo().then((_) {
                            getDeleteRemarks().then((_){
                              showDeleteBillDialog(context, lastBillResponse!.billNumber, deleteRemarks);
                            });
                          });
                        },
                      ),
                    ): Container(),SizedBox(width: 10,),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _billProduct();
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
                        Expanded(child: Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Text('S.No', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        )),
                        Expanded(child: Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: Text('Products', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        )),
                        Expanded(child: Padding(
                          padding: EdgeInsets.only(left: 30),
                          child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        )),
                        Expanded(child: Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        )),
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

    if (selectedShopData!.taxEnable && selectedShopData!.includedTax ) ...[
    ...taxItems.map((tax) =>
    _buildRow(
    '${tax.taxType} (${tax.taxPercentage})', '',
    '₹',
    (tax.taxPercentage * _cardTotalPrice / (100 + totalTaxRate)).toStringAsFixed(2))),
      _buildRow('Total Tax', '', '₹', (_cardTotalPrice * totalTaxRate / (100 + totalTaxRate)).toStringAsFixed(2))
    ],
                          if(selectedShopData!.taxEnable && !selectedShopData!.includedTax) ...[
                            ...taxItems.map((tax) =>
                                _buildRow(
                                    '${tax.taxType} (${tax.taxPercentage})', '',
                                    '₹',
                                    (tax.taxPercentage * _cardTotalPrice / 100)
                                        .toString())),
                            _buildRow('Total Tax', '', '₹', (_cardTotalTax).toStringAsFixed(2)),
                            _buildDivider(),
                          ],
                          _buildRow('Total Price', '', '₹', _cardTotalPrice.toStringAsFixed(2)),
                          if (selectedShopData!.taxEnable && selectedShopData!.includedTax ) ...[
                          _buildRow('Net Amount', '', '₹',_netTotalAmtOutTax.toStringAsFixed(2)),
                          ],
                          if(selectedShopData!.taxEnable && !selectedShopData!.includedTax) ...[
                            _buildRow('Net Amount', '', '₹', _netTotalAmtInTax.toStringAsFixed(2)),
                            ],
                          _buildDivider(),
                          _buildTextField(_discountController, 'Discount', TextInputType.number),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end, // Align all children to the end
                            children: [
                              Expanded(
                                flex: 5,
                                child: Text(
                                  'Grand Total: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  ' ₹',
                                  style: TextStyle(color: Colors.green),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  textAlign: TextAlign.start,
                                  style: TextStyle(color: Colors.green),
                                  controller: _grandTotalController,
                                  readOnly: true,
                                  onChanged: (_) => _recalculateGrandTotal(),
                                  decoration: InputDecoration(
                                    border: InputBorder.none, // Optional: style the TextField as needed
                                  ),
                                ),
                              ),
                            ],
                          ),

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
                         _clear();
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


  Widget _buildTextField(TextEditingController controller, String labelText, TextInputType keyboardType) {
    final borderRadius = BorderRadius.circular(20);
    return Align(
      alignment: Alignment.centerRight, // Align to the right
      child: Container(
        width: MediaQuery.of(context).size.width * 0.3, // Half of the screen width
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
                borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
                borderRadius: borderRadius,
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
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
          child:CustomSearchField.buildSearchField(_paymentTypeController, 'Select', Icons.money_outlined, _paymentType, (String value) {},false,true, true,false),
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

  Future<void> showDeleteBillDialog(BuildContext context, String billNo, List<String> deleteRemarks) async {
    String? selectedRemark; // To hold the selected remark

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Bill( $billNo )',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
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
                  validator: (value) => value == null ? 'Please select a remark' : null,
                ),
              ),

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
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
              onPressed: () {
                if (selectedRemark != null) {
                  deleteLastBill(context, selectedRemark!, lastBillResponse!.id); // Pass selected remark
                } else {
                  // Show a snackbar or alert if no remark is selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a remark before deleting')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }



}
