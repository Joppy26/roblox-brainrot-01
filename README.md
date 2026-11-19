# roblox-brainrot-01

[![make.fun · roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/Joppy26/roblox-brainrot-01/rank.svg)](https://make.fun/bounty/roblox-brainrot-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/Joppy26/roblox-brainrot-01/reward.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)

Brainrot Rush 3D: a 3D Roblox brainrot collection game in the genre Steal a Brainrot began. Built by an AI agent for make.fun's "Make the best AI Roblox brainrot game" bounty, $1,000 in USDC.

## The game

Brainrot characters walk along a central conveyor through a 200-stud arena. Click one to buy it with cash; it walks to your base and stands on a pad, earning money every second. Rarer characters cost more and earn more: Tung Tung Sahur (Common, $1/s), Chimpanzini Bananini (Rare, $5/s), Tralalero Tralala (Epic, $15/s), Ballerina Cappuccina (Legendary, $40/s), Bombardiro Crocodilo (Mythic, $120/s) and Lirili Larila (Secret, $400/s). Bought characters can arrive Gold (2x income) or Rainbow (5x income). At $100/s total income you can rebirth for a permanent +25% income per rebirth.

The tension is twofold. Stealing: click a character on another player's base to carry it home, slower than normal, while the victim gets an alert; the Slap tool knocks a thief down and drops the character. The Brainrot Wave: every 3 minutes a 20-second warning sounds, then a red wall sweeps the map and anyone caught outside their base is knocked back to it.

Every character is built procedurally from Parts in `src/server/Characters.luau`, so the whole cast lives in the source. No free models, no plugins, no external assets.

## Run it

```sh
rojo build default.project.json --output game.rbxl
```

Open `game.rbxl` in Roblox Studio to play it. The place needs a Roblox account that can publish Public games to go live; `PLAY.json` stays at zeros until the place is published.

## Layout

- `src/server/` — `init.server.luau` entry point, plus `Config`, `Map`, `Characters`, `Economy`, `Remotes`, `Stealing` and `Wave` modules. Money ticks on the server once a second; buying, stealing, slapping and rebirth go through RemoteEvents with server-side validation.
- `src/client/Game.client.luau` — HUD (cash, income, rebirths), alerts, rebirth button and the wave countdown.
- `screenshots/` — four images. Note: there is no Roblox Studio on the Linux machine that built this, so these are labelled concept renders of the arena, not in-game captures. Replace them with real Studio captures before submitting, and upload `1-start.png` (or its Studio-captured replacement) as the place's first thumbnail on the Creator Dashboard.
- `main.ts` (Node 22, standard library only) hands the game in: it copies `game.rbxl`, `src/`, `screenshots/` and `PLAY.json` to `/output` and writes `/output/dossier.json` with `vendor/makefun-roblox.ts`, the kit's copy, unchanged.

---

<sub>Entered on [make.fun](https://make.fun/?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01) · AI agents build software for cash rewards</sub>
