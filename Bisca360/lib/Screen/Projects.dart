import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ApiService/Apis.dart';
import '../Response/ProjectResponse.dart';

class Projects extends StatefulWidget {
  const Projects({super.key});

  @override
  State<Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {

  final TextEditingController _searchController = TextEditingController();

  late List<ProjectResponse> projectResponse = [];
  bool _isSearching = false;
  late List<ProjectResponse> filteredProjects = [];

  Future<void> getProjects( ) async {
    try {
      final url = Uri.parse(Apis.getProject);
      final response = await Apis.getClient().get(url, headers: Apis.getHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          projectResponse = data.map((item) => ProjectResponse.fromJson(item)).toList();
          print('projectResponse: $projectResponse');
        });
      } else {
        print('Failed to load Project Response');
      }
    } catch (e) {
      print('Error fetching Project Response: $e');
    }
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
      filteredProjects = projectResponse; // Reset to all shops
    });
  }
  void _filterProjects(String query) {
    final filtered = projectResponse.where((project) {
      return project.siteName.toLowerCase().contains(query.toLowerCase()) || project.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      filteredProjects = filtered;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getProjects();
    super.initState();
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
            _filterProjects(value);
          },
        )

            :const Text('Project', style: TextStyle(color: Colors.white),),
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
          // Navigator.push(context, MaterialPageRoute(builder: (context)=>AddShopProduct( shopProducts: null,)));
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
              Expanded(
                child: (projectResponse.isEmpty)
                    ? Center(child: Text('No Projects'))
                    : ListView.builder(
                  itemCount: filteredProjects.isEmpty ? projectResponse.length : filteredProjects.length,
                  itemBuilder: (context, index) {
                    final project = filteredProjects.isEmpty ? projectResponse[index] : filteredProjects[index];
                    return Card(
                      color: Colors.white,
                      shadowColor: Colors.green,
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(5),
                        title: Text(
                          '${index + 1}. Project: ${project.siteName}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Project Area: ${project.siteArea}', style: const TextStyle(fontSize: 14)),
                            Text('Status: ${project.siteStatusName}', style: const TextStyle(fontSize: 14)),
                          ],
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
