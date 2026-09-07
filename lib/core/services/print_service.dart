import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../utils/file_storage_helper.dart';

class PrintResult {
  final bool isSuccess;
  final String? errorMessage;

  const PrintResult({required this.isSuccess, this.errorMessage});

  factory PrintResult.success() => const PrintResult(isSuccess: true);
  factory PrintResult.failure(String message) => PrintResult(isSuccess: false, errorMessage: message);
}

class PrintService {
  /// Opens the native/system print dialog (Windows, macOS, Linux, Mobile, Web)
  /// allowing the user to select a printer, specify copies, and confirm or cancel.
  Future<PrintResult> printDocument({
    required Uint8List pdfBytes,
    required String documentName,
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    try {
      final printed = await Printing.layoutPdf(
        name: documentName,
        format: format,
        onLayout: (PdfPageFormat pageFormat) async => pdfBytes,
      );

      if (printed) {
        return PrintResult.success();
      } else {
        // User cancelled or dismissed print dialog
        return const PrintResult(isSuccess: true, errorMessage: 'Printing completed or dialog closed.');
      }
    } catch (e) {
      debugPrint('PrintService error in layoutPdf: $e');
      try {
        // Fallback: save to temp and open share sheet / system viewer
        final tempFile = await FileStorageHelper.saveTempPdf(
          bytes: pdfBytes,
          fileName: '$documentName.pdf',
        );
        debugPrint('Saved temporary document for printing to: ${tempFile.path}');
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename: '$documentName.pdf',
          subject: 'TRAVELGO Document - $documentName',
        );
        return PrintResult.success();
      } catch (fallbackError) {
        return PrintResult.failure(
          'Printing system dialog could not be opened. Please verify your printer connection.',
        );
      }
    }
  }

  Future<PrintResult> printPdf(
    Uint8List pdfBytes, {
    required String documentName,
    PdfPageFormat format = PdfPageFormat.a4,
  }) =>
      printDocument(pdfBytes: pdfBytes, documentName: documentName, format: format);

  /// Lists available system printers if supported by current platform.
  Future<List<Printer>> getAvailablePrinters() async {
    try {
      return await Printing.listPrinters();
    } catch (e) {
      debugPrint('Error listing printers: $e');
      return <Printer>[];
    }
  }

  /// Direct printing to a user-selected printer with confirmation
  Future<PrintResult> printToPrinter({
    required Printer printer,
    required Uint8List pdfBytes,
    required String documentName,
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    try {
      final success = await Printing.directPrintPdf(
        printer: printer,
        name: documentName,
        format: format,
        onLayout: (PdfPageFormat pageFormat) async => pdfBytes,
      );
      if (success) {
        return PrintResult.success();
      } else {
        return PrintResult.failure('Failed to send document to printer "${printer.name}".');
      }
    } catch (e) {
      debugPrint('Direct print error: $e');
      return PrintResult.failure('Print error: $e');
    }
  }
}
