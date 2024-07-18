import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/domain.dart';

part 'file_event.dart';
part 'file_state.dart';

class FileBloc extends Bloc<FileEvent, FileState> {
  final GetFiles getFiles;
  final GetFile getFile;
  final DeleteFile deleteFile;
  final UploadFile uploadFile;

  FileBloc({
    required this.getFiles,
    required this.getFile,
    required this.deleteFile,
    required this.uploadFile,
  }) : super(FileInitial()) {
    on<FetchFiles>(_onFetchFiles);
    on<DownloadFile>(_onDownloadFile);
    on<RemoveFile>(_onDeleteFile);
    on<AddFile>(_onUploadFile);
  }

  void _onFetchFiles(FetchFiles event, Emitter<FileState> emit) async {
    emit(FileLoading());
    try {
      final files = await getFiles.call();
      emit(FileLoaded(files));
    } catch (e) {
      emit(const FileError('Error when fetching files from the cloud'));
    }
  }

  void _onDownloadFile(DownloadFile event, Emitter<FileState> emit) async {
    emit(FileLoading());
    try {
      final filebytes = await getFile.call(event.fileId);
      emit(FileBytesLoaded(filebytes));
    } catch (e) {
      emit(const FileError('Error when fetching this file from the cloud'));
    }
  }

  void _onDeleteFile(RemoveFile event, Emitter<FileState> emit) async {
    emit(FileLoading());
    try {
      final wasDeleted = await deleteFile.call(event.fileId);
      if (wasDeleted) {
        emit(FileDeleteSuccess());
        return;
      }
      emit(FileDeleteFailed());
    } catch (e) {
      emit(const FileError('Error when deleting this file from the cloud'));
    }
  }

  void _onUploadFile(AddFile event, Emitter<FileState> emit) async {
    emit(FileLoading());
    try {
      final wasDeleted = await uploadFile.call(event.file);
      if (wasDeleted) {
        emit(FileUploadSuccess());
        return;
      }
      emit(FileUploadFailed());
    } catch (e) {
      emit(const FileError('Error when uploading this file to the cloud'));
    }
  }
}
