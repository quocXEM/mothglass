# Mothglass

Quiet **shadow-silhouette** puzzles. International indie structure (loc, settings, chambers, transitions).

> Place the lamp. Let shadows remember a shape that never existed in daylight.

## Run

```bash
open -a ~/Coder/Tools/Godot/Godot.app ~/Coder/mothglass
```

F5 → boot splash → **Enter**.

## Controls

| Input | Action |
|---|---|
| Drag lamp | Move light |
| Q / E or wheel | Rotate props (later chambers) |
| Esc | Pause |

## Project layout

```
scenes/          boot, menu, chambers, settings, credits, room
scripts/core/    Loc, Settings, SceneRouter
scripts/game/    GameState, AudioBus
scripts/puzzle/  rooms, shadows
assets/art/      Blender renders + graded sprites
docs/            DESIGN.md
```

## Art pipeline

```bash
~/Coder/Tools/Blender.app/Contents/MacOS/Blender --background \
  --python tools/blender_render_pro.py
```

## Version

**0.2.0** — see `CHANGELOG.md`
