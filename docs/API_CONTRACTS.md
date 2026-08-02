# API Contracts

> **Contract-first.** This document is the source of truth for the Posely AI backend interface. The backend is implemented separately against this contract; until each environment is live and wired, the app ships with **MockDatasources** (dev flavor, `AppConfig.useMockData = true`, data under `assets/mock/`). Client path constants live in `lib/core/config/constants/api_endpoints.dart` and must stay in sync with this file.

## Environments

| Env | REST base | WebSocket base |
| --- | --- | --- |
| dev | `https://api.dev.posely.app/v1` | `wss://realtime.dev.posely.app/v1` |
| uat | `https://api.uat.posely.app/v1` | `wss://realtime.uat.posely.app/v1` |
| prod | `https://api.posely.app/v1` | `wss://realtime.posely.app/v1` |

## Conventions

- **Versioning:** URI-versioned under `/v1` (already part of the base URL). Breaking changes bump to `/v2`.
- **Wire format:** JSON, **snake_case** keys, UTF-8. Timestamps are ISO-8601 UTC (`2026-08-02T10:15:00Z`). IDs are opaque strings (UUID).
- **Auth:** `Authorization: Bearer <access_token>` on every endpoint except those marked *public*.
- **Content:** `Content-Type: application/json` unless multipart is specified.
- **Idempotency (uploads & mutations that may be retried):** clients send `Idempotency-Key: <uuid>` on `POST /ai/extract-pose`, gallery uploads, and `POST /premium/subscribe`; the server must return the original result for a replayed key within 24 h.

### Standard error envelope

Every non-2xx response uses this shape (client maps it onto the sealed `AppException` hierarchy):

```json
{
  "error": {
    "code": "validation_failed",
    "message": "One or more fields are invalid.",
    "errors": {
      "email": ["Must be a valid email address."],
      "password": ["Must be at least 8 characters."]
    }
  }
}
```

`errors` is optional (field → messages). Representative codes: `unauthorized`, `token_expired`, `forbidden`, `not_found`, `validation_failed`, `rate_limited`, `conflict`, `payment_required`, `server_error`.

### Pagination

List endpoints take `?page=<1-based>&page_size=<default 20, max 100>` and return the `Paginated` envelope (mirrored by the client's `Paginated<T>` freezed type):

```json
{
  "items": [ { "...": "resource objects" } ],
  "page": 1,
  "page_size": 20,
  "total_items": 137,
  "has_more": true
}
```

---

## Auth

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| POST | `/auth/register` | public | Create account (email, password, display_name) |
| POST | `/auth/login` | public | Email/password sign-in |
| POST | `/auth/social-login` | public | Exchange a provider token for Posely tokens |
| POST | `/auth/refresh` | public* | Rotate tokens using a refresh token |
| POST | `/auth/logout` | bearer | Revoke the current refresh token |
| POST | `/auth/forgot-password` | public | Send a password-reset email |

`POST /auth/login` — request / 200:

```json
{ "email": "user@example.com", "password": "hunter22!" }
```

```json
{
  "access_token": "eyJ...",
  "refresh_token": "def50...",
  "expires_in": 900,
  "token_type": "Bearer",
  "user": { "id": "u_01H...", "email": "user@example.com", "display_name": "Minh", "avatar_url": null, "is_premium": false }
}
```

`POST /auth/social-login` — the app signs in with Google / Apple / Facebook natively, then exchanges the provider credential:

```json
{ "provider": "google", "id_token": "<provider id token>", "access_token": null }
```

Response: same token payload as login (creates the account on first exchange).

`POST /auth/refresh` — **rotation**: request `{ "refresh_token": "def50..." }`; response is a fresh token pair and the old refresh token is invalidated. Reuse of a rotated token revokes the whole family (client must sign out). The app's `AuthInterceptor` performs this transparently on 401 (full flow lands in Phase 3).

## Profile

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/profile/me` | Current user profile + stats |
| PATCH | `/profile/me` | Update display_name, avatar_url, preferences |

## Poses

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/poses` | Paginated library; filters: `category`, `difficulty`, `people_count`, `orientation` |
| POST | `/poses` | Create a pose template (from extraction/generation) |
| GET | `/poses/{id}` | Single pose with full keypoints |
| PATCH | `/poses/{id}` | Update own pose |
| DELETE | `/poses/{id}` | Delete own pose |
| GET | `/poses/categories` | Category taxonomy |
| GET | `/poses/trending` | Paginated trending poses |
| GET | `/poses/recommended` | Paginated personalized recommendations |
| GET | `/poses/search` | Paginated search: `q` (free text / semantic) + the filters above |

`GET /poses?page=1&page_size=20&category=portrait` — 200:

```json
{
  "items": [
    {
      "id": "pose_01HZX...",
      "title": "Window Light Lean",
      "category": "portrait",
      "difficulty": "easy",
      "people_count": 1,
      "orientation": "portrait",
      "image_url": "https://cdn.posely.app/poses/01HZX/cover.jpg",
      "thumbnail_url": "https://cdn.posely.app/poses/01HZX/thumb.jpg",
      "keypoints": [ { "name": "left_shoulder", "x": 0.41, "y": 0.32, "z": -0.05, "confidence": 0.98 } ],
      "tags": ["indoor", "natural-light"],
      "is_premium": false,
      "like_count": 1289,
      "is_liked": false,
      "is_saved": true,
      "author": { "id": "u_01H...", "display_name": "Posely" },
      "created_at": "2026-07-01T08:00:00Z"
    }
  ],
  "page": 1,
  "page_size": 20,
  "total_items": 137,
  "has_more": true
}
```

`keypoints` is the 33-landmark set (normalized 0–1 coordinates, ML Kit naming) — abbreviated above.

## AI

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/ai/generate-poses` | Submit a generation prompt → async job |
| GET | `/ai/jobs/{id}` | Poll job status / results |
| POST | `/ai/extract-pose` | Multipart photo upload → extracted pose |
| WS | `/ai/pose-score` | Realtime scoring stream (WebSocket base URL) |

`POST /ai/generate-poses` — request / 202:

```json
{ "prompt": "golden hour beach couple, candid walking", "count": 4, "style": "photo", "people_count": 2 }
```

```json
{ "job_id": "job_01J...", "status": "queued", "estimated_seconds": 20 }
```

`GET /ai/jobs/{id}` — 200 (`status`: `queued | running | succeeded | failed`):

```json
{
  "job_id": "job_01J...",
  "status": "succeeded",
  "progress": 100,
  "result": { "poses": [ { "id": "pose_01J...", "...": "pose object" } ] },
  "error": null
}
```

`POST /ai/extract-pose` — `multipart/form-data` with `image` (JPEG/PNG, ≤ 10 MB) and optional `hint` JSON part; send `Idempotency-Key`. 200 returns a pose object (keypoints + generated overlay asset URLs). 422 with the standard envelope when no person is detected (`code: "no_pose_detected"`).

### WebSocket `/ai/pose-score`

Connect to `wss://realtime.<env>.posely.app/v1/ai/pose-score?access_token=<jwt>`. JSON text frames, `type`-discriminated:

Client → server:

```json
{ "type": "session_start", "pose_id": "pose_01HZX...", "mode": "coach" }
```

```json
{
  "type": "landmarks",
  "seq": 412,
  "ts": 1754130900123,
  "landmarks": [ { "name": "left_shoulder", "x": 0.44, "y": 0.35, "z": -0.02, "confidence": 0.97 } ]
}
```

```json
{ "type": "session_end" }
```

Server → client:

```json
{
  "type": "score",
  "seq": 412,
  "score": 0.87,
  "per_joint": { "left_elbow": 0.62, "right_elbow": 0.95 },
  "coach_hint": { "code": "raise_left_arm", "message": "Raise your left arm slightly." }
}
```

```json
{ "type": "error", "error": { "code": "rate_limited", "message": "Frame rate too high." } }
```

Client throttles to ≤ 10 landmark frames/s; `seq` correlates scores to frames. On-device scoring is the always-available fallback — the WS channel is an enhancement (premium coach).

## Collections

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/collections` | Paginated user collections |
| POST | `/collections` | Create (`{ "name": "Beach shoot" }`) |
| GET | `/collections/{id}` | Collection with paginated poses |
| PATCH / DELETE | `/collections/{id}` | Rename / delete |
| PUT / DELETE | `/collections/{id}/poses/{pose_id}` | Add / remove a pose |

## Gallery

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/gallery/photos` | Paginated captured photos |
| POST | `/gallery/photos` | Multipart upload (`image` + metadata JSON part: `pose_id`, `match_score`, `captured_at`); `Idempotency-Key` required |
| GET | `/gallery/photos/{id}` | Single photo + metadata |
| DELETE | `/gallery/photos/{id}` | Delete |

## Community

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/community/feed` | Paginated feed (`filter=following\|trending\|latest`) |
| PUT / DELETE | `/community/follow/{user_id}` | Follow / unfollow |
| PUT / DELETE | `/community/poses/{pose_id}/like` | Like / unlike |
| GET / POST | `/community/poses/{pose_id}/comments` | Paginated comments / add (`{ "body": "..." }`) |

## Premium

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/premium/products` | Available subscriptions (ids match store products) |
| POST | `/premium/subscribe` | Validate a store receipt, activate entitlement |
| POST | `/premium/restore` | Re-validate and restore entitlements |

`POST /premium/subscribe` — request / 200:

```json
{
  "platform": "android",
  "product_id": "posely_pro_monthly",
  "purchase_token": "<store purchase token or ios receipt>"
}
```

```json
{
  "entitlement": {
    "tier": "pro",
    "active": true,
    "expires_at": "2026-09-02T10:15:00Z",
    "will_renew": true
  }
}
```

---

## Change management

- Additive changes (new optional fields, new endpoints) are non-breaking; clients must ignore unknown fields.
- Renames/removals/semantic changes require `/v2` or a deprecation window agreed with the app team.
- Update this file **and** `api_endpoints.dart` in the same PR whenever the contract moves.
