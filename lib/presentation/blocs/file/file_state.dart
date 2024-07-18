part of 'file_bloc.dart';

abstract class FileState extends Equatable {
  const FileState();

  @override
  List<Object?> get props => [];
}

class FileInitial extends FileState {}

class FileLoading extends FileState {}

class FileLoaded extends FileState {
  final List<CloudFile> files;

  const FileLoaded(this.files);
}

class FileBytesLoaded extends FileState {
  final Uint8List fileBytes;

  const FileBytesLoaded(this.fileBytes);

  @override
  List<Object> get props => [fileBytes];
}

class FileDeleteSuccess extends FileState {}

class FileUploadSuccess extends FileState {}

class FileDeleteFailed extends FileState {}

class FileUploadFailed extends FileState {}

class FileError extends FileState {
  final String message;

  const FileError(this.message);
}
