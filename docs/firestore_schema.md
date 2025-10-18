# Skema Firestore Trainix — Kanonik v1.1.0

Dokumen ini menetapkan **struktur koleksi, bidang kanonik,** serta **catatan akses** untuk aplikasi Trainix.  
Semua **dokumen baru** wajib menggunakan **casing kanonik**; `fromJson()` menerima snake_case & camelCase untuk kompatibilitas, `toJson()` hanya menulis kanonik.

---

## 🔠 Kebijakan Casing
| Jenis Koleksi | Casing Kanonik | Contoh Bidang |
|---|---|---|
| **Koleksi utama**: `teams`, `programs`, `training_logs`, `leaderboards`, `reminders` | **snake_case** | `team_id`, `athlete_id`, `created_at` |
| **Koleksi utilitas**: `training_intensities`, `notifications`, `team_notifications`, `security_logs`, `users` | **camelCase** | `teamId`, `recordedAt`, `userId` |

> **Audit fields wajib** di semua koleksi: `created_at`, `created_by`, `updated_at`, `updated_by`.

---

## 1) `users` (level atas; camelCase)
**Bidang:**
- `id` (userId), `name`, `email`, `photoUrl?`
- `fcmToken?`, `fcmUpdatedAt?`
- `createdAt`, `updatedAt`

**Akses:** privat per pengguna (read/write oleh pemilik).

---

## 2) `teams/{teamId}` (snake_case)
**Bidang:**
- `id`, `name`, `sport_branch`, `event`, `contingent`
- `created_by`, `created_at`, `updated_by`, `updated_at`

### 2.a) `members/{memberId}` (snake_case)
- `id` (= userId), `role` (`Coach|Athlete`), `is_owner` (bool)
- `status` (`approved|pending|removed`), `is_active` (bool), `joined_at`
- `created_at/by`, `updated_at/by`

> Catatan: **Tidak ada role "CoachOwner"** — Owner = `Coach + is_owner:true`.

### 2.b) `programs/{programId}` (snake_case)
- `id`, `team_id`, `name`, `week_anchor` (Timestamp)
- `template` (Map), `categories` (List<String>), `target_days` (int)
- `created_at/by`, `updated_at/by`

### 2.c) `training_logs/{logId}` (snake_case)
- `id`, `athlete_id`, `team_id`, `program_id`
- `category`, `preset`, `data` (Map), `date` (Timestamp)
- `input_by`, `user_role` (`coach|athlete`), `score` (double)
- `notes?`, `coach_feedback?`, `is_completed` (bool), `metadata?` (Map)
- `created_at/by`, `updated_at/by`

### 2.d) `reminders/{reminderId}` (snake_case)
- `id`, `title`, `description`, `date_time` (Timestamp)
- `team_id`, `athlete_id?`, `target_date?` (Timestamp)
- `status` (`pending|completed`), `is_completed` (bool)
- `created_at/by`, `updated_at/by`

### 2.e) `leaderboards/{leaderboardId}` (snake_case)
- `id`, `team_id`, `week` (e.g. `"2025-W41"`), `athlete_id`
- `scores` `{ consistency: double, intensity: double, total: double }`
- `eligible` (bool), `breakdown?` (Map), `total` (double)
- `athlete_name?`, `athlete_photo_url?`, `last_updated` (Timestamp)
- `created_at/by`, `updated_at/by`

> **Rank tidak disimpan**; dihitung di sisi klien.

---

## 3) `training_intensities/{intensityId}` (camelCase)
- `id`, `athleteId`, `teamId`, `programId`
- `hrrPercentage`, `intensityZone` (`"Zone 1"`–`"Zone 5"`)
- `recordedAt`, `avgHeartRate?`, `maxHeartRate?`, `duration?` (menit)
- `createdAt/By`, `updatedAt/By`

---

## 4) `notifications/{notificationId}` (camelCase)
- `id`, `userId`, `title`, `body`, `data?` (Map)
- `timestamp`, `read` (bool), `readAt?`
- `createdAt/By`

---

## 5) `team_notifications/{notificationId}` (camelCase)
- `id`, `teamId`, `title`, `body`, `data?` (Map)
- `timestamp`, `createdAt/By`, `updatedAt/By`

---

## 6) `security_logs/{logId}` (camelCase)
- `id`, `userId`, `action`, `timestamp`, `metadata?` (Map)
- `createdAt/By`
- **Immutable**: tidak boleh update/hapus.

---

## Indeks Disarankan
- `teams/members`: `status`, `role`, `user_id`
- `teams/training_logs`: `athlete_id`, `date`
- `teams/leaderboards`: `team_id`, `week`
- `security_logs`: `userId`, `timestamp`

---

## Catatan Implementasi
- Service/query wajib memakai **bidang kanonik** untuk koleksinya.
- Rules menerima dual-casing pada transisi (`team_id` ↔ `teamId`) saat perlu.
- Tambah bidang → perbarui model, service, indeks, dan dokumen ini.