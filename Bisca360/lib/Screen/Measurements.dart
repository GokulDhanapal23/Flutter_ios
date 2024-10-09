import 'dart:convert';

import 'package:bisca360/Response/Measurementresponse.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ApiService/Apis.dart';

class Measurements extends StatefulWidget {
  const Measurements({super.key});

  @override
  State<Measurements> createState() => _MeasurementsState();
}

class _MeasurementsState extends State<Measurements> {

  late List<MeasurementResponse> measurements;
  late List<MeasurementResponse> shopUnits = [];
  late List<MeasurementResponse> filteredUnits = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  @override
  void initState() {
    measurements = [];
    getAllMeasurements();
    super.initState();
  }

  void _filterShops(String query) {
    final filtered = measurements.where((units) {
      return units.measurementName.toLowerCase().contains(query.toLowerCase()) ||
          units.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      filteredUnits = filtered;
    });
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
      filteredUnits = measurements; // Reset to all shops
    });
  }

  getAllMeasurements() async {
    try {
      final response = await Apis.getClient().get(
        Uri.parse(Apis.getAllMeasurements),
        headers: Apis.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          measurements = data.map((item) => MeasurementResponse.fromJson(item)).toList();
          print('measurements: $measurements.toString');
        });
      } else {
        print('Failed to load measurements');
      }
    } catch (e) {
      print('Error fetching measurements: $e');
    }
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

              :const Text('Measurements', style: TextStyle(color: Colors.white),),
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
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => const AddShop(shopResponse: null),
          //   ),
          // );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: filteredUnits.isEmpty && measurements.isEmpty
          ? const Center(child: Text('No Units', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
          :  Padding(
            padding: const EdgeInsets.all(8.0),
            child: Expanded(
                    child: (measurements.isEmpty)
              ? Center(child: Text('No Units'))
              : ListView.builder(
            itemCount: filteredUnits.isEmpty ? measurements.length : filteredUnits.length,
            itemBuilder: (context, index) {
              final unit = filteredUnits.isEmpty ? measurements[index] : filteredUnits[index];
              bool isActive = unit.active;

              return Card(
                color: Colors.white,
                shadowColor: Colors.green,
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 3),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(5),
                  title: Text(
                    '${index + 1}. Name: ${unit.measurementName}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Description: ${unit.description}', style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  leading: Container(
                    width: 50, // Adjust width as needed
                    height: 50, // Adjust height as needed
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue, // Change to your desired background color
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: const AssetImage('assets/unit_jpeg.jpg'),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.indigoAccent),
                        onPressed: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => AddShopProduct(shopProducts: shopProducts[index]),
                          //   ),
                          // );
                        },
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          activeColor: Colors.indigoAccent,
                          value: isActive,
                          onChanged: (value) {
                            setState(() {
                              unit.active = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
                    ),
                  ),
          )
    );
  }
}
