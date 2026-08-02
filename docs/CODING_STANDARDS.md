# Coding Standards

The analyzer is the first reviewer. Every phase must end with `flutter analyze` at zero issues — lints are not suggestions.

## Lint philosophy

`analysis_options.yaml` builds on `flutter_lints` with:

- **Strict language modes:** `strict-casts`, `strict-inference`, `strict-raw-types`. No implicit `dynamic`, no raw generics.
- **Curated rules**, notably:
  - `always_use_package_imports` — every import is `package:posely_ai/...`; relative imports are banned.
  - `require_trailing_commas` — stable formatting and minimal diffs.
  - `prefer_single_quotes`, `directives_ordering`, `sort_pub_dependencies`.
  - Correctness set: `avoid_dynamic_calls`, `unawaited_futures`, `cancel_subscriptions`, `close_sinks`.
- `invalid_annotation_target` is ignored (freezed/json_serializable constructor annotations trip it).
- Generated files (`*.g.dart`, `*.freezed.dart`) are excluded from analysis and committed.

> **Known gap:** `riverpod_lint`/`custom_lint` are temporarily absent — current `custom_lint` pins analyzer ^8 while `riverpod_generator` 4.x needs ^13. Re-add both the moment `custom_lint` supports analyzer >= 9. Until then, provider misuse is caught in review — treat the riverpod_lint rule set as policy even without tooling. Related: `freezed` resolves to `3.2.6-dev.1` (lockfile-pinned) to satisfy analyzer 12.

## Naming

| Thing | Convention | Example |
| --- | --- | --- |
| Files | `snake_case` + role suffix | `pose_list_controller.dart` |
| Classes | `PascalCase`, matches file | `PoseListController` |
| Providers | `lowerCamelCase` + `Provider` | `poseRepositoryProvider` |
| Use cases | verb-first class, single `call()` | `GetPosesUseCase` |
| DTOs vs entities | `*Model` (wire) vs `*Entity` (domain) | `PoseModel` / `PoseEntity` |
| Constants | `lowerCamelCase` in `abstract final class` holders | `ApiEndpoints.login` |
| Booleans | positive predicates | `isLoading`, `hasMore`, `enableFirebase` |

Full file-role suffixes and import rules: [FOLDER_STRUCTURE.md](FOLDER_STRUCTURE.md).

## Providers & controllers

- Providers are named `xProvider`, declared `final`, top-level in the file that owns the thing they provide.
- Core providers are **manual**; feature code may use riverpod codegen (`@riverpod`).
- Providers that require bootstrap injection (`appConfigProvider`, `localStorageProvider`, `talkerProvider`) throw `UnimplementedError` by default and are overridden on the root `ProviderScope` — never given silent fake defaults.
- **Controller pattern:** one `AsyncNotifier` per screen concern, named `<Thing>Controller`, exposing immutable state (freezed class or domain type) via `AsyncValue`.
  - `build()` loads initial state; user intents are public methods.
  - Controllers call use cases, fold `ApiResult` into `AsyncValue`, and never touch widgets, `BuildContext`, or Dio/Hive types.
  - Widgets `watch` state and `read` methods; no business logic in widgets.

## freezed / JSON conventions

- freezed 3 **abstract class** syntax:

  ```dart
  @freezed
  abstract class PoseModel with _$PoseModel {
    const factory PoseModel({
      required String id,
      @JsonKey(name: 'image_url') required String imageUrl,
      @JsonKey(name: 'created_at') required DateTime createdAt,
    }) = _PoseModel;

    factory PoseModel.fromJson(Map<String, dynamic> json) =>
        _$PoseModelFromJson(json);
  }
  ```

- **Wire format is `snake_case`**; Dart fields are `lowerCamelCase` mapped via `@JsonKey(name: ...)` (or a shared `fieldRename` build config). Never leak snake_case into Dart identifiers.
- DTOs live in `data/models/` and expose `toEntity()`; entities never have `fromJson`.
- `Paginated<T>` is the only list envelope — do not invent per-feature pagination shapes.
- Run codegen with `dart run build_runner build --delete-conflicting-outputs`.

## Documentation comments

- `///` doc comments on every public class, constructor, method, and top-level declaration — including providers (what it provides, when it is overridden).
- First sentence is a standalone summary; use `[]` references (checked by `comment_references`).
- Comment *why*, not *what*. Tag deferred work as `// PHASE-N: ...` so it is greppable against the plan.

## Tests

- Mirror `lib/` structure under `test/`; files end in `_test.dart`.
- Descriptions follow **given / when / then**:

  ```dart
  group('PoseListController', () {
    test('given warm cache, when build is called, '
        'then emits cached page without network', () async { ... });
  });
  ```

- `mocktail` for fakes; no real network/storage in unit tests. Widget tests wrap subjects in `ProviderScope(overrides: [...])`.
- Gate: `flutter test` green before any phase closes.

## Commits — Conventional Commits

```
<type>(<scope>): <imperative summary>
```

- Types: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `build`, `ci`, `chore`.
- Scope is the feature or core area: `feat(pose): add trending rail`, `fix(network): jitter retry backoff`, `docs(architecture): realtime pipeline`.
- One logical change per commit; codegen output committed with the change that caused it.

## PR checklist

- [ ] `flutter analyze` — zero issues
- [ ] `dart run build_runner build --delete-conflicting-outputs` — clean, output committed
- [ ] `flutter test` — green; new logic has tests (given/when/then)
- [ ] Layering respected: no cross-feature imports, no data types in presentation, no Flutter in domain
- [ ] Public APIs documented; deferred work tagged `PHASE-N`
- [ ] Wire models use snake_case `@JsonKey` mapping; lists use `Paginated<T>`
- [ ] Errors flow `AppException → ApiResult → AsyncValue`; no bare `try/catch` swallowing
- [ ] [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md) updated if a phase task landed
- [ ] Conventional Commit title; no stray TODOs without a phase tag
