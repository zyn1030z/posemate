/// Build flavors supported by Posely AI.
///
/// Each flavor maps to a dedicated entrypoint (`lib/main_dev.dart`,
/// `lib/main_uat.dart`, `lib/main_prod.dart`) and a matching Android
/// product flavor / iOS scheme.
enum Flavor {
  /// Development flavor — local development against dev backend, mock data on.
  dev,

  /// User-acceptance testing flavor — staging backend, production-like config.
  uat,

  /// Production flavor — live backend, shipped to stores.
  prod;

  /// Human-readable name of this flavor, suitable for banners and about pages.
  String get label => switch (this) {
    Flavor.dev => 'Dev',
    Flavor.uat => 'UAT',
    Flavor.prod => 'Production',
  };

  /// Whether this is the development flavor.
  bool get isDev => this == Flavor.dev;

  /// Whether this is the user-acceptance testing flavor.
  bool get isUat => this == Flavor.uat;

  /// Whether this is the production flavor.
  bool get isProd => this == Flavor.prod;
}
