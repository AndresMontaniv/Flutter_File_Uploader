class CloudFile {
  final String id;
  final String filename;
  final DateTime createdAt;
  final String? fileUrl;

  CloudFile({
    required this.id,
    required this.filename,
    required this.createdAt,
    this.fileUrl,
  });
}
