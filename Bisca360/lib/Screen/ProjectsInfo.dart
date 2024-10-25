import 'package:bisca360/Response/ProjectResponse.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProjectsInfo extends StatefulWidget {
  final ProjectResponse? projectResponse;
  const ProjectsInfo({super.key, required this.projectResponse});

  @override
  State<ProjectsInfo> createState() => _ProjectsInfoState();
}

class _ProjectsInfoState extends State<ProjectsInfo> {

  late bool _paymentView = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(onPressed: () {
          Navigator.of(context).pop();
        }, icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white,)),
        title: const Text('Project Details', style: TextStyle(color: Colors.white),),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.2, // Adjust height as a percentage of screen height
              decoration: BoxDecoration(
                color: Colors.green,
                // gradient: LinearGradient(
                //   colors: [Colors.blue, Colors.green], // Example gradient
                // ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.projectResponse!.siteName}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${widget.projectResponse!.siteArea}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Project Status: ${widget.projectResponse!.siteStatusName}',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            Text(
                              'Contract: ${widget.projectResponse!.contract ? 'Yes' : 'No'}',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Card(
              color: Colors.white,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person_3_outlined, color: Colors.white),
                ),
                title: Text('${widget.projectResponse!.siteOwner}'),
                subtitle: Text('${widget.projectResponse!.ownerMobileNumber}'),
                trailing: IconButton(
                  icon: Icon(Icons.phone),
                  onPressed: () {
                    // Handle call action
                  },
                ),
              ),
            ),
            Card(
              color: Colors.white,
              child: ListTile(
                leading: Icon(Icons.payment, color: Colors.green,),
                title: Text('Project Payments'),
                trailing: _paymentView ? Icon(Icons.arrow_drop_down_sharp,color: Colors.green,) : Icon(Icons.arrow_drop_up_outlined ,color: Colors.green),
                onTap: () {
                  setState(() {
                    if(_paymentView){
                      _paymentView = false;
                    }else{
                      _paymentView = true;
                    }
                  });
                },
              ),
            ),
            if (_paymentView) Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAmountRow(context, "Contract Amount", "${widget.projectResponse!.contractAmount}", 16.0, Colors.green,),
                          Divider(color: Colors.grey[300], thickness: 2),
                          _buildAmountRow(context, "Advance Amount", "${widget.projectResponse!.advanceAmount}", 16.0, Colors.blue,),
                          Divider(color: Colors.grey[300], thickness: 2),
                          _buildAmountRow(context, "Remaining Balance", "${widget.projectResponse!.contractBalance}", 16.0,Colors.blue,),
                          Divider(color: Colors.grey[300], thickness: 2),
                        ],
                      ),
                    _buildExpenseRow(context, "Overall Expenses", "${widget.projectResponse!.siteExpenses}", Colors.redAccent),
                    _buildExpenseRow(context, "Available Balance", "${widget.projectResponse!.availableBalance}", Colors.redAccent),
                    SizedBox(height: 5),
                  ],
                ),
              ),
            ) else Card(),
            Card(
              color: Colors.white,
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ),
                  Divider(color: Colors.white,),
                  Text(
                    '${widget.projectResponse!.description}',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
                )
              ),
            ),
          ],
        ),

      ),
    );
  }
  Widget _buildAmountRow(BuildContext context, String hint, String id, double textSize, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hint,
            style: TextStyle(color: Colors.black45, fontSize: 12),
          ),
          Text(
            '₹ $id', // Replace with actual data
            style: TextStyle(color: textColor, fontSize: textSize),
          ),
        ],
      ),
    );
  }
  Widget _buildExpenseRow(BuildContext context, String hint, String id, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$hint : ',
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
          Text(
            '₹ $id', // Replace with actual data
            style: TextStyle(color: textColor, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
