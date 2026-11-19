# Brainrot Rush 3D — design spec for the recorded build

## The game

A 3D Roblox brainrot collection game in the genre Steal a Brainrot began.
Working title: **Brainrot Rush 3D**. One arena, built from Parts in code,
no ScreenGui-only gameplay: the player walks a real 3D character around a
real 3D map.

## Core loop

1. Brainrot characters walk along a central conveyor through the middle of
   the map. Each one shows a floating billboard with its name, its rarity
   and its money per second.
2. The player buys a character with cash. It walks off the conveyor to the
   player's base and stands on a pad, earning money every second.
3. Money buys rarer characters. Rarities climb Common, Rare, Epic,
   Legendary, Mythic, Secret, each with a higher price and a higher
   money-per-second rate.
4. Mutations: a bought character has a small chance to arrive Gold (2x
   income) or Rainbow (5x income). The billboard shows the mutation.
5. Rebirth: once the player owns enough total income, they can rebirth,
   resetting cash and characters for a permanent +25% income multiplier
   per rebirth, shown on the HUD and on the base sign.

## Tension

- Stealing: any player can pick up a character from another player's base
  and carry it home. While carrying, the player is slower and the victim
  gets an alert. A slap tool knocks the carrier down and drops the
  character. This is the genre's signature risk and it must be playable.
- The Wave: every 3 minutes a Brainrot Wave sweeps the middle of the map.
  A 20 second warning sounds, then the wave crosses the conveyor lane.
  Anyone caught outside their base when it passes drops their carried
  character and is knocked back to their base. The dash home is the
  second threat.

## The cast

Six characters, each built procedurally from Parts by the server code so
the whole cast lives in src/ and matches the place scripts:

1. Tung Tung Sahur (Common, $1/s) — a log with a bat.
2. Chimpanzini Bananini (Rare, $5/s) — a chimp holding a banana.
3. Tralalero Tralala (Epic, $15/s) — a shark with legs and sneakers.
4. Ballerina Cappuccina (Legendary, $40/s) — a ballerina with a cappuccino
   cup head.
5. Bombardiro Crocodilo (Mythic, $120/s) — a crocodile bomber plane.
6. Lirili Larila (Secret, $400/s) — a cactus elephant, very rare spawn.

Each model is a small assembly of coloured Parts with a head, a body and
one signature prop, plus a BillboardGui with name, rarity colour and
$/s. Names and labels must be readable at a distance.

## The map

- A baseplate arena, about 200 by 200 studs, with a coloured floor,
  a central conveyor lane, and four player bases at the corners, each
  with 6 character pads, a base sign with the owner's name and income,
  and a spawn point.
- A shop strip along one edge with rarity-coloured stalls, so the
  conveyor reads as a market.
- Lighting: bright daylight, vivid colours, fog off. The game must look
  good in a still screenshot.

## Systems (server authoritative)

- `src/server/init.server.luau` is the entry point. Split the game into
  small modules under `src/server/` (characters, economy, bases, stealing,
  wave, spawning) and a client module under `src/client/` for the HUD,
  the slap tool, the carry prompt and the wave warning.
- Money ticks on the server once a second. Cash and income live in
  leaderstats. Buying, stealing, slapping and rebirth go through
  RemoteEvents with server-side validation (price, ownership, cooldowns).
- No free models, no plugins, no external assets. Every model is built
  from Parts in code, so the place is fully reproducible from src/.

## Deliverables for the recorded session

- Replace the starter's grey-square client and hello-world server with
  the game above. Keep `main.ts` and `vendor/makefun-roblox.ts`
  unchanged.
- Build with Rojo: `~/workspace/makefun/roblox-brainrot-01/tools/rojo
  build default.project.json --output game.rbxl`. Rojo 7.7.1 is already
  installed and verified against the starter. Keep game.rbxl under
  32 MiB.
- Screenshots: 4 PNGs in `screenshots/`, 16:9, each under 256 KiB, long
  side at most 1280, short side at least 480. First by name is the cover
  and is also the thumbnail uploaded for the Roblox place. Capture them
  from a real Roblox run (Studio on the publisher's machine, or a
  headless render if one is available), showing: the conveyor with
  characters and labels, a base full of characters, a steal in progress,
  and the wave warning.
- `PLAY.json` is filled in only after the place is published Public:
  real place_id and universe_id, and the play code in the experience
  description. Do not submit with the starter zeros.

## Publishing (owner step, not the build session)

- The publisher's Roblox account must be at least 2 days old and have
  passed Roblox's age check, and publishing needs Roblox Studio on
  Windows or macOS.
- Publish the place Public, put one of the account's make.fun play
  codes in the experience description, upload the icon and the first
  thumbnail (the same picture as `screenshots/1-start.png`) on the
  Creator Dashboard, and wait for Roblox review.
- Get a play code first: `GET /api/competitions/roblox-brainrot-01/play-code`.
