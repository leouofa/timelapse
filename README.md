# Timelapse

A visual novel built with [Godot 4.7](https://godotengine.org) and [Dialogic 2](https://dialogic_solution.github.io/dialogic-docs/).

## Overview

Three characters — Osiris, Voxar, and Horus — discuss an elaborate time-travel prank in a kitchen. The game is entirely driven by Dialogic timelines, characters, and a custom layout style.

## Project Structure

```
main_menu.tscn / main_menu.gd   Title screen with New Game / Continue
timelines/
  first_timeline_kitchen.dtl     The game's dialogue timeline
characters/
  horus.dch, osiris.dch, vox.dch  Character definitions (portraits, colors)
images/                          Portrait art and backgrounds
speech_styles/
  default.tres                   Dialogic layout style (textbox, choices, etc.)
addons/dialogic/                 Dialogic 2 plugin (do not edit)
```

## How the Save / Resume System Works

### Components

| Component | File | Role |
|-----------|------|------|
| Title screen | `main_menu.tscn` + `main_menu.gd` | Entry point; shows New Game / Continue |
| Dialogic Save subsystem | Built into Dialogic addon | Handles serialization of game state |
| Timeline save event | `[save]` in `.dtl` files | Creates a save slot at a specific point |
| Autosave | Enabled in `project.godot` | Saves automatically on timeline jumps |

### Flow

```
Game launch
  |
  v
main_menu._ready()
  |-- checks Dialogic.Save.has_slot("Default")
  |-- if save exists  -->  shows "Continue" button
  |-- if no save      -->  hides "Continue" button
  |
  +---> [New Game]  -->  delete old save (if any)
  |                      Dialogic.start("first_timeline_kitchen")
  |                      [save] event creates the default save slot
  |                      autosave keeps it updated on every timeline jump
  |
  +---> [Continue]  -->  Dialogic.Save.load()
                         restores full state (timeline + event index + subsystems)
                         resumes at the exact event where the player left off
```

### What Gets Saved

Dialogic's save system serializes a `DialogicSaveState` containing:

- **Timeline path** — which `.dtl` file is active
- **Event index** — exact position within the timeline
- **Subsystem state** — every subsystem's `@export` variables (jump stack, variables, text history, etc.)

### What Gets Auto-Saved

Autosave is configured to trigger on **timeline jumps** (`autosave_mode=0`), which covers:

- Timeline start (`timeline_started` signal)
- Timeline end (`timeline_ended` signal)
- `[jump]` events within the timeline

This means the save stays current as the player progresses.

### Adding New Timelines

1. Create a `.dtl` file in `timelines/`
2. Add `[save]` at the point in the timeline where you want the save slot to be updated (typically the first line)
3. Register it in `project.godot` under `[dialogic] directories/dtl_directory`
4. Reference it in code via `Dialogic.start("timeline_name")`

### Adding Save Points

Insert `[save]` events at chosen points in the timeline:

```
[some dialogue]
[save]
[mor dialogue continues from here]
```

Without a slot name, it saves to the default slot. To use named slots:

```
[save slot="Chapter1"]
```

### Multiple Save Slots

The infrastructure supports multiple slots. Key API:

```gdscript
Dialogic.Save.add_empty_slot("SlotName")
Dialogic.Save.has_slot("SlotName")       # bool
Dialogic.Save.save("SlotName")           # save
Dialogic.Save.load("SlotName")           # load & resume
Dialogic.Save.delete_slot("SlotName")
Dialogic.Save.get_slot_names()           # Array[String]
```

To add a slot picker UI, query `get_slot_names()` and render a button per slot, calling `load(slot_name)` on selection.

## Running the Game

Open the project in Godot 4.7+ and press F5 (or click Play). The game starts at the title screen.

## Controls

- **Left Click / Enter / Space** — advance dialogue (Dialogic default action)
