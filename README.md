# HOSS Need for Speed Race Capture

Version 1.22 is a read-only Windows scanner for Need for Speed: High Stakes, Need for Speed III: Hot Pursuit, and Hot Pursuit 2. It never writes to game memory.

## How to use it

1. Keep `NFSRaceCapture.exe` and `HSRaceCapture.config.json` together in a writable folder.
2. Start Race Capture, open **Config**, and select each installed game's executable (`nfs4.exe`, `nfs3.exe`, or the HP2 executable).
3. Save. Use the game launch buttons on the Capture tab.
4. Enable **Capture AI Racers** to retain the complete AI roster.
5. Enable **Race Capture Diag** only for memory calibration; its logs can become very large.
6. Complete the race while Race Capture remains open through the results screen.
7. Review the activity log and the game-specific history directory.

**Local Only** disables payloads, uploads, and High Stakes installation approval checks while preserving local CSV history. Executable discovery is bound to the configured path; another same-named executable is ignored.

## Registering the scanner API — coming soon

Automated registration is not deployed yet. When available, use **Open Scanner Registration**, associate the scanner with a HOSS persona, and save the issued key in Config. The key is stored in `hs-race-api.key`, not JSON. Uploads are event-driven; failed items wait for the next race or **Send Queued Races Now**.

Website locations are independently overrideable in `HSRaceCapture.config.json` so site moves do not require a rebuild:

```json
{
  "apiUrl": "https://www.hoovtech.net/HOSS/API/hoss-race-ingest.php",
  "registrationUrl": "https://www.hoovtech.net/HOSS/API/hoss-scanner-register.php",
  "vivValidateUrl": "https://www.hoovtech.net/HOSS/API/hoss-viv-validate.php"
}
```

Restart after manual JSON edits. NFS3 and HP2 must not use the High Stakes ingest endpoint until dedicated endpoints exist.

## Files and game support

- `HS-RaceHistory/`: High Stakes history, encrypted queue/archive, and upload receipts.
- `NFS3HP-RaceHistory/NFS3HP-races.csv`: NFS3 player and optional AI results.
- `HS-RaceProbe-Logs/`, `NFS3HP-RaceProbe-Logs/`: optional calibration evidence.
- `NFS3HP_DATABASE_MODULE.sql`: idempotent MySQL/MariaDB NFS3 schema and lookup data.

### High Stakes

Captures humans, AI, police, lap timing, speeds, settings, upgrades, tickets, and supported series data. Protected installation files are hashed at startup and before result handoff. Use **ignore slots 1–7** for Career mode and disable it for TCP/IP multiplayer. Tournament round progression remains unconfirmed; Knockout counters are not used for it.

### NFS III: Hot Pursuit

Captures the selected configuration and up to eight roster slots. AI capture includes names, cars, positions, lap/total timing, per-lap speeds, and `TicketsReceived`/`TicketsIssued`. Older CSV files containing the former misspelling are migrated automatically.

### Hot Pursuit 2

The initial 2.42 scanner discovers the relocated ASAC region and reports live track, direction, laps, result signal, names, timing, and positions. Persistent history/API upload is not implemented.

## NFS3 database module

Import `NFS3HP_DATABASE_MODULE.sql`. It uses the `NFS3_` prefix and creates/seeds Cars, Classes, Difficulties, Tracks, and Race Modes, then creates Tournaments, Races, Results, and Annual Ratings. The eight lap times and eight lap top speeds are stored directly on `NFS3_Results`, matching the capture CSV without a separate lap table. Tournament definitions are intentionally left for confirmed data.

```powershell
mysql -u USER -p DATABASE < NFS3HP_DATABASE_MODULE.sql
```

## Build

```powershell
$env:GOCACHE = Join-Path $env:TEMP 'hoss-go-build-cache'
$env:GO111MODULE = 'off'
go test main-v1.21.go hp2_windows.go nfs3_windows.go ui_windows-v1.21.go main_test.go
go build -trimpath -ldflags='-s -w -H=windowsgui' -o NFSRaceCapture.exe main-v1.21.go hp2_windows.go nfs3_windows.go ui_windows-v1.21.go
```

## Memory mappings

Mappings apply to tested builds. Integers are little-endian.

### High Stakes (`nfs4.exe`)

| Address | Type | Meaning |
|---|---:|---|
| `0x007432D0` | UInt8 | Local slot |
| `0x00743290` | UInt32 | Track ID |
| `0x007C4CEC`, `0x00743298` | UInt32 | Configured laps; copies must agree |
| `0x007C4C9C` | UInt32 | Collision raw setting |
| `0x007C4D14` | UInt32 | Family: 0 single/HP, 1 Tournament, 2 Knockout |
| `0x007C4D10` | UInt32 | Difficulty: 0 Amateur, 1 Pro, 2 Champion |
| `0x007432F0`, `0x00743300` | UInt32 | Knockout remaining/companion |
| `0x007C4CF0` | UInt8 | Direction: 0 forward, nonzero backward |
| `0x007C4CF4`, `0x007C4CF8`, `0x007C4CFC` | UInt32 | Mirror, night, weather |
| `0x007C4CB4`, `0x007C4CB8`, `0x007C4CBC` | UInt32 | Braking, recovery, traction |
| `0x007C4CC0` | UInt32 | Damage: 0 on, 1 visual, 2 physical, 3 off |
| `0x007C4D0C`, `0x007C4D84` | UInt32 | Traffic, transmission |

Result slot bases: `0x00661FB8`, `0x00662A8C`, `0x00663560`, `0x00664034`, `0x00664B08`, `0x006655DC`, `0x006660B0`, `0x00666B84`; stride `0xAD4`.

| Relative offset | Type | Meaning |
|---|---:|---|
| `-0x44` | ASCII | Car code |
| `+0x0C` | UInt32 | Completed laps |
| `+0x10` | UInt16 | Total ticks (64/second) |
| `+0x18 + 4*n` | UInt16 | Lap ticks |
| `+0x7C` | Float32 | Top speed m/s |
| `+0x84` | UInt8 | Position |
| `+0x94` | UInt32 | Tickets issued |
| `-0x21B` | UInt8 pulse | Ticket received |

Player-name table base `0x007C4D64`, stride `0x70`. Upgrade level is UInt8 at the active entry `+0x18` (0 stock; 1–3 upgraded).

### NFS III: Hot Pursuit (`nfs3.exe`)

| Module offset | Absolute | Type | Meaning |
|---|---:|---:|---|
| `+171238` | `0x00571238` | UInt32 | In-race direction: 7 forward, 5 backward |
| `+159260` | `0x00559260` | UInt32 | Race-mode mirror |
| `+15925C` | `0x0055925C` | UInt32 | Opponent-car mirror |
| `+1E13E8` | `0x005E13E8` | UInt32 | Slot 0 tickets received |
| `+2FD2BC` | `0x006FD2BC` | UInt32 | Selected car ID 0–21 |
| `+2FD2D4` | `0x006FD2D4` | UInt32 | Transmission: 0 manual, 1 automatic |
| `+2FD3B8` | `0x006FD3B8` | UInt32 | Mode: 0 Single, 1 Tournament, 2 Knockout, 3 HP |
| `+2FD470` | `0x006FD470` | UInt32 | Difficulty: 0 Beginner, 1 Expert |
| `+2FD474` | `0x006FD474` | UInt32 | Braking assist |
| `+2FD47C` | `0x006FD47C` | UInt32 | Best line |
| `+2FD480` | `0x006FD480` | UInt32 | Navigator |
| `+2FD484` | `0x006FD484` | UInt32 | Collision recovery |
| `+2FD488` | `0x006FD488` | UInt32 | Traction |
| `+2FD48C` | `0x006FD48C` | UInt32 | Pursuit assistance |
| `+2FD4AC` | `0x006FD4AC` | UInt32 | Track ID 0–8 |
| `+2FD4B4` | `0x006FD4B4` | UInt32 | Laps |
| `+2FD4C0` | `0x006FD4C0` | UInt32 | Direction: 0 forward, 1 backward |
| `+2FD4C4`–`+2FD4CC` | `0x006FD4C4`–`0x006FD4CC` | UInt32 | Mirror, night, weather |
| `+2FD4D0` | `0x006FD4D0` | UInt32 | Opponents: 0 none, 1 one, 2 grid |
| `+2FD4D4` | `0x006FD4D4` | UInt32 | Opponent car/class 0–22 |
| `+2FD4E8` | `0x006FD4E8` | UInt32 | Traffic: 0 on, 1 off |
| `+2FD4F0` | `0x006FD4F0` | UInt32 | Skill: 0 normal, 1 aggressive |

Result base `0x006649D8`, stride `0x9AC`; AI-name base `0x0067AADC`, stride `0x6C`. Result offsets: car code `-0x44`, laps `+0x18+4*n`, lap top speeds `+0x70+4*n`, position `+0x94`. Tickets received are `0x005E13E8 + slot*0x9AC`; the adjacent UInt32 at `+4` is tickets issued.

Track IDs: 0 Hometown, 1 Redrock Ridge, 2 Atlantica, 3 Rocky Pass, 4 Country Woods, 5 Lost Canyons, 6 Aquatica, 7 Summit, 8 Empire City.

### Hot Pursuit 2 (2.42)

After relocated ASAC discovery, `ServerValors = Valors + 0x24` and player stride is `0x3DC`.

| Dynamic address | Type | Meaning |
|---|---:|---|
| `ServerValors - 0x1FEED` | UInt8 | Track ID 0–11 |
| `ServerValors - 0x1FEE9` | UInt8 | Direction ID |
| `ServerValors - 0x1FEE5` | UInt8 | Laps |
| `Temps - 0x8774` | UInt24 | Result signal |
| `Temps - 0x108F8 + slot*0x3DC` | pointer | Name pointer |
| `Temps - 0x108F0 + slot*0x3DC` | UInt32 | Name length |
| `Temps - 0x10C20 + slot*0x3DC + lap*4` | UInt32 | Cumulative lap ticks |
| `Temps - 0x10C50 + slot*0x3DC` | UInt32 | Best lap |
| `Temps - 0x10A90 + slot*0x3DC + finalLap*4` | UInt32 | Zero-based position |
