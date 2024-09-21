import 'dart:typed_data';

import 'package:http/http.dart' as http;
import '../ApiService/Apis.dart';

class ImageService{

  static Future<Uint8List?> fetchImage(String uid, String docType) async {
    try {
      final uidData = Uri.encodeComponent(uid);
      final docTypeData = Uri.encodeComponent(docType);
      final url = Uri.parse('${Apis.imageLoad}$docTypeData/$uidData');
      final response = await http.get(url, headers: Apis.getHeaders());

      if (response.statusCode == 200) {
        return response.bodyBytes; // Image data as bytes
      } else {
        print('Failed to load image');
        return null;
      }
    } catch (e) {
      print('Error fetching image: $e');
      return null;
    }
  }
}