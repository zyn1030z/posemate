import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:posely_ai/core/config/constants/app_constants.dart';

part 'paginated.freezed.dart';
part 'paginated.g.dart';

/// A single page of results from a paginated list endpoint.
///
/// Wire shape (json_serializable is globally configured for snake_case field
/// renaming, so Dart camelCase fields map to snake_case keys):
///
/// ```json
/// {
///   "items": [ ... ],
///   "page": 1,
///   "page_size": 20,
///   "total_items": 137,
///   "has_more": true
/// }
/// ```
///
/// The generic item type is decoded through the `fromJsonT` callback passed
/// to `Paginated.fromJson`, matching json_serializable generic argument
/// factories.
@Freezed(genericArgumentFactories: true)
abstract class Paginated<T> with _$Paginated<T> {
  /// Creates a page of results.
  const factory Paginated({
    /// The items on this page, in server order.
    required List<T> items,

    /// One-based index of this page.
    required int page,

    /// Number of items requested per page.
    required int pageSize,

    /// Total number of items across all pages.
    required int totalItems,

    /// Whether at least one more page can be fetched after this one.
    required bool hasMore,
  }) = _Paginated<T>;

  /// Decodes a page from JSON, using `fromJsonT` to decode each item.
  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$PaginatedFromJson(json, fromJsonT);

  /// An empty first page: no items, nothing more to load.
  ///
  /// Useful as an initial value for pagination state before the first fetch.
  static Paginated<T> empty<T>() => Paginated<T>(
    // A const literal cannot be typed by a type parameter; Never upcasts.
    items: const <Never>[],
    page: 1,
    pageSize: AppConstants.defaultPageSize,
    totalItems: 0,
    hasMore: false,
  );
}
