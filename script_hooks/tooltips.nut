::ModGauntletEvents.TooltipIdentifier <- {
    Screen = {
        Main = {
            Save = ::MSU.Class.BasicTooltip("Save the pool", "Save the current pool")
        }
        Units = {
            Name = ::MSU.Class.BasicTooltip("Name", "In-game name for unit."),
            Num = ::MSU.Class.BasicTooltip("Amount", "Amount of this unit."),
            DifficultyRating = ::MSU.Class.BasicTooltip("Difficulty Rating", "Measure how hard this is. Used as points for building the composition of a fight")
            Weight = ::MSU.Class.BasicTooltip("Weight", "Measure how common a unit would appear in a composition")
        }
    }
}