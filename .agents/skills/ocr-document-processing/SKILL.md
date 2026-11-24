---
name: ocr-document-processing
description: Document scanning, optical character recognition (OCR) extraction, and structured data validation. Use this skill when capturing identity documents (passports, national IDs, driver licenses, boarding passes), preprocessing document images, parsing Machine Readable Zones (MRZ / ICAO Doc 9303), verifying document checksums, and validating extracted PII.
---

# Document Scanning, OCR Extraction & Data Validation

This skill provides an end-to-end engineering guide for capturing physical identity documents, running optical character recognition (OCR), parsing structured fields (including ICAO 9303 MRZ), and validating checksums.

---

## 1. Objectives & Scope

- **High-Fidelity Document Ingestion**: Capture images with proper framing, resolution, lighting, and blur detection.
- **Image Preprocessing**: Deskew, crop, contrast-stretch, and binarize images to maximize OCR confidence.
- **Structured Field Extraction**: Accurately extract passenger names, passport numbers, birth dates, expirations, and issuing states.
- **Deterministic Checksum Validation**: Verify standard ICAO 9303 Modulo 10 (weight 7-3-1) checksum algorithms on MRZ lines.
- **Strict Privacy & PII Compliance**: Enforce ephemeral storage for document images and encrypt all parsed biometric/identity data.

---

## 2. Execution Instructions

### Step 1: Capture Quality Assessment & Camera Framing
1. Enforce on-screen guide overlays (aspect ratio 85.60 × 53.98 mm for ID cards; ISO/IEC 7810 ID-3 for passports).
2. Run pre-OCR quality checks:
   - **Resolution**: Require minimum 1080p (1920x1080) capture.
   - **Blur Detection**: Calculate Laplacian variance; reject images below threshold (e.g., variance < 100).
   - **Glare & Exposure**: Check histogram distribution to ensure text regions are not washed out by flash.

### Step 2: Image Preprocessing Pipeline
1. Crop image to detected document bounding box.
2. Convert image to grayscale.
3. Apply adaptive thresholding or contrast enhancement (histogram equalization) to accentuate printed alphanumeric characters against complex security backgrounds.

### Step 3: Text Recognition (On-Device OCR)
1. Execute on-device OCR using Google ML Kit (`google_mlkit_text_recognition`) or Apple Vision framework to prevent transmitting unencrypted raw biometric images across the network.
2. Extract text blocks, lines, and character confidence scores.
3. Filter out low-confidence blocks (confidence score < 0.65).

### Step 4: Machine Readable Zone (MRZ) Parsing
1. Locate the two-line (TD3 - Passports) or three-line (TD1 - ID cards) MRZ lines at the bottom of the document:
   - Passports (TD3): 2 lines of 44 characters (`[A-Z0-9<]{44}`).
   - ID Cards (TD1): 3 lines of 30 characters (`[A-Z0-9<]{30}`).
2. Clean common OCR misidentifications:
   - `O` (letter) vs `0` (zero)
   - `I` (letter) vs `1` (one)
   - `S` (letter) vs `5` (five)
   - Replace filler `<` characters with whitespace or delimiter.

### Step 5: ICAO 9303 Checksum Calculation
1. Apply the **ICAO Doc 9303 Modulo 10 algorithm** with repeating weights **7, 3, 1**:
   - Values: `0-9` = `0-9`, `A-Z` = `10-35`, `<` = `0`.
   - Multiply each character value by its corresponding weight `(7, 3, 1, 7, 3, 1, ...)`.
   - Sum products and take `sum % 10`.
   - The result must match the check digit located immediately after the field.
2. Validate three individual check digits:
   - Document Number check digit.
   - Date of Birth check digit (`YYMMDD`).
   - Expiration Date check digit (`YYMMDD`).
3. Validate Composite / Overall check digit over all combined fields.

### Step 6: User Review & Confirmation Flow
1. Display parsed fields in editable form fields.
2. Highlight any field where checksum failed or confidence was marginal (< 0.80).
3. Require explicit user review and confirmation before associating data with a booking.

---

## 3. Practical Checklists

### Pre-Processing Checklist
- [ ] Camera permissions requested with clear purpose explanation.
- [ ] On-screen document alignment mask displayed to user.
- [ ] Flash/torch toggle available for low-light environments.

### Extraction & Validation Checklist
- [ ] Text recognized using on-device ML engine.
- [ ] MRZ lines verified for exact character length (44 chars for TD3).
- [ ] Document number checksum verified.
- [ ] Date of birth checksum verified and date is in past.
- [ ] Expiration date checksum verified and date is in future.
- [ ] Passenger name parsed correctly (Surname << Given Names).

### Security & Privacy Checklist
- [ ] Raw document images deleted from temporary cache immediately after extraction.
- [ ] No raw scanned images uploaded to cloud storage without explicit user consent.
- [ ] Extracted passport/ID numbers encrypted at rest using platform hardware keychains.
- [ ] Passport numbers masked in logs (`AB***123`).

---

## 4. Error-Handling & Ambiguity Procedures

| OCR Failure | Cause | Remediation Procedure |
| :--- | :--- | :--- |
| **Blurry Capture** | Camera shake or out of focus | Trigger immediate recapture prompt: "Document too blurry. Please hold steady." |
| **MRZ Checksum Mismatch** | Misread character (e.g. `0` read as `O`) | Attempt known OCR substitution matrix; if check digit still fails, prompt user to manually correct field. |
| **Expired Document** | Extracted expiration date is before current date | Display warning banner: "Document is expired. Please provide a valid travel document." |
| **Non-Standard ID Layout** | Document lacks standard ICAO MRZ | Fall back to visual keyword scanning (e.g., search for "Passport No", "DOB", "Exp"). |

---

## 5. Security Guardrails

- **Zero Unencrypted PII at Rest**: Never save scanned identity documents or unmasked passport numbers in unencrypted local storage or SQLite.
- **On-Device Processing First**: Perform OCR locally on the device to minimize network transmission of sensitive biometric identification documents.
- **Memory Purge**: Clear byte buffers containing image scans from RAM once processing completes.

---

## 6. Examples & Checksum Implementation

### ICAO 9303 Check Digit Calculator (Dart)
```dart
int calculateIcaoCheckDigit(String input) {
  const weights = [7, 3, 1];
  int sum = 0;

  for (int i = 0; i < input.length; i++) {
    final char = input[i].toUpperCase();
    int value;

    if (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57) {
      // 0-9
      value = char.codeUnitAt(0) - 48;
    } else if (char.codeUnitAt(0) >= 65 && char.codeUnitAt(0) <= 90) {
      // A-Z -> 10-35
      value = char.codeUnitAt(0) - 55;
    } else if (char == '<') {
      value = 0;
    } else {
      throw FormatException('Invalid character in MRZ string: $char');
    }

    final weight = weights[i % 3];
    sum += value * weight;
  }

  return sum % 10;
}

bool verifyIcaoField(String field, String expectedCheckDigit) {
  final checkDigit = int.tryParse(expectedCheckDigit);
  if (checkDigit == null) return false;
  return calculateIcaoCheckDigit(field) == checkDigit;
}
```

### TD3 Passport MRZ Line Structure
```text
Line 1: P<GBRTHOMPSON<<SARAH<<<<<<<<<<<<<<<<<<<<<<<
Line 2: 7083049580GBR8806236F2701014<<<<<<<<<<<<<<04
        |--DocNo--| |Nat| |-DOB-| |Exp-|          |Comp|
```
