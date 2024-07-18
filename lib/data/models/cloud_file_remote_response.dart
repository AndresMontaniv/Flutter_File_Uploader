import 'dart:convert';

import 'package:cloudstorage/domain/entities/cloud_file.dart';

class CloudFileRemoteResp {
  final String fileid;
  final String filename;
  final DateTime createdAt;
  final String? fileUrl;

  CloudFileRemoteResp({
    required this.fileid,
    required this.filename,
    required this.createdAt,
    this.fileUrl,
  });

  factory CloudFileRemoteResp.fromJson(String str) => CloudFileRemoteResp.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CloudFileRemoteResp.fromMap(Map<String, dynamic> json) {
    return CloudFileRemoteResp(
      fileid: json['_id'].toString(),
      filename: json['fileName'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      fileUrl: json['filePath'],
    );
  }

  Map<String, dynamic> toMap() => {
        '_id': fileid,
        'fileName': filename,
      };

  factory CloudFileRemoteResp.fromCloudFileEntity(CloudFile cf) => CloudFileRemoteResp(
        fileid: cf.id,
        filename: cf.filename,
        createdAt: cf.createdAt,
        fileUrl: cf.fileUrl,
      );

  CloudFile toCloudFileEntity() => CloudFile(
        id: fileid,
        filename: filename,
        createdAt: createdAt,
        fileUrl: fileUrl,
      );
}
