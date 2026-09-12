import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/services/print_service.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/file_storage_helper.dart';
import '../../models/booking.dart';

class PdfPreviewScreen extends StatefulWidget {
  final Booking booking;
  final PdfService pdfService;
  final PrintService printService;
  final ShareService shareService;

  const PdfPreviewScreen({
    super.key,
    required this.booking,
    required this.pdfService,
    required this.printService,
    required this.shareService,
  });

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  PdfPageFormat _pageFormat = PdfPageFormat.a4;
  bool _isProcessing = false;

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    return widget.pdfService.generateBookingPdf(widget.booking, format: format);
  }

  Future<void> _handleSavePdf() async {
    setState(() => _isProcessing = true);
    try {
      final bytes = await widget.pdfService.generateBookingPdf(
        widget.booking,
        format: _pageFormat,
      );

      if (!mounted) return;
      final savedPath = await FileStorageHelper.savePdfWithPicker(
        bytes: bytes,
        suggestedFileName: widget.booking.suggestedPdfFileName,
        context: context,
      );

      if (!mounted) return;
      if (savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document successfully saved to:\n$savedPath'),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('We couldn\'t save your booking document. Please try again.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handlePrint() async {
    setState(() => _isProcessing = true);
    try {
      final bytes = await widget.pdfService.generateBookingPdf(
        widget.booking,
        format: _pageFormat,
      );

      final result = await widget.printService.printDocument(
        pdfBytes: bytes,
        documentName: widget.booking.suggestedPdfFileName,
        format: _pageFormat,
      );

      if (!mounted) return;
      if (!result.isSuccess && result.errorMessage != null && !result.errorMessage!.contains('cancelled')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage!),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('We couldn\'t start printing. Please check your printer connection and try again.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleShare() async {
    setState(() => _isProcessing = true);
    try {
      final bytes = await widget.pdfService.generateBookingPdf(
        widget.booking,
        format: _pageFormat,
      );

      final result = await widget.shareService.sharePdf(
        pdfBytes: bytes,
        fileName: widget.booking.suggestedPdfFileName,
        subject: 'TRAVELGO Booking Confirmation (${widget.booking.bookingReference})',
      );

      if (!mounted) return;
      if (result.isSuccess && result.savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document ready at: ${result.savedPath}'),
            backgroundColor: AppTheme.accentBlue,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('We couldn\'t share your document. Please try again.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Document Preview • ${widget.booking.bookingReference}'),
        actions: [
          // Format switch: A4 / Letter
          PopupMenuButton<PdfPageFormat>(
            tooltip: 'Select Page Format',
            icon: const Icon(Icons.aspect_ratio),
            onSelected: (format) {
              setState(() => _pageFormat = format);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: PdfPageFormat.a4,
                child: Row(
                  children: [
                    if (_pageFormat == PdfPageFormat.a4)
                      const Icon(Icons.check, size: 16, color: AppTheme.accentBlue)
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    const Text('A4 (Standard)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: PdfPageFormat.letter,
                child: Row(
                  children: [
                    if (_pageFormat == PdfPageFormat.letter)
                      const Icon(Icons.check, size: 16, color: AppTheme.accentBlue)
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    const Text('US Letter'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            tooltip: 'Save PDF',
            icon: const Icon(Icons.download),
            onPressed: _isProcessing ? null : _handleSavePdf,
          ),
          IconButton(
            tooltip: 'Print',
            icon: const Icon(Icons.print),
            onPressed: _isProcessing ? null : _handlePrint,
          ),
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share),
            onPressed: _isProcessing ? null : _handleShare,
          ),
        ],
      ),
      body: Stack(
        children: [
          PdfPreview(
            build: (format) => _generatePdf(format),
            pageFormats: const {
              'A4': PdfPageFormat.a4,
              'Letter': PdfPageFormat.letter,
            },
            initialPageFormat: _pageFormat,
            allowPrinting: true,
            allowSharing: true,
            canChangePageFormat: true,
            canChangeOrientation: false,
            canDebug: false,
            pdfFileName: widget.booking.suggestedPdfFileName,
            actions: [
              PdfPreviewAction(
                icon: const Icon(Icons.save_alt),
                onPressed: (ctx, buildFn, pageFormat) => _handleSavePdf(),
              ),
            ],
            loadingWidget: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Generating PDF Document...'),
                ],
              ),
            ),
            onError: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
                    const SizedBox(height: 12),
                    const Text(
                      'We couldn\'t generate your booking document.',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Please verify your booking data and try again.',
                      style: TextStyle(color: AppTheme.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
