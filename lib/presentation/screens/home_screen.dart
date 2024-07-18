import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../presentation.dart';
import '../../domain/domain.dart';

class HomeScreen extends StatelessWidget {
  static const name = 'home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Manager'),
      ),
      body: BlocBuilder<FileBloc, FileState>(
        builder: (context, state) {
          if (state is FileLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          } else if (state is FileLoaded) {
            return _buildFileList(context, state.files);
          } else if (state is FileError) {
            return _buildTryAgainWidget(
              context,
              icondata: Icons.error,
              msg: state.message,
            );
          } else if (state is FileDeleteSuccess) {
            return _buildFileDeletedStatusWidget(context, true);
          } else if (state is FileDeleteFailed) {
            return _buildFileDeletedStatusWidget(context, false);
          } else if (state is FileUploadSuccess) {
            return _buildFileUploadedStatusWidget(context, true);
          } else if (state is FileUploadFailed) {
            return _buildFileUploadedStatusWidget(context, false);
          } else {
            return _buildTryAgainWidget(
              context,
              icondata: Icons.storage,
              msg: 'No files were found',
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _selectFile(context),
        label: const Text(
          'Upload File',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        icon: const Icon(Icons.upload),
      ),
    );
  }

  Widget _buildFileUploadedStatusWidget(BuildContext ctx, bool wasSuccessful) {
    final color = wasSuccessful ? Colors.green : Colors.red;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            wasSuccessful ? Icons.upload_file_outlined : Icons.file_upload_off,
            color: color,
            size: 50,
          ),
          const SizedBox(height: 10),
          Text(
            wasSuccessful ? 'Your file was successfully uploaded! 🤓' : 'We were unable to upload your file. 🙁',
            textAlign: TextAlign.center,
            style: Theme.of(ctx).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(color),
              foregroundColor: const WidgetStatePropertyAll(Colors.white),
            ),
            onPressed: () => ctx.read<FileBloc>().add(FetchFiles()),
            child: Text(wasSuccessful ? 'Continue' : 'Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildFileDeletedStatusWidget(BuildContext ctx, bool wasSuccessful) {
    final color = wasSuccessful ? Colors.green : Colors.red;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            wasSuccessful ? Icons.check_box : Icons.sms_failed,
            color: color,
            size: 50,
          ),
          const SizedBox(height: 10),
          Text(
            wasSuccessful ? 'Your file was successfully deleted! 🤓' : 'We were unable to delete your file. 🙁',
            textAlign: TextAlign.center,
            style: Theme.of(ctx).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(color),
              foregroundColor: const WidgetStatePropertyAll(Colors.white),
            ),
            onPressed: () => ctx.read<FileBloc>().add(FetchFiles()),
            child: Text(wasSuccessful ? 'Continue' : 'Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildTryAgainWidget(BuildContext ctx, {required IconData icondata, String? msg}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icondata,
            color: Colors.grey,
            size: 100,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 20),
            child: Text(
              msg ?? 'Something went wrong!',
              style: Theme.of(ctx).textTheme.headlineSmall,
            ),
          ),
          ElevatedButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.deepOrange),
              foregroundColor: WidgetStatePropertyAll(Colors.white),
            ),
            onPressed: () => ctx.read<FileBloc>().add(FetchFiles()),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList(BuildContext context, List<CloudFile> files) {
    Icon leadingIcon = const Icon(FontAwesomeIcons.file);
    return files.isEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'You have no files',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 20),
                Text(
                  'Feel free to upload files whenever you are ready.\nThe upload button is at the bottom right corner.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.deepOrange),
                    foregroundColor: WidgetStatePropertyAll(Colors.white),
                  ),
                  onPressed: () => context.read<FileBloc>().add(FetchFiles()),
                  child: const Text('Fetch files again'),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: () async {
              context.read<FileBloc>().add(FetchFiles());
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  final fileExtension = file.filename.contains('.') ? file.filename.split('.').last : null;
                  switch (fileExtension) {
                    case 'pdf':
                      leadingIcon = const Icon(
                        FontAwesomeIcons.filePdf,
                        color: Colors.redAccent,
                      );
                      break;
                    case 'docx':
                      leadingIcon = const Icon(
                        FontAwesomeIcons.fileWord,
                        color: Colors.blue,
                      );
                      break;
                    case 'xlsx':
                    case 'xlsm':
                    case 'xlsb':
                      leadingIcon = const Icon(
                        FontAwesomeIcons.fileExcel,
                        color: Colors.green,
                      );
                      break;
                    case 'csv':
                      leadingIcon = const Icon(
                        FontAwesomeIcons.fileCsv,
                        color: Colors.green,
                      );
                      break;
                    case 'mp4':
                      leadingIcon = const Icon(
                        FontAwesomeIcons.fileVideo,
                        color: Colors.purple,
                      );
                      break;
                    case 'mp3':
                      leadingIcon = const Icon(
                        FontAwesomeIcons.fileAudio,
                        color: Colors.orange,
                      );
                      break;
                    case 'png':
                    case 'jpeg':
                    case 'jpg':
                      leadingIcon = const Icon(
                        FontAwesomeIcons.fileImage,
                        color: Colors.blueGrey,
                      );
                      break;
                  }
                  return ListTile(
                    title: Text(
                      file.filename,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Uploaded 3 hours ago',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                    leading: leadingIcon,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye),
                          onPressed: () {
                            context.goNamed(
                              FilePreviewScreen.name,
                              pathParameters: {'id': file.id},
                              queryParameters: {
                                'filename': file.filename,
                                'fileurl': file.fileUrl,
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => context.read<FileBloc>().add(RemoveFile(file.id)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
  }

  void _selectFile(BuildContext context) async {
    File? fileToUpload;

    try {
      if (kIsWeb) {
        throw UnimplementedError();
      } else {
        // Mobile/desktop-specific file picker
        FilePickerResult? result = await FilePicker.platform.pickFiles();

        if (result != null) {
          final file = result.files.first;

          if (file.path != null) {
            fileToUpload = File(file.path!);
          }
        }
      }

      if (fileToUpload != null && context.mounted) {
        context.read<FileBloc>().add(AddFile(fileToUpload));
        return;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error uploading file')),
    );
  }
}
