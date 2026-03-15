# 24 Competition – CRM / Admin: What You Can Show

This list is derived from the current app data model (Firestore collections and `ChallengeService` / `WalletService`). Use it to design an **admin CRM** or **admin dashboard** for 24 Competition.

---

## 1. **Competitions** (main 24 competitions)

| What to show (admin CRM) | Firestore source | Notes |
|--------------------------|------------------|--------|
| List of all competitions | `competitions` | Filter by `status`: UPCOMING, LIVE, COMPLETED |
| Title, subtitle, description | `competitions` | `title`, `subtitle`, `description` |
| Sport type | `competitions` | `sport_type` (e.g. Running, Cycling) |
| Status | `competitions` | `status`: UPCOMING / LIVE / COMPLETED |
| Start & end dates | `competitions` | `start_at`, `end_at` (Timestamps) |
| Entry fee (points) | `competitions` | `entry_fee` |
| Participant cap | `competitions` | `participant_cap` |
| Current participants count | `competitions` | `current_participants` |
| Interested count | `competitions` | `interested_count` (notification signups) |
| Location, distance (km) | `competitions` | `location`, `distance_km` |
| Rules & terms | `competitions` | `rules`, `terms` |
| Banner / map images | `competitions` | `bg_image`, `map_image` |
| Prize structure | `competitions` | `prize_pool` (1st, 2nd, 3rd labels and values) |
| Created at | `competitions` | `created_at` |
| **Per-competition leaderboard** | `{title_slug}_24_competition` | Enrollment collection per competition; docs have `user_id`, `display_name`, `score`, `joined_at`, `final_rank`, `points_earned` |

**Admin actions (CRM):** Create / edit / cancel competition, change status (UPCOMING → LIVE → COMPLETED), view participants and export list.

---

## 2. **Competition participants & enrollments**

| What to show (admin CRM) | Firestore source | Notes |
|--------------------------|------------------|--------|
| Who joined a competition | `{title_slug}_24_competition` (per competition) | One doc per user: `user_id`, `display_name`, `avatar_url`, `gender`, `joined_at`, `score`, `time_elapsed`, `final_rank`, `points_earned` |
| Join count per competition | `competitions.current_participants` | Already on competition doc |
| List of user IDs per competition | Same enrollment collection | Use for “export participants” or “contact participants” in CRM |

**Admin actions:** View participants, remove participant (and refund if needed), export CSV for email/SMS.

---

## 3. **Competition notifications (interested users)**

| What to show (admin CRM) | Firestore source | Notes |
|--------------------------|------------------|--------|
| Users interested in a competition | `competition_notifications` | Docs: `competition_id`, `user_id`, `created_at` |
| Count of “notify me” signups | `competitions.interested_count` | Denormalized on competition doc |

**Admin actions:** See who to notify when competition goes live; export list for push/email.

---

## 4. **Challenge rooms** (Private Zone / Adventure-style rooms)

| What to show (admin CRM) | Firestore source | Notes |
|--------------------------|------------------|--------|
| List of all rooms | `challenge_rooms` | With filters: `visibility` (OPEN / INVITE), `status` (LOBBY, ACTIVE, ENDED) |
| Room name, rules, entry fee | `challenge_rooms` | From create-room payload (e.g. `name`, `rules`, `entry_fee`) |
| Admin / creator | `challenge_rooms` | `admin_display_name`, `admin_avatar_url`; creator = first participant |
| Max participants & current count | `challenge_rooms` | `max_participants`, `current_participants` |
| Started / ended time | `challenge_rooms` | `started_at`, `ended_at`, `created_at` |
| Room participants | `challenge_rooms/{roomId}/participants` | `user_id`, `display_name`, `avatar_url`, `joined_at`, `rank`, `calories`, `duration`, `heart_rate`, `distance`, `pace`, `points_earned`, `final_rank` |
| Pending join requests (locked rooms) | `challenge_rooms/{roomId}/join_requests` | `user_id`, `display_name`, `avatar_url`, `status` (PENDING), `requested_at`, `resolved_at`, `fee_charged` |
| Room chat / messages | `challenge_rooms/{roomId}/messages` | For moderation: `sent_at`, sender, body (if stored) |

**Admin actions:** List all rooms, close/archive room, view participants and join requests, moderate messages, ban user from room if needed.

---

## 5. **Global leaderboard**

| What to show (admin CRM) | Firestore source | Notes |
|--------------------------|------------------|--------|
| Top users by sport | `global_leaderboard` | Query by `sport_type`; fields e.g. `total_points`, user id/name (depending on schema) |
| Rank, points, sport | `global_leaderboard` | Used for “Top 10” in app; admin can show full list and trends |

**Admin actions:** View/export leaderboard, detect abuse (e.g. impossible scores), reset or adjust points if needed.

---

## 6. **Users & wallet (for CRM)**

| What to show (admin CRM) | Firestore source | Notes |
|--------------------------|------------------|--------|
| User balance (points) | `users/{userId}` | Field: `points` |
| Transaction history | `users/{userId}/wallet_transactions` | `amount` (negative for deductions), `reason` (e.g. `competition_join`, `room_join`), `timestamp` |
| Profile (name, avatar) | App profile / Firestore profile doc | For display in CRM tables (join with `user_id` from enrollments/rooms) |

**Admin actions:** View balance and history, add/refund points (e.g. after support resolution), block user.

---

## 7. **Sponsor requests**

| What to show (admin CRM) | Firestore source | Notes |
|--------------------------|------------------|--------|
| Pending sponsor requests | `sponsor_requests` | `status`: PENDING; plus submitted data (company, contact, etc.), `submitted_at` |

**Admin actions:** List PENDING, approve/reject, mark as contacted, add notes.

---

## 8. **App config (feature locks)**

| What to show (admin CRM) | Firestore source | Notes |
|--------------------------|------------------|--------|
| Challenge feature locks | `app_config/challenge_locks` | `private_zone_locked`, `ai_challenge_locked`, `adventure_zone_locked` (booleans) |

**Admin actions:** Toggle locks (e.g. open/close Private Zone, AI Challenge, Adventure Zone) without app release.

---

## Suggested CRM dashboard sections for admin

1. **Competitions** – Table: title, status, sport, start/end, entry fee, capacity, current participants, interested count; actions: View, Edit, View participants, Export.
2. **Participants** – Drill-down from competition or room: user id, name, avatar, joined at, score/rank, points earned; Export CSV.
3. **Rooms** – Table: name, visibility, status, creator, current/max participants, created at; actions: View, View participants, View join requests, Close room.
4. **Join requests** – List pending by room; Approve / Reject.
5. **Users & wallet** – Search by user id/name; show points balance and transaction history; Add/refund points.
6. **Leaderboard** – Global leaderboard by sport; optional: export, flag suspicious.
7. **Sponsor requests** – List PENDING; Approve, Reject, Mark contacted.
8. **Config** – Challenge locks toggles.

---

## Firestore collections summary

| Collection (or path) | Purpose |
|----------------------|--------|
| `competitions` | Main 24 competitions (title, dates, fee, status, counts) |
| `{title_slug}_24_competition` | Per-competition enrollments (participants + scores) |
| `competition_notifications` | “Notify me” signups per competition |
| `challenge_rooms` | Private/Adventure rooms (metadata) |
| `challenge_rooms/{id}/participants` | Room members and their stats |
| `challenge_rooms/{id}/join_requests` | Pending join requests for locked rooms |
| `challenge_rooms/{id}/messages` | Room chat (for moderation) |
| `global_leaderboard` | Top users by sport |
| `users/{userId}` | User profile + `points` balance |
| `users/{userId}/wallet_transactions` | Deductions (and credits if you add them) |
| `sponsor_requests` | Sponsor request submissions |
| `app_config/challenge_locks` | Feature flags for challenge zones |

Use this list to define admin-only screens or an external CRM that reads/writes the same Firestore (with proper security rules for admin role).
