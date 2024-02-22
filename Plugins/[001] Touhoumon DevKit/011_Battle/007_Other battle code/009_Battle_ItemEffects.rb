#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Additions of the various Touhoumon items
#	* Changes to vanilla Pokemon items to accomidate new Touhoumon mechanics
#	* Changed it so that Rock Incense had its own entry so it could buff
#	  Earth types and wouldn't be copied by Hard Stone/Stone Plate
#	* Changed it so that Rose Incense had its own entry so it could buff
#	  Nature types and wouldn't be copied by Miracle Seed/Meadow Plate
#	* Changed it so that Sea Incense had its own entry so it could buff
#	  Touhoumon Water types and wouldn't be copied by Mystic Water/Splash Plate
#	* Changed it so that Odd Incense had its own entry so it could buff
#	  Reason types and wouldn't be copied by Twisted Spoon/Mind Plate
#	* Added the Scepter Spheres, which are used by Sariel Omega as Type-Changing
#	  items akin to Arceus' Plates.
#	* Added in the Puppet Gemstones and Hairpins (T1 and T2 Gemstones)
#	* Added in the Pokemon Ribbons (T2 Gemstones)
#	* Added in the Puppet Type Resisting Charms
#	* Added in the Pokemon Type Resisting Pendants
#	* Added in Potato and Baked Potato
#==============================================================================#

Battle::ItemEffects::HPHeal.add(:POTATO,
  proc { |item, battler, battle, forced|
    next false if !battler.canHeal?
    next false if !forced && battler.hp > battler.totalhp / 2
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] Forced consuming of #{itemName}") if forced
    battle.pbCommonAnimation("UseItem", battler) if !forced
    battler.pbRecoverHP(20)
    if forced
      battle.pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} restored its health using its {2}!", battler.pbThis, itemName))
    end
    next true
  }
)

Battle::ItemEffects::HPHeal.add(:BAKEDPOTATO,
  proc { |item, battler, battle, forced|
    next false if !battler.canHeal?
    next false if !forced && battler.hp > battler.totalhp / 2
	next false if battler.status == :NONE &&
                  battler.effects[PBEffects::Confusion] == 0
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] Forced consuming of #{itemName}") if forced
    battle.pbCommonAnimation("UseItem", battler) if !forced
    battler.pbRecoverHP(80)
    if battler.status != :NONE || battler.effects[PBEffects::Confusion] != 0
	  battler.pbCureStatus(forced)
      battler.pbCureConfusion	
	  if forced
		battle.pbDisplay(_INTL("{1} was cured of its ailments and restored HP.", battler.pbThis))
	  else
		battle.pbDisplay(_INTL("{1} was cured of its ailments and restored HP using its {2}!", battler.pbThis, itemName))
	  end
	else
      if forced
		battle.pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
      else
		battle.pbDisplay(_INTL("{1} restored its health using its {2}!", battler.pbThis, itemName))
      end
	end
    next true
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:CHOICEBAND,:BLOOMERS,:POWERRIBBON)
Battle::ItemEffects::DamageCalcFromUser.copy(:CHOICESPECS,:POWERGOGGLES)
Battle::ItemEffects::DamageCalcFromUser.copy(:CHOICESCARF,:POWERCAPE)

Battle::ItemEffects::DamageCalcFromUser.add(:KUSANAGI,
  proc { |item, user, target, move, mults, power, type|
    if user.isSpecies?(:RINNOSKE) && move.specialMove?
      mults[:attack_multiplier] *= 2
    end
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:HARDSTONE,:STONEPLATE)

Battle::ItemEffects::DamageCalcFromUser.add(:ROCKINCENSE,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if (type == :ROCK || type == :EARTH18)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:ICEBALL,
  proc { |item, user, target, move, mults, power, type|
    if user.isSpecies?(:CCIRNO)
      mults[:attack_multiplier] *= 2
    end
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:MIRACLESEED,:MEADOWPLATE)

Battle::ItemEffects::DamageCalcFromUser.add(:ROSEINCENSE,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if (type == :GRASS || type == :NATURE18)
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:MYSTICWATER,:SPLASHPLATE,:WAVEINCENSE)

Battle::ItemEffects::DamageCalcFromUser.add(:SEAINCENSE,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if (type == :WATER || type == :WATER18)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:CURSEDRIBBON,
  proc { |item, user, target, move, mults, power, type|
    if (user.isSpecies?(:CHINA) || user.isSpecies?(:HINA)) && move.physicalMove?
      mults[:attack_multiplier] *= 2
    end
  }
)

Battle::ItemEffects::DamageCalcFromUser.copy(:TWISTEDSPOON,:MINDPLATE)

Battle::ItemEffects::DamageCalcFromUser.add(:ODDINCENSE,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if (type == :PSYCHIC || type == :REASON18)
  }
)

# ----------------------------
Battle::ItemEffects::DamageCalcFromUser.add(:BUNNYSUIT,
  proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :BEAST18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:MAIDCOSTUME,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :STEEL18
  }


)

Battle::ItemEffects::DamageCalcFromUser.add(:SWEATER,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :EARTH18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:CAMOUFLAGE,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :NATURE18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:BLAZER,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :HEART18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:MISTRESS,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :DARK18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:NINJA,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :WIND18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:NURSE,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :MIASMA18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:SWIMSUIT,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :WATER18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:STEWARDESS,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :FLYING18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:THICKFUR,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :ICE18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:KIMONO,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :GHOST18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:WITCH18,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :REASON18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:GOTHIC,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :FIRE18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:BRIDALGOWN,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :ILLUSION18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:PRIESTESS,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :FAITH18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:CHINADRESS,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :DREAM18
  }
)

#------------------------

Battle::ItemEffects::DamageCalcFromTarget.add(:YATAMIRROR,
    proc { |item, user, target, move, mults, power, type|
    if target.isSpecies?(:RINNOSUKE) && move.specialMove?
      mults[:defense_multiplier] *= 2
    end
  }
)

Battle::ItemEffects::CriticalCalcFromUser.add(:NYUUDOUFIST,
  proc { |item, user, target, c|
    next c + 2 if (user.isSpecies?(:CICHIRIN) ||
    			   user.isSpecies?(:ICHIRIN))
  }
)

Battle::ItemEffects::OnBeingHit.add(:POTATO,
  proc { |item, user, target, move, battle|
    next unless [:FIRE,:FIRE18].include?(move.calcType)
    target.pbRemoveItem
	target.setInitialItem(:BAKEDPOTATO)
	target.item= :BAKEDPOTATO
	battle.pbDisplay(_INTL("{1}'s Potato turned into a Baked Potato from the heat!", target.pbThis))
  }
)

Battle::ItemEffects::AfterMoveUseFromUser.add(:POTATO,
  proc { |item, user, targets, move, numHits, battle|
    next unless [:FIRE,:FIRE18].include?(move.calcType)
    target.pbRemoveItem
	target.setInitialItem(:BAKEDPOTATO)
	target.item= :BAKEDPOTATO
	battle.pbDisplay(_INTL("{1}'s Potato turned into a Baked Potato from the heat!", target.pbThis))
  }
)

# --- Pokemon T2 Gemstones - Ribbons
Battle::ItemEffects::DamageCalcFromUser.add(:FIRERIBBON,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:FIRE, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:WATERRIBBON,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:WATER, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:DARKRIBBON,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:DARK, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:DRAGONRIBBON,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:DRAGON, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:ELECTRICRIBBON,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:ELECTRIC, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:FIGHTINGRIBBON,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:FIGHTING, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:FLYINGRIBBON,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:FLYING, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:GHOSTRIBBON,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:GHOST, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:GRASSRIBBON,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:GRASS, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:GROUNDRIBBON,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:GROUND, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:ICERIBBON,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:ICE, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:NORMALRIBBON,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:NORMAL, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:POISONRIBBON,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:POISON, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:PSYCHICRIBBON,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:PSYCHIC, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:ROCKRIBBON,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:ROCK, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:STEELRIBBON,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:STEEL, move, type, mults)
	$game_temp.inertItem = true
  }
)
# ----------------------------------

# --- Puppet T1 Gemstones
Battle::ItemEffects::DamageCalcFromUser.add(:HEMATITE,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:STEEL18, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:QUARTZ,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:EARTH18, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:ONYX,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:BEAST18, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:MALACHITE,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:NATURE18, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:GOLD,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:HEART18, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:OBSIDIAN,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:DARK18, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:JADE,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:WIND18, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:AMETHYST,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:MIASMA18, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:DIAMOND,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:FLYING18, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:LAPISLAZULI,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:ICE18, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:SUGILITE,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:GHOST18, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:OPAL,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:REASON18, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:GARNET,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:FIRE18, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:MORGANITE,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:ILLUSION18, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:TOPAZ,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:FAITH18, move, type, mults)
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:MOONSTONE,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:DREAM18, move, type, mults)
  }
)
# -----------------------

# --- Puppet T2 Gemstones: Hairpins
Battle::ItemEffects::DamageCalcFromUser.add(:HEMATITEHAIRPIN,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:STEEL18, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:QUARTZHAIRPIN,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:EARTH18, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:ONYXHAIRPIN,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:BEAST18, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:MALACHITEHAIRPIN,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:NATURE18, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:GOLDHAIRPIN,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:HEART18, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:OBSIDIANHAIRPIN,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:DARK18, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:JADEHAIRPIN,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:WIND18, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:AMETHYSTHAIRPIN,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:MIASMA18, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:DIAMONDHAIRPIN,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:FLYING18, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:LAPISHAIRPIN,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:ICE18, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:SUGILITEHAIRPIN,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:GHOST18, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:OPALHAIRPIN,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:REASON18, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:GARNETHAIRPIN,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:FIRE18, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:MORGANITEHAIRPIN,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:ILLUSION18, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:TOPAZHAIRPIN,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:FAITH18, move, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:MOONSTONEHAIRPIN,
    proc { |item, user, target, move, mults, power, type|
    user.pbMoveTypePoweringUpGem(:DREAM18, move, type, mults)
	$game_temp.inertItem = true
  }
)
# ---------------------------------

# --- Puppet Scepter Spheres
Battle::ItemEffects::DamageCalcFromUser.add(:DAMASCUSSPHERE,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :STEEL18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:TERRASPHERE,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :EARTH18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:FERALSPHERE,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :BEAST18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:GROWTHSPHERE,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :NATURE18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:TRUSTSPHERE,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :HEART18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:SINSPHERE,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :DARK18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:GUSTSPHERE,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :WIND18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:CORROSIONSPHERE,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :MIASMA18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:FLOODSPHERE,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :HYDRO18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:FLIGHTSPHERE,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :FLYING18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:FROSTSPHERE,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :ICE18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:SOULSPHERE,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :GHOST18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:KNOWLEDGESPHERE,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :REASON18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:BLAZESPHERE,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :FIRE18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:VIRTUESPHERE,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :FAITH18
  }
)

Battle::ItemEffects::DamageCalcFromUser.add(:PHANTASMSPHERE,
    proc { |item, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.2 if type == :DREAM18
  }
)
# --------------------------

# --- Pokemon T2 Damage Resist Berries: Pendants

Battle::ItemEffects::DamageCalcFromTarget.add(:BABIRIPENDANT,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:STEEL, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:CHARTIPENDANT,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:ROCK, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:CHILANPENDANT,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:NORMAL, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:CHOPLEPENDANT,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:FIGHTING, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:COBAPENDANT,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:FLYING, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:COLBURPENDANT,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:DARK, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:HABANPENDANT,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:DRAGON, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:KASIBPENDANT,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:GHOST, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:KEBIAPENDANT,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:POISON, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:OCCAPENDANT,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:FIRE, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:PASSHOPENDANT,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:WATER, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:PAYAPAPENDANT,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:PSYCHIC, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:RINDOPENDANT,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:GRASS, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:SHUCAPENDANT,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:GROUND, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:TANGAPENDANT,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:BUG, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:WACANPENDANT,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:ELECTRIC, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:YACHEPENDANT,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:ICE, type, mults)
	$game_temp.inertItem = true
  }
)
# ----------------------------------------------

# --- Puppet T2 Damage Resist Berries: Charms
Battle::ItemEffects::DamageCalcFromTarget.add(:ANTIMETAL,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:STEEL18, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:ANTIEARTH,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:EARTH18, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:ANTIBEAST,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:BEAST18, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:ANTINATURE,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:NATURE18, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:ANTIHEART,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:HEART18, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:ANTIUMBRAL,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:DARK18, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:ANTIWIND,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:WIND18, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:ANTIMIASMA,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:MIASMA18, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:ANTIHYDRO,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:WATER18, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:ANTIAERO,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:FLYING18, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:ANTICRYO,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:ICE18, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:ANTINETHER,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:GHOST18, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:ANTIREASON,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:REASON18, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:ANTIPYRO,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:FIRE18, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:ANTIILLUSION,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:ILLUSION18, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:ANTIFAITH,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:FAITH18, type, mults)
	$game_temp.inertItem = true
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:ANTIDREAM,
    proc { |item, user, target, move, mults, power, type|
    target.pbMoveTypeWeakeningBerry(:DREAM18, type, mults)
	$game_temp.inertItem = true
  }
)

# ------------------------------------------