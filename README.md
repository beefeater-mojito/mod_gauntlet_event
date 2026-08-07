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
* Customizable thresholds, flags and scalings. (WIP).

\*While the special events (examples are new ambitions and desertions) are checked frequently, there are a few edge cases where events might be prevented from firing, such as wandering near a hostile party.

\*\*This works by enabling `IsArenaMode` in combat properties, allowing `gatherLoot()` to remove non-players loot while let players recover gears from their fallen bros. However, this comes with a few unwanted behaviors, such as corpse resurrection not having full gears. 

# Requirements

0. Battle Brother (v1.5.2.2+), with all of the game's DLCs.
1. Adam Mill's Modding Script Hook (v20+).
2. Modern Hooks (v0.6.0+).
3. Modding Standards and Utilities (MSU, v1.9.0+).

# Installation

1. Open `build.bat`, edit your `MODKITDIR` to be your current folder containing the `scripts` and `script_hooks` folder.
2. Run `build.bat`.

Alternatively, you can just zip the two folders `scripts` and `script_hooks` and put it inside the data folder, just like what the `build.bat` does.


# Suggested cooldown setting (WIP)

**For a normal campaign with a few occasional fights:** Cooldown 8-15.

**For a heavy fighting campaign that almost ignore the overworld**: Cooldown 5-7, toggle on "Always Allow Looting".

# To-do

* Implementing and testing a late-game pool (WIP!).
* Create a mod option menu that allow further customization on date threshold, scaling and some toggles. (WIP!)
* ~~Figure out how to either 1\) disable corpse resurrection on player's dead bros, or 2\) prevent gears lost for resurrected zombie bros~~. At the moment, resurrection from the player's corpses while inside gauntlet fights is disabled, and unarmed, resurrected zombies and skeletons will be re-equipped randomly.
* ...And more!

# Acknowledgement

Thank you to the BB modding community for numerous code references and guidance on technical side of the game. The special event format was inspired by [Sato's Rebalanced Vanilla Origin's](https://github.com/jcsato/sato_rebalanced_vanilla_origins/tree/master) implementation for the Cultist scenario.

And thank you to Overhype for creating such an amazing game.
