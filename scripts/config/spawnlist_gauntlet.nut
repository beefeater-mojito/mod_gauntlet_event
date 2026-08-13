local gt = this.getroottable();

if (!("World" in gt.Const)) {
	gt.Const.World <- {};
}

if (!("Spawn" in gt.Const.World)) {
	gt.Const.World.Spawn <- {};
}
// About pool creation, ensure every pool has a melee unit with a DR of 1.
// This unit should also not have any special flag.
// DR value should be positive integer, but technically float can work too
gt.Const.World.Spawn.GauntletEarly <- [
	{
		Cost = 0,
		MovementSpeedMult = 1.0,
		VisibilityMult = 1.0,
		VisionMult = 1.0,
		Body = "figure_bandit_01",
		Troops = [
			{
				Type = this.Const.World.Spawn.Troops.Wardog,
				Num = 3
			}
		],
		DayStartpoint = 0,
		DayEndpoint = 15,
		Pool = [
			{
				Type = this.Const.World.Spawn.Troops.Footman,
				DifficultyRating = 2,
				Weight = 3
			},
			{
				Type = this.Const.World.Spawn.Troops.Billman,
				DifficultyRating = 2,
				Weight = 3,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.Arbalester,
				DifficultyRating = 3,
				IsRange = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ArmoredWardog
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.ManAtArms,
				DifficultyRating = 3
			},
			// gilded
			{
				Type = this.Const.World.Spawn.Troops.Conscript,
				DifficultyRating = 2,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.ConscriptPolearm,
				DifficultyRating = 3,
				Weight = 2,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.CaravanGuard
					}
				]
			},
			// brigand
			{
				Type = this.Const.World.Spawn.Troops.BanditRaider,
				DifficultyRating = 1,
				IsSquishyMelee = true,
				Weight = 4
			},
			{
				Type = this.Const.World.Spawn.Troops.BanditMarksman,
				DifficultyRating = 2,
				IsRange = true,
				Weight = 2,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.Wardog
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.BanditLeader,
				DifficultyRating = 3,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ArmoredWardog
					}
				]
			},
			// nomad
			{
				Type = this.Const.World.Spawn.Troops.NomadOutlaw,
				DifficultyRating = 1,
				Weight = 3
			},
			{
				Type = this.Const.World.Spawn.Troops.NomadArcher,
				DifficultyRating = 1,
				IsRange = true,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.NomadLeader,
				DifficultyRating = 3
			},
			// barb
			{
				Type = this.Const.World.Spawn.Troops.BarbarianMarauder,
				Num = 2,
				DifficultyRating = 3,
				Weight = 3
			},
			// orc
			{
				Type = this.Const.World.Spawn.Troops.OrcYoung,
				DifficultyRating = 1,
				IsSquishyMelee = true,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.OrcBerserker,
				DifficultyRating = 3,
				IsSquishyMelee = true,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.OrcWarriorLOW,
				DifficultyRating = 4
			},
			// gobbo
			{
				Type = this.Const.World.Spawn.Troops.GoblinSkirmisher,
				DifficultyRating = 1,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.GoblinAmbusher,
				DifficultyRating = 2,
				IsRange = true
			},
			{
				Type = this.Const.World.Spawn.Troops.GoblinWolfrider,
				DifficultyRating = 2,
				IsSquishyMelee = true
			},
			// beast
			{
				Type = this.Const.World.Spawn.Troops.Ghoul,
				DifficultyRating = 1,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.Serpent,
				DifficultyRating = 1,
				IsSquishyMelee = true
			},
			// undead
			{
				Type = this.Const.World.Spawn.Troops.ZombieKnight,
				DifficultyRating = 3,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.Warhound
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.Ghost,
				DifficultyRating = 7,
				IsCrowdControl = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ZombieNomad,
						Num = 2
					},
					{
						Type = this.Const.World.Spawn.Troops.ZombieYeomanBodyguard,
						Num = 2
					},
					{
						Type = this.Const.World.Spawn.Troops.ArmoredWardog,
						Num = 2
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.Necromancer,
				DifficultyRating = 11,
				IsCrowdControl = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ZombieYeomanBodyguard,
						Num = 2
					},
					{
						Type = this.Const.World.Spawn.Troops.ZombieNomad,
						Num = 2
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.SkeletonMedium,
				DifficultyRating = 3,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.SkeletonMediumPolearm,
				DifficultyRating = 3,
				Weight = 2
			}
		]
	}
]

gt.Const.World.Spawn.GauntletMid <- [
	{
		Cost = 0,
		MovementSpeedMult = 1.0,
		VisibilityMult = 1.0,
		VisionMult = 1.0,
		Body = "figure_bandit_01",
		Troops = [
			{
				Type = this.Const.World.Spawn.Troops.Wardog,
				Num = 4
			}
		],
		DayStartpoint = 15,
		DayEndpoint = 35,
		Pool = [
			// noble
			{
				Type = this.Const.World.Spawn.Troops.Footman,
				Num = 2,
				DifficultyRating = 3,
				Weight = 4
			},
			{
				Type = this.Const.World.Spawn.Troops.Billman,
				DifficultyRating = 1,
				Weight = 4,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.Arbalester,
				DifficultyRating = 2,
				IsRange = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ArmoredWardog
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.ManAtArms,
				DifficultyRating = 2,
				Weight = 3
			},
			{
				Type = this.Const.World.Spawn.Troops.Sergeant,
				DifficultyRating = 3,
				Weight = 2,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ArmoredWardog
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.Greatsword,
				DifficultyRating = 3,
				Weight = 3,
				IsSquishyMelee = true
			},
			// gilded
			{
				Type = this.Const.World.Spawn.Troops.Conscript,
				DifficultyRating = 2,
				Weight = 4
			},
			{
				Type = this.Const.World.Spawn.Troops.ConscriptPolearm,
				DifficultyRating = 2,
				Weight = 4
			},
			{
				Type = this.Const.World.Spawn.Troops.Gunner,
				DifficultyRating = 3,
				Weight = 3,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.Officer,
				DifficultyRating = 4
			},
			{
				Type = this.Const.World.Spawn.Troops.Assassin,
				DifficultyRating = 4
			},
			{
				Type = this.Const.World.Spawn.Troops.Mortar,
				DifficultyRating = 12,
				IsCrowdControl = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.Engineer,
						Num = 2
					},
					{
						Type = this.Const.World.Spawn.Troops.Officer,
						Num = 1
					}
				]
			},
			// brigand
			{
				Type = this.Const.World.Spawn.Troops.BanditMarauder,
				DifficultyRating = 3,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.BountyHunter,
				DifficultyRating = 3,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.BountyHunterRanged,
				DifficultyRating = 3,
				IsRange = true
			},
			// nomad + glads
			{
				Type = this.Const.World.Spawn.Troops.NomadLeader,
				DifficultyRating = 3
			},
			{
				Type = this.Const.World.Spawn.Troops.Gladiator,
				DifficultyRating = 6
			},
			// barb
			{
				Type = this.Const.World.Spawn.Troops.BarbarianMarauder,
				DifficultyRating = 1,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.BarbarianChampion,
				DifficultyRating = 4,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.BarbarianUnhold,
				DifficultyRating = 7,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.BarbarianBeastmaster
					}
				]
			},
			// orc
			{
				Type = this.Const.World.Spawn.Troops.OrcBerserker,
				DifficultyRating = 2,
				Weight = 3,
				IsSquishyMelee = true,
			},
			{
				Type = this.Const.World.Spawn.Troops.OrcWarrior,
				DifficultyRating = 4,
				Weight = 3
			},
			{
				Type = this.Const.World.Spawn.Troops.OrcWarlord,
				DifficultyRating = 8
			},
			// gobbo
			{
				Type = this.Const.World.Spawn.Troops.GoblinAmbusher,
				DifficultyRating = 2,
				IsRange = true
			},
			{
				Type = this.Const.World.Spawn.Troops.GoblinWolfrider,
				DifficultyRating = 1,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.GoblinOverseer,
				DifficultyRating = 4,
				IsRange = true
			},
			// beast
			{
				Type = this.Const.World.Spawn.Troops.GhoulHIGH,
				DifficultyRating = 2,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.Unhold,
				DifficultyRating = 6,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.UnholdFrost,
				DifficultyRating = 8,
				Weight = 2
			},
			// undead: zombie
			{
				Type = this.Const.World.Spawn.Troops.ZombieKnight,
				DifficultyRating = 2,
				Weight = 3,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.Warhound
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.Ghost,
				DifficultyRating = 7,
				IsCrowdControl = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ZombieKnight,
						Num = 1
					},
					{
						Type = this.Const.World.Spawn.Troops.ZombieNomad,
						Num = 2
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.Necromancer,
				DifficultyRating = 15,
				IsCrowdControl = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ZombieKnightBodyguard
					},
					{
						Type = this.Const.World.Spawn.Troops.ZombieYeomanBodyguard
					},
					{
						Type = this.Const.World.Spawn.Troops.ZombieKnight
					}
				]
			},
			// undead: skellies
			{
				Type = this.Const.World.Spawn.Troops.SkeletonMedium,
				DifficultyRating = 2,
				Weight = 4
			},
			{
				Type = this.Const.World.Spawn.Troops.SkeletonMediumPolearm,
				DifficultyRating = 2,
				Weight = 4,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.VampireLOW,
				DifficultyRating = 6,
				IsSquishyMelee = true
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.SkeletonLight
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.SkeletonHeavy,
				DifficultyRating = 4,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.SkeletonHeavyPolearm,
				DifficultyRating = 4,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.SkeletonPriest,
				DifficultyRating = 13,
				IsCrowdControl = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.SkeletonHeavyBodyguard,
						Num = 1
					}
				]
			},
			// undead: golem
			{
				Type = this.Const.World.Spawn.Troops.LesserFleshGolem,
				DifficultyRating = 4
			}
		]
	}
]

gt.Const.World.Spawn.GauntletLate <- [
	{
		Cost = 0,
		MovementSpeedMult = 1.0,
		VisibilityMult = 1.0,
		VisionMult = 1.0,
		Body = "figure_bandit_01",
		Troops = [
			{
				Type = this.Const.World.Spawn.Troops.Wardog,
				Num = 5
			}
		],
		DayStartpoint = 35,
		DayEndpoint = null,
		Pool = [
			// noble
			{
				Type = this.Const.World.Spawn.Troops.Footman,
				DifficultyRating = 3,
				Num = 2,
				Weight = 3
			},
			{
				Type = this.Const.World.Spawn.Troops.Billman,
				DifficultyRating = 1,
				Weight = 2,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.Arbalester,
				DifficultyRating = 2,
				IsRange = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ArmoredWardog
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.ManAtArms,
				DifficultyRating = 2,
				Weight = 3
			},
			{
				Type = this.Const.World.Spawn.Troops.Sergeant,
				DifficultyRating = 2,
				Weight = 2,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ArmoredWardog
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.Greatsword,
				DifficultyRating = 2,
				Weight = 2,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.Knight,
				DifficultyRating = 5
			},
			// gilded
			{
				Type = this.Const.World.Spawn.Troops.Conscript,
				Num = 2,
				DifficultyRating = 3,
				Weight = 3
			},
			{
				Type = this.Const.World.Spawn.Troops.ConscriptPolearm,
				DifficultyRating = 2,
				Weight = 3,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.Gunner,
				DifficultyRating = 3,
				Weight = 2,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.Officer,
				DifficultyRating = 4,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.Assassin,
				DifficultyRating = 4,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.Mortar,
				DifficultyRating = 11,
				IsCrowdControl = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.Engineer,
						Num = 2
					},
					{
						Type = this.Const.World.Spawn.Troops.Officer,
						Num = 1
					}
				]
			},
			// brigand + merc
			{
				Type = this.Const.World.Spawn.Troops.BanditMarauder,
				DifficultyRating = 3,
				Weight = 3
			},
			{
				Type = this.Const.World.Spawn.Troops.BountyHunter,
				DifficultyRating = 2,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.BountyHunterRanged,
				DifficultyRating = 3,
				IsRange = true
			},
			{
				Type = this.Const.World.Spawn.Troops.HedgeKnight,
				DifficultyRating = 6
			},
			{
				Type = this.Const.World.Spawn.Troops.Oathbringer,
				DifficultyRating = 7
			},
			// nomad + glads
			{
				Type = this.Const.World.Spawn.Troops.Executioner,
				DifficultyRating = 8
			},
			{
				Type = this.Const.World.Spawn.Troops.Gladiator,
				DifficultyRating = 6
			},
			// barb
			{
				Type = this.Const.World.Spawn.Troops.BarbarianChampion,
				DifficultyRating = 4,
				Weight = 3
			},
			{
				Type = this.Const.World.Spawn.Troops.BarbarianUnhold,
				DifficultyRating = 6,
				Weight = 2,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.BarbarianBeastmaster
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.BarbarianUnholdFrost,
				DifficultyRating = 9,
				Weight = 2,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.BarbarianBeastmaster
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.BarbarianChosen,
				DifficultyRating = 6
			},
			// orc
			{
				Type = this.Const.World.Spawn.Troops.OrcBerserker,
				DifficultyRating = 2,
				Weight = 2,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.OrcWarrior,
				DifficultyRating = 4,
				Weight = 3
			},
			{
				Type = this.Const.World.Spawn.Troops.OrcWarlord,
				DifficultyRating = 6
			},
			// gobbo
			{
				Type = this.Const.World.Spawn.Troops.GoblinOverseer,
				DifficultyRating = 4,
				IsRange = true
			},
			// beast
			{
				Type = this.Const.World.Spawn.Troops.UnholdFrost,
				DifficultyRating = 7,
				Weight = 2
			},
			// undead: zombie
			{
				Type = this.Const.World.Spawn.Troops.ZombieKnight,
				DifficultyRating = 2,
				Weight = 2,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ZombieNomad
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.Ghost,
				DifficultyRating = 6,
				IsCrowdControl = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ZombieKnight,
						Num = 4
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.Necromancer,
				DifficultyRating = 17,
				IsCrowdControl = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ZombieKnightBodyguard,
						Num = 2
					},
					{
						Type = this.Const.World.Spawn.Troops.ZombieKnight,
						Num = 2
					}
				]
			},
			// undead: skellies
			{
				Type = this.Const.World.Spawn.Troops.SkeletonMedium,
				Num = 2,
				DifficultyRating = 3,
				Weight = 3
			},
			{
				Type = this.Const.World.Spawn.Troops.SkeletonMediumPolearm,
				Num = 2,
				DifficultyRating = 3,
				Weight = 3,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.Vampire,
				DifficultyRating = 5,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.SkeletonHeavy,
				DifficultyRating = 3,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.SkeletonHeavyPolearm,
				DifficultyRating = 3,
				Weight = 2,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.SkeletonPriest,
				DifficultyRating = 13,
				IsCrowdControl = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.SkeletonHeavyBodyguard,
						Num = 2
					}
				]
			},
			//undead: golem
			{
				Type = this.Const.World.Spawn.Troops.GreaterFleshGolem,
				DifficultyRating = 8
			}
		]
	}
]

gt.Const.World.Spawn.GauntletChampion <- [
	{
		Cost = 0,
		MovementSpeedMult = 1.0,
		VisibilityMult = 1.0,
		VisionMult = 1.0,
		Body = "figure_bandit_01",
		Troops = [
			{
				Type = this.Const.World.Spawn.Troops.Wardog,
				Num = 7
			}
		],
		Pool = [
			{
				Type = this.Const.World.Spawn.Troops.ZombieKnight,
				DifficultyRating = 4
			},
			{
				Type = this.Const.World.Spawn.Troops.BanditLeader,
				DifficultyRating = 5
			},
			{
				Type = this.Const.World.Spawn.Troops.NomadLeader,
				DifficultyRating = 6
			},
			{
				Type = this.Const.World.Spawn.Troops.SkeletonHeavy,
				DifficultyRating = 6
			},
			{
				Type = this.Const.World.Spawn.Troops.OrcWarrior,
				DifficultyRating = 7
			},
			{
				Type = this.Const.World.Spawn.Troops.BarbarianChampion,
				DifficultyRating = 7
			},
			{
				Type = this.Const.World.Spawn.Troops.Officer,
				DifficultyRating = 8
			},
			{
				Type = this.Const.World.Spawn.Troops.BarbarianChosen,
				DifficultyRating = 8
			},
			{
				Type = this.Const.World.Spawn.Troops.OrcWarlord,
				DifficultyRating = 8
			},
			{
				Type = this.Const.World.Spawn.Troops.Knight,
				DifficultyRating = 9
			},
			{
				Type = this.Const.World.Spawn.Troops.HedgeKnight,
				DifficultyRating = 10
			},
			{
				Type = this.Const.World.Spawn.Troops.Gladiator,
				DifficultyRating = 10
			},
			{
				Type = this.Const.World.Spawn.Troops.Oathbringer,
				DifficultyRating = 11
			},
			{
				Type = this.Const.World.Spawn.Troops.Executioner,
				DifficultyRating = 12
			},
		]
	}
]

gt.Const.World.Spawn.GauntletMiniBoss <- [
	{
		Cost = 0,
		MovementSpeedMult = 1.0,
		VisibilityMult = 1.0,
		VisionMult = 1.0,
		Body = "figure_bandit_01",
		Troops = [
			{
				Type = this.Const.World.Spawn.Troops.Wardog,
				Num = 6
			}
		],
		Pool = [
			{
				Type = this.Const.World.Spawn.Troops.Swordmaster,
				DifficultyRating = 25
			},
			{
				Type = this.Const.World.Spawn.Troops.MasterArcher,
				DifficultyRating = 30,
				IsRange = true
			},
			{
				Type = this.Const.World.Spawn.Troops.DesertDevil,
				DifficultyRating = 25,
			},
			{
				Type = this.Const.World.Spawn.Troops.DesertStalker,
				DifficultyRating = 30,
				IsRange = true
			},
			{
				Type = this.Const.World.Spawn.Troops.Lindwurm,
				DifficultyRating = 20
			}
		]
	},
]

gt.Const.World.Spawn.GauntletBoss <- [
	{
		Cost = 0,
		MovementSpeedMult = 1.0,
		VisibilityMult = 1.0,
		VisionMult = 1.0,
		Body = "figure_bandit_01",
		Troops = [
			{
				Type = this.Const.World.Spawn.Troops.Wardog,
				Num = 7
			}
		],
		Pool = [ // enemies here, along with co-spawn, will be spawn as Champion
			{
				Type = this.Const.World.Spawn.Troops.Necromancer,
				DifficultyRating = 35,
				IsCrowdControl = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ZombieKnightBodyguard,
						Num = 2
					},
					{
						Type = this.Const.World.Spawn.Troops.ZombieKnight
						Num = 1
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.Swordmaster,
				DifficultyRating = 50
			},
			{
				Type = this.Const.World.Spawn.Troops.DesertDevil,
				DifficultyRating = 50
			},
			{
				Type = this.Const.World.Spawn.Troops.ZombieBoss,
				DifficultyRating = 45,
				IsCrowdControl = true
			},
			{
				Type = this.Const.World.Spawn.Troops.GrandDiviner,
				DifficultyRating = 35,
				IsCrowdControl = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.FaultFinder,
						Num = 2
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.SkeletonBoss,
				DifficultyRating = 16
			}
		]
	}
]

gt.Const.World.Spawn.GauntletPreset <- [
	{
		Cost = 0,
		MovementSpeedMult = 1.0,
		VisibilityMult = 1.0,
		VisionMult = 1.0,
		Body = "figure_bandit_01",
		Troops = [
			{
				Type = this.Const.World.Spawn.Troops.Wardog,
				Num = 8
			}
		],
		Pool = [
			{
				Type = this.Const.World.Spawn.Troops.Mortar,
				DifficultyRating = 12,
				IsCrowdControl = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.Engineer,
						Num = 2
					},
					{
						Type = this.Const.World.Spawn.Troops.Officer,
						Num = 1
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.ZombieYeoman,
				DifficultyRating = 1
			},
			{
				Type = this.Const.World.Spawn.Troops.ZombieKnight,
				DifficultyRating = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.SkeletonLight,
				DifficultyRating = 1
			},
			{
				Type = this.Const.World.Spawn.Troops.SkeletonHeavy,
				DifficultyRating = 3
			}
		]
	}
]

function onCostCompare(_t1, _t2) {
	if (_t1.Cost < _t2.Cost) {
		return -1;
	} else if (_t1.Cost > _t2.Cost) {
		return 1;
	}

	return 0;
}

function calculateCosts(_p) {
	foreach (p in _p) {
		p.Cost <- 0;

		foreach (t in p.Troops) {
			p.Cost += t.Type.Cost * t.Num;
		}

		if (!("MovementSpeedMult" in p)) {
			p.MovementSpeedMult <- 1.0;
		}
	}

	_p.sort(this.onCostCompare);
}

this.calculateCosts(this.Const.World.Spawn.GauntletEarly)
this.calculateCosts(this.Const.World.Spawn.GauntletMid)
this.calculateCosts(this.Const.World.Spawn.GauntletLate)
this.calculateCosts(this.Const.World.Spawn.GauntletChampion)
this.calculateCosts(this.Const.World.Spawn.GauntletMiniBoss)
this.calculateCosts(this.Const.World.Spawn.GauntletBoss)
this.calculateCosts(this.Const.World.Spawn.GauntletPreset)
