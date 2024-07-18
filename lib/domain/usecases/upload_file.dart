import 'dart:io';

import '../domain.dart';

class UploadFile {
  final CloudFileRepository repository;

  UploadFile(this.repository);

  Future<bool> call(File file) {
    return repository.uploadFile(file);
  }
}
