# Viltrumite Simulator — Setup & Testing Guide

## Important: Linux users

**Roblox Studio runs on Windows and macOS only.**
The source code lives on Linux (this repo), but you need a Windows or Mac
machine to actually open Studio and test. You have three options:

| Option | How |
|---|---|
| **Separate PC/Mac** | Pull the repo there, run Rojo there, open Studio there |
| **Same machine, network serve** | Run `rojo serve` on Linux, connect Studio on another device on the same network using your Linux machine's local IP (e.g. `192.168.x.x:34872`) |
| **Windows VM / cloud** | Shadow PC, GeForce NOW dev mode, or a local VirtualBox Windows VM |

The simplest path if you have a second machine: clone the repo on that machine,
`cd viltrumite-sim`, then follow the steps below.

---

## Prerequisites

| Tool | Where to get it |
|---|---|
| **Roblox Studio** | https://create.roblox.com/download |
| **Rojo CLI** | https://github.com/rojo-rbx/rojo/releases — download the binary for your OS |
| **Rojo Studio plugin** | Same releases page — install the `.rbxm` plugin file in Studio |

> Rojo has Linux, Mac, and Windows binaries. You can run the *server* (`rojo serve`)
> on Linux even though Studio itself must be on Windows/Mac.

---

## Step-by-step first run

```bash
# 1. Navigate to the game folder
cd /path/to/Valentine-site/viltrumite-sim

# 2. Start the Rojo live-sync server (keep this terminal open)
rojo serve default.project.json
# Output: Rojo server listening on port 34872
```

Then in **Roblox Studio**:

1. Create a new **Baseplate** place (File → New → Baseplate)
2. In the toolbar click the **Rojo** plugin tab
3. Click **Connect** — default target is `localhost:34872`
   (if Studio is on a different machine, use the Linux machine's LAN IP instead)
4. Studio will sync all scripts instantly. Every time you save a `.lua` file,
   Studio reflects the change within ~1 second.

---

## One-time Studio world setup (already handled by MapService)

`MapService.Build()` runs automatically on server start and creates:

- The three conquest zone trigger Parts in `workspace.Zones`
- Grayson Residence, GDA HQ, and Viltrum Outpost builds
- Training stations (Gravity Chamber, Speed Course, Endurance Ring, Meditation Dais)
- Cecil NPC with ProximityPrompt
- All boss spawn points

**You do not need to place anything manually.** Just press Play.

---

## Running the game

| Mode | How | Use for |
|---|---|---|
| **Solo** | Studio toolbar → ▶ Play | Fastest; tests server + one client |
| **Team Test** | Studio toolbar → ▶ Team Test → Start | Multiple local clients; test multiplayer/conquest |
| **Output** | Studio → View → Output | Server print/warn/error messages |

---

## Controls

### Combat
| Key | Action | PL Requirement |
|---|---|---|
| **LMB** | M1 combo (5-hit chain, final hit launches) | Any |
| **Q** (hold) | Block — reduces damage by 70% | Any |
| **E** | Sonic Clap — forward AoE cone | PL 0+ |
| **R** | Viltrumite Rush — supersonic dash | PL 5,000+ |
| **F** | Earth Shatter — requires flight | PL 20,000+ |
| **G** | Thorax Strike — grab | PL 100,000+ |
| **T** | Supreme Overdrive — Pure Viltrumite only | PL 500,000+ |

### Flight
| Key | Action | PL Requirement |
|---|---|---|
| **Z** | Toggle flight | PL 1,000+ |
| **WASD** | Directional flight | — |
| **Space** | Ascend | — |
| **Ctrl** | Descend | — |
| **Shift** | Sprint / boost (sonic trail activates) | — |

### UI
| Key | Action |
|---|---|
| **L** | Toggle leaderboard |
| **H** | Toggle guild panel |
| **E** (near Cecil) | Open quest dialog |
| **E** (near training station) | Begin training session (hold to complete) |

### Mobile (auto-detected on TouchEnabled devices)
Right-side button cluster: ATK, BLK, FLY, SPRINT, E, R, F, G, T
Left virtual joystick appears during flight.

---

## Bloodlines (rolled on first join, stored in DataStore)

| Bloodline | Rarity | Roll chance | Starting PL |
|---|---|---|---|
| Pure Viltrumite | Legendary | ~3% | 50,000 |
| Half-Blood Viltrumite | Rare | ~10% | 10,000 |
| Viltrumite Descendant | Uncommon | ~22% | 1,000 |
| Enhanced Human | Uncommon | ~30% | 100 |
| Human | Common | ~35% | 0 |

To re-roll during testing: open the DataStore for your UserId in Studio's
**DataStore Editor** plugin and delete the key, then rejoin.

---

## Training stations

| Station | Stat | Hold time | PL reward | Cooldown |
|---|---|---|---|---|
| Gravity Chamber | Strength (+0.10% damage/pt) | 5s | +80 PL | 120s |
| Speed Course | Speed (+0.05 WalkSpeed/pt) | 4s | +60 PL | 120s |
| Endurance Ring | Endurance (+2 MaxHealth/pt) | 6s | +70 PL | 120s |
| Meditation Dais | Focus (+0.10% special dmg/pt) | 8s | +40 PL | 120s |

Max 100 points per stat. Stats persist via DataStore.

---

## Boss spawns (auto at 8s after server start)

| Boss | Location | Respawn |
|---|---|---|
| Omni-Man | (0, 5, -80) — near Grayson Residence | 120s |
| Thragg | (120, 5, 80) — Viltrum Outpost area | 120s |
| Conquest | (-80, 5, 120) — GDA HQ area | 120s |
| Immortal | (50, 5, -50) — mid-map | 12s (respawn immune) |

---

## Common issues

| Problem | Fix |
|---|---|
| "Remotes folder never appeared" | `RemoteSetup.server.lua` must run before `Main.server.lua`. Rename it to `AARemoteSetup` if load order breaks. |
| Bosses T-pose / no animations | Animation IDs in `AnimationData.lua` are placeholders. Replace with real IDs from the Roblox animation editor. |
| DataStore errors in Studio | Enable **Allow HTTP Requests** and **Enable Studio Access to API Services** in Game Settings → Security. |
| Training prompt doesn't appear | Stations spawn 0s after `MapService.Build()`. If the world takes time to load, wait 2–3s after Play. |
| Flight doesn't activate | PL must be ≥ 1,000. Check your starting PL matches your bloodline. |

---

## Phase status

- [x] Phase 1 — Core systems: combat, flight, progression, conquest, HUD
- [x] Phase 2 — Boss NPC AI, bloodlines, cosmetics, destruction, map
- [x] Phase 3 — Quests, guild system, leaderboards, cosmetic shop
- [x] Phase 4 — Training system, mobile support
