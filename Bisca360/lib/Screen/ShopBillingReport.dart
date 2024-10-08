import 'dart:convert';
import 'dart:io';

import 'package:bisca360/Request/SearchSalesRequest.dart';
import 'package:bisca360/Response/BiilingResponse.dart';
import 'package:bisca360/Screen/ShopBilling.dart';
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
import '../Response/ShopSalesDetailsResponse.dart';
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
  late TextEditingController _DatePickerController = TextEditingController();
  late TextEditingController _toDatePickerController = TextEditingController();
  final TextEditingController _reportTypeController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool? _selectedBooleanValue;
  int? _selectedValue;

  late List<Shopresponse> shopResponses = [];
  late List<ShopCustomerResponse> shopCustomer = [];
  BillingResponse? billingResponse;
  late List<String> reportType = ['Summarized Report','Detailed Report','Invoice'];
  late List<String> month = ['January','February','March','April','May','June','July','August','September','October','November','December'];
  List<String> year = [];

  void _currentYear() {
    int currentYear = DateTime.now().year;
    for (int i = 0; i < 3; i++) {
      year.add((currentYear - i).toString());
    }
  }

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

  late Shopresponse selectedShopData;
  void _handleShopSelection(String selectedShop) {
    billingResponse == null;
    _customerController.clear();
    getShopCustomer(selectedShop);
    selectedShopData = shopResponses.firstWhere(
            (shop) => shop.shopName == selectedShop
    );
  }
  late  ShopCustomerResponse? selectedCustomerData;
  void _handleCustomerSelection(String selectedCustomer) {
    selectedCustomerData = null;
    billingResponse == null;
    selectedCustomerData = shopCustomer.firstWhere(
            (customer) => customer.customerName == selectedCustomer
    );
  }
  void _clear(){
    _customerController.clear();
    _fromDatePickerController.clear();
    _monthController.clear();
    _yearController.clear();
    _toDatePickerController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _DatePickerController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _selectedValue=4;
    setState(() {
      billingResponse = null;
    });
  }

  Future<void> saveShop(SearchSalesRequest sales, BuildContext context) async {
    try {
      print(jsonEncode(sales.toJson()));
      var res = await Apis.getClient().post(
        Uri.parse(Apis.shopSalesSearch),
        body: jsonEncode(sales.toJson()),
        headers: Apis.getHeaders(),
      );
      // Decode the response body directly here
      final response = jsonDecode(res.body);
      if (response != null) {
        setState(() {
          billingResponse = BillingResponse.fromJson(response);
          print('salesResponse: $billingResponse');
        });
      } else {
        print('Failed to load salesResponse');
      }
    } catch (e) {
      print('Error: $e');
    }
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
  void _downloadExcelReport(){
    var selectedShop=_shopNameController.text;
    selectedShopData = shopResponses.firstWhere(
          (shop) => shop.shopName == selectedShop,
    );
    String fromDate;
    String toDate;
    String month;
    String year;
    int customerId = 0;
    String shopName;
    String type;
    String date;
    if(_selectedValue==1){
      fromDate = _fromDatePickerController.text;
      toDate = _toDatePickerController.text;
      month = '';
      year = '';
      date = '';
    }else if(_selectedValue==2){
      fromDate = '';
      toDate = '';
      month = _monthController.text;
      year = _yearController.text;
      date = '';
    }else if(_selectedValue==3){
      fromDate = '';
      toDate = '';
      month = '';
      year = _yearController.text;
      date = '';
    }else{
      fromDate = '';
      toDate = '';
      month = '';
      year = '';
      date = _DatePickerController.text;
    }
    shopName = selectedShopData.shopName;
    if(_customerController.text.isNotEmpty){
      customerId = selectedCustomerData!.id;
    }
    final encodedFromDate = Uri.encodeComponent(fromDate);
    final encodedToDate = Uri.encodeComponent(toDate);
    final encodedMonth = Uri.encodeComponent(month);
    final encodedYear = Uri.encodeComponent(year);
    final encodedShopName = Uri.encodeComponent(shopName);
    final encodedDate = Uri.encodeComponent(date);
    if(_reportTypeController.text=='Summarized Report'){
      String type = 'Summary';
      final encodedType = Uri.encodeComponent(type);
      final url = Uri.parse('${Apis.shopSummary}type=$encodedType?fromDate=$encodedFromDate&toDate=$encodedToDate&month=$encodedMonth&year=$encodedYear&customerId=$customerId&shopName=$encodedShopName&date=$encodedDate');
      String frtTwoLet = shopName.substring(0,3);
      String fileName = '$frtTwoLet-summary-${DateTime.now()}';
      downloadExcel(context, url, fileName);
    }else{
      String type = 'Detail';
      final encodedType = Uri.encodeComponent(type);
      final url = Uri.parse('${Apis.shopSummary}type=$encodedType?fromDate=$encodedFromDate&toDate=$encodedToDate&month=$encodedMonth&year=$encodedYear&customerId=$customerId&shopName=$encodedShopName&date=$encodedDate');
      String frtTwoLet = shopName.substring(0,3);
      String fileName = '$frtTwoLet-detailed-${DateTime.now()}';
      downloadExcel(context, url, fileName);
    }

  }
  void _downloadPdfReport(){
    var selectedShop=_shopNameController.text;
    selectedShopData = shopResponses.firstWhere(
          (shop) => shop.shopName == selectedShop,
    );
    String fromDate;
    String toDate;
    String month;
    String year;
    int customerId = 0;
    String shopName;
    String type;
    String date;
    if(_selectedValue==1){
      fromDate = _fromDatePickerController.text;
      toDate = _toDatePickerController.text;
      month = '';
      year = '';
      date = '';
    }else if(_selectedValue==2){
      fromDate = '';
      toDate = '';
      month = _monthController.text;
      year = _yearController.text;
      date = '';
    }else if(_selectedValue==3){
      fromDate = '';
      toDate = '';
      month = '';
      year = _yearController.text;
      date = '';
    }else{
      fromDate = '';
      toDate = '';
      month = '';
      year = '';
      date = _DatePickerController.text;
    }
    shopName = selectedShopData.shopName;
    if(_customerController.text.isNotEmpty){
      customerId = selectedCustomerData!.id;
    }
    final encodedFromDate = Uri.encodeComponent(fromDate);
    final encodedToDate = Uri.encodeComponent(toDate);
    final encodedMonth = Uri.encodeComponent(month);
    final encodedYear = Uri.encodeComponent(year);
    final encodedDate = Uri.encodeComponent(date);
    final encodedShopName = Uri.encodeComponent(shopName);
      if(_customerController.text.isEmpty){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill customer correctly')),
        );
        print('Please fill customer correctly');
        return;
      }
      final url = Uri.parse('${Apis.shopInvoicePdf}?fromDate=$encodedFromDate&toDate=$encodedToDate&month=$encodedMonth&year=$encodedYear&customerId=$customerId&shopName=$encodedShopName&date=$encodedDate');
      String frtTwoLet = shopName.substring(0,3);
      String fileName = '$frtTwoLet-${DateTime.now()}';
      downloadPdf(context,url,fileName);
  }
  void _searchSales(){
    var selectedShop=_shopNameController.text;
    selectedShopData = shopResponses.firstWhere(
          (shop) => shop.shopName == selectedShop,
    );
    String fromDate;
    String toDate;
    String month;
    String year;
    String date;
    String ReportFor = '';
    int customerId = 0;
    String shopName;
    String type;
    if(_selectedValue==1){
      fromDate = _fromDatePickerController.text;
      toDate = _toDatePickerController.text;
      month = '';
      year = '';
      date = '';
      ReportFor = 'range';
    }else if(_selectedValue==2){
      fromDate = '';
      toDate = '';
      month = _monthController.text;
      year = _yearController.text;
      date = '';
      ReportFor = 'month';
    }else if(_selectedValue==3){
      fromDate = '';
      toDate = '';
      month = '';
      year = _yearController.text;
      date = '';
      ReportFor = 'year';
    } else {
      fromDate = '';
      toDate = '';
      month = '';
      year = '';
      date = _DatePickerController.text;
      ReportFor = 'byDate';
    }
    shopName = selectedShopData.shopName;
    if(_customerController.text.isNotEmpty){
      customerId = selectedCustomerData!.id;
    }
    SearchSalesRequest searchSalesRequest = new SearchSalesRequest(reportFor: ReportFor, reportType: '', fromDate: fromDate, toDate: toDate, month: month, year: year, customerId: customerId, shopName: shopName, date: date, ownerId: 0);

    saveShop(searchSalesRequest,context);
  }
  void _downloadBill(BuildContext context, String shopName, String billNumber){
    final encodedShopName = Uri.encodeComponent(shopName);
    final encodedBillNumber = Uri.encodeComponent(billNumber);
    final url = Uri.parse('${Apis.shopBillPdf}?shopName=$encodedShopName&billNumber=$encodedBillNumber');
    String fileName = '$billNumber-${DateTime.now()}';
    downloadPdf(context,url,fileName);
  }
  @override
  void initState() {
    super.initState();
    _currentYear();
    _toDatePickerController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _DatePickerController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _selectedValue = 4;
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
        title: const Text('Billing History', style: TextStyle(color: Colors.white)),
      ),
      body: GestureDetector(
    onTap: () {
    FocusScope.of(context).unfocus();
    },child : Padding(
        padding: const EdgeInsets.all(16.0),
        child : Form(
          key:  _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSearchField.buildSearchField(_shopNameController, 'Shop Name', Icons.shop, _shopItems, _handleShopSelection,false,true, true , false),

            const SizedBox(height: 10),
            CustomSearchField.buildSearchField(_customerController, 'Customer', Icons.person, _shopCustomer, _handleCustomerSelection,false,false, true, false),
            const SizedBox(height: 10),
            CustomSearchField.buildSearchField(_reportTypeController, 'Report Type', Icons.note_alt, _reportType, (String value) {},false,true, true, false),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Radio<int>(
                        value: 4, // Unique value for this option
                        groupValue: _selectedValue,
                        onChanged: (int? value) {
                          setState(() {
                            _selectedValue = value;
                            _toDatePickerController.clear();
                            _fromDatePickerController.clear();
                            _yearController.clear();
                            _monthController.clear();
                          });
                        },
                      ),
                      const Expanded(
                        child: Text('Date'),
                      ),
                    ],
                  ),
                ),
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
              visible: _selectedValue == 4,
              child: Row(
                children: [
                  Expanded(
                    child: TextFieldDateWidget(
                      _DatePickerController,
                      "Date",
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
                    child: CustomSearchField.buildSearchField(_monthController, 'Month', Icons.calendar_today, _month, (String value) {},false,false, false, false),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomSearchField.buildSearchField(_yearController, 'Year', Icons.calendar_today, _year, (String value) {},false,false, false, false),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: _selectedValue == 3,
              child: Row(
                children: [
                  Expanded(
                    child: CustomSearchField.buildSearchField(_yearController, 'Year', Icons.calendar_today, _year, (String value) {},false,false, false, false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    iconSize: 30,
                    icon: const Icon(Icons.table_view, color: Colors.green),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _downloadExcelReport();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill in all fields correctly')),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    iconSize: 30,
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _downloadPdfReport();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill in all fields correctly')),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 20),
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
                    child: const Text('    Clear   ', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _searchSales();
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
                    child: const Text('Search', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Expanded(
              child: billingResponse == null
                  ? const Center(child: Text('No Bills'))
                  : _buildBillingReport(),
            ),
          ],
        ),
      ),
      ),
    ),);
  }
  Widget _buildBillingReport() {
    return Column(
      children: [
        SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green, width: 2), // Border color and width
            borderRadius: BorderRadius.circular(10), // Match the Card's rounded corners
          ),
          child: Card(
            color: Colors.white,
            shadowColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between items
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Bill Count   : ',
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          TextSpan(
                            text: '${billingResponse?.billingCount}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Delete Count : ',
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        TextSpan(
                          text: '${billingResponse?.deletedCount}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 0), // Space above subtitle
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSubtitleRow('Total Price   : ', billingResponse?.totalPrice),
                    _buildSubtitleRow('Total Tax      : ', billingResponse?.totalTax),
                    _buildSubtitleRow('Grand Total  : ', billingResponse?.grandTotalPrice),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: billingResponse!.listShopSalesDetailsResponse.length,
            itemBuilder: (context, index) {
              final bill = billingResponse!.listShopSalesDetailsResponse[index];
              return Card(
                color: Colors.white,
                shadowColor: Colors.green,
                elevation: 1,
                child: ListTile(
                 // Increased padding for better spacing
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                          children: [
                            Text(
                              '${index + 1}. Bill No: ${bill.billNumber}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Date: ${bill.dateAndTime}',
                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                            Text(
                              'Payment Type: ${bill.paymentType}',
                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                            Text(
                              'Net Amount: ₹ ${bill.grandTotalPrice}',
                              style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      // Buttons on the right
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _showDetailsDialog(context, bill);
                            },
                            child: const Icon(Icons.remove_red_eye_rounded),
                          ),
                          const SizedBox(height: 5), // Space between buttons
                          ElevatedButton(
                            onPressed: () {
                              _downloadBill(context, selectedShopData.shopName,bill.billNumber);
                            },
                            child: const Icon(Icons.print),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

      ],
    );

  }
  Widget _buildSubtitleRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2), // Space between rows
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(width: 5), // Small gap between label and value
          Text(
            '₹ $value',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
        ],
      ),
    );
  }
  void _showDetailsDialog(BuildContext context, ShopSalesDetailsResponse bill) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bill Details for ${bill.billNumber}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shop Name: ${bill.shopName}'),
                Text('Customer Name: ${bill.customerName}'),
                Text('Date: ${bill.dateAndTime}'),
                Text('Payment Type: ${bill.paymentType}'),
                Text('Total Price: ${bill.totalPrice}'),
                Text('Total Tax: ${bill.totalTax}'),
                Text('Net Total Price: ${bill.netTotalPrice}'),
                Text('Discount Price: ${bill.discountPrice}'),
                Text('Grand Total Price: ${bill.grandTotalPrice}'),
                // const SizedBox(height: 10),
                // Text('Selling Data:', style: TextStyle(fontWeight: FontWeight.bold)),
                // // Display the list of selling data
                // for (var sellingData in bill.listSellingData) // Assuming this is a list
                //   Padding(
                //     padding: const EdgeInsets.symmetric(vertical: 2),
                //     child: Text(
                //       'S.No: 1, Item: ${sellingData.item}, Quantity: ${sellingData.quantity}, Unit: ${sellingData.units}, Price: ${sellingData.price}, Total Price: ${sellingData.totalPriceList}',
                //     ),
                //   ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

}


