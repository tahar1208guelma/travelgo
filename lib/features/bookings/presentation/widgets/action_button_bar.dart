import 'package:flutter/material.dart';

class ActionButtonBar extends StatelessWidget {
  final VoidCallback? onViewPdf;
  final VoidCallback? onSavePdf;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;
  final bool isLoading;

  const ActionButtonBar({
    super.key,
    this.onViewPdf,
    this.onSavePdf,
    this.onPrint,
    this.onShare,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 480;
        final buttons = [
          if (onViewPdf != null)
            ElevatedButton.icon(
              onPressed: onViewPdf,
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text('View PDF'),
            ),
          if (onSavePdf != null)
            OutlinedButton.icon(
              onPressed: onSavePdf,
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Save PDF'),
            ),
          if (onPrint != null)
            OutlinedButton.icon(
              onPressed: onPrint,
              icon: const Icon(Icons.print, size: 18),
              label: const Text('Print'),
            ),
          if (onShare != null)
            OutlinedButton.icon(
              onPressed: onShare,
              icon: const Icon(Icons.share, size: 18),
              label: const Text('Share'),
            ),
        ];

        if (isWide) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: buttons,
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: buttons
                .map((btn) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: btn,
                    ))
                .toList(),
          );
        }
      },
    );
  }
}
