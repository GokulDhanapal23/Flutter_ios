import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../ApiService/Apis.dart';

class FileService{

    String? _downloadPath;
    Future<void> downloadPdf(BuildContext context, final url) async {
    try{
      print('URL ; $url');
      final response = await Apis.getClient().get(url, headers: Apis.getHeaders());
        final bytes = response.bodyBytes;
      final Directory? directory = await getExternalStorageDirectory();
      _downloadPath = directory?.path ?? '';
        final filePath = '$_downloadPath/sample.pdf';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF downloaded to $filePath')),
      );
        print('File Service : pdf download Success $filePath');
    } catch(e){
      print('File Service : Error on pdf download failed $e');
    }
  }
}