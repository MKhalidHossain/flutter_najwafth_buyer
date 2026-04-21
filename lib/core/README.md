# Core

Reusable Flutter foundation for this project and future apps.

## What is inside

- `bootstrap`: async app setup and ProviderScope creation.
- `config`: app name, environment, API base URL, and timeout settings.
- `errors`: `Result`, `AppFailure`, and `AppException` for predictable error handling.
- `network`: Dio and `ApiClient` providers.
- `storage`: SharedPreferences-backed key-value storage.
- `providers`: common Riverpod providers such as lifecycle and theme mode.
- `theme`: app theme, spacing, radius, and breakpoint tokens.
- `extensions`: context, navigation, date formatting, and AsyncValue helpers.
- `utils`: validators, typedefs, and debouncer.
- `widgets`: reusable loading, error, gap, and AsyncValue rendering widgets.

## Copying to another project

Copy `lib/core`, add these dependencies, then call `AppBootstrap.createProviderScope`
from `main.dart`.

```yaml
dependencies:
  dio: any
  flutter_riverpod: any
  intl: any
  shared_preferences: any
```

Customize `AppConfig.development()` and `AppTheme` for each app.
