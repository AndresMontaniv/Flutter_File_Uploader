import '../domain.dart';

class GetFiles {
  final CloudFileRepository repository;

  GetFiles(this.repository);

  Future<List<CloudFile>> call() {
    return repository.getFiles();
  }
}
