import '../domain.dart';

class DeleteFile {
  final CloudFileRepository repository;

  DeleteFile(this.repository);

  Future<bool> call(String id) {
    return repository.deleteFile(id);
  }
}
