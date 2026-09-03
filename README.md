# HOSS / Need for Speed: High Stakes Race Capture

HS Race Capture reads race results from the Windows release of `nfs4.exe`, keeps a local CSV history, and queues encrypted results for the HOSS API. Memory access is strictly **read-only**: the scanner opens the process with `PROCESS_VM_READ | PROCESS_QUERY_INFORMATION` and never writes to game memory.

The current development line is v1.21. The active reverse-engineering work covers Hot Pursuit tickets, AI/police results, and Tournament series progression.

## Runtime files

The compiled executable embeds `HS_cars.json`; an external car catalog is not required at runtime. The Config tab selects the **NFS:HS executable** and stores it under `nfsHSExecutable`; its parent folder remains available as `nfsHSInstallRoot` for installation hashing and process binding. The Capture tab displays the icon extracted from that executable as a game launch button. NFS:HP2 continues to use the separate `nfsHP2InstallRoot`. HS capture functions use the `HS_` namespace so the current `nfs4.exe` scanner remains isolated from future HP2 capture logic. Normal runtime files are:

If no valid NFS:HS executable is configured, Race Capture opens directly on the Config tab without displaying a startup file picker. After the player selects and saves an executable, its extracted icon becomes the Capture-tab launch button.

The Config tab's **Local Only** option disables API workers and upload payload generation. Completed races are written only to `RaceHistory.csv` (or its locked-file pending fallback), and HOSS installation hash/approval checks are bypassed.

The HP2 scanner uses a separate `HP2_` namespace. When an HP2 root is configured, it locates a running HP2 executable beneath that exact installation, discovers the relocated ASAC memory region, validates the HP2 2.42 race fields, and reads track, direction, configured laps, result signal, player names, cumulative/individual laps, best laps, totals, and final positions. This initial HP2 layer reports live decoded state to the activity log; HP2 history and API upload remain separate follow-up work.

- `NFSRaceCapture.exe`
- `HSRaceCapture.config.json`
- `hs-race-api.key`
- `HS-RaceHistory/RaceHistory.csv`
- `HS-RaceHistory/RaceHistory.pending.csv` only when the primary history is locked
- `HS-RaceProbe-Logs/` when calibration logging is enabled

## Confirmed global memory mappings

Addresses below apply to the currently tested `nfs4.exe` build. Multi-byte integer fields are little-endian.

## Installation integrity and process binding

At startup, the scanner hashes the configured installation's `nfs4.exe`, active `.viv` files below `Data/Cars`, and every regular file below `Data/Tracks` except `.zip` archives. Extension matching is case-insensitive. Car archives, notes, and disabled files such as `car.viv.disabled` are ignored because the game does not load them; non-ZIP track support files remain protected. The aggregate fingerprint and file count must be approved by the HOSS validation API. The same files are rehashed after a completed race and before its history/queue/API handoff; added, missing, or modified protected files reject the capture and are listed in `Installation-Hash-Mismatches.csv`.

Process discovery is bound to the configured absolute `nfs4.exe` path. A different High Stakes installation running from another directory is ignored even though its process is also named `nfs4.exe`.

Automatic download or replacement of mismatched files is intentionally deferred to a later build.

An integrity or API-approval failure does not close the application. The Capture tab displays the failure and the activity log contains its details, allowing the installation/API configuration to be corrected. Race storage and upload remain blocked until the selected installation passes validation.

For Career mode, enable **Career mode: ignore slots 1-7 (capture local racer only)** on the Capture tab. This prevents career AI names from being mistaken for remote human racers: only the local slot is required to finish and only its result is included. Disable the option before TCP/IP multiplayer races.

With calibration logging enabled, `upgrade-discovery-changes.csv` monitors the read-only range `0x00600000–0x007FFFFF` for small enum-like transitions. For an upgrade calibration run, start the scanner and game, leave the car stationary in the upgrade screen for several seconds, then select stock, upgrade 1, upgrade 2, upgrade 3, and stock again, pausing several seconds after each selection. Do not change other settings during the sequence; timestamps in the CSV identify candidate addresses that follow the upgrade choices.

### Creating an approved hash manifest

`NFSInstallHasher.exe` creates upload-ready JSON and CSV manifests using the same rules: `nfs4.exe`, only active `.viv` files below `Data/Cars`, and all regular files below `Data/Tracks` except `.zip` archives. It uses the same sorting and aggregate fingerprint algorithm as Race Capture and does not include the user's absolute installation path.

```powershell
.\NFSInstallHasher.exe "C:\Games\Need for Speed High Stakes"
```

This writes `HS_NFSHS-Hashes.json` and `HS_NFSHS-Hashes.csv` in the current directory. An optional second argument selects another output prefix. The JSON includes the aggregate `setSha256`, `fileCount`, and the complete per-file list for upload to the HOSS site.

Run `HS_MIGRATION-VIV-FILE-MANIFESTS.sql` on HOSS and import each approved JSON manifest's `files` entries into `HSRC_VIV_Files` using the corresponding `VIV_Set_ID`. The validation endpoint compares an unapproved client manifest with the closest enabled approved set and returns every `MODIFIED`, `MISSING`, and `ADDED` file. Race Capture shows that list in its integrity status and Activity Log and writes the detailed hashes to `Installation-Hash-Mismatches.csv`.

| Address | Type | Meaning | Confidence / evidence |
|---|---:|---|---|
| `0x007432D0` | UInt8 | Selected/local participant slot | Confirmed in repeated races |
| `0x00743290` | UInt32 | Track ID | Confirmed against track changes |
| `0x00743310` | ASCII | Secondary player-name source | Used as a fallback |
| `0x007C4CEC` | UInt32 | Configured laps A | Must agree with configured laps B |
| `0x00743298` | UInt32 | Configured laps B | Must agree with configured laps A |
| `0x007C4C9C` | UInt32 | Collision setting/raw value | Single Race uses raw `1`/`2` as ON; Knockout, Tournament, and Hot Pursuit force semantic collision ON because Career/HP can retain legacy raw `0` |
| `0x007C4D14` | UInt32 | Race family | `0` single/HP, `1` Tournament, `2` Knockout |
| `0x007C4D10` | UInt32 | Series difficulty/signature A | `0` Amateur, `1` Pro, `2` Champion for Tournament/KO |
| `0x007C4D18` | UInt32 | Race signature B | Part of mode signature; meaning not fully normalized |
| `0x007C4D1C` | UInt32 | Race signature C | Part of mode signature; meaning not fully normalized |
| `0x007C4D20` | UInt32 | Race signature D | Part of mode signature; meaning not fully normalized |
| `0x007432F0` | UInt32 | Knockout racers remaining | Confirmed for KO; **not** a Tournament round counter |
| `0x00743300` | UInt32 | Knockout companion value | KO validation uses `remaining - 1`; constant `7` in the Tournament evidence |
| `0x007C4CF0` | UInt8 | Direction | `0` forward, nonzero backward |
| `0x007C4CF8` | UInt32 | Night option | `1` means night |
| `0x007C4CF4` | UInt32 | Mirror option | `1` means mirrored |
| `0x007C4CFC` | UInt32 | Weather option | `1` means weather enabled |
| `0x007C4CB4` | UInt32 | Braking assistance (`0=Off`, `1=On`) | Confirmed by repeated toggles |
| `0x007C4CB8` | UInt32 | Collision recovery (`0=Off`, `1=On`) | Confirmed by repeated toggles |
| `0x007C4CBC` | UInt32 | Traction control (`0=Off`, `1=On`) | Confirmed by repeated toggles |
| `0x007C4CC0` | UInt32 | Damage (`0=On`, `1=Visual Only`, `2=Physical Only`, `3=Off`) | Confirmed by complete setting cycle |
| `0x007C4D0C` | UInt32 | Traffic raw option | `1` means enabled; only an effective Single/Hot Pursuit race may override legacy raw `0` to ON |
| `0x007C4D84` | UInt32 | Transmission | `0` manual, `1` automatic |

## Participant result slots

The eight result-block bases are:

| Slot | Result base |
|---:|---:|
| 0 | `0x00661FB8` |
| 1 | `0x00662A8C` |
| 2 | `0x00663560` |
| 3 | `0x00664034` |
| 4 | `0x00664B08` |
| 5 | `0x006655DC` |
| 6 | `0x006660B0` |
| 7 | `0x00666B84` |

Slot 6 was corrected from the earlier incorrect `0x00666060` value. The result stride is `0xAD4`.

Confirmed offsets relative to each result base:

| Relative offset | Type | Meaning | Notes |
|---|---:|---|---|
| `-0x44` | ASCII, up to 16 bytes | Vehicle folder code | Examples: `suv`, `sedan`, `hatchbk`, `caprice`, `pbmw` |
| `+0x0C` | UInt32 | Completed lap count | Compared with configured laps |
| `+0x10` | UInt16 | Total race ticks | Game timing uses 64 ticks/second |
| `+0x18 + 4*n` | UInt16 | Lap `n+1` ticks | Eight lap positions are read |
| `+0x7C` | Float32 | Top speed in metres/second | Converted to MPH/KMH |
| `+0x84` | UInt8 | Race placement | Validated range currently 1–32 |
| `+0x94` | UInt32 | Hot Pursuit tickets issued | Persistent police `Unit##` total; controlled final patterns match summary screens |
| `-0x21B` | UInt8 pulse | Hot Pursuit ticket received event | Rising edges are counted per non-police participant |

### Hot Pursuit ticket evidence

The received-ticket field at `-0x21B` is an event pulse, not a persistent final counter. Controlled runs showed rising edges corresponding to `0 → 1 → 2` received tickets for human and AI racers.

The issued-ticket field at `+0x94` is a persistent UInt32. It reproduced final per-unit patterns including Unit38 reaching two issued tickets while zero-ticket units remained zero.

Police names are discovered from game evidence and matched as `Unit` followed by digits. The scanner does not maintain an invented list of Unit numbers.

Hot Pursuit is detected by either a `Unit##` participant name or a participant vehicle whose embedded catalog type contains `Pursuit`. For HOSS, Hot Pursuit always has traffic.

## Player-name table

| Item | Value |
|---|---:|
| Base | `0x007C4D64` |
| Stride | `0x70` bytes |
| Slots | 8 |

### Car upgrade level

The persistent in-race upgrade level is a UInt8 at offset `+0x18` from the active player's name-table entry:

```text
upgrade address = 0x007C4D64 + (local slot * 0x70) + 0x18
```

For the normal Career local slot 0, this resolves to `0x007C4D7C`.

| UInt8 value | Meaning | Upload behavior |
|---:|---|---|
| `0` | Stock | `Results.Validation_ID = 0` |
| `1` | Upgrade 1 | `Results.Validation_ID = 1` |
| `2` | Upgrade 2 | `Results.Validation_ID = 1` |
| `3` | Upgrade 3 | `Results.Validation_ID = 1` |

Controlled evidence showed this field remaining `3` throughout two Upgrade 3 races and `0` throughout a race using a separately owned stock copy of the same car. `RaceHistory.csv` stores the raw `0`-`3` value in `UpgradeLevel`, and the same value is included as `player.upgradeLevel` in the upload payload.

The following related addresses are diagnostic only and must not drive the in-race result:

| Address | Observed role | Reason not used |
|---|---|---|
| `0x0069BC56` | Garage/menu upgrade copy | Returned to `0` or was cleared while a race loaded |
| `0x0069BC5A` | Duplicate garage/menu copy | Behaved like `0x0069BC56` |
| `0x0067BF2C` | Upgrade-shop working value | Followed shop changes but was not consistently refreshed for the car used in a race |
| `0x0069B9A3` | Upgrade menu highlight/index | Changed with menu navigation before the applied selection stabilized |

Known normal AI names include Ace, Bogey, Bully, Gotcha, Scream, Sleepy, and Wild 1. AI identification is also preserved explicitly in the normalized model and HOSS `Personas.Persona_AI` field.

## Result normalization

- Human participants determine the PIT racer count; AI and police never increase it.
- Normal AI results are stored for statistics. Police receive 10 race points per issued ticket under the current ingest rules.
- Police positions begin after all racers.
- Police lap times are synthesized as the slowest recorded racer lap plus 10 seconds per lap; total time is the sum of those laps.
- All police use the slowest racer top speed plus 32 MPH.
- A non-police AI with a complete stamped result retains its real time. An AI without a proper stamped total that is also a `DNF` retains its real completed laps and tickets, while its normalized total becomes the slowest completed human total plus 15 seconds per configured lap. Each subsequent DNF receives another 5 seconds in placement order.

## Tournament progression: unresolved

The 2026-09-02 Amateur Tournament capture proved that the KO fields cannot determine Tournament progress:

| Actual race | Track | `0x007432F0` | `0x00743300` | Incorrect old result |
|---:|---|---:|---:|---:|
| 1 | Celtic Ruins | 8 | 7 | Race 1 |
| 2 | Landstrasse | 8 | 7 | Race 1 |

The scanner therefore must not treat the KO calculation `9 - racersRemaining` as evidence of a Tournament round. A production Tournament mapping will not be added until a full controlled series reveals a stable field.

The 2026-09-02 Champion Tournament capture at Landstrasse (backward, four laps) is user-confirmed as race 1 and provides the labeled starting point for the full-series progression comparison.

## Locked RaceHistory fallback

If Excel or another program locks `RaceHistory.csv`, the scanner writes the identical normalized row and header to `RaceHistory.pending.csv`. A successful fallback counts as a successful local capture, so the encrypted queue and API upload continue. The primary history file is never overwritten or modified while locked.

At the next startup, pending rows are merged into `RaceHistory.csv` and `RaceHistory.pending.csv` is removed after the merge flushes successfully. The Config tab also provides **Delete race file after successful upload**; when enabled, an uploaded encrypted `.hsrc` file is deleted instead of moved to `EncryptedArchive`.

## VIV integrity failures

The approved car VIV set is hashed at startup and rehashed after each completed race before local storage or upload. If a file was modified, removed, or added, the race is rejected and the application reports every mismatching relative filename with `MODIFIED`, `MISSING`, or `ADDED` status. Full expected/actual sizes and SHA-256 values are written to `HS-RaceProbe-Logs/Car-VIV-Mismatches.csv`. Automatic repair/download is deferred to a later build.

### Tournament progression sniffer

With calibration logging enabled, the scanner reads the compact global range `0x00743200–0x007433FF` once per sample and writes:

- `tournament-progression.csv`: complete snapshots plus the known slot, track, laps, and KO values.
- `tournament-progression-changes.csv`: each changed byte and its containing aligned UInt32 before/after value.

The probe is read-only. For the next controlled test, start the scanner before starting a fresh Tournament, complete the entire series without restarting either process, and retain the complete timestamped log directory.

## Calibration evidence files

Each enabled probe session creates a timestamped directory under `HS-RaceProbe-Logs` containing:

- `events.csv` — normalized race state changes
- `multiplayer-slots.csv` — parsed participant slots
- `participant-memory.csv` — wide per-participant snapshots
- `ticket-candidates.csv` — small per-participant byte transitions
- `player-records.csv` and `player-record-changes.csv` — player-name-record calibration
- `player-roster.csv` — participant name changes
- `tournament-progression.csv` and `tournament-progression-changes.csv` — global Tournament counter search
- `upgrade-discovery-changes.csv` — small enum-like transitions across `0x00600000`–`0x007FFFFF`
- `meta.txt` — process, capture, and probe settings

## Build

Windows x64 GUI build:

```powershell
$env:GO111MODULE='off'
$env:GOOS='windows'
$env:GOARCH='amd64'
$env:CGO_ENABLED='0'
go test ./...
go build -trimpath -ldflags='-s -w -H=windowsgui' -o NFSRaceCapture.exe .
```

Do not create a release until the current reverse-engineering changes have been validated with controlled game evidence.
