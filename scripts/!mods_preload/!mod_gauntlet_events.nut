::ModGauntletEvents <- {
	ID = "mod_gauntlet_events",
	Name = "The Gauntlet",
	Version = "1.2.7",
}
// Instantiate the Modern Hooks object, add MSU as a requirement, and queue after MSU
// https://bbmodding.enduriel.com/docs/modern-hooks/mod-object/
::ModGauntletEvents.MH <- ::Hooks.register(::ModGauntletEvents.ID, ::ModGauntletEvents.Version, ::ModGauntletEvents.Name);
::ModGauntletEvents.MH.require("mod_msu");
::ModGauntletEvents.MH.queue(">mod_msu", function () {
	// Instantiate the MSU Object
	// https://github.com/MSUTeam/MSU/wiki/Mod
	::ModGauntletEvents.Mod <- ::MSU.Class.Mod(::ModGauntletEvents.ID, ::ModGauntletEvents.Version, ::ModGauntletEvents.Name);

	::include("script_hooks/setup_gauntlet");
	::ModGauntletEvents.Setup <- this.new("script_hooks/setup_gauntlet");


	// UI screen
	::Hooks.registerJS("ui/mods/ModGauntletEvents/GauntletPoolEditorScreen.js");
	::Hooks.registerCSS("ui/mods/ModGauntletEvents/GauntletPoolEditorScreen.css")
	::ModGauntletEvents.Screen <- this.new("scripts/ui/screens/gauntlet_pool_editor_screen")
	::MSU.UI.registerConnection(::ModGauntletEvents.Screen)

	::ModGauntletEvents.Mod.Keybinds.addSQKeybind("toggleGauntletPoolCustomization", "ctrl+shift+p", ::MSU.Key.State.World, ::ModGauntletEvents.Screen.toggle.bindenv(::ModGauntletEvents.Screen))

	// Includes the 'load' file of your private folder
	// Within this file, you can execute things or load more files (such as hooks)
	// as to better organise your mod, not clutter this file, and load things in order
	::include("script_hooks/setting_gauntlet.nut")
	::include("script_hooks/hook_gauntlet.nut");
	::include("script_hooks/file_gauntlet.nut");
	::include("script_hooks/tooltips_gauntlet");
	// ::MSU.Log.printData(::ModGauntletEvents.Mod.Tooltips, 10, false);
	::ModGauntletEvents.Mod.Tooltips.setTooltips(this.new("script_hooks/tooltips_gauntlet"))
});