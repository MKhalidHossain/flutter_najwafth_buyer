---
name: API Integration
description: Book API integration details — endpoints, auth, providers, price logic
type: project
---

Backend base URL: `http://localhost:5001/api/v1` (set in `app_config.dart`).
All book routes require `Authorization: Bearer <token>` — injected automatically by the Dio interceptor in `network_providers.dart` from `buyer_access_token` in SharedPreferences.

**Book API endpoints:**
- `GET /books` — list with `search`, `category`, `page`, `limit` query params; response: `{ success, data: { books[], meta } }`
- `GET /books/:id` — single book; response: `{ success, data: { book } }`

**Key providers:**
- `booksAsyncProvider` — AsyncNotifier, fetches all books; has `search()`, `filterByCategory()`, `refresh()`
- `bookDetailProvider(id)` — FutureProvider.family, fetches single book for detail page
- `storeCatalogProvider` — sync proxy returning `booksAsyncProvider.asData?.value ?? []`; used by cart/checkout

**BookItem model** (`store_models.dart`): `coverImageAsset` is nullable; `coverImageUrl` is the network URL from API; `stock` (bool) controls Add-to-Cart; `shopName` comes from populated `shopId.name`.

**Price logic in BookDetailsPage:** blue price = `price × qty`; crossed-out = `price × 1.20 × qty` (20% markup as original price).

**Why:** `storeCatalogProvider` is kept sync so cart/checkout don't need async changes; it just reads the cached async value.
