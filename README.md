# The Gauntlet

A mod for Battle Brother that add a special event triggering a non-avoidable fight scaled by in-game days. Inspired by [Lezaleas's The Battle Trial](https://www.nexusmods.com/battlebrothers/mods/191?tab=description).

# Features

* Start a non-avoidable, non-retreatable combat at 10-days interval (currently set as default). 
* Implemented as a special event to guarantee events firing at the morning when a certain number of days passed since last gauntlet\*. 
* The enemies composition based on days passed and combat difficulty. 
  * Higher day counts draw tougher enemies from pools divided by early, mid and late game threshold.
  * Enemies pools are hand-crafted and weighted to provide some degree of variety, while limiting too many annoying or squishy enemies.
  * Champions and bosses can spawn in late game pool (requiring some toggles in the Mod Settings).
* Looting after events is toggleable from economy difficulty (and from a mod option menu)\*\*. However, players are guaranteed to receive some supplies after the fight.
* Feature ***an editor*** for gauntlet pools!
  * Each unit's number, difficulty rating, weight and properties can now be user's input.
  * Unit can be added, deleted and even co-spawn with others.
  * Persistent data and saving features for customized gauntlet pool.
* Customizable thresholds, flags and scalings (WIP).
   
\*While the special events (examples are new ambitions and desertions) are checked frequently, there are a few edge cases where events might be prevented from firing, such as wandering near a hostile party.

\*\*This works by enabling `IsArenaMode` in combat properties, allowing `gatherLoot()` to remove non-players loot while let players recover gears from their fallen bros. However, this comes with a few unwanted behaviors, such as corpse resurrection not having full gears (partially fixed by equipping resurrected zombies and skeletons random weapons). 

# Requirements

0. Battle Brother (v1.5.2.2+), with all of the game's DLCs.
1. Adam Mill's Modding Script Hook (v20+).
2. Modern Hooks (v0.6.0+).
3. Modding Standards and Utilities (MSU, v1.9.0+).

# Installation

1. Open `build.bat`, edit your `MODKITDIR` to be your current folder, and `GAME_DATA_DIR` to be your Battle Brother's `data` folder.
2. Run `build.bat`.

# Usage 

## Gauntlet Pool Editor

The Gauntlet Pool Editor is a UI screen that allow player's customization for the current gauntlet pool used in the mod.

To open the pool, press the keybind button \(default is `Ctrl-Shift-P`\) WHILE INSIDE the overworld screen. You can change the keybind in the keybind tab of the gauntlet's Mod Setting menu.

Follow the tooltips for more informations.

### Basic Usage

The Gauntlet Editor allows players to edit a pre-set pool's composition used in the event. A pool consist of multiple units, consisting each unit's Name, Num, Difficulty Rating (DR), Weights and special Flags. The editor allow players to:
* Add or remove a unit from the composition.
* Change a unit's Num, DR, Weights or special Flags.
* Save the current pool composition, or restore to the default value of the current edited pool or every pool.

The editor also includes a help popup regarding the gauntlet event, sort functions for units' enumerable fields, and copy-and-paste the edited pool as JSON's data.

### Temporary state (clean/dirty)

Some operations, like adding/removing unit or changing its value, can affect the pool's data. Player may be prompted to save or discard the current composition, or cancel the operation that would terminal or overwrite unsaved data.

### Copy-and-paste

Players can copy the edited pool's current composition, stored as JSON, into the clipboard. Players can also paste from the clipboard a valid JSON data to parse and overwrite the edited pool's composition. 

## Persistent data

The Gauntlet saves the composition of the default six pools used in the event's logic. Its data are read and written by the MSU's Persistent Data feature. You can access the file at `Documents\Battle Brothers\savegames\MSU#mod_gauntlet_events#GauntletData.sav`.

You can also access a pool's composition by the editor's copy-and-paste feature.

# Suggested setting (WIP)

**For a normal campaign with a few occasional fights:** Cooldown 8-15.

**For a heavy fighting campaign that almost ignore the overworld**: Cooldown 4-7, toggle on "Always Allow Looting".

Players wanting tougher early composition can increase the difficulty modifers inside the Mod Setting menu.

# To-do

* More testing to the late-game pool (WIP!).
* Create a mod option menu that allow further customization on date threshold, scaling and some toggles. (WIP!).
* ~~Create a UI for viewing and editing various gauntlet pools, and even testing them!~~
  * ~~Add option to kick-start a fight with a Difficulty Score input~~.
  * Add gauntlet pool creation. 
* ~~Figure out how to either 1\) disable corpse resurrection on player's dead bros, or 2\) prevent gears lost for resurrected zombie bros~~. At the moment, resurrection from the player's corpses while inside gauntlet fights is disabled, and unarmed, resurrected zombies and skeletons will be re-equipped randomly.
* ...And more!

# Acknowledgement

Thank you to the BB modding community for numerous code references and guidance on technical side of the game. This mod project is possible thanks to:
* [Sato's Rebalanced Vanilla Origin's](https://github.com/jcsato/sato_rebalanced_vanilla_origins/tree/master) for the special event format in their implementation for the Cultist scenario. 
* [Combat Simulator](https://www.nexusmods.com/battlebrothers/mods/564) for various references to the screen UI, and the 'Add Unit' boxes.
* TaroEld's implementation for [the dropdown menu](https://github.com/TaroEld/js_dropdown).


And thank you to the Overhype studio for creating such an amazing game.
