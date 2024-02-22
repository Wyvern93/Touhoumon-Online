#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Tweaks to existing move effects to account for Touhoumon mechanics
#==============================================================================#



#===============================================================================
# In wild battles, makes target flee. Fails if target is a higher level than the
# user.
# In trainer battles, target switches out.
# For status moves. (Roar, Whirlwind)
#
# Addition: Added in a check for Gatekeeper, which is a clone of Suction Cups
#===============================================================================
class Battle::Move::SwitchOutTargetStatusMove < Battle::Move
  def pbFailsAgainstTarget?(user, target, show_message)
    if target.hasActiveAbility?(:SUCTIONCUPS) && !@battle.moldBreaker
      if show_message
        @battle.pbShowAbilitySplash(target)
        if Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} anchors itself!", target.pbThis))
        else
          @battle.pbDisplay(_INTL("{1} anchors itself with {2}!", target.pbThis, target.abilityName))
        end
        @battle.pbHideAbilitySplash(target)
      end
      return true
	elsif target.hasActiveAbility?(:GATEKEEPER) && !@battle.moldBreaker
      if show_message
        @battle.pbShowAbilitySplash(target)
        if Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} stood resolte!", target.pbThis))
        else
          @battle.pbDisplay(_INTL("{1} stood resolute like a {2}!", target.pbThis, target.abilityName))
        end
        @battle.pbHideAbilitySplash(target)
      end
      return true
    end
    if target.effects[PBEffects::Ingrain]
      @battle.pbDisplay(_INTL("{1} anchored itself with its roots!", target.pbThis)) if show_message
      return true
    end
    if target.wild? && target.allAllies.length == 0 && @battle.canRun
      # End the battle
      if target.level > user.level
        @battle.pbDisplay(_INTL("But it failed!")) if show_message
        return true
      end
    elsif !target.wild?
      # Switch target out
      canSwitch = false
      @battle.eachInTeamFromBattlerIndex(target.index) do |_pkmn, i|
        canSwitch = @battle.pbCanSwitchIn?(target.index, i)
        break if canSwitch
      end
      if !canSwitch
        @battle.pbDisplay(_INTL("But it failed!")) if show_message
        return true
      end
    else
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end
end

#===============================================================================
# When used against a sole wild Pokémon, makes target flee and ends the battle;
# fails if target is a higher level than the user.
# When used against a trainer's Pokémon, target switches out.
# For damaging moves. (Circle Throw, Dragon Tail)
#
# Addition: Added in a check for Gateekeper
#===============================================================================
class Battle::Move::SwitchOutTargetDamagingMove < Battle::Move
  def pbSwitchOutTargetEffect(user, targets, numHits, switched_battlers)
    return if !switched_battlers.empty?
    return if user.fainted? || numHits == 0
    targets.each do |b|
      next if b.fainted? || b.damageState.unaffected || b.damageState.substitute
      next if b.wild?
      next if b.effects[PBEffects::Ingrain]
      next if (b.hasActiveAbility?(:SUCTIONCUPS) ||
			   b.hasActiveAbility?(:GATEKEEPER)) && !@battle.moldBreaker
      newPkmn = @battle.pbGetReplacementPokemonIndex(b.index, true)   # Random
      next if newPkmn < 0
      @battle.pbRecallAndReplace(b.index, newPkmn, true)
      @battle.pbDisplay(_INTL("{1} was dragged out!", b.pbThis))
      @battle.pbClearChoice(b.index)   # Replacement Pokémon does nothing this round
      @battle.pbOnBattlerEnteringBattle(b.index)
      switched_battlers.push(b.index)
      break
    end
  end
end

#===============================================================================
# The target uses its most recent move again. (Instruct)
# 
# Additions: Added Recollection to Instruct's blacklist
#===============================================================================
class Battle::Move::TargetUsesItsLastUsedMoveAgain < Battle::Move
  def initialize(battle, move)
    super
    @moveBlacklist = [
      "MultiTurnAttackBideThenReturnDoubleDamage",       # Bide
      "ProtectUserFromDamagingMovesKingsShield",         # King's Shield
      "TargetUsesItsLastUsedMoveAgain",                  # Instruct (this move)
      # Struggle
      "Struggle",                                        # Struggle
      # Moves that affect the moveset
      "ReplaceMoveThisBattleWithTargetLastMoveUsed",     # Mimic
      "ReplaceMoveWithTargetLastMoveUsed",               # Sketch
      "TransformUserIntoTarget",                         # Transform
	  "UserCopiesMovesWithoutTransforming",			   	   # Recollection
      # Moves that call other moves
      "UseLastMoveUsedByTarget",                         # Mirror Move
      "UseLastMoveUsed",                                 # Copycat
      "UseMoveTargetIsAboutToUse",                       # Me First
      "UseMoveDependingOnEnvironment",                   # Nature Power
      "UseRandomUserMoveIfAsleep",                       # Sleep Talk
      "UseRandomMoveFromUserParty",                      # Assist
      "UseRandomMove",                                   # Metronome
      # Moves that require a recharge turn
      "AttackAndSkipNextTurn",                           # Hyper Beam
      # Two-turn attacks
      "TwoTurnAttack",                                   # Razor Wind
      "TwoTurnAttackOneTurnInSun",                       # Solar Beam, Solar Blade
      "TwoTurnAttackParalyzeTarget",                     # Freeze Shock
      "TwoTurnAttackBurnTarget",                         # Ice Burn
      "TwoTurnAttackFlinchTarget",                       # Sky Attack
      "TwoTurnAttackChargeRaiseUserDefense1",            # Skull Bash
      "TwoTurnAttackInvulnerableInSky",                  # Fly
      "TwoTurnAttackInvulnerableUnderground",            # Dig
      "TwoTurnAttackInvulnerableUnderwater",             # Dive
      "TwoTurnAttackInvulnerableInSkyParalyzeTarget",    # Bounce
      "TwoTurnAttackInvulnerableRemoveProtections",      # Shadow Force, Phantom Force
      "TwoTurnAttackInvulnerableInSkyTargetCannotAct",   # Sky Drop
      "AllBattlersLoseHalfHPUserSkipsNextTurn",          # Shadow Half
      "TwoTurnAttackRaiseUserSpAtkSpDefSpd2",            # Geomancy
      # Moves that start focussing at the start of the round
      "FailsIfUserDamagedThisTurn",                      # Focus Punch
      "UsedAfterUserTakesPhysicalDamage",                # Shell Trap
      "BurnAttackerBeforeUserActs"                       # Beak Blast
    ]
  end
end
#===============================================================================
# For 4 rounds, the target must use the same move each round. (Encore)
#
# Addition: Added Recollection to Encore's blacklist
#===============================================================================
class Battle::Move::DisableTargetUsingDifferentMove < Battle::Move
  def initialize(battle, move)
    super
    @moveBlacklist = [
      "DisableTargetUsingDifferentMove",               # Encore
      # Struggle
      "Struggle",                                      # Struggle
      # Moves that affect the moveset
      "ReplaceMoveThisBattleWithTargetLastMoveUsed",   # Mimic
      "ReplaceMoveWithTargetLastMoveUsed",             # Sketch
      "TransformUserIntoTarget",                       # Transform
	  "UserCopiesMovesWithoutTransforming",			   	   # Recollection
      # Moves that call other moves (see also below)
      "UseLastMoveUsedByTarget"                        # Mirror Move
    ]
    if Settings::MECHANICS_GENERATION >= 7
      @moveBlacklist += [
        # Moves that call other moves
#        "UseLastMoveUsedByTarget",                    # Mirror Move   # See above
        "UseLastMoveUsed",                             # Copycat
        "UseMoveTargetIsAboutToUse",                   # Me First
        "UseMoveDependingOnEnvironment",               # Nature Power
        "UseRandomUserMoveIfAsleep",                   # Sleep Talk
        "UseRandomMoveFromUserParty",                  # Assist
        "UseRandomMove"                                # Metronome
      ]
    end
  end
end