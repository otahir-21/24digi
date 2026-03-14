# Firestore Data Setup — Challenge Module

To ensure the Challenge Module (Competitions, Global Leaderboard, and Zone Locks) works correctly, you need to set up specific collections and documents in Firestore.

## 1. App Configuration (Locks)
This controls which zones are entryable from the Challenge Dashboard.

**Collection:** `app_config`  
**Document ID:** `challenge_locks`

| Field Name | Type | Description |
|---|---|---|
| `private_zone_locked` | Boolean | True to show a lock icon and prevent entry. |
| `ai_challenge_locked` | Boolean | True to lock AI Challenge Zone. |
| `adventure_zone_locked` | Boolean | True to lock Adventure Zone. |

---

## 2. Global Leaderboard
This displays the "Top #10" users on the Challenge Dashboard.

**Collection:** `global_leaderboard`  
**Document ID:** Auto-generated (one per user/entry)

| Field Name | Type | Description |
|---|---|---|
| `display_name` | String | User's name (e.g., "Maryam"). |
| `avatar_url` | String | URL to user avatar or asset path. |
| `total_points` | Number | Used for ranking (Descending). |
| `sport_type` | String | "All", "Walking", "Running", "Cycling", etc. |

---

## 3. Competitions
This drives the "24 Competition" list and detail screens.

**Collection:** `competitions`  
**Document ID:** Auto-generated

| Field Name | Type | Description |
|---|---|---|
| `title` | String | Name of the competition. |
| `status` | String | `ACTIVE`, `UPCOMING`, or `COMPLETED`. |
| `sport_type` | String | e.g. `Running`, `Cycling`. |
| `location` | String | Location text. |
| `distance` | String | e.g. `5 KM`. |
| `entry_fee` | Number | Points required to join. |
| `objective` | String | Long text describing the goal. |
| `bg_image` | String | URL or asset path for the header image. |
| `start_at` | Timestamp | Start date/time. |
| `end_at` | Timestamp | End date/time. |
| `current_participants`| Number | Counter of joined users. |
| `participant_cap` | Number | Max allowed users. |

---

## Data Seeding Script (Python)
If you have the `firebase-admin` SDK set up, you can run this script to populate your database with demo data.

```python
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timedelta

# Initialize with your service account key
cred = credentials.Certificate('path/to/serviceAccountKey.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

def seed_data():
    # 1. Setup Locks
    db.collection('app_config').document('challenge_locks').set({
        'private_zone_locked': False,
        'ai_challenge_locked': True,
        'adventure_zone_locked': True
    })

    # 2. Setup Global Leaderboard
    users = [
        {"display_name": "Maryam", "total_points": 2500, "sport_type": "All", "avatar_url": "assets/fonts/female.png"},
        {"display_name": "Essa", "total_points": 2100, "sport_type": "All", "avatar_url": "assets/fonts/male.png"},
        {"display_name": "Khalfan", "total_points": 1850, "sport_type": "All", "avatar_url": "assets/fonts/male.png"},
    ]
    for u in users:
        db.collection('global_leaderboard').add(u)

    # 3. Setup Competitions
    comps = [
        {
            "title": "Red Bull Urban Run 2026",
            "status": "ACTIVE",
            "sport_type": "Running",
            "location": "Dubai Marina",
            "distance": "5 KM",
            "entry_fee": 500,
            "objective": "Complete the 5KM circuit within the marina in under 25 minutes.",
            "bg_image": "assets/challenge/challenge_24_main_1.png",
            "start_at": datetime.now(),
            "end_at": datetime.now() + timedelta(days=7),
            "current_participants": 1240,
            "participant_cap": 5000
        },
        {
            "title": "Highland Cycle Championship",
            "status": "UPCOMING",
            "sport_type": "Cycling",
            "location": "Hatta Mountains",
            "distance": "42 KM",
            "entry_fee": 750,
            "objective": "A grueling mountain bike trek across the Hatta peaks.",
            "bg_image": "assets/challenge/challenge_24_main_4.png",
            "start_at": datetime.now() + timedelta(days=2),
            "end_at": datetime.now() + timedelta(days=9),
            "current_participants": 850,
            "participant_cap": 2000
        }
    ]
    for c in comps:
        db.collection('competitions').add(c)

    print("Success: Firestore seeded!")

if __name__ == "__main__":
    seed_data()
```
