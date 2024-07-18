import 'dart:typed_data';

import '../domain.dart';

class GetFile {
  final CloudFileRepository repository;

  GetFile(this.repository);

  Future<Uint8List> call(String id) {
    return repository.getFile(id);
  }
}
