local mod = ::ModGauntletEvents.Mod;
local filename = ::ModGauntletEvents.Setup.getFilename();
local setup = ::ModGauntletEvents.Setup;
if (!(mod.PersistentData.hasFile(filename))) {
	setup.defaultOverwriteAll();
} else {
	local debug_init = "VERIFYING GAUNTLET FILE: "; 
	::logDebug(debug_init + "CHECKING POOLS KEYS")
	local check = setup.checkMissingDefaultPoolsNameInFile();
	if (!check){
		::logDebug("FAILED TO CHECK MISSING DEFAULT POOLS NAME!")
		throw "checkMissingDefault FAILED!";
	}

	::logDebug(debug_init + "VERIFYING DATA INSIDE POOLS!");
	local verifiedFile = setup.assertFileDataIsCorrect()
	if (verifiedFile){
		::logDebug("VERIFYING SUCCESS!")
	} else {
		::logError("VERIFYING FAILED! CONSULT TO THE LOG!");

		::logError("FOR MOD USER, RESTORE DEFAULT TO THE INVALID POOL MIGHT FIX THIS!")
	}
}