this.tooltips_gauntlet <- {
    GauntletEditorScreen = {
        Units = {
            Name = ::MSU.Class.BasicTooltip("Name", "In-game name for unit."),
            Num = ::MSU.Class.BasicTooltip("Amount", "Amount of this unit."),
            DifficultyRating = ::MSU.Class.BasicTooltip("Difficulty Rating", "Measure how hard this is. Used as points for building the composition of a fight."),
            Weight = ::MSU.Class.BasicTooltip("Weight", "Measure how common a unit would appear in a composition."),
            Flags = ::MSU.Class.BasicTooltip("Flags", "Flags for extra properties of units. Hover over each icon for more details.")
        },
        Flags = {
            Range = ::MSU.Class.BasicTooltip("Range", "Unit is able to use range weapons."),
            SquishyMelee = ::MSU.Class.BasicTooltip("Squishy Melee", "Unit often fights in close range, yet doesn't have much survivability."),
            CrowdControl = ::MSU.Class.BasicTooltip("Crowd Control", "Unit can cast debuffs in AOE, or able to call in/resurrect other troops."),
            Boss = ::MSU.Class.BasicTooltip("Champions", "Unit will spawn as champions if variants exist. Is set as default in GauntletChampion and GauntletBoss.")
        },
        UnitRowButton = {
            DeleteRow = ::MSU.Class.BasicTooltip("Delete this Row", "Delete this unit row."),
            AddCospawn = ::MSU.Class.BasicTooltip("Add Co-Spawn", "Add units that will spawn along with the main unit. Does not take up a composition's total DR or Num.")
        },
        FootbarButton = {
            AddUnit = ::MSU.Class.BasicTooltip("Add a Unit", "Add a unit into the pool, from the game's available units."),
            SavePool = ::MSU.Class.BasicTooltip("Save this Pool", "Save this pool into the mod's data file."),
            RestoreThis = ::MSU.Class.BasicTooltip("Restore THIS to Default", "Restore this pool to its initial loaded state."),
            RestoreAll = ::MSU.Class.BasicTooltip("Restore ALL to Default", "Restore EVERY POOL's data to the default value. If unsure, please make a backup of the mod's datafile before proceeding!"),
            Close = ::MSU.Class.BasicTooltip("Close the Editor", "Close this editor windows.")
        }
    }
};

