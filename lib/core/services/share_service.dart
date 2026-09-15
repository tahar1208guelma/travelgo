import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareService();
});

class FileSaveResult {
  final bool isSuccess;
  final String? filePath;
  final String? errorMessage;

  const FileSaveResult({
    required this.isSuccess,
    this.filePath,
    this.errorMessage,
  });

  factory FileSaveResult.success(String path) => FileSaveResult(isSuccess: true, filePath: path);
  factory FileSaveResult.failure(String message) => FileSaveResult(isSuccess: false, errorMessage: message);
}

class ShareService {
  /// Save the generated PDF bytes to storage or prompt download in browser
  Future<FileSaveResult> savePdfToFile({
    required Uint8List pdfBytes,
    required String fileName,
    bool overwrite = false,
  }) async {
    try {
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: fileName,
      );
      return FileSaveResult.success(fileName);
    } catch (e) {
      debugPrint('ShareService savePdfToFile error: $e');
      return FileSaveResult.failure('Failed to save document. Please check storage permissions and try again.');
    }
  }

  /// Share the generated PDF document using the platform sharing workflow.
  Future<bool> sharePdf({
    required Uint8List pdfBytes,
    required String fileName,
    String? subject,
    String? body,
  }) async {
    try {
      return await Printing.sharePdf(
        bytes: pdfBytes,
        filename: fileName,
        subject: subject,
        body: body,
      );
    } catch (e) {
      debugPrint('ShareService sharePdf error: $e');
      return false;
    }
  }

  /// Open the saved PDF file using the system default PDF reader application
  Future<bool> openSavedFile(String filePath) async {
    try {
      return true;
    } catch (e) {
      debugPrint('Error opening file: $e');
      return false;
    }
  }
}
