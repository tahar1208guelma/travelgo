---
name: pdf-processing
description: PDF generation, form filling, and document processing. Use this skill when generating travel vouchers, booking confirmations, digital boarding passes, receipts, and invoices in PDF format, embedding QR/barcodes, handling RTL/Arabic fonts, filling PDF forms, and integrating native printing/sharing.
---

# PDF Document Generation, Form Filling & Processing

This skill provides a standardized engineering methodology for programmatic PDF document generation, layout design, multilingual/RTL font embedding, AcroForm filling, and integration with native print and sharing subsystems.

---

## 1. Objectives & Scope

- **High-Fidelity Document Generation**: Produce pixel-perfect, vector-based travel vouchers, boarding passes, invoices, and expense receipts.
- **Full Multilingual & RTL Support**: Accurately render Arabic, English, and complex script typography with correct glyph shaping and bidirectional flow.
- **Embedded Visual Codes**: Render crisp vector QR codes and 2D barcodes (PDF417, Aztec) for airport and hotel check-in scanning.
- **Form Manipulation & Flattening**: Fill existing PDF AcroForms and flatten form fields to prevent unauthorized post-generation tampering.
- **Native OS Integration**: Provide seamless printing (`Printing.layoutPdf`), document preview (`PdfPreview`), and system file sharing.

---

## 2. Execution Instructions

### Step 1: Document Structure & Page Theme Definition
1. Select standard page formats: `PdfPageFormat.a4` (210 x 297 mm) or `PdfPageFormat.letter`.
2. Configure uniform page margins (standard: 20-30 points) and multi-page layout structures (`MultiPage`).
3. Define running headers and footers with dynamic page numbering:
   ```dart
   footer: (context) => Container(
     alignment: Alignment.centerRight,
     margin: const EdgeInsets.only(top: 10),
     child: Text(
       'Page ${context.pageNumber} of ${context.pagesCount}',
       style: const TextStyle(fontSize: 9, color: PdfColors.grey700),
     ),
   ),
   ```

### Step 2: Font Loading & Multilingual / RTL Rendering
1. Standard built-in PDF fonts (Helvetica, Times) only support basic ASCII and Western European characters.
2. For internationalization and Arabic support:
   - Bundle TrueType/OpenType Unicode fonts (e.g., Cairo, Amiri, Noto Sans).
   - Load font bytes from app assets into `Font.ttf()`:
     ```dart
     final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
     final ttf = Font.ttf(fontData);
     ```
   - For RTL/Arabic text, apply bidirectional reordering (`intl.Bidi.stripHtmlIfNeeded` or text direction wrappers):
     ```dart
     Text('تأكيد الحجز', textDirection: TextDirection.rtl, style: TextStyle(font: ttf));
     ```

### Step 3: Barcode & QR Code Integration
1. Embed scannable high-density vector codes directly into the document layout:
   - **QR Code**: For booking PNR lookup, verification URLs, or self-check-in:
     ```dart
     BarcodeWidget(
       barcode: Barcode.qrCode(errorCorrectLevel: BarcodeQRCorrectionLevel.high),
       data: 'https://travelgo.app/booking/$bookingId',
       width: 80,
       height: 80,
     );
     ```
   - **PDF417 / Aztec**: Standard IATA barcode formats for airline boarding passes.

### Step 4: PDF Form Filling (AcroForms)
1. When filling existing template documents:
   - Load template bytes into document parser.
   - Inspect and map AcroForm text fields (`passenger_name`, `flight_number`, `departure_date`).
   - Populate field values with validated domain entity data.
   - **Flatten the document**: Convert interactive form fields into static page content to ensure the resulting PDF cannot be edited by the recipient.

### Step 5: Optimization & Binary Generation
1. Compress embedded raster images (logos, partner emblems) before adding them to the PDF:
   - Use PNG/JPEG images scaled to no more than 300 DPI at actual printed size.
2. Render document bytes:
   ```dart
   final Uint8List pdfBytes = await pdf.save();
   ```

### Step 6: Native Printing & System Sharing
1. Trigger native platform print spooler without creating temporary disk clutter:
   ```bash
   # Utilizing printing package
   await Printing.layoutPdf(
     onLayout: (format) async => pdfBytes,
     name: 'Booking_Voucher_$bookingId.pdf',
   );
   ```
2. Enable native sharing to email, messaging, or cloud drives:
   ```bash
   await Printing.sharePdf(bytes: pdfBytes, filename: 'Voucher_$bookingId.pdf');
   ```

---

## 3. Practical Checklists

### Pre-Generation Checklist
- [ ] Document data model verified and complete (no `null` where text expected).
- [ ] Required TTF/OTF fonts bundled and verified for glyph coverage (Arabic + Latin).
- [ ] High-resolution vector/PNG logos prepared.

### Layout & Rendering Checklist
- [ ] `MultiPage` widget utilized for content that may span multiple pages (e.g., flight itineraries).
- [ ] Tables use explicit column width definitions (`TableColumnWidth`) to prevent layout overflow.
- [ ] All prices, fees, and totals formatted deterministically via currency formatters.
- [ ] QR code and barcodes tested with a physical optical scanner.
- [ ] Arabic and RTL strings render right-to-left without detached or reversed glyphs.

### Delivery & Security Checklist
- [ ] Document metadata sanitized (author, creation tool, machine paths removed).
- [ ] Interactive form fields flattened before distribution.
- [ ] Temporary cached PDF files purged after print/share action completes.

---

## 4. Error-Handling & Troubleshooting Matrix

| Issue | Cause | Remediation Procedure |
| :--- | :--- | :--- |
| **Question Mark `?` or Missing Glyphs** | Built-in font lacks Unicode / Arabic glyphs | Load and inject a Unicode TrueType font (e.g., Cairo, Noto Sans) into `ThemeData.withFont()`. |
| **Table Overflow Crashing Page** | Unbounded table row or huge cell content exceeds page height | Set `table.wrap` or break long text across rows; ensure parent is `MultiPage`. |
| **Reversed Arabic Text** | PDF engine rendered Arabic characters without HarfBuzz / RTL shaping | Pass `textDirection: TextDirection.rtl` and ensure font supports Arabic ligatures. |
| **Massive File Size (>10MB)** | Uncompressed 4K raster images embedded in voucher | Downsample images to 300 DPI and compress as JPEG before embedding. |

---

## 5. Security Guardrails

- **Financial Immutability**: Always flatten PDF vouchers to lock prices, dates, and PNRs against client-side tampering.
- **Metadata Sanitization**: Strip internal server hostnames, user file paths, and build machine identifiers from PDF metadata dictionary.
- **No Sensitive Payment Card Data**: Never include full credit card numbers or CVVs on printable vouchers or invoices; mask to last 4 digits (`**** 1234`).

---

## 6. Examples & Voucher Generation Template

### Complete Booking Voucher Generator Snippet (Dart)
```dart
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> generateFlightVoucherPdf({
  required String pnr,
  required String passengerName,
  required String flightNumber,
  required String departureAirport,
  required String arrivalAirport,
  required DateTime departureTime,
  required double totalAmount,
  required String currencyCode,
}) async {
  final pdf = pw.Document();

  // Load Unicode font
  final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
  final boldData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
  final regularFont = pw.Font.ttf(fontData);
  final boldFont = pw.Font.ttf(boldData);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TRAVELGO E-TICKET VOUCHER', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                pw.Text('PNR: $pnr', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.Divider(thickness: 1, color: PdfColors.grey400),
            pw.SizedBox(height: 12),

            // Flight Information Table
            pw.TableHelper.fromTextArray(
              headers: ['Flight', 'From', 'To', 'Departure', 'Passenger'],
              data: [
                [flightNumber, departureAirport, arrivalAirport, departureTime.toString().substring(0, 16), passengerName],
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerLeft,
                4: pw.Alignment.centerLeft,
              },
            ),
            pw.SizedBox(height: 20),

            // Financial Summary & Verification QR
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Total Paid: $currencyCode ${totalAmount.toStringAsFixed(2)}',
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                    pw.Text('Status: Confirmed', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                  ],
                ),
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: 'TRAVELGO:$pnr:$passengerName',
                  width: 70,
                  height: 70,
                ),
              ],
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
```
