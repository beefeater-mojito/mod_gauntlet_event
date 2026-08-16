local mod = ::ModGauntletEvents.Mod;
local filename = ::ModGauntletEvents.Setup.getFilename();
if (!(mod.PersistentData.hasFile(filename))) {
	::ModGauntletEvents.Setup.writeToFileWithDefaultData();
}