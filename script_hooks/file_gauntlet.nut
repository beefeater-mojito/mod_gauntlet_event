local mod = ::ModGauntletEvents.Mod;
local gauntletNames = ["GauntletEarly", "GauntletMid", "GauntletLate", "GauntletChampion", "GauntletMiniBoss", "GauntletBoss"];

foreach(name in gauntletNames){
    local filename = name;
    if (!(mod.PersistentData.hasFile(filename))){
        // Get the default data from config/spawnlist_gauntlet file
        local data = ::Const.World.Spawn[name]
        mod.PersistentData.createFile(filename, data)
        local readData = mod.PersistentData.readFile(filename)
        assert(::MSU.deepEquals(readData, data))
    }
}
