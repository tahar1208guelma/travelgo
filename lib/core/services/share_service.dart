import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';
import '../utils/file_storage_helper.dart';

class ShareResultInfo {
  final bool isSuccess;
  final String? message;
  final String? savedPath;

  const ShareResultInfo({required this.isSuccess, this.message, this.savedPath});

  factory ShareResultInfo.success([String? path]) => ShareResultInfo(isSuccess: true, savedPath: path);
  factory ShareResultInfo.failure(String message) => ShareResultInfo(isSuccess: false, message: message);
}

class ShareService {
  /// Shares generated PDF document via system share sheet or desktop workflow
  Future<ShareResultInfo> sharePdf({
    required Uint8List pdfBytes,
    required String fileName,
    String? subject,
    String? text,
  }) async {
    try {
      // Primary: Cross-platform printing share integration (Windows, macOS, Linux, Web, Mobile)
      final shared = await Printing.sharePdf(
        bytes: pdfBytes,
        filename: fileName,
        subject: subject ?? 'TRAVELGO Booking Confirmation',
        body: text ?? 'Here is your TRAVELGO booking confirmation document.',
      );

      if (shared) {
        return ShareResultInfo.success();
      }

      // Fallback: save temp file and report location
      final tempFile = await FileStorageHelper.saveTempPdf(
        bytes: pdfBytes,
        fileName: fileName,
      );

      return ShareResultInfo.success(tempFile.path);
    } catch (e) {
      debugPrint('ShareService error: $e');
      try {
        final tempFile = await FileStorageHelper.saveTempPdf(
          bytes: pdfBytes,
          fileName: fileName,
        );
        return ShareResultInfo(
          isSuccess: true,
          message: 'Saved temporary document to: ${tempFile.path}',
          savedPath: tempFile.path,
        );
      } catch (fallbackErr) {
        return ShareResultInfo.failure('Unable to share document: $e');
      }
    }
  }
}
