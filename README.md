# Need for Speed Race Capture

Current packaged build: **1.26.19**. Documentation and memory findings updated **October 16, 2026**.

Read-only Windows capture for Need for Speed: High Stakes, Need for Speed III: Hot Pursuit, Need for Speed II SE, Porsche Unleashed, and Hot Pursuit 2. The scanner never writes to game memory. The standalone EXE and `NFSRaceCapture-1.26.19.zip` contain the same tested scanner build, with the Installation Hasher embedded.

Scanner EXE SHA-256: `8ea5a98612457e5aa1a524922061583606a32c548f6b48287d525ad04115ed6d`.
The ZIP includes the scanner, this README, `QUICK-START.txt`, and the optional
NFS4 ASI 1.0.5 with its INI and installation guide. Personal configuration,
API-key files, saved races and logs are excluded. Version remains 1.26.19.

## Findings since the 1.26.2 README

- **HP2:** confirmed Police and Traffic setup fields, race mode and event type, native placement/lap-lead/getaway awards and counts, award-based difficulty inference, and the shifted Knockout result layout. Corrected timing conversion to the game's 60 ticks/second and preserved car/transmission through results-menu resets.
- **PU:** added local finish capture, coherent player/car setup retention, native track directories, collision/damage, transmission and controller classification, all tuning/gear adjustments, installed parts and stock checks, and retained lap/race peak speeds. PU timing uses 64 ticks/second.
- **PU ABS/traction:** the verified On/On and Off/Off runs both contain zero in the old setup fields. The packaged scanner retains validated pre-race menu selections at launch and reports Unknown when no selection was observed. Per-car availability remains separate from the chosen On/Off state.
- **PU stiffness:** validated the adjustable dial at setup car +0x134 and the current menu object at module+0x2919AC. The separate +0x130 evidence field is now clearly named NativeSuspensionStiffness (1.26.18), with lossless migration of the old column name.
- **Shared application/storage:** the current source uses one scanner EXE with an embedded Installation Hasher. History is in `RaceHistory`, probes in `RaceProbe-Logs`, and snapshots in `Memory-Dumps`; old per-game folders migrate at startup.
- **PU uploads and roster:** completed local results use the common encrypted upload queue with a personal API key. The GUI lists all observed racer slots, independently of High Stakes filters; it matches cars to names across the separate result/setup arrays.
- **PU temporary placement:** complete captured totals are ordered by time, following IPLOUNGE's time-order approach. `PositionMethod` records `Race time order`; incomplete, tied or ambiguous results remain blank. No native finishing-rank pointer is claimed.
- **PU hash handoff:** each new capture includes the EXE plus car model, simulation/physics and track hashes. The installed-game audit produced 700 files and matched all 568 currently approved website paths; the additional 132 simulation files still need reference approval. The website policy now checks registered optional files whenever submitted.
- **Duplicate prevention:** only one scanner may use a history folder. A second launch focuses the existing instance. Stable capture IDs survive the new placement fields, and old CSVs retain their original race values after an exact backup.

The detailed address tables below distinguish decoded capture fields, raw diagnostics, and research-only references.

## How to use it

1. Extract the package into a writable folder and start `NFSRaceCapture.exe`. First launch creates `HSRaceCapture.config.json`; keep existing settings and keys when replacing an older EXE.
2. Start Race Capture, open **Config**, and select each installed game's executable (`nfs4.exe`, `nfs3.exe`, `nfs2se.exe`, `nfs5.exe` / `Porsche.exe`, or the HP2 executable).
3. Save. Use the game launch buttons on the Capture tab.
4. Enable **Capture AI Racers** to retain the complete AI roster.
5. Enable **Race Capture Diag** only for memory calibration; its logs can become very large.
6. Complete the race while Race Capture remains open through the results screen.
7. Review the activity log and the shared `RaceHistory` directory. PU and HP2 save local CSV results and use the common encrypted upload queue when Local Only is off. The log reports server acceptance, validation status and hash-check outcomes.

**Local Only** disables payloads, uploads, and High Stakes installation approval checks while preserving local CSV history. Executable discovery is bound to the configured path; another same-named executable is ignored.

## Registering the scanner API

Register or log in on the website, then open **Profile → Scanner API keys → Create API key**. Save the issued key in Config and link your in-game racer names under **Profile → Linked personas**. Turn off **Local Only** to enable uploads. NFS3 and NFS4 have built-in game-scoped public keys when the personal key field is blank; a personal key takes priority. The key is stored in `hs-race-api.key`, not JSON. Uploads are event-driven; failed items wait for the next race or **Send Queued Races Now**.

Website locations are independently overrideable in `HSRaceCapture.config.json` so site moves do not require a rebuild:

```json
{
  "apiUrl": "https://races.eaoutlaws.net/api/v1/ingest.php",
  "registrationUrl": "https://races.eaoutlaws.net/login.php",
  "vivValidateUrl": ""
}
```

Restart after manual JSON edits.

## Files and game support

Current shared folders and filenames (relative to the scanner EXE):

| Location | Contents |
| --- | --- |
| `RaceHistory/NFS4HS-RaceHistory.csv` | High Stakes history |
| `RaceHistory/NFS3HP-races.csv` | NFS3 player and optional AI results |
| `RaceHistory/NFS2SE-races.csv` | NFS2SE player and optional AI results |
| `RaceHistory/NFS6HP-races.csv` | HP2 completed local-player results and decoded awards |
| `RaceHistory/NFS5PU-RaceResults-YYYYMMDD.csv` | PU 67-column common-value local history, including temporary placement |
| `RaceHistory/UploadQueue/`, `RaceHistory/EncryptedArchive/` | Common upload queue and encrypted archive; filenames identify the game |
| `RaceProbe-Logs/` | Calibration CSVs, HP2 memory-discovery sessions, PU address/time-candidate logs |
| `Memory-Dumps/` | Manual PU full-memory BIN snapshots and CSV address maps |

The shared settings are `historyDir` and `probeLogsDir`. Restart after changing either. Existing per-game folders are migrated without replacing differing files; conflicting copies are retained with a migration hash suffix. Use the current EXE's **Installation Hasher** button instead of starting a second hasher EXE.

### High Stakes

Captures humans, AI, police, lap timing, speeds, settings, upgrades, tickets, and supported series data. Protected installation files are hashed at startup and before result handoff. Use **ignore slots 1–7** for Career mode and disable it for TCP/IP multiplayer. Tournament round progression remains unconfirmed; Knockout counters are not used for it.

### NFS III: Hot Pursuit

Captures the selected configuration and up to eight roster slots. AI capture includes names, cars, positions, lap/total timing, per-lap speeds, and `TicketsReceived`/`TicketsIssued`. Older CSV files containing the former misspelling are migrated automatically.

### Hot Pursuit 2

The 2.42 scanner discovers the relocated ASAC region and captures track, direction, laps, names, timing, final position, selected car, class, NFS Edition status, transmission, guarded top/average speeds, race mode, Police/Traffic options, and validated native awards/counts. Completed local-player results are saved locally and queued for upload when **Local Only** is disabled. Knockout has a separate validated result layout. HP2 support remains beta and build/mode dependent.

### Porsche Unleashed

Auto-detects `nfs5.exe` and `Porsche.exe`, or binds discovery to the executable selected in Config. Current PU capture exports common-value local daily CSVs; address probes and full-detail results require Race Capture Diag. It matches setup records to the player/car, retains a coherent setup through menu clearing, waits for a stable complete timing result, and suppresses repeated exports when menu track/car values change while old times remain in memory. The result is local-player capture, not a claim of validated eight-player PU finish export.

Version remains **1.26.19**. Normal history now has **67 columns**: capture/player, temporary position/method, track and car information, race options, total/best and eight lap times, installed part names/status, the four setup controls in menu order, brake balance/downforce/tire pressures, gear adjustments, and overall/per-lap peak speeds in MPH and KMPH. Values are readable decimals; options and availability use **1/0**, unknowns are blank, times use **m:ss.mmm**, and speeds use two decimals. InstalledParts is a quoted JSON array of part slots, decimal IDs, names and 1/0 stock flags when known. Controller is omitted. Legacy semicolon/name-only rows remain supported. Gear columns are menu adjustments, not absolute gearbox ratios. No hex, memory addresses, raw ticks, process/module details, or diagnostic provenance appears in normal history.

The same slim history is written with debugging on or off. **Race Capture Diag** additionally creates `NFS5PU-AddressProbe-*`, `NFS5PU-TimeCandidates-*`, and full **220-column** `NFS5PU-RaceResults-Debug-*` CSVs in `RaceProbe-Logs/`. Switching diagnostics off closes them and stops the discovery sweep; re-enabling creates a new session. Manual PU memory snapshots also require diagnostics enabled.

Existing detailed or 65-column daily files convert at startup/attach with a byte-for-byte `.before-common-history-*.bak` backup. Existing race values are preserved and historical placement remains blank. Restart duplicate detection works from the readable times. Older assist labels are converted as recorded, without claiming new verification. The website adapter accepts both CSV formats, decimal car IDs, parts/setup/gear data, both speed units, and 1/0 flags. Completed new PU races also upload automatically when Local Only is off and a personal API key is configured.

The PU roster includes all eight observed slots, including AI names. Uploads
currently contain the local player's completed result. Temporary placement
uses all observed racers' complete total times, matched by name; missing times,
a tie with the local player or ambiguous identities leave position blank.
The API records `position_source=total_time_order`. This is provisional until
additional race testing establishes the native finishing-rank field.

Each new PU capture hashes `Game EXE`, `GameData/CarModel`,
`GameData/Simulation` and `GameData/Track`. The website compares submitted
registered files with active approved hashes; optional files may be absent,
but a submitted registered version must match. The scanner does not approve
new files. The October 16 audit matched all 568 registered paths, with 132
additional simulation files awaiting trusted reference approval.

Deploy the corresponding website `_private/app/hash_policy.php` for optional
file checks and `_private/app/ingest_normalizers.php` to retain CSV placement
metadata. The admin-table correction in `admin/races.php` also tolerates a PU
race whose mode was not captured. These updates require no schema changes.

The PU **Upgrade** column follows Car in website history. Its MOD/STOCK label
opens a per-race-result car setup page with adjustments, gears, options and
one row per installed part. The structured parts array and tuning object use
the existing race_results.result_json field, preserving each race's setup
independently of later car changes. Version is held at **1.26.19** until an
explicit user request to change it. Website changes must be deployed to be live.

### Need for Speed II SE

Captures race settings, player timing and position, and optional AI results. The scanner locates result records dynamically and saves stable single-player finishes to local CSV history. Multiplayer result capture remains unvalidated.

## Optional legacy NFS3 database module

The separate legacy `NFS3HP_DATABASE_MODULE.sql` is not bundled in this scanner package. Where that integration is used, it creates/seeds the `NFS3_` Cars, Classes, Difficulties, Tracks, and Race Modes, then creates Tournaments, Races, Results, and Annual Ratings. The eight lap times and eight lap top speeds are stored directly on `NFS3_Results`, matching the capture CSV without a separate lap table. Tournament definitions are intentionally left for confirmed data.

```powershell
mysql -u USER -p DATABASE < NFS3HP_DATABASE_MODULE.sql
```

## Build

From the private source checkout, use the build script so the embedded hasher, public-key resources, Windows sources, and tests are included:

```powershell
.\capture\build.ps1
```

For a staged build while the normal scanner is running:

```powershell
.\capture\build.ps1 -OutputExe .\capture\bin\NFSRaceCapture.pending
```

The full scanner Go suite, Installation Hasher checks, PHP ingestion/admin
checks and live-manifest comparison passed for the packaged 1.26.19 build.
The real scanner JSON and CSV ingestion also agreed for six saved October 16
races. Multiracer PU placement remains provisional pending further live tests.

Package an already tested build without rebuilding it:

```powershell
.\capture\package-release.ps1 -UseExistingBuild -ReadmeFile 'C:\GitHub\NFS-Race-Capture-Release\README.md'
```

The package records checksums, includes the versioned quick-start guide, and
updates the local website download ZIP and metadata. Copying these artifacts
does not publish a GitHub release or deploy the live website.

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

### Hot Pursuit 2 (2.42): current pointer and result map

`M` is the loaded HP2 executable's module base (`NFSHP2.exe` in the tested setup). `A` is a discovered, committed readable ASAC allocation larger than `0x05000000` bytes. These are **dynamic allocation bases**, not fixed `NFSHP2.exe+...` pointers:

```text
Temps        = A + 0x0366F448 + 12260 = A + 0x0367242C
Valors       = Temps - (0x0012571F + 12260) = Temps - 0x00128703
ServerValors = Valors + 0x24
roster slot  = slot * 0x54       (84 bytes; slots 0-7)
result slot  = slot * 0x3DC
```

Discovery validates track 0-11, direction 0-3, and laps 1-8 before accepting a region. Do not substitute one session's absolute addresses or confuse the roster and result strides.

#### HP2 setup and executable-relative fields

| Address / pointer | Type | Current interpretation |
| --- | --- | --- |
| `ServerValors-0x1FEED` | UInt8 | Track ID 0-11 |
| `ServerValors-0x1FEE9` | UInt8 | Direction ID; upload maps 0 to forward, other recognized IDs to backward |
| `ServerValors-0x1FEE5` | UInt8 | Configured laps 1-8 |
| `ServerValors-0x1FED5` | UInt8 | Police / Cops: 0 Off, 1 On; other values unknown |
| `ServerValors-0x1FF01` | UInt32 | Traffic: **0 Off, 2 On**; other values unknown |
| `ServerValors-0x1FE95+slot*0x54` | UInt8 / 84-byte block | Roster car ID and raw roster evidence |
| `ServerValors-0x1FE91+slot*0x54` | UInt8 | Roster `+0x04`: `0x10` marks NFS Edition when the ID is 0-23 |
| `ServerValors-0x1F5DD+slot*0x54` | UInt8 | Transmission: 0 Automatic, 1 Manual; current snapshot uses the local slot |
| `NFSHP2.exe+0x302FE8` | UInt32 | Race mode: 0 Single, 1 Knockout, 2 Tournament, 3 Be the Cop, 5 Free Run/Test Drive; unknown values stay unknown |
| `NFSHP2.exe+0x43F2E0` | UInt32 raw bits | Event type: 1065354614 = Career, 3151848916 = Single Challenge; other values unlabeled |

Traffic's UInt32 0/2 interpretation matched the controlled four-toggle capture and remained stable during each hold. The executable candidates examined earlier did not establish the persistent Police/Traffic options. Keep their raw values and source addresses for audit.

Car IDs 0-23 select the standard roster. Explicit NFS Edition IDs 38-61 subtract 38 to obtain the base car. A base-range ID with roster byte `+0x04 == 0x10` is the second supported NFS Edition representation, observed in the F1 comparison. NFS Edition names receive `NFS ` and their class receives `+`. Current PC classes are 1-5. The scanner retains a nonzero live car selection and observed Manual transmission across results-menu resets. If roster decoding fails, the fallback scans only the current result record and follows bounded 32-bit pointers at most two levels for a known car-folder token; there is no single confirmed fixed car-folder pointer chain.

Track IDs: 0 Coastal Parklands; 1 National Forest; 2 Scenic Drive; 3 Island Outskirts; 4 Palm City Island; 5 Tropical Sunset; 6 Fall Winds; 7 Alpine Trail; 8 Autumn Crossing; 9 Wine Country; 10 Calypso Coast; 11 Mediterranean Paradise.

#### HP2 normal timing, positions, speed, and awards

`slot` is zero based. `lap` is zero based. Every result row below uses the separate `0x3DC` result stride. HP2 timing is **60 ticks/second**, not PU/HS's 64.

| Address / pointer | Type | Meaning |
| --- | --- | --- |
| `Temps-0x8774` | UInt24 | Nonzero result signal; alone does not prove a complete finish |
| `[Temps-0x108F8+slot*0x3DC]` | 32-bit pointer to bytes | Player name; use the length below, bounded to 1-64 |
| `Temps-0x108F0+slot*0x3DC` | UInt32 | Name length |
| `Temps-0x10C20+slot*0x3DC+lap*4` | UInt32 | Cumulative lap ticks; total is the final cumulative value |
| `Temps-0x10C50+slot*0x3DC` | UInt32 | Best-lap ticks |
| `Temps-0x10A90+slot*0x3DC+(laps-1)*4` | UInt32 | Final zero-based position; exported position is raw + 1 |
| `Temps-0x10C2C+slot*0x3DC` | Float32 m/s | Final top speed |
| `Temps-0x10C28+slot*0x3DC` | Float32 m/s | Final average speed |
| `Temps-0x108A4+slot*0x3DC` | UInt32 | Placement award points |
| `Temps-0x108A0+slot*0x3DC` | UInt32 | Lap-lead award points |
| `Temps-0x1089C+slot*0x3DC` | UInt32 | Getaway award points |
| `Temps-0x1088C+slot*0x3DC` | UInt32 | Laps-led count |
| `Temps-0x10888+slot*0x3DC` | UInt32 | Getaway count |

Individual laps are differences between strictly increasing cumulative values. A result needs a nonzero signal, supported lap count, plausible final position, positive total, and complete positive splits summing to that total. Speeds are converted with `m/s * 2.2369362920544` for MPH and are range checked; invalid values remain blank. A guarded Time Attack fallback reads **best lap and both speed fields another `0x08` bytes earlier** only if their combined values are plausible. It does not shift the lap array or final-position array.

Knockout's validated parallel result record is **`0x20` bytes earlier**: subtract another `0x20` from the signal, timing, position, speed, and award/count addresses above. It is accepted only when normal results are incomplete, raw race mode is 1, and the shifted result is complete. If HP2 cleared the normal player list, slot zero is retained as a candidate and the configured persona restores the saved local name. The guarded best-lap/speed `0x08` fallback can also apply within that shifted record. Name/roster reads still use their normal sources; they are not shifted blindly.

Native points are the sum of the captured placement, lap-lead, and getaway awards. Awards/counts are validated together before publishing. There is **no confirmed direct difficulty pointer**: first-place awards 1000/1500/2000 imply Beginner/Intermediate/Advanced; alternatively exact lap-lead rates 50/75/100 per lap imply those tiers. Unsupported or ambiguous values leave difficulty blank. Native Points and the website's Network Points remain separate values.

Finish signatures use laps, position, total, and all lap splits. Mutable menu track/direction and player-name clearing do not create another result. Existing history can receive a captured award breakdown for the same finish instead of a duplicate row.

#### HP2 diagnostic-only addresses

These are read for research and **are not substitutes for the decoded setup/award fields above**:

| Executable-relative address / block | Role |
| --- | --- |
| `NFSHP2.exe+0x44E55C` | Old lap-lead/traffic-correlated candidate; not the Traffic setting |
| `NFSHP2.exe+0x3A0C70` | Lap-led counter candidate |
| `NFSHP2.exe+0x3031A4`, `+0x3031A8`, `+0x3031AC`, `+0x3031B0` | Native-point candidates |
| `NFSHP2.exe+0x303000`, `+0x3A0C00`, `+0x44E500`, `+0x44BC00` | Four watched `0x400`-byte blocks for change logs |
| `NFSHP2.exe+0x447E78` | Earlier Police-correlated candidate; fluctuated during the race, not the selected setting |
| `NFSHP2.exe+0x44C971`, `+0x446FE9` | Earlier difficulty menu candidates; not used as confirmed difficulty fields |

Each finish writes award/result CSV evidence and nearby binary slices. With **Race Capture Diag (memory + JSON)** enabled, HP2 also saves a compressed full baseline, then changed readable memory blocks, per-sample maps, a module map, `samples.csv`, and decoded `HP2-state.csv`. Discovery covers the x86 user address space up to its actual readable limit; guard/inaccessible pages are excluded. Sessions stop at 600 scans or 2 GiB compressed, and toggling diagnostics creates a new baseline. Raw memory discovery runs independently of finish detection.

### Porsche Unleashed: complete current pointer and field map

The notation below uses **`Porsche.exe+0xRVA`** as requested. Set the module name to the executable actually loaded; for the verified local build the same notation is **`nfs5.exe+0xRVA`**. The scanner auto-detects both filenames and resolves reads against the loaded base, rather than using fixed absolute addresses.

**Build coverage:** the mapped and captured executable is `nfs5.exe`, SHA256 `c318af393d4c2b7071a820ca3d69e956bbd94769b6e5c2e3e49f498ecbc94906`. The separately installed `Porsche.exe` has a different hash and has not been independently mapped. Listing `Porsche.exe+...` is an address convention, not a claim that every differently named/versioned binary has this layout. Preferred image base is `0x00400000`; all offsets below are hexadecimal RVAs, with little-endian integers and **32-bit pointers**. `[address]` means dereference a pointer; an address without brackets is a direct field.

#### PU shared setup, result buffers, and diagnostic reads

| Pointer / address | Type / size | Use |
| --- | --- | --- |
| `Porsche.exe+0x2573E8` | Raw `0x38A4`-byte block | Complete setup block currently read for eight car records |
| `Porsche.exe+0x25740C` | UInt32 | Collision / NOCOLLISION: 0 On, nonzero Off |
| `Porsche.exe+0x257A2C` | UInt32 | Damage: 0 Off, nonzero On |
| `Porsche.exe+0x25742C` | UInt32 | Setup mirror: 0 No, nonzero Yes |
| `Porsche.exe+0x257430` | UInt32 | Setup direction: 0 Forward, nonzero Backward |
| `Porsche.exe+0x257444` | 10 NUL-terminated bytes | Native track directory; authoritative completed-result track identity |
| `Porsche.exe+0x258600` | UInt32 | Selected/local car ID; also first setup car +0x574 |
| `Porsche.exe+0x299FB4` | UInt32 | Configured laps = raw + 1; accepted range 1-8 |
| `Porsche.exe+0x299F2C` | UInt32 | Diagnostic direction: 0 Forward, 1 Backward, 2 Forward mirrored, 3 Backward mirrored |
| `Porsche.exe+0x299F30` | UInt32 / 12-byte PUDataA buffer | Raw numeric track candidate plus adjacent diagnostic bytes |
| `Porsche.exe+0x299E44` | 12-byte PUDataB buffer | Raw diagnostic bytes; no additional semantics asserted |
| `Porsche.exe+0x20C890` | 12-byte result buffer | Diagnostic bytes; not an independent confirmed finish flag |
| `Porsche.exe+0x2580A0`, `Porsche.exe+0x2580A4`, `Porsche.exe+0x2580A8` | Three UInt32 values | Raw StateFlag1/2/3 diagnostics; these alias first-car controller values, not a reliable race-stage flag |

Native directories: `coastal` = Côte d'Azur; `forest` = Schwarzwald; `foothills` = Pyrénées; `alps` = Alps; `autobahn` = Autobahn; `castle` = Auvergne; `farmland` = Normandie; `industrial` = Zone Industrielle; `canyon` = Corsica; `skidpad` = Weissach Skid Pad; `monaco1` through `monaco5` = Monte Carlo Circuits 1-5. The numeric track candidate can change to a default during menus without a new race; keep it as `TrackIDRaw`, not the finish identity.

#### PU per-racer timing, identity, and peak speed

Result/timing records use **`slot * 0x258`**, zero-based slots 0-7. Add that stride to every direct address in this table for the corresponding result slot. CSV finish/speed export uses the local slot; the reader now also collects all eight identity and 32-bit total/lap blocks for provisional placement. Diagnostic probes retain those complete blocks as `Slot1ResultTimesHex` through `Slot8ResultTimesHex`. All timing values use **64 ticks/second**.

| Slot-zero address | Type | Meaning |
| --- | --- | --- |
| `Porsche.exe+0x1E75A0` | Float32[8] m/s | Retained per-lap peak-speed array; lap n adds (n-1)*4 |
| `Porsche.exe+0x1E75F0` | UInt32 | Total race ticks |
| `Porsche.exe+0x1E75F4` | UInt32 | Lap 1 ticks |
| `Porsche.exe+0x1E75F8` | UInt32 | Lap 2 ticks |
| `Porsche.exe+0x1E75FC` | UInt32 | Lap 3 ticks |
| `Porsche.exe+0x1E7600` | UInt32 | Lap 4 ticks |
| `Porsche.exe+0x1E7604` | UInt32 | Lap 5 ticks |
| `Porsche.exe+0x1E7608` | UInt32 | Lap 6 ticks |
| `Porsche.exe+0x1E760C` | UInt32 | Lap 7 ticks |
| `Porsche.exe+0x1E7610` | UInt32 | Lap 8 ticks |
| `Porsche.exe+0x1E7644` | 12-byte identity buffer | Player name decoded as bounded Windows Western text |
| `Porsche.exe+0x1E75F0` | 2-byte CodeA diagnostic | Low two bytes are also included in each raw slot probe |
| `Porsche.exe+0x1E77C8` | UInt16 / CodeB diagnostic | Fallback for lap 2 when its main DWORD is zero |

| Lap | Slot-zero peak-speed address |
| --- | --- |
| 1 | `Porsche.exe+0x1E75A0` |
| 2 | `Porsche.exe+0x1E75A4` |
| 3 | `Porsche.exe+0x1E75A8` |
| 4 | `Porsche.exe+0x1E75AC` |
| 5 | `Porsche.exe+0x1E75B0` |
| 6 | `Porsche.exe+0x1E75B4` |
| 7 | `Porsche.exe+0x1E75B8` |
| 8 | `Porsche.exe+0x1E75BC` |

A complete finish needs a supported configured lap count and positive lap ticks summing exactly to total. One missing local lap can be derived as total minus the known laps and is marked `Derived from total` in diagnostics; two missing laps are not accepted. Normal history preserves milliseconds as `m:ss.mmm`; legacy diagnostic clocks use truncated hundredths. No native finishing-position pointer is established. Temporary position orders complete captured totals; it does not use participant slot numbers as finishing places.

Peak speed is Float32 **metres/second**, not a direct MPH value. Use `MPH = m/s * 2.2374138832092285` (the game's HUD factor), `km/h = m/s * 3.6`, and the maximum over configured/completed laps only. Overall peak remains blank unless every completed lap has a finite positive peak. The verified 80 MPH calibration had lap 1 = 35.906494140625 m/s and lap 2 = 35.91230392456055 m/s, giving **80.350687378841 MPH**, raw DWORD `0x420FA633`, on lap 2. Entries beyond the configured laps are excluded even if they retain positive values.

Research-only reference constants are `Porsche.exe+0x1B3014` (Float32 MPH factor), `+0x1B3018` (km/h factor), and `+0x257DC0` (captured HUD speed-unit flag). The scanner embeds the verified MPH factor; these are not additional runtime pointer reads. Native code updates an active car's peak array at runtime car `+0xAD4+lap*4` and copies it to the retained result record on finish. The old runtime car pointer can be freed/reused on the results screen, so the exporter reads the retained array above.

#### PU setup-car bases and identity/settings

Setup records use a **different `0x580` stride**. Define `C = loaded module base + 0x25808C + carSlot*0x580`. The scanner matches the selected car ID and player name; a setup slot number is not assumed to be the same as a result slot number. The setup block's first-car offset is `0xCA4`.

| Setup car slot | Car record base |
| --- | --- |
| 0 | `Porsche.exe+0x25808C` |
| 1 | `Porsche.exe+0x25860C` |
| 2 | `Porsche.exe+0x258B8C` |
| 3 | `Porsche.exe+0x25910C` |
| 4 | `Porsche.exe+0x25968C` |
| 5 | `Porsche.exe+0x259C0C` |
| 6 | `Porsche.exe+0x25A18C` |
| 7 | `Porsche.exe+0x25A70C` |

| Field | Car-zero module address | Any setup car | Type / interpretation |
| --- | --- | --- | --- |
| Transmission | `Porsche.exe+0x258098` | `C+0xC` | UInt32; 0 Manual, nonzero Automatic |
| Controller raw 1 / .RAMPS | `Porsche.exe+0x2580A0` | `C+0x14` | UInt32; First legacy response/classification value |
| Controller raw 2 / .RAMPG | `Porsche.exe+0x2580A4` | `C+0x18` | UInt32; Second legacy response/classification value |
| Controller raw 3 / .RAMPB | `Porsche.exe+0x2580A8` | `C+0x1C` | UInt32; Third legacy response/classification value |
| Setup traction raw | `Porsche.exe+0x2580AC` | `C+0x20` | UInt32; Evidence only; zero also occurred in a verified On run |
| Setup ABS raw | `Porsche.exe+0x2580B0` | `C+0x24` | UInt32; Evidence only; zero also occurred in a verified On run |
| Player name | `Porsche.exe+0x258208` | `C+0x17C` | 10 NUL-terminated bytes; Match to local result identity |
| Car model | `Porsche.exe+0x2582B4` | `C+0x228` | 10 NUL-terminated bytes; Native model token |
| Car physics | `Porsche.exe+0x2582F4` | `C+0x268` | 10 NUL-terminated bytes; Native physics token |
| Car spec | `Porsche.exe+0x258334` | `C+0x2A8` | 10 NUL-terminated bytes; Native specification token |
| Car sound | `Porsche.exe+0x258374` | `C+0x2E8` | 10 NUL-terminated bytes; Native sound token |
| Car description | `Porsche.exe+0x2585C0` | `C+0x534` | 50 NUL-terminated bytes; Trailing * gives the legacy Mod label; otherwise Stock |
| Car ID | `Porsche.exe+0x258600` | `C+0x574` | UInt32; Native ID; name lookup uses the bundled car list |

IPLounge's controller classifier recognizes `(0,0,0)` = Wheel, `(0,1,1)` = Gamepad, `(1,1,1)` = Keyboard. Other triples are **Unknown**. These response values do not prove which physical controller is attached. The independently derived description Stock/Mod label does not replace installed-part stock checking. The GUI shows [STOCK] or [MOD] immediately after the car name, using the same CarType classification as the CSV; it shows [UNKNOWN] until a matching description is available.

#### PU tuning and all gear adjustments

The 220-column debug format groups the first four tuning controls in game-menu order: **ShocksRideHeight, ShocksStiffness, ShocksTravel, SteeringToeIn**, each followed by its RawHex column. Older detailed headers RideHeight, ShockStiffness, SuspensionTravel, and ToeIn are recognized during migration; normal history keeps the common values and the original full record is backed up. The separate native stiffness evidence appears after the other tuning fields in debug output; it is omitted from normal history.

Every field below is a **signed Q16.16 integer**: read Int32 and divide by 65536. It is not an IEEE Float32. Preserve the raw DWORD. Add `carSlot*0x580` to the displayed car-zero address.

| Field | Car-zero module address | Any setup car |
| --- | --- | --- |
| ShocksRideHeight (Shocks - Ride Height) | `Porsche.exe+0x2581AC` | `C+0x120` |
| ShocksStiffness (Shocks - Stiffness) / .SHOCKRATE | `Porsche.exe+0x2581C0` | `C+0x134` |
| ShocksTravel (Shocks - Travel) | `Porsche.exe+0x2581B0` | `C+0x124` |
| SteeringToeIn (Steering - Toe In) | `Porsche.exe+0x2581B4` | `C+0x128` |
| FrontBrakeBias | `Porsche.exe+0x2581A8` | `C+0x11C` |
| FrontDownforce | `Porsche.exe+0x2581A0` | `C+0x114` |
| RearDownforce | `Porsche.exe+0x2581A4` | `C+0x118` |
| FrontTirePressure | `Porsche.exe+0x2581C8` | `C+0x13C` |
| RearTirePressure | `Porsche.exe+0x2581CC` | `C+0x140` |
| NativeSuspensionStiffness / .SUSPENSIONSTIFFNESS | `Porsche.exe+0x2581BC` | `C+0x130` |
| Gear1Adjustment | `Porsche.exe+0x258188` | `C+0xFC` |
| Gear2Adjustment | `Porsche.exe+0x25818C` | `C+0x100` |
| Gear3Adjustment | `Porsche.exe+0x258190` | `C+0x104` |
| Gear4Adjustment | `Porsche.exe+0x258194` | `C+0x108` |
| Gear5Adjustment | `Porsche.exe+0x258198` | `C+0x10C` |
| Gear6Adjustment | `Porsche.exe+0x25819C` | `C+0x110` |
| FinalGearAdjustment | `Porsche.exe+0x25817C` | `C+0xF0` |
| ReverseGearAdjustment | `Porsche.exe+0x258180` | `C+0xF4` |

`RearBrakeBiasDerived = 100 - FrontBrakeBias`; no independent rear-bias pointer was found. Gear values are tuning adjustments, not the installed gearbox's absolute ratios. The adjustable **SHOCKS - STIFFNESS** control is ShocksStiffness / .SHOCKRATE at `C+0x134`. The October 15 modified Boxster S races captured `0x00017D70` (1.489990234375, displayed 1.49) and `0x00011EB8` (1.1199951171875, displayed 1.12). The separate native `C+0x130` remained 1 in those samples. Version 1.26.18 renames its columns to NativeSuspensionStiffness and NativeSuspensionStiffnessRawHex; existing daily CSVs migrate those names with an original-file backup and preserve all values. The scanner preserves native values instead of reproducing IPLounge's special stiffness substitution.

Gear-slider availability is gated by the game's Race-class factory definition.
The verified factory roster enables adjustments for the 1956 550 A Spyder,
1978 935/78 Moby Dick, 1998 GT1, 1997 GT2 and 1998 GT3 Cup. Their factory
transmissions are sufficient. Road-car close/high/low-ratio replacement
transmissions are fixed presets and do not unlock these sliders.

#### PU stiffness menu pointer (research validated October 15)

The game's carsetup.lay binds the stiffness buttons/value to **ShockRate**; English string 11003 is **SHOCKS - STIFFNESS**. `Suspension` is the separate travel control. The current stiffness object is **`[Porsche.exe+0x2919AC]`** (32-bit pointer). Validate the mapped build, vtable `module+0x1B4F44`, name `ShockRate` via `[[object+4]]`, and resolved byte `object+0x1D == 0`. Read Int32 index at `object+0x18`, Float32 minimum at `+0x24`, maximum at `+0x28`, and step at `+0x2C`. Compute **index * step + minimum**; verified limits are 0.70-1.50 in 0.01 steps. Heap addresses change between launches.

Saved 22:37:11 and 22:41:19 dumps contain menu indices 42 (1.12) and 36 (1.06), while their retained applied race values are 1.49 and 1.12. Later menu movement must not overwrite an already completed race's tuning. This is a research pointer; current finish export continues to use the matched, retained setup-car +0x134 field. Native code and the installed layout validate the binding, rather than assuming the similarly named +0x130 is the dial. The time-candidate log does not establish every intermediate menu movement.

#### PU all 20 installed-part pointers

Each slot is a four-byte DWORD. Its low UInt16 is the installed part ID; zero is empty. Resolve `(native car ID, part ID)` together against the embedded catalog. Preserve raw values and slot positions.

| Part slot | Car-zero module address | Any setup car |
| --- | --- | --- |
| 1 | `Porsche.exe+0x2580B4` | `C+0x28` |
| 2 | `Porsche.exe+0x2580B8` | `C+0x2C` |
| 3 | `Porsche.exe+0x2580BC` | `C+0x30` |
| 4 | `Porsche.exe+0x2580C0` | `C+0x34` |
| 5 | `Porsche.exe+0x2580C4` | `C+0x38` |
| 6 | `Porsche.exe+0x2580C8` | `C+0x3C` |
| 7 | `Porsche.exe+0x2580CC` | `C+0x40` |
| 8 | `Porsche.exe+0x2580D0` | `C+0x44` |
| 9 | `Porsche.exe+0x2580D4` | `C+0x48` |
| 10 | `Porsche.exe+0x2580D8` | `C+0x4C` |
| 11 | `Porsche.exe+0x2580DC` | `C+0x50` |
| 12 | `Porsche.exe+0x2580E0` | `C+0x54` |
| 13 | `Porsche.exe+0x2580E4` | `C+0x58` |
| 14 | `Porsche.exe+0x2580E8` | `C+0x5C` |
| 15 | `Porsche.exe+0x2580EC` | `C+0x60` |
| 16 | `Porsche.exe+0x2580F0` | `C+0x64` |
| 17 | `Porsche.exe+0x2580F4` | `C+0x68` |
| 18 | `Porsche.exe+0x2580F8` | `C+0x6C` |
| 19 | `Porsche.exe+0x2580FC` | `C+0x70` |
| 20 | `Porsche.exe+0x258100` | `C+0x74` |

The source catalog contains 4,618 records for 93 car IDs: 1,529 stock `S` entries and 3,089 cataloged alternatives. A matching `S` is Stock; a matching blank marker is Non-stock; an unmatched ID stays Unknown. The 9D/01FD IPLounge allowance does not prove that missing catalog entry is stock. Parts, tuning, and the description's trailing-asterisk label are reported separately.

#### PU ABS, traction, transmission menu pointers and availability

These are actual pointer chains, unlike the direct setup fields. Heap addresses change between sessions, so dereference the module-relative roots on each read.

| Pointer chain | Type | Meaning / validation |
| --- | --- | --- |
| `[Porsche.exe+0x29193C]+0x18` | UInt32 | Menu transmission; property ID 0; 0 Manual, 1 Automatic; diagnostic menu source |
| `[Porsche.exe+0x291984]+0x18` | UInt32 | Menu ABS selection; property ID 570; 0 Off, 1 On |
| `[Porsche.exe+0x291988]+0x18` | UInt32 | Menu traction selection; property ID 571; 0 Off, 1 On |
| `[menuObject+0x00]` | Pointer | Must equal `Porsche.exe+0x1B518C` (expected enum vtable) |
| `menuObject+0x08` | UInt32 | Must match the expected property ID |
| `menuObject+0x1D` | UInt8 | Must be zero; nonzero marks an unresolved selection |

Here `menuObject` is the pointer obtained from the corresponding root. Raw selection values above 1 are rejected. Factory availability is separate from selected On/Off state:

```text
V = pointer32 at Porsche.exe+0x2919EC
B = pointer32 at V+0x00           # definition-pointer vector begin
E = pointer32 at V+0x04           # vector end, exclusive
D = pointer32 at B+i*4           # factory definition i
car ID           = UInt16 at D+0x00
ABS available    = UInt8 at D+0x2E2
traction present = UInt8 at D+0x2E3
```

Validate pointer bounds, vector alignment/count (at most 512), native IDs 1-255, and 0/1 capability bytes. A missing/partially loaded selected car triggers another catalog read; it must not permanently cache Unknown. The verified factory list contains 84 definitions: 53 with neither assist, 23 with ABS only, and 8 with both. The eight traction-capable IDs are D5, A1, A7, A2, A4, A3, A5, A6. These are this game's definitions, not claims about real vehicle equipment.

The two verified Skid Pad runs on October 15 used A6 (2000 911 Turbo):

| Completed capture (local EDT) | Total ticks / display | User-confirmed and pre-race menu settings | Old setup raw ABS / traction |
| --- | --- | --- | --- |
| 16:06:09.7123593 | 3580 / 0:55.93 | **On / On**; menu raw 1 / 1 | 0 / 0 |
| 16:07:58.2115301 | 3496 / 0:54.62 | **Off / Off**; menu raw 0 / 0 | 0 / 0 |

The saved 16:06:17 and 16:08:05 snapshots confirm that the old setup fields remain zero in both cases while menu values differ. Both A6 capability bytes are 1. Thus `Porsche.exe+0x2580B0` and `+0x2580AC` remain useful raw evidence, but zero there cannot establish that ABS/traction was Off in these single-player races.

The correction retains both validated menu selections together at launch, matches player/car, and preserves them through result-menu resets. The first run's menu briefly resets to 0/0 after finishing before returning to 1/1; sampling that later menu would again mislabel the finished run. `ABS`/`TractionControl` and their selected raw values use the pinned pre-race selection; debug `AssistSource` and `AssistCapturedAt` record provenance. `SetupABSRaw` and `SetupTractionControlRaw` keep the original setup DWORDs in diagnostics. Without a pre-race selection the state is Unknown; a confirmed unavailable option is represented separately. This correction is included in the packaged 1.26.19 build and covered by the scanner regression tests. Start the scanner before selecting assists so it can retain the menu choices. The exporter does not automatically rewrite old assist values.

The follow-up A3 (1999 911 Carrera 4 Coupe) pair independently reproduced the issue with the older executable:

| Completed capture (local EDT) | Total ticks / display | Validated saved menu ABS / traction | Collision / Damage / Transmission |
| --- | --- | --- | --- |
| 20:50:42.7598529 | 2734 / 0:42.71 | **On / On**, raw 1 / 1 in the 20:50:54 snapshot | On / On / Automatic |
| 20:52:32.7590575 | 3212 / 0:50.18 | **Off / Off**, raw 0 / 0 in the 20:52:43 snapshot | Off / Off / Manual |

Both setup assist DWORDs remained zero and both capabilities were available. These records were written by the 12:11 build before the correction was installed. The two rows were corrected separately from their matching saved snapshots, with explicit `AssistSource` / `AssistCapturedAt`, original setup raw values, and an exact original CSV backup; other historical captured values were preserved. That historical repair was performed when the 1.26.16 correction was installed. The packaged executable is now 1.26.19; the source correction and historical snapshot repair remain distinct operations.

#### PU finish lifecycle, replay evidence, and probe limits

PU can retain the previous complete times throughout the next race. A nonzero time buffer therefore does not prove a new finish or lock setup to a new race. Current finish identity uses total and all lap ticks, not mutable track/car menu IDs. The scanner stages the first coherent player/car/native-directory result, waits at least one second for stability, and keeps that snapshot rather than replacing it with later menu edits. It seeds the latch from the last complete daily CSV result on restart, ignores an old finish on initial attachment, and requires a sustained empty timing buffer (at least two seconds) to rearm an exactly repeated timing signature. An identical new race with no observable reset remains indistinguishable from retained results.

A Windows instance reservation is scoped to the normalized history directory
before migrations and capture workers start. It prevents two copies from writing
the same race simultaneously; a second launch focuses the existing scanner.

The game copies setup memory beginning at `Porsche.exe+0x2573E8` to its replay buffer at `+0x1E9A20`; the observed native copy size is `0x3E24`. This establishes the replay/setup relationship. The scanner reads only `0x38A4` for eight setup cars; the extra capacity in the replay copy is not treated as another validated racer.

The address probe also samples `Porsche.exe+0x1E0000` through `+0x29FFFF` in `0x1000`-byte pages, prioritizing `+0x256000`, for changed time/value candidates. That sweep is filtered, so absence from it does not prove a value stayed constant; menu option heap objects are outside that image range. Manual memory snapshots save readable process bytes to a BIN plus a CSV virtual-address/file-offset map. Read-only offline decoding avoids using freed menu/runtime pointers as live telemetry.

Reserved fields `VID`, `RaceID`, `CarCheck`, `TrackCheck`, and `FileCheck` do not have confirmed direct game pointers. Database IDs and computed integrity checks must not be filled from invented addresses. No new PU native-points or finishing-position pointer is claimed by this update.

#### PU IPLOUNGE result ordering and current hash checks

IPLOUNGE v5.42 `SetResult` at `0x006E348C` searches racer identities starting
at game `0x005E7644`, advances `0x258` per result, and subtracts `0x54` to read
the matched race time. Its PureResults writer stores `racetime` and `time00`
without a finishing-position field. The `showsort` routine at `0x0063D89C`
can select `Order by time00 ASC`. The scanner's temporary placement adapts
that time order, using full UInt32 totals and complete opponent lap sums.
Missing results, duplicate names and a local tie leave placement unset.

The three saved October 15 result snapshots contain only the local name `Lix`.
Their totals, 3212, 10984 and 10726 ticks, each agree with the configured lap
sum. These verify the timing-slot reads; they do not establish multiracer native
finishing ranks. `PositionMethod=Race time order` and API
`position_source=total_time_order` preserve that distinction.

On October 16 the scanner's 700-file evidence matched all 568 paths in the
website's current approved manifest. Those registered paths were all optional.
The corrected website policy compares a registered file whenever it is sent,
while `required` continues to control absence. Windows path case and slash
direction are normalized. The response's `checked_files` count is shown in
the scanner log along with approval mismatches or missing check configuration.
The remaining 132 simulation files have no registered approvals yet; a local
reference CSV was prepared separately for administrator review. Sending a new
unregistered non-VIV hash does not approve it or make it a website check.

### Need for Speed II SE (`nfs2se.exe`)

The addresses below are offsets from the loaded `nfs2se.exe` module base. UInt32 timing values use 64 ticks per second.

| Module offset | Type | Meaning |
|---|---:|---|
| `+0xE5934`, `+0xD4E58` | UInt32 | Game type: 0 single player, 1 split screen, 2 modem, 3 serial, 4 network |
| `+0xE5938` | UInt32 | Single-player car ID |
| `+0xE5A50` | UInt32 | Multiplayer car ID in low 24 bits; transmission in high byte |
| `+0x112F40` | UInt32 | Multiplayer opponent selection |
| `+0xD4E5C` | UInt32 | Mode: 0 Single Race, 1 Tournament, 2 Knockout |
| `+0x112DB0` | UInt32 | Track ID 0–7 |
| `+0x112DAC` | UInt32 | Opponent skill: 16777216 Beginner, 16777472 Advanced |
| `+0x112DB8` | UInt32 | Packed laps (low byte), backward direction (byte 2), mirror (byte 3) |
| `+0x112DA8` | UInt32 | Mode (byte 2) and style (byte 3): 0 Simulation, 1 Wild, 2 Arcade |
| `+0x112DC0` | UInt32 | Transmission: 1377713153 Automatic, 1377713152 Manual |
| `+0x112DF8` | UInt32 | Traffic: 256 On, 257 Off |
| `+0x10B3BC` | UInt32 | Player total time, ticks |
| `+0x112024` | UInt32 | Current/last lap timing value, ticks |
| `+0x10B3DC` | UInt32 | Diagnostic best-lap candidate; can remain stale |
| `+0x112044` | UInt32 | Player finishing position, one-based |
| `+0x112F4C`, `+0xE5EC8`, `+0xE5C1C` | string | Player name copies; single-player copies must agree |
| `+0xD5C7C`, `+0x10A91C`, `+0x10B130` | UInt32 | Finish-state values; 12 at observed single-player finish |
| `+0x10B364` | UInt32 | Finish-state value; 7 at observed single-player finish |
| `+0x10B3B4` | UInt32 | Completed laps; must match configured laps at finish |

The scanner discovers the result block by matching total, last lap, lap count, and lap sum. An observed result-total address was `0x000EB088`, but this is a dynamic allocation and must not be hardcoded. Result slots have a `0x684` stride. Relative to each result-total address, `+0x44` is the one-based position, `-0x18` holds the metadata pointer, and the racer name is at metadata pointer `+0x34`. Candidate speed data begins at result total `+0x24`; speed conversion (`raw / 65536 / 0.44704` mph) remains provisional. Complete lap arrays are accepted only when their count, sum, and final lap agree with the independent timing fields. These finish states have been validated in two single-player races; other modes need live validation.
