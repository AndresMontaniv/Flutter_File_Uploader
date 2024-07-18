import 'dart:io';
import 'dart:typed_data';
import 'package:cloudstorage/data/data.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../service_locator.dart';
import '../presentation.dart';

class FilePreviewScreen extends StatefulWidget {
  static const name = 'file_preview';

  final String fileId;
  final String filename;
  final String? fileUrl;

  const FilePreviewScreen({
    super.key,
    required this.fileId,
    required this.filename,
    this.fileUrl,
  });

  @override
  State<FilePreviewScreen> createState() => _FilePreviewScreenState();
}

class _FilePreviewScreenState extends State<FilePreviewScreen> {
  Future<String> createFileFromBytes(String filename, Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$filename');
    await tempFile.writeAsBytes(bytes);
    return tempFile.path;
  }

  @override
  void initState() {
    super.initState();
    context.read<FileBloc>().add(DownloadFile(widget.fileId));
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = sl.get<AppConfig>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview - ${widget.filename}'),
        leading: CloseButton(
          onPressed: () {
            // if (!context.mounted) return;
            context.read<FileBloc>().add(FetchFiles());
            context.pop();
          },
        ),
      ),
      body: BlocBuilder<FileBloc, FileState>(
        builder: (context, state) {
          if (state is FileLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          } else if (state is FileBytesLoaded) {
            return _buildBody(state.fileBytes, appConfig.baseUrl);
          } else if (state is FileError) {
            return _buildErrorView(context);
          } else {
            return const Center(child: Text('No data yet'));
          }
        },
      ),
    );
  }

  Widget _buildBody(Uint8List filebytes, String baseUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 10,
      ),
      child: Center(
        child: Column(
          children: [
            Expanded(child: _buildPreview(filebytes)),
            if (!kIsWeb)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: () async {
                    final tempFilePath = await createFileFromBytes(widget.filename, filebytes);
                    OpenFilex.open(tempFilePath);
                  },
                  child: const Text('Open with External app'),
                ),
              ),
            if (widget.fileUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: () async {
                    final Uri url = Uri.parse('$baseUrl/${widget.fileUrl!}');
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  child: const Text('Open in Browser'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext ctx) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning,
            color: Colors.yellow,
            size: 100,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 20),
            child: Text(
              'Something went wrong when loading the file',
              style: Theme.of(ctx).textTheme.headlineSmall,
            ),
          ),
          ElevatedButton(
            onPressed: () => ctx.read<FileBloc>().add(DownloadFile(widget.fileId)),
            child: const Text('Reload File'),
          )
        ],
      ),
    );
  }

  Widget _buildPreview(Uint8List filebytes) {
    final fileExtension = widget.filename.split('.').last.toLowerCase();
    switch (fileExtension) {
      case 'pdf':
        return _buildPdfPreview(filebytes);
      case 'jpg':
      case 'jpeg':
      case 'png':
        return _buildImagePreview(filebytes);
      default:
        return _buildUnsupportedFile();
    }
  }

  Widget _buildPdfPreview(Uint8List filebytes) {
    try {
      return PdfView(
        controller: PdfController(
          document: PdfDocument.openData(filebytes),
        ),
      );
    } catch (e) {
      return Center(child: Text('Error loading PDF: $e'));
    }
  }

  Widget _buildImagePreview(Uint8List filebytes) {
    try {
      return Image.memory(filebytes);
    } catch (e) {
      return Center(child: Text('Error loading image: $e'));
    }
  }

  Widget _buildUnsupportedFile() {
    return const Center(child: Text('File type not supported'));
  }
}
