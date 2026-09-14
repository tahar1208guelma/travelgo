import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

final printServiceProvider = Provider<PrintService>((ref) {
  return PrintService();
});

class PrintResult {
  final bool isSuccess;
  final String? errorMessage;

  const PrintResult({
    required this.isSuccess,
    this.errorMessage,
  });

  factory PrintResult.success() => const PrintResult(isSuccess: true);
  factory PrintResult.failure(String message) => PrintResult(isSuccess: false, errorMessage: message);
}

class PrintService {
  /// Opens the native/system print workflow (supporting Windows, macOS, Linux, Android, iOS).
  ///
  /// This prompts the user with the standard operating system print dialog where they can:
  /// - Choose their preferred printer
  /// - Select page orientation and copies
  /// - Confirm or cancel the print job
  Future<PrintResult> printDocument({
    required Uint8List pdfBytes,
    required String documentName,
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    try {
      final success = await Printing.layoutPdf(
        name: documentName,
        format: format,
        onLayout: (PdfPageFormat pageFormat) async => pdfBytes,
      );

      if (success) {
        return PrintResult.success();
      } else {
        // User may have cancelled the print dialog
        return const PrintResult(
          isSuccess: true,
          errorMessage: null,
        );
      }
    } catch (e) {
      debugPrint('PrintService error: $e');
      return PrintResult.failure(
        'Unable to open print dialog. Please make sure a printer is installed or export the document as PDF.',
      );
    }
  }

  /// Check if printing is supported on the current platform environment.
  Future<bool> canPrint() async {
    try {
      final info = await Printing.info();
      return info.canPrint;
    } catch (_) {
      return false;
    }
  }

  /// List available local or networked printers (for advanced Windows / desktop selection)
  Future<List<Printer>> getPrinters() async {
    try {
      return await Printing.listPrinters();
    } catch (e) {
      debugPrint('Error listing printers: $e');
      return [];
    }
  }
}
