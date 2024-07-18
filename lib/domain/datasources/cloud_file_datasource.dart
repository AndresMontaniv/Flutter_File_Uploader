import 'dart:io';
import 'dart:typed_data';

import '../entities/cloud_file.dart';

abstract class CloudFileDataSource {
  Future<List<CloudFile>> getFiles();
  Future<Uint8List> getFile(String id);
  Future<bool> deleteFile(String id);
  Future<bool> uploadFile(File file);
}
