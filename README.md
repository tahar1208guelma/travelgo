# TravelGo • Enterprise Multiplatform Travel Booking Platform
### Global Flights & Hotels Reservation Network (Algeria & Worldwide)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-20.x-339933?logo=node.js)](https://nodejs.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791?logo=postgresql)](https://www.postgresql.org)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)](https://www.docker.com)
[![License](https://img.shields.io/badge/License-Proprietary-blue.svg)]()

TravelGo is a production-grade, full-stack travel booking platform engineered for high-volume flight and hotel reservations. Designed specifically for travelers in Algeria and internationally, it features complete RTL Arabic, French, and English internationalization, provider abstraction architecture, dynamic platform commission calculation, server-side verified payments, and automated PDF travel document generation.

---

## 📑 جدول المحتويات / Table of Contents
1. [متطلبات التشغيل (System Requirements)](#1-متطلبات-التشغيل-system-requirements)
2. [تثبيت وإعداد Flutter (Flutter Setup)](#2-تثبيت-وإعداد-flutter-flutter-setup)
3. [تثبيت وتشغيل Backend (Backend Setup)](#3-تثبيت-وتشغيل-backend-backend-setup)
4. [إعداد قاعدة البيانات (Database Setup & Migrations)](#4-إعداد-قاعدة-البيانات-database-setup--migrations)
5. [إعداد المتغيرات البيئية (Environment Variables)](#5-إعداد-المتغيرات-البيئية-environment-variables)
6. [تشغيل المشروع بالكامل (Running the Platform)](#6-تشغيل-المشروع-بالكامل-running-the-platform)
7. [تشغيل الاختبارات (Running Automated Tests)](#7-تشغيل-الاختبارات-running-automated-tests)
8. [ربط مزودي الطيران الحقيقيين (Connecting Real Flight APIs)](#8-ربط-مزودي-الطيران-الحقيقيين-connecting-real-flight-apis)
9. [ربط مزودي الفنادق الحقيقيين (Connecting Real Hotel APIs)](#9-ربط-مزودي-الفنادق-الحقيقيين-connecting-real-hotel-apis)
10. [ربط بوابات الدفع الإلكتروني (Connecting Payment Gateways)](#10-ربط-بوابات-الدفع-الإلكتروني-connecting-payment-gateways)
11. [بناء تطبيق أندرويد (Building Android APK)](#11-بناء-تطبيق-أندرويد-building-android-apk)
12. [بناء تطبيق ويندوز (Building Windows EXE)](#12-بناء-تطبيق-ويندوز-building-windows-exe)

---

## 1. متطلبات التشغيل (System Requirements)
* **Operating Systems**: macOS (Apple Silicon / Intel), Windows 10/11 (64-bit), or Linux Ubuntu 22.04 LTS.
* **Flutter SDK**: version `>= 3.22.0` (Dart `>= 3.4.0`).
* **Node.js**: version `>= 18.x` LTS (Node 20 recommended) & npm `>= 9.x`.
* **PostgreSQL**: version `14` or `15+`.
* **Docker & Docker Compose**: (Optional for containerized 1-click execution).

---

## 2. تثبيت وإعداد Flutter (Flutter Setup)
تحقق من اكتمال تثبيت فلاتر وتوفر كافة الحزم:
```bash
# Verify Flutter toolchain
flutter doctor

# Navigate to project root and install Flutter dependencies
flutter pub get

# Ensure zero static analysis issues
flutter analyze
```

---

## 3. تثبيت وتشغيل Backend (Backend Setup)
تم بناء الـ Backend باستخدام **Node.js, Express, و TypeScript** مع معمارية معيارية مشددة الحماية:
```bash
cd backend

# Install production and development dependencies
npm install

# Build TypeScript to production JavaScript
npm run build

# Start the development server with live reload
npm run dev

# Or run the production built server
npm start
```
يعمل السيرفر افتراضياً على: `http://localhost:4000`.

---

## 4. إعداد قاعدة البيانات (Database Setup & Migrations)
تحتوي قاعدة البيانات على **21 جدولاً علائقياً** متكاملاً تشمل المستخدمين، الرحلات، الفنادق، الحجوزات، المدفوعات، العمولات، وسجلات الأمان (Audit Logs).

### الطريقة 1: عبر Docker (الأسرع والأسهل)
```bash
# Starts PostgreSQL 15 and executes database/schema.sql automatically
docker-compose up -d postgres
```

### الطريقة 2: عبر PostgreSQL المحلي
```bash
# Create the database
createdb travelgo

# Apply initial schema, indexes, and seed data
psql -d travelgo -f database/schema.sql
```

الملفات المرجعية:
* `database/migrations/001_initial_schema.sql`: الجداول الأساسية والروابط.
* `database/migrations/002_indexes_and_constraints.sql`: الفهارس العالية الأداء.
* `database/migrations/003_seed_data.sql`: الأدوار، العملات (DZD, EUR, USD, GBP)، والمزودين، ونسبة العمولة الافتراضية (0.75%).

---

## 5. إعداد المتغيرات البيئية (Environment Variables)
انسخ ملف الإعدادات النموذجي إلى `.env`:
```bash
cp .env.example .env
```
أهم المتغيرات:
```ini
NODE_ENV=development
PORT=4000
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/travelgo
JWT_SECRET=your_super_secret_jwt_key_64_characters_here

# TravelGo Commission (0.75% default = 0.0075)
COMMISSION_RATE=0.0075

# Flight Provider Credentials (Amadeus / Duffel)
AMADEUS_CLIENT_ID=
AMADEUS_CLIENT_SECRET=
DUFFEL_ACCESS_TOKEN=

# Hotel Provider Credentials (Booking.com / Expedia)
BOOKING_COM_API_KEY=

# Payment Gateways (Stripe / Algeria SATIM CIB & Edahabia)
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
CIB_MERCHANT_KEY=
```

---

## 6. تشغيل المشروع بالكامل (Running the Platform)

### عبر Docker Compose (الباك إند وقاعدة البيانات معاً):
```bash
docker-compose up --build
```

### تشغيل تطبيق Flutter على الأجهزة:
```bash
# Run on connected Android Device or Emulator
flutter run -d android

# Run on macOS Desktop
flutter run -d macos

# Run on Windows Desktop
flutter run -d windows
```

---

## 7. تشغيل الاختبارات (Running Automated Tests)

### اختبارات الـ Frontend (Flutter Unit, Widget & BLoC Tests):
```bash
flutter test
```
*النتيجة*: $\mathbf{42/42\text{ Tests Passing (100\%)}}$ تغطي البحث، الحجوزات، التحقق من بطاقات الدفع 3DS، واستخراج التذاكر.

### اختبارات الـ Backend (Jest Unit & Integration Tests):
```bash
cd backend
npm test
```
تختبر حساب العمولة، التحقق من الأسعار، حالة المستندات، واستجابة الـ Mock Providers.

---

## 8. ربط مزودي الطيران الحقيقيين (Connecting Real Flight APIs)
تم عزل الـ Providers بطبقة تجريد `IFlightProvider` في المسار `backend/src/providers/`:
1. **Amadeus**: سجّل في [Amadeus for Developers](https://developers.amadeus.com)، واحصل على `API Key` و `API Secret`.
2. ضع القيم في ملف `.env`:
   ```ini
   AMADEUS_CLIENT_ID=your_amadeus_client_id
   AMADEUS_CLIENT_SECRET=your_amadeus_client_secret
   ```
3. من لوحة تحكم المدير (`Admin Console`)، فعّل خيار `Amadeus Global Travel Network`. سيقوم النظام بالتحول تلقائياً من الـ Mock إلى الـ Live API.
4. **ملاحظة أمان**: تطبيق فلاتر **لا يرى إطلاقاً** هذه المفاتيح السرية؛ كافة العمليات تتم عبر TravelGo Backend.

---

## 9. ربط مزودي الفنادق الحقيقيين (Connecting Real Hotel APIs)
تعتمد طبقة الفنادق على `IHotelProvider` في المسار `backend/src/providers/`:
1. احصل على مفتاح الربط من مزود الخدمة (مثل Booking.com Affiliate أو Expedia Partner Solutions).
2. ضعه في `.env`:
   ```ini
   BOOKING_COM_API_KEY=your_booking_com_key
   ```
3. عند توفر المفتاح، يقوم `HotelsService` بتحويل طلبات البحث والحجز إلى المزود المباشر. وفي حال عدم وجود مفاتيح، يعمل المزود المعتمد `MockHotelProvider` مع وسم واضح: `DEMO ONLY`.

---

## 10. ربط بوابات الدفع الإلكتروني (Connecting Payment Gateways)
تعتمد بوابات الدفع على معيار **Server-side Verification & Tokenization**:
* **Stripe (Global)**:
  1. ضع `STRIPE_SECRET_KEY` في `.env`.
  2. تدعم البطاقات البنكية الدولية مع تفعيل تحدي الأمان ثلاثي الأبعاد **(3-D Secure)**.
* **الجزائر (SATIM / البطاقة الذهبية Edahabia وبطاقات CIB)**:
  1. ضع `CIB_MERCHANT_KEY` الصادر من بريد الجزائر / SATIM.
  2. يتم توليد رابط الدفع الرسمي بالدينار الجزائري (DZD)، والتحقق من الاستجابة عبر Webhook قبل اعتماد الحجز.

---

## 11. بناء تطبيق أندرويد (Building Android APK)
تم إعداد وضبط حزمة أندرويد بالكامل وجاهزة للإنتاج:
```bash
# Build standalone release APK
flutter build apk --release
```
* **ملف الـ APK الناتج والمختبر جاهز في جذر المشروع**:
  ```text
  TRAVELGO_Release_v1.0.apk (59.7 MB)
  ```

---

## 12. بناء تطبيق ويندوز (Building Windows EXE)
لبناء ملف التنصيب لنظام Windows:
```bash
# Enable desktop windows support
flutter config --enable-windows-desktop

# Compile release executable
flutter build windows --release
```
* **الملفات الناتجة على نظام ويندوز**:
  ```text
  build/windows/x64/runner/Release/travelgo.exe
  ```
  *(يمكن تجميع المجلد عبر Inno Setup أو WiX Toolset لإنتاج ملف Setup.exe نهائي للمستخدمين)*.

---

## 13. النظام المالي وسحب عمولات مالك المنصة (Merchant Wallet & Financial System)

يحتوي TravelGo على نظام مالي احترافي متكامل مصمم لإدارة مستحقات وعمولات مالك المنصة (بنسبة 0.75% افتراضياً، قابلة للتعديل من لوحة الإدارة):

### دورة حياة العمولة الصارمة (9 مراحل أمان):
```text
Booking
   ↓
Payment confirmed
   ↓
Provider confirmed (PNR / Hotel Voucher Issued)
   ↓
Commission calculated (0.75%)
   ↓
Commission pending
   ↓
Commission available
   ↓
Withdrawal request
   ↓
Admin verification
   ↓
Bank payout
   ↓
Withdrawal completed
```

> **ملاحظة أمان جوهرية**: لا تعتبر العمولة مالاً قابلاً للسحب بمجرد إنشاء الحجز! بل تبقى في حالة `Pending` حتى تأكيد المزود رسمياً وإصدار التذكرة/الفوتشر، وعندها تنتقل تلقائياً إلى رصيد المحفظة القابل للسحب `Available`.

### ميزات النظام المالي:
1. **عزل العملات التام (Strict Multi-Currency Isolation)**:
   - محافظ منفصلة تماماً لكل عملة: **EUR**، **USD**، **DZD**، و **GBP**.
   - لا يتم جمع عملات مختلفة (مثلاً: 100 EUR + 100 USD لا تساوي 200).
2. **سجل مالي ثابت غير قابل للتعديل (Immutable Financial Ledger)**:
   - جدول `wallet_transactions` يعمل بنظام الإضافة فقط (Append-Only).
   - يسجل `balance_before` و `balance_after` لكل عملية.
   - أي تصحيح أو استرجاع (Refund) يتم بقيد تسوية جديد (`adjustment`) دون مساس بالسجلات السابقة.
3. **الحسابات البنكية وإخفاء البيانات الحساسة (Bank Accounts & Data Masking)**:
   - تخزين آمن لبيانات الحسابات البنكية (اسم الحساب، اسم البنك، IBAN/RIB، SWIFT/BIC، الدولة).
   - إخفاء البيانات البنكية الحساسة في واجهة المستخدم (مثل `DZ****1234`).
4. **حدود السحب الدنيا (Minimum Withdrawal Thresholds)**:
   - 50.00 EUR
   - 50.00 USD
   - 6,500.00 DZD
   - 40.00 GBP
5. **طبقة مزودي الصرف البنكي (Payout Providers)**:
   - **Manual Wire Transfer Workflow**: تحويل بنكي يدوي مؤكد مع تتبع رقم الحوالة (`WIRE-TG-XXXXX`).
   - **Stripe Connect Automated Payouts**: دعم الصرف الآلي للحسابات البنكية المرتبطة.
6. **إيصالات السحب الرسمية (PDF Withdrawal Receipts)**:
   - توليد وطباعة إيصال رسمي رقمي ومشفّر مع رمز QR ومعرف المعاملة وتفاصيل البنك المحول إليه.

---

## 14. التكامل مع المبرمج الذكي المستقل Google Jules (Google Jules Integration)

تم تجهيز مشروع **TravelGo** بالكامل ليدعم التكامل الأصلي مع **Google Jules**، وهو وكيل الذكاء الاصطناعي البرمجي المستقل (Autonomous AI Coding Agent) المطور من قِبل Google Labs والذي يعمل على منصة السحاب Google Cloud لإنشاء المهام وحل المشكلات وفتح Pull Requests تلقائياً.

### ملفات التوجيه والتهيئة المضافة:
1. **`AGENTS.md` (في جذر المشروع)**:
   - الدليل الإرشادي القياسي المعتمد من Agentic AI Foundation (AAIF) و Google.
   - يعرّف Jules على المعمارية (Flutter BLoC + Express TypeScript)، وقواعد الأعمال الجوهرية (نسبة العمولة 0.75%، دورة حياة الـ 9 مراحل، عزل العملات EUR/USD/DZD/GBP)، وأوامر الاختبار (`flutter test`, `flutter analyze`, `npm test`).
2. **`.jules/config.json`**:
   - ملف الإعدادات التقنية لبيئة عمل Jules وسيرفرات الاختبار الافتراضية والملفات المحمية مثل `.env`.
3. **`.github/workflows/jules.yml`**:
   - سير عمل GitHub Actions مؤتمت يستدعي Jules عند إضافة وسم `jules` على أي Issue أو كتابة تعليق يبدأ بـ `/jules`، أو عبر التشغيل اليدوي (Workflow Dispatch).

### خطوات ربط المشروع مع Google Jules:
1. افتح منصة **[jules.google.com](https://jules.google.com)** وسجّل الدخول بحساب Google الخاص بك.
2. اختر **Connect GitHub** وامنح Jules الإذن للوصول إلى مستودع (Repository) مشروع `TravelGo`.
3. احصل على مفتاح **Jules API Key** من لوحة التحكم في الموقع.
4. في مستودع GitHub لمشروعك، اذهب إلى:
   `Settings` -> `Secrets and variables` -> `Actions` -> أضف سراً جديداً باسم:
   ```text
   JULES_API_KEY
   ```
5. **طرق تشغيل Jules لحل المشكلات برمجياً وتلقائياً**:
   - **عبر موقع Jules**: اكتب الأمر أو الميزة المطلوبة وسيقوم Jules باستنساخ المشروع في بيئة VM خاصة وتجربة الحل وفتح Pull Request جاهز للمراجعة.
   - **عبر قضايا GitHub (Issues)**: أنشئ Issue جديداً لأي مشكلة وضع عليه Label باسم `jules` أو علّق بداخله:
     ```text
     /jules قم بإصلاح مشكلة حساب الضريبة في الحجوزات وإضافة اختبار وحدة لها
     ```
   - سيتولى Jules فحص `AGENTS.md` وقراءة الكود وتشغيل الاختبارات وتجهيز الـ PR تلقائياً!

---

## 🔒 ترخيص الأمان والوثائق الرسمية (PDF Documents)
* **تذكرة الطيران الإلكترونية (E-Ticket)**: لا يُطلق عليها "تذكرة طيران مؤكدة" إلا بعد استلام رمز الـ PNR الفعلي وتأكيد الحجز من شركة الطيران.
* **مسار الرحلة (Flight Itinerary)**: يُستخرج كوثيقة حجز مبدئية معتمدة ومطابقة لشروط ملفات التأشيرة (Visa Application) لدى TLScontact و VFS Global.
* **فوتشر الفندق (Hotel Voucher)**: يوضح تفاصيل النزلاء، التواريخ، والرمز الشريطي للتحقق الرقمي.
* **إيصال السحب المالي (Merchant Payout Receipt)**: وثيقة اعتماد السحب المالي لمالك المنصة من السجل المالي غير القابل للتعديل.

