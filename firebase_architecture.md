# TRAVELGO — Backend & Firebase Architecture Specification

## 1. Cloud Firestore Collections

### `users`
```json
{
  "id": "usr_99218",
  "name": "Sarah Connor",
  "email": "sarah.connor@traveler.com",
  "profileImage": "https://...",
  "preferredLanguage": "ar",
  "preferredCurrency": "USD",
  "role": "user", // "user" | "admin"
  "createdAt": "2026-08-28T20:00:00Z",
  "updatedAt": "2026-08-28T20:00:00Z"
}
```

### `config` (Document: `global_commission`)
```json
{
  "standardDirectServiceFeeUSD": 1.00,
  "standardAffiliateServiceFeeUSD": 0.00,
  "enableAffiliateCommission": false,
  "taxRatePercentage": 0.05,
  "updatedAt": "2026-08-28T20:00:00Z"
}
```

### `searches`
```json
{
  "id": "search_101",
  "userId": "usr_99218",
  "searchType": "flight", // "flight" | "hotel"
  "searchParameters": {
    "originCode": "ALG",
    "destinationCode": "DXB",
    "departureDate": "2026-09-05",
    "returnDate": "2026-09-12",
    "adults": 1,
    "cabinClass": "economy"
  },
  "createdAt": "2026-08-28T20:10:00Z"
}
```

### `bookings`
```json
{
  "id": "bk_772910",
  "userId": "usr_99218",
  "provider": "Amadeus",
  "bookingType": "flight",
  "status": "confirmed", // "initiated" | "pending" | "confirmed" | "cancelled" | "failed"
  "externalBookingReference": "TG882194",
  "itemName": "Emirates Flight (ALG → DXB)",
  "startDate": "2026-09-05T08:30:00Z",
  "basePriceUSD": 320.00,
  "taxesUSD": 45.00,
  "serviceFeeUSD": 1.00,
  "totalAmountUSD": 366.00,
  "currency": "USD",
  "createdAt": "2026-08-28T20:15:00Z"
}
```

### `affiliateClicks`
```json
{
  "id": "aff_55102",
  "userId": "usr_99218",
  "provider": "Booking.com",
  "productType": "hotel",
  "productId": "ht_dubai_001",
  "trackingId": "trk_99182a17",
  "targetUrl": "https://www.booking.com/hotel/...",
  "clickedAt": "2026-08-28T20:20:00Z"
}
```

---

## 2. Firebase Security Rules (`firestore.rules`)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // User profile: only owner or admin can read/write
    match /users/{userId} {
      allow read, write: if request.auth != null && (request.auth.uid == userId || request.auth.token.role == 'admin');
    }

    // Config document: read-only for authenticated users, write restricted to admin
    match /config/{document} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.role == 'admin';
    }

    // Searches: owner only
    match /searches/{searchId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }

    // Bookings: owner can view and create, admin can view all
    match /bookings/{bookingId} {
      allow read: if request.auth != null && (request.auth.uid == resource.data.userId || request.auth.token.role == 'admin');
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow update, delete: if request.auth != null && request.auth.token.role == 'admin';
    }

    // Affiliate Clicks: write-only log
    match /affiliateClicks/{clickId} {
      allow create: if true;
      allow read: if request.auth != null && request.auth.token.role == 'admin';
    }
  }
}
```
