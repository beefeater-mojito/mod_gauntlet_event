::mods_registerMod("gauntlet_events", 1.0, "Gauntlet Event");
::mods_queue("gauntlet_events", null, function(){
	::include("script_hooks/hook_gauntlet")
});

// ::ModGauntletEvents <- {
// 	ID = "mod_gauntlet_events",
// 	Name = "ModGauntletEvents",
// 	Version = "1.0.0",
// 	// Modern Hooks Object
// 	MH = null,
// 	// MSU Object
// 	Mod = null,
// }
// // Instantiate the Modern Hooks object, add MSU as a requirement, and queue after MSU
// // https://bbmodding.enduriel.com/docs/modern-hooks/mod-object/
// ::ModGauntletEvents.MH = ::Hooks.register(::ModGauntletEvents.ID, ::ModGauntletEvents.Version, ::ModGauntletEvents.Name);
// ::ModGauntletEvents.MH.require("mod_msu");
// ::ModGauntletEvents.MH.queue(">mod_msu", function(){
// 	// Instantiate the MSU Object
// 	// https://github.com/MSUTeam/MSU/wiki/Mod
// 	::ModGauntletEvents.Mod = ::MSU.Class.Mod(::ModGauntletEvents.ID, ::ModGauntletEvents.Version, ::ModGauntletEvents.Name);

// 	// Includes the 'load' file of your private folder
// 	// Within this file, you can execute things or load more files (such as hooks)
// 	// as to better organise your mod, not clutter this file, and load things in order
// 	::include("mod_gauntlet_events/load.nut")
// });