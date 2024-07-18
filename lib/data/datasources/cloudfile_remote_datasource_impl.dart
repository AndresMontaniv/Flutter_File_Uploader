import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import '../../data/data.dart';
import '../../domain/domain.dart';

class CloudFileRemoteDataSourceImpl implements CloudFileDataSource {
  final http.Client client;
  final String baseUrl;

  CloudFileRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<List<CloudFile>> getFiles() async {
    final response = await client.get(Uri.parse('$baseUrl/files'));
    if (response.statusCode == 200) {
      final filesJson = json.decode(response.body) as List;
      return filesJson.map((item) => CloudFileRemoteResp.fromMap(item).toCloudFileEntity()).toList();
    } else {
      throw Exception('Failed to load files');
    }
  }

  @override
  Future<Uint8List> getFile(String id) async {
    final response = await client.get(Uri.parse('$baseUrl/files/$id'));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load file');
    }
  }

  @override
  Future<bool> deleteFile(String id) async {
    try {
      final response = await client.delete(Uri.parse('$baseUrl/files/$id'));

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to upload file');
    }
  }

  @override
  Future<bool> uploadFile(File file) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/files'));

      request.files.add(await http.MultipartFile.fromPath(
        'fileName',
        file.path,
        filename: file.path.split('/').last,
      ));

      final response = await request.send();

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to upload file');
    }
  }
}
