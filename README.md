# Wonderful Perfumes

Wonderful Perfumes is a Flutter inventory and sales desktop app for a perfume shop. It uses Supabase to store perfume inventory, sellers, and sales.

## Features

- **Inventory overview:** See perfume types, total units, and items needing attention.
- **Inventory search and filters:** Search by perfume name or brand; filter by fragrance category or stock status; sort by name or unit count.
- **Stock management:** Add stock to an existing perfume and edit its name, brand, category, bottle size, or reorder level.
- **Perfume intake:** Add a perfume with its brand, category, bottle size, starting quantity, reorder level, and optional notes. Supported categories are Eau de Parfum, Eau de Toilette, Parfum, and Eau de Cologne.
- **Stock status:** Automatically label items as in stock, low stock (at or below their reorder level), or out of stock.
- **Seller management:** Add sellers with an optional email address and see the eight most recently added sellers.
- **Sales recording:** Sell an in-stock perfume, select a seller and payment method (Card, Cash, or Bank transfer), and record the quantity sold. The database checks available stock and records the sale atomically.
- **Sales ledger:** Review sale number, date, perfume, seller, quantity, payment method, and status. Search sales and filter by date (all dates, today, or the last seven days) and status.
- **Sales summaries:** See units sold, completed orders, and today's orders.
- **Desktop-style navigation:** Switch between Inventory, Sales, Add Seller, and Add Perfume from the fixed sidebar.

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (includes the Dart SDK)
- A [Supabase](https://supabase.com/) project
- A supported Flutter target. The layout is designed for desktop; Windows users can run the Windows desktop target after enabling [Windows desktop support](https://docs.flutter.dev/platform-integration/windows).

## Setup

1. **Get the project** and open a terminal in its root directory (the directory containing `pubspec.yaml`).

2. **Create and configure Supabase.** In the Supabase dashboard, create a project and open **SQL Editor**. Run the contents of [`supabase_schema.sql`](./supabase_schema.sql) to create the tables, stock RPC functions, and row-level security policies required by the app.

3. **Set the Supabase project credentials.** In **Project Settings → API** (or **Data API** in newer dashboards), copy the project URL and the **anon/publishable key**. Replace the empty values in `lib/config.dart`:

   ```dart
   class AppConfig {
     static const supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
     static const supabaseAnonKey = 'YOUR_SUPABASE_ANON_OR_PUBLISHABLE_KEY';
   }
   ```

   The app currently reads these values directly from `lib/config.dart`; it does not load them from environment variables. Never put a Supabase `service_role` or secret key in the Flutter app.

4. **Fetch dependencies** from the project root:

   ```powershell
   flutter pub get
   ```

5. **Run the app.** For Windows desktop:

   ```powershell
   flutter run -d windows
   ```

   To see the available targets, run `flutter devices`, then replace `windows` with the target device ID (for example, an attached phone or browser). Use `flutter run` to let Flutter select a connected target.

## Using the app

1. Open **Add Seller** and save at least one seller before recording a sale. An email address is optional.
2. Open **Add Perfume** to create an inventory item. Name, brand, category, and bottle size are required; starting quantity defaults to zero and reorder level defaults to five when left blank.
3. Use **Inventory** to search, filter, sort, edit perfume details, or choose **Add stock** to receive more units. Low-stock items have units at or below their reorder level.
4. Open **Sales → Sell from Inventory**, select a perfume, quantity, seller, and payment method, then confirm. Only perfumes with available units can be selected; a sale reduces inventory and creates its sales record together.
5. Search and filter the **Sales** ledger to review recorded orders and the summary cards.

## Database and security notes

The SQL setup enables row-level security but grants the `anon` role read/write access to all three tables to support this app's current no-login design. Anyone who can obtain the app's public anon key can therefore access the data under those policies. Use this configuration only in a trusted/private environment. Before exposing the app or database publicly, add authentication and replace the permissive policies with appropriately restricted policies. The anon/publishable key is not a substitute for access control.

The app requires a working internet connection and a reachable Supabase project. It does not currently provide offline storage or user sign-in.

## Development checks

Run the test suite and static analyzer from the project root:

```powershell
flutter test
flutter analyze
```

Build a Windows desktop release with:

```powershell
flutter build windows --release
```
