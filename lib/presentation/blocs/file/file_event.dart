part of 'file_bloc.dart';

abstract class FileEvent extends Equatable {
  const FileEvent();

  @override
  List<Object?> get props => [];
}

class FetchFiles extends FileEvent {}

class DownloadFile extends FileEvent {
  final String fileId;

  const DownloadFile(this.fileId);
}

class RemoveFile extends FileEvent {
  final String fileId;

  const RemoveFile(this.fileId);
}

class AddFile extends FileEvent {
  final File file;

  const AddFile(this.file);
}
