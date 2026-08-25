local mod = ::ModGauntletEvents.Mod;
local filename = ::ModGauntletEvents.Setup.getFilename();
if (!(mod.PersistentData.hasFile(filename))) {
	::ModGauntletEvents.Setup.defaultOverwriteAll();
} else {

	::logDebug("VERIFYING GAUNTLET FILE!");
	local verifiedFile = ::ModGauntletEvents.Setup.assertFileDataIsCorrect()
	if (verifiedFile){
		::logDebug("VERIFYING SUCCESS!")
	} else {
		::logError("VERIFYING FAILED! CONSULT TO THE LOG!");

		::logError("FOR MOD USER, RESTORE DEFAULT TO THE INVALID POOL MIGHT FIX THIS!")
	}
}