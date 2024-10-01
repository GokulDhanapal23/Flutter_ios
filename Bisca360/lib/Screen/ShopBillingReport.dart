import 'dart:convert';
import 'dart:io';

import 'package:bisca360/Service/FileService.dart';
import 'package:bisca360/Service/LoginService.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pinput/pinput.dart';
import 'package:searchfield/searchfield.dart';

import '../ApiService/Apis.dart';
import '../Response/ShopCustomerResponse.dart';
import '../Response/ShopResponse.dart';
import '../Widget/CustomSearchfieldWidget.dart';
import '../Widget/TextDatewidget.dart';

class ShopBillingReport extends StatefulWidget {
  const ShopBillingReport({super.key});

  @override
  State<ShopBillingReport> createState() => _ShopBillingReportState();
}

class _ShopBillingReportState extends State<ShopBillingReport> {

  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  late TextEditingController _fromDatePickerController = TextEditingController();
  late TextEditingController _toDatePickerController = TextEditingController();
  final TextEditingController _reportTypeController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool? _selectedBooleanValue;
  int? _selectedValue;

  late List<Shopresponse> shopResponses = [];
  late List<ShopCustomerResponse> shopCustomer = [];
  late List<String> reportType = ['Summarized Report','Detailed Report','Invoice'];
  late List<String> month = ['ALL','January','February','March','April','May','June','July','August','September','October','November','December'];
  late List<String> year = ['2024','2023','2022'];

  List<SearchFieldListItem<String>> get _shopItems {
    return shopResponses.map((shop) => SearchFieldListItem<String>(shop.shopName)).toList();
  }


  List<SearchFieldListItem<String>> get _shopCustomer {
    return shopCustomer.map((shop) => SearchFieldListItem<String>(shop.customerName)).toList();
  }
  List<SearchFieldListItem<String>> get _reportType {
    return reportType.map((report) => SearchFieldListItem<String>(report)).toList();
  }
  List<SearchFieldListItem<String>> get _month {
    return month.map((month) => SearchFieldListItem<String>(month)).toList();
  }
  List<SearchFieldListItem<String>> get _year {
    return year.map((year) => SearchFieldListItem<String>(year)).toList();
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

  late final Shopresponse selectedShopData;
  void _handleShopSelection(String selectedShop) {
    getShopCustomer(selectedShop);
    selectedShopData = shopResponses.firstWhere(
            (shop) => shop.shopName == selectedShop
    );
  }
  late final ShopCustomerResponse selectedCustomerData;
  void _handleCustomerSelection(String selectedCustomer) {
    selectedCustomerData = shopCustomer.firstWhere(
            (customer) => customer.customerName == selectedCustomer
    );
  }
  void _clear(){
    _shopNameController.clear();
    _customerController.clear();
    _reportTypeController.clear();
    _fromDatePickerController.clear();
    _monthController.clear();
    _yearController.clear();
    _toDatePickerController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _selectedValue=1;
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
      LoginService.showBlurredSnackBarFile(context, 'File Downloaded Successfully ', filePath, type: SnackBarType.success);
      print('File Service : pdf download Success $filePath');
    } catch(e){
      print('File Service : Error on pdf download failed $e');
    }
  }

  Future<void> downloadExcel(BuildContext context, final url, String fileName) async{
    try{
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
    final filePath = '$_downloadPath/$fileName.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    LoginService.showBlurredSnackBarFile(context, 'File Downloaded Successfully ', filePath, type: SnackBarType.success);
    print('File Service : Excel download Success $filePath');
  } catch(e){
  print('File Service : Error on Excel download failed $e');
  }
  }
  void _downloadReport(){
    String fromDate;
    String toDate;
    String month;
    String year;
    int customerId;
    String shopName;
    String type;
    if(_selectedValue==1){
      fromDate = _fromDatePickerController.text;
      toDate = _toDatePickerController.text;
      month = '';
      year = '';
    }else if(_selectedValue==2){
      fromDate = '';
      toDate = '';
      month = _monthController.text;
      year = _yearController.text;
    }else{
      fromDate = '';
      toDate = '';
      month = '';
      year = _yearController.text;
    }
    shopName = selectedShopData.shopName;
    customerId = selectedCustomerData.id;
    final encodedFromDate = Uri.encodeComponent(fromDate);
    final encodedToDate = Uri.encodeComponent(toDate);
    final encodedMonth = Uri.encodeComponent(month);
    final encodedYear = Uri.encodeComponent(year);
    final encodedShopName = Uri.encodeComponent(shopName);
    if(_reportTypeController.text=='Invoice'){
      final url = Uri.parse('${Apis.shopInvoicePdf}?fromDate=$encodedFromDate&toDate=$encodedToDate&month=$encodedMonth&year=$encodedYear&customerId=$customerId&shopName=$encodedShopName');
      String frtTwoLet = shopName.substring(0,3);
      String fileName = '$frtTwoLet-${DateTime.now()}';
      downloadPdf(context,url,fileName);
    } else if(_reportTypeController.text=='Summarized Report'){
      String type = 'Summary';
      final encodedType = Uri.encodeComponent(type);
      final url = Uri.parse('${Apis.shopSummary}type=$encodedType?fromDate=$encodedFromDate&toDate=$encodedToDate&month=$encodedMonth&year=$encodedYear&customerId=$customerId&shopName=$encodedShopName');
      String frtTwoLet = shopName.substring(0,3);
      String fileName = '$frtTwoLet-summary-${DateTime.now()}';
      downloadExcel(context, url, fileName);
    }else if(_reportTypeController.text=='Detailed Report'){
      String type = 'Detail';
      final encodedType = Uri.encodeComponent(type);
      final url = Uri.parse('${Apis.shopSummary}type=$encodedType?fromDate=$encodedFromDate&toDate=$encodedToDate&month=$encodedMonth&year=$encodedYear&customerId=$customerId&shopName=$encodedShopName');
      String frtTwoLet = shopName.substring(0,3);
      String fileName = '$frtTwoLet-detailed-${DateTime.now()}';
      downloadExcel(context, url, fileName);
    }

  }

  @override
  void initState() {
    super.initState();
    _toDatePickerController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _selectedValue = 1;
    getAllShops().then((_) {
      // Ensure this runs after the shops have been fetched
      if (shopResponses.isNotEmpty) {
        _shopNameController.text = shopResponses.first.shopName;
        getShopCustomer(_shopNameController.text); // Fetch products after setting the shop name
      }
    });
  }

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
        title: const Text('Billing Report', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child : Form(
          key:  _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSearchField.buildSearchField(_shopNameController, 'Shop Name', Icons.shop, _shopItems, _handleShopSelection,true, true),

            const SizedBox(height: 10),
            CustomSearchField.buildSearchField(_customerController, 'Customer', Icons.person, _shopCustomer, _handleCustomerSelection,false, true),
            const SizedBox(height: 10),
            CustomSearchField.buildSearchField(_reportTypeController, 'Report Type', Icons.note_alt, _reportType, (String value) {},true, true),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Radio<int>(
                        value: 1, // Unique value for this option
                        groupValue: _selectedValue,
                        onChanged: (int? value) {
                          setState(() {
                            _selectedValue = value;
                            _yearController.clear();
                            _monthController.clear();
                          });
                        },
                      ),
                      const Expanded(
                        child: Text('Range'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Radio<int>(
                        value: 2, // Unique value for this option
                        groupValue: _selectedValue,
                        onChanged: (int? value) {
                          setState(() {
                            _selectedValue = value;
                            _fromDatePickerController.clear();
                            _toDatePickerController.clear();
                          });
                        },
                      ),
                      const Expanded(
                        child: Text('Month'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Radio<int>(
                        value: 3, // Unique value for this option
                        groupValue: _selectedValue,
                        onChanged: (int? value) {
                          setState(() {
                            _selectedValue = value;
                            _fromDatePickerController.clear();
                            _toDatePickerController.clear();
                            _monthController.clear();
                          });
                        },
                      ),
                      const Expanded(
                        child: Text('Year'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Visibility(
              visible: _selectedValue == 1,
              child: Row(
                children: [
                  Expanded(
                    child: TextFieldDateWidget(
                      _fromDatePickerController,
                      "From Date",
                      const Icon(Icons.date_range, color: Colors.green),
                      TextInputAction.next,
                      TextInputType.text,
                      "PAST",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFieldDateWidget(
                      _toDatePickerController,
                      "To Date",
                      const Icon(Icons.date_range, color: Colors.green),
                      TextInputAction.next,
                      TextInputType.text,
                      "PAST",
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: _selectedValue == 2,
              child: Row(
                children: [
                  Expanded(
                    child: CustomSearchField.buildSearchField(_monthController, 'Month', Icons.calendar_today, _month, (String value) {},false, false),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomSearchField.buildSearchField(_yearController, 'Year', Icons.calendar_today, _year, (String value) {},false, false),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: _selectedValue == 3,
              child: Row(
                children: [
                  Expanded(
                    child: CustomSearchField.buildSearchField(_yearController, 'Year', Icons.calendar_today, _year, (String value) {},false, false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      _clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('      Clear     ', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: (){
                      if (_formKey.currentState!.validate()) {
                        _downloadReport();
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
                    child: const Text('Download', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      ),
    );
  }
}


