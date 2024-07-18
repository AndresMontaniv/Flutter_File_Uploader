import 'dart:io';
import 'dart:typed_data';

import '../../domain/domain.dart';

class CloudFileRepositoryImpl implements CloudFileRepository {
  final CloudFileDataSource remoteDataSource;

  CloudFileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CloudFile>> getFiles() => remoteDataSource.getFiles();

  @override
  Future<Uint8List> getFile(String id) => remoteDataSource.getFile(id);

  @override
  Future<bool> deleteFile(String id) => remoteDataSource.deleteFile(id);

  @override
  Future<bool> uploadFile(File file) => remoteDataSource.uploadFile(file);
}
