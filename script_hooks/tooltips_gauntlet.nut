this.tooltips_gauntlet <- {
    GauntletEditorScreen = {
        Units = {
            Name = ::MSU.Class.BasicTooltip("Name", "In-game name for unit."),
            Num = ::MSU.Class.BasicTooltip("Amount", "Amount of this unit."),
            DifficultyRating = ::MSU.Class.BasicTooltip("Difficulty Rating", "Measure how hard to fight this unit is. Used as points for building the composition of a fight."),
            Weight = ::MSU.Class.BasicTooltip("Weight", "Measure how common a unit would appear in a composition. An array of every unit with a weight of 1 is a uniform distribution."),
            Flags = ::MSU.Class.BasicTooltip("Flags", "Flags for extra properties of units. These properties are considered to limit the unit's number in a fight, like too many range or squishy units. Hover over each icon for more details.")
        },
        Flags = {
            Range = ::MSU.Class.BasicTooltip("Range", "Unit is considered to be range unit."),
            SquishyMelee = ::MSU.Class.BasicTooltip("Squishy Melee", "Unit often fights in close range, yet doesn't have much survivability."),
            CrowdControl = ::MSU.Class.BasicTooltip("Crowd Control", "Unit can cast debuffs in AOE, or able to call in or resurrect other troops."),
            Boss = ::MSU.Class.BasicTooltip("Champions/Bosses", "Unit will always spawn as champions if variants exist, and will be chosen in the Boss pool. Is set as default in GauntletChampion and GauntletBoss.")
        },
        UnitRowButton = {
            DeleteRow = ::MSU.Class.BasicTooltip("Delete this Row", "Delete this unit row."),
            AddCospawn = ::MSU.Class.BasicTooltip("Add Co-Spawn", "Add units that will spawn along with the main unit. Does not take up a composition's total DR or Num."),
        },
        CombatPopup = {
            DifficultyScore = ::MSU.Class.BasicTooltip("Difficulty Score", "Used to generate the composition.")
            Days = ::MSU.Class.BasicTooltip("Days Combat Taken Place", "Used to determine the base pool. Consult to the threshold setting in the Mod Setting menu.")
            AllowLooting = ::MSU.Class.BasicTooltip("Allow Enemies Gear Drops", "Allow enemies to drop gears in the gauntlet fight.")
            GiveSupplies = ::MSU.Class.BasicTooltip("Give Supplies", "Give players supplies that would be handed out after the fight ends.")
        },
        TopbarButton = {
            RevertChange = ::MSU.Class.BasicTooltip("Revert Changes", "Revert changes made to this pool, and load the its latest version."),
            RestoreThis = ::MSU.Class.BasicTooltip("Restore THIS to Default", "Restore this pool's data to its default value."),
            ViewHelp = ::MSU.Class.BasicTooltip("View help", "View extra infos about the gauntlet mechanic.")
            CopyPool = ::MSU.Class.BasicTooltip("Copy this Pool", "Copy this pool's data as JSON to your clipboard. You can then paste and store it in a txt file."),
            PastePool = ::MSU.Class.BasicTooltip("Paste onto this Pool", "Paste the JSON data from your clipboard and parse it as data for this Gauntlet Pool. Recommend to save this pool before pasting. Newly pasted pool isn't saved yet, so this action can be reverted.")
            Sort = {
                Name = ::MSU.Class.BasicTooltip("Sort by Name", "Sort units by Name, alphabetically.")
                Num = ::MSU.Class.BasicTooltip("Sort by Num", "Sort units by Numbers.")
                Dr = ::MSU.Class.BasicTooltip("Sort by DR", "Sort units by Difficulty Rating.")
                Weight = ::MSU.Class.BasicTooltip("Sort by Weight", "Sort units by Weight.")
            }
        },
        FootbarButton = {
            AddUnit = ::MSU.Class.BasicTooltip("Add a Unit", "Add a unit into the pool, from the game's available units."),
            SavePool = ::MSU.Class.BasicTooltip("Save this Pool", "Save this pool into the mod's data file."),
            RestoreAll = ::MSU.Class.BasicTooltip("Restore ALL to Default", "Restore EVERY POOL's data to the default value. If unsure, please make a backup of the mod's datafile before proceeding!"),
            Close = ::MSU.Class.BasicTooltip("Close the Editor", "Close this editor windows.")
            StartCombat = ::MSU.Class.BasicTooltip("Start a Combat", "Open a pop-up screen for starting a gauntlet combat. Warning: This will use your current party!.")
        }
    }
};

