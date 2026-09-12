import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class QrCodeView extends StatelessWidget {
  final String data;
  final double size;
  final String? subtitle;

  const QrCodeView({
    super.key,
    required this.data,
    this.size = 140,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _BarcodePainter(
              barcode: Barcode.qrCode(),
              data: data,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            data,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: AppTheme.primaryNavy,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _BarcodePainter extends CustomPainter {
  final Barcode barcode;
  final String data;
  final Color color;

  _BarcodePainter({
    required this.barcode,
    required this.data,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    try {
      final elements = barcode.make(
        data,
        width: size.width,
        height: size.height,
        drawText: false,
      );

      for (final element in elements) {
        if (element is BarcodeBar && element.black) {
          canvas.drawRect(
            Rect.fromLTWH(
              element.left,
              element.top,
              element.width,
              element.height,
            ),
            paint,
          );
        }
      }
    } catch (e) {
      // Fallback: draw error placeholder
      final errorPaint = Paint()
        ..color = AppTheme.borderSubtle
        ..style = PaintingStyle.stroke;
      canvas.drawRect(Offset.zero & size, errorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}
