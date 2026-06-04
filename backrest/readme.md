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
- A Google Drive account with rclone configured as a remote named `GoogleDrive`, using your **own** OAuth client ID (see [Google Drive rate-limit tuning](#google-drive-rate-limit-tuning)). The shared default client ID is the main cause of `403` rate-limit errors.

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

### 3. Configure the rclone remote

Set up the `GoogleDrive` remote with your own OAuth client ID and the tuning shown in [Google Drive rate-limit tuning](#google-drive-rate-limit-tuning). Do this **before** the first `init` so the repo is created on your own quota.

### 4. Initialise the restic repository (first time only)

```bash
restic -r rclone:GoogleDrive:restic-backups/0x796E-MBP14/ init
```

### 5. Fix Backrest's launchd PATH

Backrest runs as a daemon with a minimal PATH that doesn't include Homebrew. The plist at `~/.dotfiles/launchd/homebrew.mxcl.backrest.plist` already contains the fix (`/opt/homebrew/bin` added to `EnvironmentVariables`). Symlink and load it:

```bash
ln -sf ~/.dotfiles/launchd/homebrew.mxcl.backrest.plist \
       ~/Library/LaunchAgents/homebrew.mxcl.backrest.plist

launchctl load ~/Library/LaunchAgents/homebrew.mxcl.backrest.plist
```

> ⚠️ Never use `brew services start backrest` — it overwrites the plist and removes the PATH fix. Use `launchctl load/unload` instead.

### 6. Grant Full Disk Access (optional)

Without Full Disk Access, macOS blocks the TCC-protected `~/Library` stores (Contacts, Calendars, Mail, Biome, call history, the TCC DB, etc.) and restic logs `operation not permitted` for each. These are non-fatal warnings — the snapshot still completes — but they mark the run ⚠️ and add churn.

**Most of these aren't worth backing up** (live, machine-specific, often-locked system databases; Contacts/Calendars already live in iCloud), so the supported, reliable fix is simply to **exclude them** — see the *macOS TCC-protected system stores* block in [Excludes](#excludes). With that block in place you can skip this step entirely.

Only grant FDA if you specifically want a protected store captured (realistically just `MobileSync`, i.e. local iOS device backups). If so:

1. **Grant FDA to `backrest`, not just `restic`.** The read chain is launchd → backrest → restic, and macOS attributes TCC to the *responsible* process — the one launchd started (`backrest`) — so a grant on `restic` alone is ignored. backrest is the one that matters; restic inherits it as a child.

   ```bash
   readlink -f "$(which backrest)"   # resolve the real Cellar path
   ```
   In **System Settings → Privacy & Security → Full Disk Access**, click **`+`**, press **⌘⇧G**, paste that path, add it, and enable the toggle.

2. **Restart the agent** — toggling FDA does nothing until the process relaunches:
   ```bash
   launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.backrest.plist
   launchctl load   ~/Library/LaunchAgents/homebrew.mxcl.backrest.plist
   ```
   A full reboot sometimes forces TCC to pick it up.

> ⚠️ FDA for a launchd-launched CLI is **unreliable on current macOS** (reported as not working at all on 26.x). If backrest + reload + reboot doesn't clear the errors, don't fight it — use the exclude block instead. Also note a `brew upgrade` changes the resolved Cellar path and silently breaks any grant, requiring a re-add.

### 7. Configure Backrest

Open [http://localhost:9898](http://localhost:9898) and:

1. Add a repo with URI `rclone:GoogleDrive:restic-backups/0x796E-MBP14/` and your password
2. Click **Index Snapshots** to import existing snapshots
3. Add a plan pointing to `/Users/thierry`
4. Apply the repo settings, plan settings, excludes, schedule, and retention from the **Configuration** section below

Alternatively, stop Backrest and write `~/.config/backrest/config.json` directly, then reload.

### 8. Install the SwiftBar plugin

```bash
cp ~/.dotfiles/swiftbar/backrest.5m.sh \
   ~/Library/Application\ Support/SwiftBar/Plugins/
chmod +x ~/Library/Application\ Support/SwiftBar/Plugins/backrest.5m.sh
```

---

## Configuration

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

- Inside the remote section the pacer keys use their **bare** names (`pacer_min_sleep`, `pacer_burst`) — *not* the `drive_`-prefixed CLI form. `100ms` ≈ 10 transactions/sec, the documented sweet spot for Drive. Raise to `200ms` only if 403s persist.
- rclone's config format has no inline comments, so keep the values above clean.

> ⚠️ While the OAuth consent screen is in **Testing**, tokens expire after 7 days — fatal for an unattended every-4-hours backup. **Publish** the app (consent screen → Publish app) to get non-expiring tokens.

**2. Cap the request rate in Backrest.** Set these at the **repository** level (Repos → edit your repo) so they apply to backup, forget, prune, *and* check alike.

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

`RESTIC_PACK_SIZE=64` (MiB) makes restic write fewer, larger pack files; fewer files means fewer API calls. It applies only to newly written packs, so the benefit phases in as old packs are rewritten by `prune`. If 403s persist, lower `rclone.connections` to `2`.

> ℹ️ Google also caps uploads at ~750 GB/account/day. The initial backup of a large repo can stall on this independently of the 403 rate limit.

### Schedule & retention (plan level)

| Setting | Value |
|---------|-------|
| Backup frequency | Every 4h (`CLOCK_LAST_RUN_TIME`) |
| Hourly snapshots | 24 |
| Daily snapshots | 30 |
| Monthly snapshots | 12 |

**Plan-level backup flags** (valid only for `backup`, so keep them on the plan — *not* in the repo-level flags, where `forget`/`prune`/`check` would reject them):

```
--one-file-system
```

`--one-file-system` stops restic wandering into anything mounted under the home folder (a mounted disk image, network share, etc.).

### Maintenance (repo level)

| Policy | Schedule |
|--------|----------|
| Forget | Every 1 day after last run |
| Prune | Every 7 days after last run |
| Check | Every 30 days after last run (5% read-data subset) |

### Excludes

restic matches patterns against a file's **full path** on complete path components; a leading `/` anchors to the **filesystem root** (not the backup root), so user-folder directories are listed with their full `/Users/thierry/...` path, while bare names (no slash) match anywhere.

Paste the following into the plan's **Excludes** field (one per line):

```
# macOS system junk (match anywhere)
.DS_Store
.Spotlight-V100
.Trashes
.fseventsd
.DocumentRevisions-V100
.TemporaryItems

# Dev artifacts (match anywhere)
node_modules
__pycache__
.venv
build
dist
**/.git/objects/pack

# Temp / lock files (match anywhere)
*.tmp
*.lock
*.pid
*.swp

# Disk images & VM disks (match anywhere)
*.dmg
*.sparseimage
*.sparsebundle
*.vmdk
*.iso

# Caches, logs, cloud mounts, app containers (anchored, full path)
/Users/thierry/.Trash
/Users/thierry/.orbstack
/Users/thierry/.ollama
/Users/thierry/Library/Caches
/Users/thierry/Library/Logs
/Users/thierry/Library/CloudStorage
/Users/thierry/Library/Containers
/Users/thierry/Library/Messages
/Users/thierry/Library/Metadata
/Users/thierry/Library/Application Support/Claude/vm_bundles
/Users/thierry/Library/Application Support/Google/Chrome/OptGuideOnDeviceModel
/Users/thierry/Library/Application Support/OneDrive
/Users/thierry/Library/Application Support/Spark Mail/core-data

# macOS TCC-protected system stores (require Full Disk Access; not worth backing up)
/Users/thierry/Library/Accounts
/Users/thierry/Library/AppleMediaServices
/Users/thierry/Library/Assistant
/Users/thierry/Library/Autosave Information
/Users/thierry/Library/Biome
/Users/thierry/Library/Calendars
/Users/thierry/Library/ContainerManager
/Users/thierry/Library/Cookies
/Users/thierry/Library/CoreFollowUp
/Users/thierry/Library/HomeKit
/Users/thierry/Library/IdentityServices
/Users/thierry/Library/Mail
/Users/thierry/Library/Sharing
/Users/thierry/Library/Suggestions
/Users/thierry/Library/Application Support/AddressBook
/Users/thierry/Library/Application Support/CallHistoryDB
/Users/thierry/Library/Application Support/CallHistoryTransactions
/Users/thierry/Library/Application Support/CloudDocs
/Users/thierry/Library/Application Support/DifferentialPrivacy
/Users/thierry/Library/Application Support/FaceTime
/Users/thierry/Library/Application Support/FileProvider
/Users/thierry/Library/Application Support/Knowledge
/Users/thierry/Library/Application Support/com.apple.TCC
/Users/thierry/Library/Application Support/com.apple.avfoundation
/Users/thierry/Library/Application Support/com.apple.sharedfilelist
/Users/thierry/Library/Group Containers/group.com.apple.secure-control-center-preferences

# Optional — large, re-downloadable (uncomment to exclude)
# /Users/thierry/Downloads/Transmission

# Local iOS device backups — LARGE. Exclude unless you want them captured
# (the one TCC-protected store with real restore value; needs FDA to read).
# /Users/thierry/Library/Application Support/MobileSync
```

Why these matter (discovered by auditing apparent file sizes — see [Troubleshooting](#backup-total-is-far-larger-than-the-disk)):

- **`.orbstack`** holds an 8 TiB *sparse* VM disk image (`data.img`) plus `swap.img`. It reports 8 TiB but uses only a few GB on disk; restic still tries to read the full logical size. This single exclude is the difference between an ~8 TiB and a sane backup total.
- **`Library/CloudStorage`** (OneDrive/Dropbox/Google Drive file-provider mounts) contains cloud-only placeholder files — already protected by their provider, and a frequent source of read errors.
- The **VM disks, model weights, mail/list caches** are large and fully reproducible.
- The **TCC-protected stores** (Contacts, Calendars, Mail, Biome, call history, cookies, the TCC DB…) are live, machine-specific system databases that need Full Disk Access to read and aren't useful to restore — Contacts/Calendars already live in iCloud. Excluding them clears the `operation not permitted` warnings instead of fighting TCC (see [Installation step 6](#6-grant-full-disk-access-optional)). The lone exception is `MobileSync` (local iOS backups), left commented above.

> ℹ️ **iCloud Drive is *not* excluded here.** Your `~/Documents` and `~/Desktop` are managed by iCloud's *Desktop & Documents* sync and contain irreplaceable files you *do* want backed up. See the cloud-only files note in Troubleshooting for how to keep them readable.

---

## SwiftBar plugin

The plugin at `~/.dotfiles/swiftbar/backrest.5m.sh` refreshes every 5 minutes and reads directly from Backrest's local sqlite database — no Google Drive API calls.

| Menu bar | Meaning |
|----------|---------|
| ☁️ ✅ 2h ago | Last backup succeeded |
| ☁️ ⟳ backing up... | Backup in progress |
| ☁️ ⚠️ 3h ago | Last backup had warnings (e.g. skipped/unreadable files) |
| ☁️ ❌ 1h ago | Last backup failed |

Clicking opens a dropdown with the last 5 operations and a link to the Backrest UI.

> ⚠️ A ⚠️ (warnings) state often means files were **skipped** — they are *not* in the snapshot. Don't treat warnings as harmless; see Troubleshooting.

---

## Troubleshooting

### Backup total is far larger than the disk

restic's progress "Total" is the sum of each file's **apparent (logical) size**, not on-disk usage and not bytes uploaded. On macOS this can hugely exceed physical capacity because of:

- **Sparse files** — VM/disk images (OrbStack, Docker, UTM, `.sparseimage`) report a big logical size but occupy little disk. restic reads them in full.
- **Dataless / cloud-only files** — iCloud "Optimize Mac Storage" and online-only OneDrive/Dropbox files report full size with zero local bytes.

Find the culprits by apparent size:

```bash
find /Users/thierry -type f -size +1G 2>/dev/null \
  -exec stat -f '%z %N' {} + | sort -rn | head -40
```

Compare logical vs on-disk size to confirm a file is sparse/dataless:

```bash
ls -lhO "/path/to/file"   # logical size + flags (look for "dataless")
du -h    "/path/to/file"   # actual disk used
```

Fix: add the offenders to the [Excludes](#excludes) (the `.orbstack` 8 TiB image was the big one here), plus `--one-file-system` at the plan level.

### "resource deadlock avoided" errors

These are **cloud-only (dataless) files** that restic can't read because no bytes are local — macOS returns `EDEADLK`. Confirm with the `dataless` flag:

```bash
ls -lO ~/Documents/Administration/<some>.pdf
# -rw-r--r--@ ... compressed,dataless ...   ← online-only, skipped by restic
```

Affected files are **silently omitted from the snapshot**. For irreplaceable content (e.g. `~/Documents/Administration`), force it local so restic can read it:

```bash
# Finder: right-click the folder → Download Now / Keep Downloaded, or:
find ~/Documents/Administration -type f -exec brctl download {} \;
```

For a *durable* fix on iCloud-managed folders, either turn off **Optimize Mac Storage** (System Settings → Apple Account → iCloud) so files stay local, or mark the must-keep folders **Keep Downloaded** — otherwise macOS can re-evict them and they'll drop out of future snapshots. Cloud folders you *don't* need a second copy of (e.g. `Library/CloudStorage`) should instead be excluded.

### "operation not permitted" on ~/Library paths

These are TCC-protected system stores (`Library/Accounts`, `Library/Biome`, `Library/Application Support/AddressBook`, the TCC DB, etc.) plus `.Trash`. restic can't read them without Full Disk Access, so it logs `operation not permitted` and skips them — non-fatal, but the run shows ⚠️.

Recommended fix: leave them excluded (the *TCC-protected system stores* block in [Excludes](#excludes), and `.Trash`). They're churny, machine-specific, and mostly duplicated in iCloud.

If you instead want them captured, grant Full Disk Access to **`backrest`** — not just `restic`. The read chain is launchd → backrest → restic, and TCC attributes access to the responsible process (the one launchd started), so a grant on `restic` alone is ignored. See [Installation step 6](#6-grant-full-disk-access-optional) — and note FDA for a launchd CLI is unreliable on current macOS, so excluding is the dependable path.

### Verify important files actually made it into the repo

After fixing excludes / cloud-only files, confirm a known file is present:

```bash
restic -r rclone:GoogleDrive:restic-backups/0x796E-MBP14/ find "Vigselintyg.pdf"
```

If it lists a snapshot, the file is in the backup. Re-check after the next run that the deadlock errors for `Administration` are gone.

### Errors persist for a path that's already excluded

restic only emits per-file errors *inside* a directory if it descended into it — which means the exclude isn't live yet. Editing `config.json` by hand, or saving a plan, only takes effect after Backrest reloads (and a run that started before the save still uses the old config). Confirm the pattern is actually applied:

```bash
restic -r rclone:GoogleDrive:restic-backups/0x796E-MBP14/ backup /Users/thierry \
  --dry-run -v \
  --exclude "/Users/thierry/Library/Application Support/FileProvider" 2>&1 \
  | grep -c FileProvider
```

`0` means the tree is being skipped. If it's non-zero, the pattern genuinely isn't matching — the usual culprit is a path with spaces (e.g. `Application Support`) being split into separate arguments by however it was entered.

> ℹ️ `Library/Application Support/FileProvider` is the File Provider engine's internal sync staging area (`wharf`, `tombstone`, `delete` housekeeping) — dataless/locked scratch files, **not** your actual synced content (which lives in `~/Documents`, `~/Desktop`, `~/Library/CloudStorage`). Safe to exclude; it's already in the block above.

### Backups still hitting 403 rate limits

In order of effectiveness: confirm you're on your **own** client ID (`rclone config show GoogleDrive`), lower `rclone.connections` to `2`, raise `pacer_min_sleep` to `200ms`, and make sure the rate-limit env vars are at the **repo** level so prune/check are covered too.