local mod = ::ModGauntletEvents.Mod;
local gauntletNames = ["GauntletEarly", "GauntletMid", "GauntletLate"];

foreach(name in gauntletNames){
    local filename = mod.ID + name;
    if (!(mod.PersistentData.hasFile(filename))){
        // Get the default data from config/spawnlist_gauntlet file
        local data = ::Const.World.Spawn[name]
        mod.PersistentData.createFile(filename, data)
    }
}
