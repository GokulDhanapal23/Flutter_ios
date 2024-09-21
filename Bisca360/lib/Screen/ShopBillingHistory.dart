import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:searchfield/searchfield.dart';

import '../ApiService/Apis.dart';
import '../Response/BiilingResponse.dart';
import '../Response/ShopResponse.dart';
import '../Widget/CustomSearchfieldWidget.dart';
import '../Widget/TextDatewidget.dart';
import 'ShopBillingReport.dart';

class ShopBillingHistory extends StatefulWidget {
  const ShopBillingHistory({super.key});

  @override
  State<ShopBillingHistory> createState() => _ShopBillingHistoryState();
}

class _ShopBillingHistoryState extends State<ShopBillingHistory> {

  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopReController = TextEditingController();
  final TextEditingController _fromDatePickerController = TextEditingController();
  final TextEditingController _toDatePickerController = TextEditingController();
  final TextEditingController _datePickerController = TextEditingController();

  late List<Shopresponse> shopResponses = [];
  BillingResponse? billingResponse;


  List<SearchFieldListItem<String>> get _shopItems {
    return shopResponses.map((shop) => SearchFieldListItem<String>(shop.shopName)).toList();
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

  Future<void> getAllBillByDate(String date, String shopName) async {
    try {
      final encodedShopName = Uri.encodeComponent(shopName);
      final encodedDate = Uri.encodeComponent(date);

      final url = Uri.parse('${Apis.getAllBillByDate}?shopName=$encodedShopName&date=$encodedDate');
      final response = await Apis.getClient().get(url, headers: Apis.getHeaders());
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          billingResponse = BillingResponse.fromJson(data);
        });
      } else {
        print('Failed to load Bills');
      }
    } catch (e) {
      print('Error fetching Bills: $e');
    }
  }
  void _handleShopSelection(String selectedShop) {
    billingResponse=null;
    getAllBillByDate(_datePickerController.text.toString(), selectedShop);
  }
  @override
  void initState() {
    getAllShops();
    _datePickerController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
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
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        // actions: [
        //   IconButton(onPressed: () {
        //     openAppSettings();
        //     // const ShopBillingReport();
        //     // dialogPopup();
        //   }, icon: const Icon(Icons.download_for_offline_rounded), color: Colors.white),
        // ],
        title: const Text('Billing History', style: TextStyle(color: Colors.white)),
      ),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
      child:  Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              child: CustomSearchField.buildSearchField(_shopNameController, 'Shop Name', Icons.shop, _shopItems, _handleShopSelection,true),
            ),
          ],
        ),
              const SizedBox(height: 5),
              Expanded(
                child: billingResponse == null
                    ? const Center(child: Text('No Bills'))
                    : ListView.builder(
                  itemCount: billingResponse!.listShopSalesDetailsResponse.length,
                  itemBuilder: (context, index) {
                    final bill = billingResponse!.listShopSalesDetailsResponse[index];
                    return Card(
                      color: Colors.white,
                      shadowColor: Colors.green,
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(5),
                        title: Row(
                          children: [
                            Expanded(child: Text(
                              '${index + 1}. Bill No: ${bill.billNumber}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),),
                            Text(
                              'Date: ${bill.dateAndTime}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                        Expanded(child: Text('Payment Type: ${bill.paymentType}', style: const TextStyle(fontSize: 14))),
                        Text('Net Amount: ${bill.netTotalPrice}', style: const TextStyle(fontSize: 14)),
                              ],
                            ), // Text('Unit: ${bill.unit}', style: const TextStyle(fontSize: 14)),
                            // Text('Quantity: ${bill.quantity}', style: const TextStyle(fontSize: 14)),
                          ],
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
    );
  }


  dialogPopup(){
    showDialog(context: context,
        builder: (context) {
      return  AlertDialog(
        backgroundColor: Colors.grey[200],
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
        scrollable: true,
        title: const Center(child: Text('Report',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green,fontSize: 20),)),
        contentPadding: const EdgeInsets.all(10.0),
        content: Column(
          children: [
            CustomSearchField.buildSearchField(_shopNameController, 'Shop Name', Icons.shop, _shopItems, _handleShopSelection,true),
            const SizedBox(height: 10),
            Row(
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
                const SizedBox(width: 5),
                Expanded(
                  child: TextFieldDateWidget(
                    _toDatePickerController,
                    "To Date",
                    const Icon(Icons.date_range, color: Colors.green),
                    TextInputAction.next,
                    TextInputType.text,
                    "PAST",
                  ),                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
        }
        );
  }
}
