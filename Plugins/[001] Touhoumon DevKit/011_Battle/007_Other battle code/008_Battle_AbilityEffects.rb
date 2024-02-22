#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Additions of the Touhoumon unique abilities
#	* Tweaks to existing abilities to account for Touhoumon mechanics
#	* Addition of duplicate handlers for Touhoumon abilities
#	* Removed explicit references to Pokemon
#==============================================================================#

Battle::AbilityEffects::StatusImmunity.copy(:MAGMAARMOR,:FIREVEIL)

Battle::AbilityEffects::StatusCure.copy(:MAGMAARMOR,:FIREVEIL)

Battle::AbilityEffects::StatLossImmunity.copy(:CLEARBODY,:WHITESMOKE,:HAKUREIMIKO,:BARRIER)

Battle::AbilityEffects::StatLossImmunity.copy(:HYPERCUTTER,:HISTRENGTH)

Battle::AbilityEffects::PriorityChange.add(:FLOWOFTIME,
  proc { |ability, battler, move, pri|
    next pri+1 if battler.hp<=(battler.totalhp/2)
  }
)

Battle::AbilityEffects::MoveImmunity.add(:FLASHFIRE,
  proc { |ability, user, target, move, type, battle, show_message|
    next false if user.index == target.index
    next false if type != :FIRE
    next false if type != :FIRE18
    if show_message
      battle.pbShowAbilitySplash(target)
      if !target.effects[PBEffects::FlashFire]
        target.effects[PBEffects::FlashFire] = true
        if Battle::Scene::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("The power of {1}'s Fire-type moves rose!", target.pbThis(true)))
        else
          battle.pbDisplay(_INTL("The power of {1}'s Fire-type moves rose because of its {2}!",
             target.pbThis(true), target.abilityName))
        end
      elsif Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
      else
        battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
                               target.pbThis, target.abilityName, move.name))
      end
      battle.pbHideAbilitySplash(target)
    end
    next true
  }
)

Battle::AbilityEffects::MoveImmunity.add(:LIGHTNINGROD,
  proc { |ability, user, target, move, type, battle, show_message|
    next target.pbMoveImmunityStatRaisingAbility(user, move, type,
       :ELECTRIC, :SPECIAL_ATTACK, 1, show_message)
    next target.pbMoveImmunityStatRaisingAbility(user, move, type,
       :WIND18, :SPECIAL_ATTACK, 1, show_message)
  }
)

Battle::AbilityEffects::MoveImmunity.add(:SAPSIPPER,
  proc { |ability, user, target, move, type, battle, show_message|
    next target.pbMoveImmunityStatRaisingAbility(user, move, type,
       :GRASS, :ATTACK, 1, show_message)
    next target.pbMoveImmunityStatRaisingAbility(user, move, type,
       :NATURE18, :ATTACK, 1, show_message)
  }
)

Battle::AbilityEffects::MoveImmunity.add(:STORMDRAIN,
  proc { |ability, user, target, move, type, battle, show_message|
    next target.pbMoveImmunityStatRaisingAbility(user, move, type,
       :WATER, :SPECIAL_ATTACK, 1, show_message)
    next target.pbMoveImmunityStatRaisingAbility(user, move, type,
       :WATER18, :SPECIAL_ATTACK, 1, show_message)
  }
)

Battle::AbilityEffects::MoveImmunity.add(:TELEPATHY,
  proc { |ability, user, target, move, type, battle, show_message|
    next false if move.statusMove?
    next false if user.index == target.index || target.opposes?(user)
    if show_message
      battle.pbShowAbilitySplash(target)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} avoids attacks by its ally!", target.pbThis(true)))
      else
        battle.pbDisplay(_INTL("{1} avoids attacks by its ally with {2}!",
           target.pbThis, target.abilityName))
      end
      battle.pbHideAbilitySplash(target)
    end
    next true
  }
)

Battle::AbilityEffects::MoveImmunity.add(:VOLTABSORB,
  proc { |ability, user, target, move, type, battle, show_message|
    next target.pbMoveImmunityHealingAbility(user, move, type, :ELECTRIC, show_message)
    next target.pbMoveImmunityHealingAbility(user, move, type, :WIND18, show_message)
  }
)

Battle::AbilityEffects::MoveImmunity.add(:WATERABSORB,
  proc { |ability, user, target, move, type, battle, show_message|
    next target.pbMoveImmunityHealingAbility(user, move, type, :WATER, show_message)
    next target.pbMoveImmunityHealingAbility(user, move, type, :WATER18, show_message)
  }
)

Battle::AbilityEffects::MoveImmunity.copy(:WONDERGUARD,:PLAYGHOST)

Battle::AbilityEffects::AccuracyCalcFromUser.copy(:COMPOUNDEYES,:FOCUS)

Battle::AbilityEffects::AccuracyCalcFromTarget.add(:LIGHTNINGROD,
  proc { |ability, mods, user, target, move, type|
    mods[:base_accuracy] = 0 if (type == :ELECTRIC ||
    							 type == :WIND18)
  }
)

Battle::AbilityEffects::AccuracyCalcFromTarget.add(:STORMDRAIN,
  proc { |ability, mods, user, target, move, type|
    mods[:base_accuracy] = 0 if (type == :WATER ||
    							 type == :WATER18)
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:BLAZE,
  proc { |ability, user, target, move, mults, power, type|
    if user.hp <= user.totalhp / 3 && (type == :FIRE ||
									   type == :FIRE18)
      mults[:attack_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:FLASHFIRE,
  proc { |ability, user, target, move, mults, power, type|
    if user.effects[PBEffects::FlashFire] && (type == :FIRE ||
    										  type == :FIRE18)
      mults[:attack_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.copy(:HUGEPOWER,:PUREPOWER,:UNZAN)

Battle::AbilityEffects::DamageCalcFromUser.add(:OVERGROW,
  proc { |ability, user, target, move, mults, power, type|
    if user.hp <= user.totalhp / 3 && (type == :GRASS ||
    								   type == :NATURE18)
      mults[:attack_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:SANDFORCE,
  proc { |ability, user, target, move, mults, power, type|
    if user.effectiveWeather == :Sandstorm &&
       [:ROCK, :GROUND, :STEEL, :EARTH18, :BEAST18, :STEEL18].include?(type)
      mults[:power_multiplier] *= 1.3
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:INNERPOWER,
  proc { |ability, user, target, move, mults, power, type|
    if user.hp <= user.totalhp / 3 && type == :DREAM18
      mults[:attack_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:TORRENT,
  proc { |ability, user, target, move, mults, power, type|
    if user.hp <= user.totalhp / 3 && (type == :WATER ||
    								   type == :WATER18)
      mults[:attack_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:DRYSKIN,
  proc { |ability, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.25 if (type == :FIRE ||
    										   type == :FIRE18)
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:HEATPROOF,
  proc { |ability, user, target, move, mults, power, type|
    mults[:power_multiplier] /= 2 if (type == :FIRE ||
											type == :FIRE18)
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.copy(:MARVELSCALE,:SPRINGCHARM)
#BattleHandlers::DamageCalcTargetAbility.add(:SPRINGCHARM,
#  proc { |ability,user,target,move,mults,power,type|
#    if target.pbHasAnyStatus? && move.physicalMove?
#      mults[:defense_multiplier] *= 1.5
#    end
#  }
#)

Battle::AbilityEffects::DamageCalcFromTarget.add(:THICKFAT,
  proc { |ability, user, target, move, mults, power, type|
    mults[:power_multiplier] /= 2 if [:FIRE, :ICE, :FIRE18, :ICE18].include?(type)
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.copy(:THICKFAT,:ICEWALL)

Battle::AbilityEffects::CriticalCalcFromTarget.copy(:BATTLEARMOR,:SHELLARMOR,:GUARDARMOR)

Battle::AbilityEffects::OnBeingHit.copy(:EFFECTSPORE,:INFECTIOUS)

Battle::AbilityEffects::OnBeingHit.add(:DOLLWALL,
  proc { |ability, user, target, move, battle|
    next if !move.pbContactMove?(user)
    battle.pbShowAbilitySplash(target)
    if user.takesIndirectDamage?(Battle::Scene::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      battle.scene.pbDamageAnimation(user)
      user.pbReduceHP(user.totalhp / 16, false)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is hurt!", user.pbThis))
      else
        battle.pbDisplay(_INTL("{1} is hurt by {2}'s {3}!", user.pbThis,
           target.pbThis(true), target.abilityName))
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:RETRIBUTION,
  proc { |ability, user, target, move, battle|
    next if !move.pbContactMove?(user)
    battle.pbShowAbilitySplash(target)
    if user.takesIndirectDamage?(Battle::Scene::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      battle.scene.pbDamageAnimation(user)
      user.pbReduceHP((user.pbReduceHP(1000)).floor)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} was not prepared!", user.pbThis))
      else
        battle.pbDisplay(_INTL("{1} was not prepared for {2}'s {3}!", user.pbThis,
           target.pbThis(true), target.abilityName))
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::OnBeingHit.copy(:POISONPOINT,:POISONBODY)

Battle::AbilityEffects::OnDealingHit.add(:POISONTOUCH,
  proc { |ability, user, target, move, battle|
    next if !move.contactMove?
    next if battle.pbRandom(100) >= 30
    battle.pbShowAbilitySplash(user)
    if (target.hasActiveAbility?(:SHIELDDUST) ||
       target.hasActiveAbility?(:ADVENT)) && !battle.moldBreaker
      battle.pbShowAbilitySplash(target)
      if !Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis))
      end
      battle.pbHideAbilitySplash(target)
    elsif target.pbCanPoison?(user, Battle::Scene::USE_ABILITY_SPLASH)
      msg = nil
      if !Battle::Scene::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} poisoned {3}!", user.pbThis, user.abilityName, target.pbThis(true))
      end
      target.pbPoison(user, msg)
    end
    battle.pbHideAbilitySplash(user)
  }
)

Battle::AbilityEffects::OnEndOfUsingMove.add(:MAGICIAN,
  proc { |ability, user, targets, move, battle|
    next if battle.futureSight
    next if !move.pbDamagingMove?
    next if user.item
    next if user.wild?
    targets.each do |b|
      next if b.damageState.unaffected || b.damageState.substitute
      next if !b.item
      next if b.unlosableItem?(b.item) || user.unlosableItem?(b.item)
      battle.pbShowAbilitySplash(user)
      if (b.hasActiveAbility?(:STICKYHOLD) || b.hasActiveAbility?(:COLLECTOR))
        battle.pbShowAbilitySplash(b) if user.opposes?(b)
        if Battle::Scene::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1}'s item cannot be stolen!", b.pbThis))
        end
        battle.pbHideAbilitySplash(b) if user.opposes?(b)
        next
      end
      user.item = b.item
      b.item = nil
      b.effects[PBEffects::Unburden] = true if b.hasActiveAbility?(:UNBURDEN)
      if battle.wildBattle? && !user.initialItem && user.item == b.initialItem
        user.setInitialItem(user.item)
        b.setInitialItem(nil)
      end
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} stole {2}'s {3}!", user.pbThis,
           b.pbThis(true), user.itemName))
      else
        battle.pbDisplay(_INTL("{1} stole {2}'s {3} with {4}!", user.pbThis,
           b.pbThis(true), user.itemName, user.abilityName))
      end
      battle.pbHideAbilitySplash(user)
      user.pbHeldItemTriggerCheck
      break
    end
  }
)

Battle::AbilityEffects::OnEndOfUsingMove.add(:GEHABURN,
  proc { |ability, user, targets, move, battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted == 0 || !user.pbCanRaiseStatStage?(:ATTACK, user)
    battle.pbDisplay(_INTL("{1} drew power from {2} by defeating their foes!",user.pbThis,
		user.abilityName))
    user.pbRaiseStatStageByAbility(:ATTACK, numFainted, user)
  }
)

Battle::AbilityEffects::AfterMoveUseFromTarget.copy(:COLORCHANGE,:MYSTERIOUS)

Battle::AbilityEffects::AfterMoveUseFromTarget.add(:PICKPOCKET,
  proc { |ability, target, user, move, switched_battlers, battle|
    # NOTE: According to Bulbapedia, this can still trigger to steal the user's
    #       item even if it was switched out by a Red Card. That doesn't make
    #       sense, so this code doesn't do it.
    next if target.wild?
    next if switched_battlers.include?(user.index)   # User was switched out
    next if !move.contactMove?
    next if user.effects[PBEffects::Substitute] > 0 || target.damageState.substitute
    next if target.item || !user.item
    next if user.unlosableItem?(user.item) || target.unlosableItem?(user.item)
    battle.pbShowAbilitySplash(target)
    if (user.hasActiveAbility?(:STICKYHOLD) || user.hasActiveAbility?(:COLLECTOR))
      battle.pbShowAbilitySplash(user) if target.opposes?(user)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s item cannot be stolen!", user.pbThis))
      end
      battle.pbHideAbilitySplash(user) if target.opposes?(user)
      battle.pbHideAbilitySplash(target)
      next
    end
    target.item = user.item
    user.item = nil
    user.effects[PBEffects::Unburden] = true if user.hasActiveAbility?(:UNBURDEN)
    if battle.wildBattle? && !target.initialItem && target.item == user.initialItem
      target.setInitialItem(target.item)
      user.setInitialItem(nil)
    end
    battle.pbDisplay(_INTL("{1} pickpocketed {2}'s {3}!", target.pbThis,
       user.pbThis(true), target.itemName))
    battle.pbHideAbilitySplash(target)
    target.pbHeldItemTriggerCheck
  }
)

Battle::AbilityEffects::EndOfRoundHealing.copy(:SHEDSKIN,:MAINTENANCE)

# Derx: Custom Ability for Ayakashi, not in Vanilla 1.8
# Abyssal Drain - Drains foes by 1/16th max hp
Battle::AbilityEffects::EndOfRoundEffect.add(:ABYSSALDRAIN,
  proc { |ability, battler, battle|
    battle.allOtherSideBattlers(battler.index).each do |b|
      next if !b.near?(battler)
      battle.pbShowAbilitySplash(battler)
      next if !b.takesIndirectDamage?(Battle::Scene::USE_ABILITY_SPLASH)
      b.pbTakeEffectDamage(b.totalhp / 16) { |hp_lost|
        if Battle::Scene::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1}'s lifeforce is being taken!", b.pbThis))
        else
          battle.pbDisplay(_INTL("{1}'s lifeforce is being taken by {2}'s {3}!",
             b.pbThis, battler.pbThis(true), battler.abilityName))
        end
        battle.pbHideAbilitySplash(battler)
      }
    end
  }
)

Battle::AbilityEffects::EndOfRoundGainItem.add(:GRAVEROBBER,
  proc { |ability, battler, battle|
    next if battler.item
    foundItem = nil
    fromBattler = nil
    use = 0
    battle.allBattlers.each do |b|
      next if b.index == battler.index
      next if b.effects[PBEffects::PickupUse] <= use
      foundItem   = b.effects[PBEffects::PickupItem]
      fromBattler = b
      use         = b.effects[PBEffects::PickupUse]
    end
    next if !foundItem
    battle.pbShowAbilitySplash(battler)
    battler.item = foundItem
    fromBattler.effects[PBEffects::PickupItem] = nil
    fromBattler.effects[PBEffects::PickupUse]  = 0
    fromBattler.setRecycleItem(nil) if fromBattler.recycleItem == foundItem
    if battle.wildBattle? && !battler.initialItem && fromBattler.initialItem == foundItem
      battler.setInitialItem(foundItem)
      fromBattler.setInitialItem(nil)
    end
    battle.pbDisplay(_INTL("{1} dug up one {2}!", battler.pbThis, battler.itemName))
    battle.pbHideAbilitySplash(battler)
    battler.pbHeldItemTriggerCheck
  }
)

# Derx: Renamed 1.8 Shadow Tag to Piercing Stare so it doesn't work like Pokemon's Shadow Tag.
Battle::AbilityEffects::TrappingByTarget.copy(:ARENATRAP,:PIERCINGSTARE)

Battle::AbilityEffects::OnSwitchIn.add(:NEUTRALIZINGGAS,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler, true)
    battle.pbHideAbilitySplash(battler)
    battle.pbDisplay(_INTL("Neutralizing gas filled the area!"))
    battle.allBattlers.each do |b|
      # Slow Start - end all turn counts
      b.effects[PBEffects::SlowStart] = 0
      # Truant - let b move on its first turn after Neutralizing Gas disappears
      b.effects[PBEffects::Truant] = false
      # Gorilla Tactics - end choice lock
      if !b.hasActiveItem?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF,
	                        :BLOOMERS, :POWERRIBBON, :POWERGOGGLES, :POWERCAPE])
        b.effects[PBEffects::ChoiceBand] = nil
      end
      # Illusion - end illusions
      if b.effects[PBEffects::Illusion]
        b.effects[PBEffects::Illusion] = nil
        if !b.effects[PBEffects::Transform]
          battle.scene.pbChangePokemon(b, b.pokemon)
          battle.pbDisplay(_INTL("{1}'s {2} wore off!", b.pbThis, b.abilityName))
          battle.pbSetSeen(b)
        end
      end
    end
    # Trigger items upon Unnerve being negated
    battler.ability_id = nil   # Allows checking if Unnerve was active before
    had_unnerve = battle.pbCheckGlobalAbility([:UNNERVE, :ASONECHILLINGNEIGH, :ASONEGRIMNEIGH])
    battler.ability_id = :NEUTRALIZINGGAS
    if had_unnerve && !battle.pbCheckGlobalAbility([:UNNERVE, :ASONECHILLINGNEIGH, :ASONEGRIMNEIGH])
      battle.allBattlers.each { |b| b.pbItemsOnUnnerveEnding }
    end
  }
)

Battle::AbilityEffects::OnSwitchIn.copy(:AIRLOCK,:CLOUDNINE,:HISOUTEN,:UNCONCIOUS)

Battle::AbilityEffects::OnSwitchIn.add(:LUCIDDREAMING,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is a sleepwalker!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::ChangeOnBattlerFainting.add(:POWEROFALCHEMY,
  proc { |ability, battler, fainted, battle|
    next if battler.opposes?(fainted)
    next if fainted.ungainableAbility? ||
       [:POWEROFALCHEMY, :RECEIVER, :TRACE, :WONDERGUARD, :PLAYGHOST].include?(fainted.ability_id)
    battle.pbShowAbilitySplash(battler, true)
    battler.ability = fainted.ability
    battle.pbReplaceAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1}'s {2} was taken over!", fainted.pbThis, fainted.abilityName))
    battle.pbHideAbilitySplash(battler)
  }
)