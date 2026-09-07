import 'dart:io';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FileStorageHelper {
  /// Prompts user to choose a save location, checks for existing file confirmation,
  /// and writes the PDF bytes. Returns the saved file path, or null if cancelled.
  static Future<String?> savePdfWithPicker({
    required Uint8List bytes,
    required String suggestedFileName,
    BuildContext? context,
  }) async {
    try {
      const typeGroup = XTypeGroup(
        label: 'PDF Document',
        extensions: <String>['pdf'],
        mimeTypes: <String>['application/pdf'],
      );

      final location = await getSaveLocation(
        suggestedName: suggestedFileName,
        acceptedTypeGroups: [typeGroup],
      );

      if (location == null) {
        // User cancelled picker
        return null;
      }

      String targetPath = location.path;
      if (!targetPath.toLowerCase().endsWith('.pdf')) {
        targetPath = '$targetPath.pdf';
      }

      final targetFile = File(targetPath);
      if (await targetFile.exists() && context != null && context.mounted) {
        final shouldOverwrite = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('File Already Exists'),
            content: Text('The file "${targetFile.uri.pathSegments.last}" already exists. Do you want to overwrite it?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Overwrite'),
              ),
            ],
          ),
        );

        if (shouldOverwrite != true) {
          return null;
        }
      }

      await targetFile.writeAsBytes(bytes, flush: true);
      return targetFile.path;
    } catch (e) {
      // Fallback: save to Downloads / Documents directory
      try {
        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/$suggestedFileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes, flush: true);
        return file.path;
      } catch (fallbackError) {
        throw Exception('Failed to save booking document: $e');
      }
    }
  }

  /// Saves a temporary file suitable for printing/sharing workflows.
  static Future<File> saveTempPdf({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsBytes(bytes, flush: true);
    return tempFile;
  }
}
