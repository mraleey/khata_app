# Digital Khata — Flutter App

A professional Digital Ledger (Khata) app built with Flutter, GetX, and Firebase.

## Features

- **Dual Authentication** — Email/Password + Phone (OTP)
- **30-Day Session** — Persistent login using get_storage
- **Customer Management** — Add, search, view all customers
- **Transaction Ledger** — Cash In / Cash Out per customer
- **Real-time Balances** — Live net balance per customer + global summary
- **Color-coded UI** — Green for credit, Red for debit
- **Offline Support** — Firestore offline persistence enabled
- **Swipe to Delete** — Slide transactions to remove them

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── app/
│   ├── bindings/initial_binding.dart  # Global DI setup
│   └── routes/
│       ├── app_routes.dart            # Route name constants
│       └── app_pages.dart             # Route definitions + bindings
├── core/
│   ├── theme/app_theme.dart           # Colors, typography, component themes
│   └── utils/session_manager.dart    # 30-day session logic (get_storage)
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── customer_model.dart
│   │   └── transaction_model.dart
│   ├── services/
│   │   └── firebase_service.dart      # Firebase instances + collection refs
│   └── repositories/
│       ├── auth_repository.dart       # Firebase Auth (email + phone OTP)
│       ├── customer_repository.dart   # Firestore CRUD for customers
│       └── transaction_repository.dart # Firestore CRUD for transactions
└── presentation/
    ├── auth/
    │   ├── login/                     # Email login + signup
    │   └── phone_auth/               # Phone OTP login
    ├── dashboard/                     # Home screen with summary + customer list
    ├── customers/
    │   ├── add_customer/             # Add new customer form
    │   └── customer_detail/          # Transaction history + balance
    └── transactions/
        └── add_transaction/          # Cash In / Cash Out entry form
```

## Quick Start

1. **Clone & install**
   ```bash
   flutter pub get
   ```

2. **Set up Firebase** — Follow `FIREBASE_SETUP.md` step by step

3. **Replace config files**
   - `android/app/google-services.json` — your real file from Firebase Console
   - `ios/Runner/GoogleService-Info.plist` — your real file from Firebase Console

4. **Run the app**
   ```bash
   flutter run
   ```

## Tech Stack

| Layer | Technology |
|---|---|
| UI Framework | Flutter (latest stable) |
| State Management | GetX |
| Routing & DI | GetX (GetMaterialApp + Bindings) |
| Backend | Firebase Auth + Cloud Firestore |
| Local Storage | get_storage |
| Date Formatting | intl |
| Swipe Actions | flutter_slidable |

## Architecture

MVC-style with GetX:
- **View** — Pure UI, reads from controller via `Obx()` / `GetView`
- **Controller** — Business logic + reactive state (`RxBool`, `RxList`, `.obs`)
- **Repository** — All Firebase/data access, returns Streams or Futures
- **Model** — Pure Dart data classes with `fromMap` / `toMap`

Controllers are lazy-loaded per route via GetX bindings and automatically disposed on route pop.
