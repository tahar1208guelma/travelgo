import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

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
  /// Save the generated PDF bytes to the device's Documents or Downloads directory
  Future<FileSaveResult> savePdfToFile({
    required Uint8List pdfBytes,
    required String fileName,
    bool overwrite = false,
  }) async {
    try {
      Directory? baseDir;

      // On Windows / Desktop, prefer Downloads or Documents directory
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        baseDir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      } else {
        baseDir = await getApplicationDocumentsDirectory();
      }

      String targetPath = '${baseDir.path}${Platform.pathSeparator}$fileName';
      File file = File(targetPath);

      // Check if file exists to prevent silent unintentional overwrite
      if (await file.exists() && !overwrite) {
        final dotIndex = fileName.lastIndexOf('.');
        final namePart = dotIndex != -1 ? fileName.substring(0, dotIndex) : fileName;
        final extPart = dotIndex != -1 ? fileName.substring(dotIndex) : '.pdf';
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        targetPath = '${baseDir.path}${Platform.pathSeparator}${namePart}_$timestamp$extPart';
        file = File(targetPath);
      }

      await file.writeAsBytes(pdfBytes, flush: true);
      return FileSaveResult.success(file.path);
    } catch (e) {
      debugPrint('ShareService savePdfToFile error: $e');
      return FileSaveResult.failure('Failed to save document. Please check storage permissions and try again.');
    }
  }

  /// Share the generated PDF document using the platform sharing workflow.
  /// On Windows, if native share dialog is not supported, saves a copy and opens the file or folder.
  Future<bool> sharePdf({
    required Uint8List pdfBytes,
    required String fileName,
    String? subject,
    String? body,
  }) async {
    try {
      if (Platform.isWindows || Platform.isLinux) {
        // Windows Desktop fallback workflow:
        // 1. Save file to temporary directory
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}${Platform.pathSeparator}$fileName';
        final file = File(filePath);
        await file.writeAsBytes(pdfBytes, flush: true);

        // 2. Attempt SharePlus first, or fallback to Printing.sharePdf
        try {
          final xFile = XFile(file.path, mimeType: 'application/pdf', name: fileName);
          final result = await Share.shareXFiles(
            [xFile],
            subject: subject ?? 'TRAVELGO Booking Confirmation',
            text: body ?? 'Here is your TRAVELGO booking confirmation document.',
          );
          if (result.status == ShareResultStatus.success) {
            return true;
          }
        } catch (_) {
          // If SharePlus is not active on Windows desktop, use Printing.sharePdf
          await Printing.sharePdf(
            bytes: pdfBytes,
            filename: fileName,
            subject: subject,
            body: body,
          );
          return true;
        }
        return true;
      } else {
        // Mobile (Android / iOS / macOS / Web)
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename: fileName,
          subject: subject,
          body: body,
        );
        return true;
      }
    } catch (e) {
      debugPrint('ShareService sharePdf error: $e');
      return false;
    }
  }

  /// Open the saved PDF file using the system default PDF reader application
  Future<bool> openSavedFile(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      return result.type == ResultType.done;
    } catch (e) {
      debugPrint('Error opening file: $e');
      return false;
    }
  }
}
