import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';
import '../../core/repositories/repositories.dart';
import '../../core/models/models.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  final List<Map<String, dynamic>> _uploads = [];
  bool _isUploading = false;

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _uploads.add({
          'name': picked.name,
          'path': picked.path,
          'size': picked.length,
          'type': 'image',
        });
      });
    }
  }

  Future<void> _uploadFile(Map<String, dynamic> file) async {
    setState(() => _isUploading = true);
    try {
      final storageService = context.read<StorageService>();
      final fileObj = File(file['path']);
      final url = await storageService.uploadFile('documents', file['name'], fileObj);
      if (url != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yükləndi: ${file['name']}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yükləmə xətası: $e')),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fayl Yükləmə'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file_rounded),
            onPressed: _pickFile,
            tooltip: 'Fayl seç',
          ),
        ],
      ),
      body: _uploads.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_rounded, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    'Fayl yüklə',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  Text(
                    'Tibbi sənədlər, şəkillər və s. yükləyin',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              itemCount: _uploads.length,
              itemBuilder: (context, index) {
                final file = _uploads[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacing2),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(Icons.insert_drive_file_rounded, color: theme.colorScheme.primary),
                    ),
                    title: Text(file['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${(file['size'] / 1024).toStringAsFixed(1)} KB'),
                    trailing: IconButton(
                      icon: const Icon(Icons.upload_rounded, color: AppTheme.primary),
                      onPressed: _isUploading ? null : () => _uploadFile(file),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
