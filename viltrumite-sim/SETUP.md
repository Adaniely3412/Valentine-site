# Viltrumite Simulator — Setup & Testing Guide

## Prerequisites
- **Roblox Studio** (free, Mac/Windows): https://create.roblox.com/
- **Rojo** (file-sync plugin): https://github.com/rojo-rbx/rojo/releases
  - Install Rojo CLI: `cargo install rojo` or download the binary
  - Install the Rojo Roblox Studio plugin from the releases page

## First-time setup

```bash
# 1. Clone / pull the repo, navigate to the game folder
cd viltrumite-sim

# 2. Start Rojo live-sync server
rojo serve default.project.json
```

Then in Roblox Studio:
1. Open a **Baseplate** place
2. Click the **Rojo** plugin tab → **Connect** (targets localhost:34872)
3. All scripts sync automatically — Studio reflects every file save instantly

## Studio world setup (one time)
The conquest system expects three `Part` instances in Workspace
(or inside a `Workspace.Zones` folder) named exactly:

| Part Name | Suggested location |
|---|---|
| `Grayson Residence` | Suburban area |
| `GDA HQ` | City center |
| `Viltrum Outpost` | Elevated / separate area |

Make each Part large, flat, `Anchored = true`, and `CanCollide = false`
so players walk through it. They act as invisible capture zones.

## Testing
- **Solo play**: Studio `▶ Play` — tests server + client in one window
- **Multiplayer**: Studio `▶ Team Test` — opens multiple clients locally
- **Check output**: View → Output for server print/warn messages

## Controls
| Key | Action |
|---|---|
| **LMB** | M1 combo (5-hit chain, last hit launches) |
| **Q (hold)** | Block / parry |
| **E** | Sonic Clap (PL 0+) |
| **R** | Viltrumite Rush (PL 5,000+) |
| **F** | Earth Shatter — requires flight (PL 20,000+) |
| **G** | Thorax Strike grab (PL 100,000+) |
| **T** | Supreme Overdrive — Pure Viltrumite only (PL 500,000+) |
| **Z** | Toggle flight (PL 1,000+) |
| **Shift** | Sprint / boost while flying |
| **Space / Ctrl** | Ascend / descend while flying |

## Bloodlines (rolled on first join)
| Bloodline | Rarity | Weight |
|---|---|---|
| Pure Viltrumite | Legendary | 3% |
| Half-Blood Viltrumite | Rare | 10% |
| Viltrumite Descendant | Uncommon | 22% |
| Enhanced Human | Uncommon | 30% |
| Human | Common | 35% |

## Phase roadmap
- [x] Phase 1 — Core systems: combat, flight, progression, conquest, HUD
- [ ] Phase 2 — Boss NPC AI, animation IDs, sound effects
- [ ] Phase 3 — Map, destructible environments, cosmetic shop
- [ ] Phase 4 — Quests, guild/warband system, leaderboards
