import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/services/share_service.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';

class PdfPreviewScreen extends ConsumerStatefulWidget {
  final Booking booking;

  const PdfPreviewScreen({super.key, required this.booking});

  @override
  ConsumerState<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends ConsumerState<PdfPreviewScreen> {
  PdfPageFormat _pageFormat = PdfPageFormat.a4;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pdfService = ref.watch(pdfServiceProvider);
    final shareService = ref.watch(shareServiceProvider);
    final docNotifier = ref.read(documentOperationProvider(widget.booking.bookingReference).notifier);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Document Preview: ${widget.booking.bookingReference}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Format switch dropdown (A4 vs Letter)
          PopupMenuButton<PdfPageFormat>(
            icon: const Icon(Icons.aspect_ratio_rounded),
            tooltip: 'Change Page Format',
            onSelected: (format) {
              setState(() => _pageFormat = format);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: PdfPageFormat.a4,
                child: Text('A4 Format (Default)'),
              ),
              const PopupMenuItem(
                value: PdfPageFormat.letter,
                child: Text('US Letter Format'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Save PDF File',
            onPressed: () async {
              final path = await docNotifier.saveDocument();
              if (context.mounted) {
                if (path != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Saved to:\n$path'),
                      backgroundColor: AppColors.success,
                      action: SnackBarAction(
                        label: 'OPEN',
                        textColor: Colors.white,
                        onPressed: () {
                          shareService.openSavedFile(path);
                        },
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not save PDF file. Please check permissions.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: PdfPreview(
        maxPageWidth: 700,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        pdfFileName: widget.booking.suggestedPdfFileName,
        initialPageFormat: _pageFormat,
        build: (format) => pdfService.generateBookingPdf(
          widget.booking,
          format: _pageFormat,
        ),
        loadingWidget: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'Rendering TRAVELGO Document...',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        onError: (context, error) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                const Text(
                  'We couldn\'t generate your booking document.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please try again or contact customer support.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
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
    );
  }
}
