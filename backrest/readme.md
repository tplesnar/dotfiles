# Mac Backup — restic + rclone + Backrest + SwiftBar

Automated, encrypted backups of `/Users/thierry` to Google Drive using restic as the backup engine, rclone as the Google Drive transport, Backrest as the scheduler/UI, and SwiftBar for menu bar monitoring.

---

## Overview

| Component | Role |
|-----------|------|
| **restic** | Deduplicating, encrypted backup engine |
| **rclone** | Connects restic to Google Drive |
| **Backrest** | Web UI, scheduler, retention policies |
| **SwiftBar** | Menu bar status plugin |

Backups run every 4 hours (relative to last run, using `CLOCK_LAST_RUN_TIME` — safe for laptops that sleep). The repo lives at:

```
rclone:GoogleDrive:restic-backups/0x796E-MBP14/
```

---

## Prerequisites

- macOS (Apple Silicon)
- Homebrew
- A Google Drive account with rclone configured as a remote named `GoogleDrive` — ideally using your **own** OAuth client ID to avoid rate limits (see [Google Drive rate-limit tuning](#google-drive-rate-limit-tuning))

---

## Installation

### 1. Install packages

```bash
brew bundle --file ~/.dotfiles/Brewfile
```

Or individually:

```bash
brew install restic rclone backrest swiftbar
```

### 2. Store the repo password in Keychain

```bash
security add-generic-password -a restic -s restic-backup -w 'YOUR_PASSWORD'
```

### 3. Initialise the restic repository (first time only)

```bash
restic -r rclone:GoogleDrive:restic-backups/0x796E-MBP14/ init
```

### 4. Fix Backrest's launchd PATH

Backrest runs as a daemon with a minimal PATH that doesn't include Homebrew. The plist at `~/.dotfiles/launchd/homebrew.mxcl.backrest.plist` already contains the fix (`/opt/homebrew/bin` added to `EnvironmentVariables`). Symlink and load it:

```bash
ln -sf ~/.dotfiles/launchd/homebrew.mxcl.backrest.plist \
       ~/Library/LaunchAgents/homebrew.mxcl.backrest.plist

launchctl load ~/Library/LaunchAgents/homebrew.mxcl.backrest.plist
```

> ⚠️ Never use `brew services start backrest` — it overwrites the plist and removes the PATH fix. Use `launchctl load/unload` instead.

### 5. Configure Backrest

Open [http://localhost:9898](http://localhost:9898) and:

1. Add a repo with URI `rclone:GoogleDrive:restic-backups/0x796E-MBP14/` and your password
2. Click **Index Snapshots** to import existing snapshots
3. Add a plan pointing to `/Users/thierry`
4. Apply the excludes, schedule, and retention from the section below

Alternatively, stop Backrest and write `~/.config/backrest/config.json` directly (see **Configuration** below), then reload.

### 6. Install the SwiftBar plugin

```bash
cp ~/.dotfiles/swiftbar/backrest.5m.sh \
   ~/Library/Application\ Support/SwiftBar/Plugins/
chmod +x ~/Library/Application\ Support/SwiftBar/Plugins/backrest.5m.sh
```

---

## Configuration

### Schedule & retention (plan level)

| Setting | Value |
|---------|-------|
| Backup frequency | Every 4h (`CLOCK_LAST_RUN_TIME`) |
| Hourly snapshots | 24 |
| Daily snapshots | 30 |
| Monthly snapshots | 12 |

### Maintenance (repo level)

| Policy | Schedule |
|--------|----------|
| Forget | Every 1 day after last run |
| Prune | Every 7 days after last run |
| Check | Every 30 days after last run (5% read-data subset) |

### Google Drive rate-limit tuning

Google enforces an API rate limit **per OAuth client ID**, so heavy runs — especially `prune` and `check`, not just `backup` — can hit `403 userRateLimitExceeded`. Two changes keep us under the limit.

**1. Use your own rclone OAuth client ID.** rclone's built-in client ID is shared across every rclone user worldwide, so you compete for a single global quota. Creating your own gives you a dedicated quota and usually eliminates the 403s on its own.

Create one at [console.cloud.google.com](https://console.cloud.google.com): new project → enable **Google Drive API** → configure the **OAuth consent screen** → **Credentials → Create OAuth client ID**, application type **Desktop app**. Add the id/secret to the `[GoogleDrive]` remote in `~/.config/rclone/rclone.conf`:

```ini
[GoogleDrive]
type = drive
scope = drive
client_id = <your-id>.apps.googleusercontent.com
client_secret = GOCSPX-<your-secret>
token = {"access_token":...}
team_drive =
pacer_min_sleep = 100ms
pacer_burst = 100
chunk_size = 64M
```

Then re-authorise so the token is re-minted under the new client ID:

```bash
rclone config reconnect GoogleDrive:
```

Notes:

- Inside the remote section the pacer keys use their **bare** names (`pacer_min_sleep`, `pacer_burst`) — *not* the `drive_`-prefixed CLI form. `100ms` ≈ 10 transactions/sec, the documented sweet spot for Drive.
- rclone's config format has no inline comments, so keep the values above clean.

> ⚠️ While the OAuth consent screen is in **Testing**, tokens expire after 7 days — fatal for an unattended every-4-hours backup. **Publish** the app (consent screen → Publish app) to get non-expiring tokens.

**2. Cap the request rate in Backrest.** Set these at the **repository** level (Repos → edit your repo) so they apply to backup, forget, prune, *and* check.

Environment Variables:

| Variable | Value |
|----------|-------|
| `RCLONE_TPSLIMIT` | `10` |
| `RCLONE_TPSLIMIT_BURST` | `10` |
| `RESTIC_PACK_SIZE` | `64` |

Flags (two separate entries — `-o` and its argument):

```
-o
rclone.connections=4
```

`RESTIC_PACK_SIZE=64` (MiB) makes restic write fewer, larger pack files; fewer files means fewer API calls. It applies only to newly written packs, so the benefit phases in as old packs are rewritten by `prune`.

> ℹ️ Google also caps uploads at ~750 GB/account/day. The initial backup of a large repo can stall on this independently of the 403 rate limit.

### Excludes

The following are excluded from backups:

- macOS system junk (`.DS_Store`, `.Spotlight-V100`, etc.)
- `Library/Caches`, `Library/Logs`, `Library/CloudStorage`
- `Library/Containers`, `Library/Messages`, `Library/Metadata`
- Dev artifacts (`node_modules`, `build/`, `dist/`, `__pycache__`, etc.)
- Virtual machines (`*.vmdk`, `*.iso`, etc.)
- AI model files (`.ollama`)
- Temp files (`*.tmp`, `*.lock`, `*.pid`, `.git/objects/pack`)

---

## SwiftBar plugin

The plugin at `~/.dotfiles/swiftbar/backrest.5m.sh` refreshes every 5 minutes and reads directly from Backrest's local sqlite database — no Google Drive API calls.

| Menu bar | Meaning |
|----------|---------|
| ☁️ ✅ 2h ago | Last backup succeeded |
| ☁️ ⟳ backing up... | Backup in progress |
| ☁️ ⚠️ 3h ago | Last backup had warnings |
| ☁️ ❌ 1h ago | Last backup failed |

Clicking opens a dropdown with the last 5 operations and a link to the Backrest UI.