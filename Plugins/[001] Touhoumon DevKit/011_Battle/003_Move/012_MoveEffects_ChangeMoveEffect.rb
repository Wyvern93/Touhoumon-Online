#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Tweaks to existing move effects to account for Touhoumon mechanics
#==============================================================================#


#===============================================================================
# User is Ghost: User loses 1/2 of max HP, and curses the target.
# Cursed Pokémon lose 1/4 of their max HP at the end of each round.
# User is not Ghost: Decreases the user's Speed by 1 stage, and increases the
# user's Attack and Defense by 1 stage each. (Curse)
#
# Additions: Now made to account for Touhoumon Ghost
#===============================================================================
class Battle::Move::CurseTargetOrLowerUserSpd1RaiseUserAtkDef1 < Battle::Move
  def pbTarget(user)
    if (user.pbHasType?(:GHOST) || user.pbHasType?(:GHOST18))
      ghost_target = (Settings::MECHANICS_GENERATION >= 8) ? :RandomNearFoe : :NearFoe
      return GameData::Target.get(ghost_target)
    end
    return super
  end

  def pbMoveFailed?(user, targets)
    return false if (user.pbHasType?(:GHOST) || user.pbHasType?(:GHOST18))
    failed = true
    (@statUp.length / 2).times do |i|
      next if !user.pbCanRaiseStatStage?(@statUp[i * 2], user, self)
      failed = false
      break
    end
    (@statDown.length / 2).times do |i|
      next if !user.pbCanLowerStatStage?(@statDown[i * 2], user, self)
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if (user.pbHasType?(:GHOST) ||
		user.pbHasType?(:GHOST18)) && target.effects[PBEffects::Curse]
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    return if (user.pbHasType?(:GHOST) ||
			   user.pbHasType?(:GHOST18))
    # Non-Ghost effect
    showAnim = true
    (@statDown.length / 2).times do |i|
      next if !user.pbCanLowerStatStage?(@statDown[i * 2], user, self)
      if user.pbLowerStatStage(@statDown[i * 2], @statDown[(i * 2) + 1], user, showAnim)
        showAnim = false
      end
    end
    showAnim = true
    (@statUp.length / 2).times do |i|
      next if !user.pbCanRaiseStatStage?(@statUp[i * 2], user, self)
      if user.pbRaiseStatStage(@statUp[i * 2], @statUp[(i * 2) + 1], user, showAnim)
        showAnim = false
      end
    end
  end

  def pbEffectAgainstTarget(user, target)
    return if !(user.pbHasType?(:GHOST) ||
				user.pbHasType?(:GHOST18))
    # Ghost effect
    @battle.pbDisplay(_INTL("{1} cut its own HP and laid a curse on {2}!", user.pbThis, target.pbThis(true)))
    target.effects[PBEffects::Curse] = true
    user.pbReduceHP(user.totalhp / 2, false, false)
    user.pbItemHPHealCheck
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    hitNum = 1 if !(user.pbHasType?(:GHOST) ||
					user.pbHasType?(:GHOST18)) # Non-Ghost anim
    super
  end
end

#===============================================================================
# Uses the last move that was used. (Copycat)
#
# Addition: Added Recollection to Copycat's blacklist
#===============================================================================
class Battle::Move::UseLastMoveUsed < Battle::Move
  def initialize(battle, move)
    super
    @moveBlacklist = [
      # Struggle, Belch
      "Struggle",                                          # Struggle
      "FailsIfUserNotConsumedBerry",                       # Belch              # Not listed on Bulbapedia
      # Moves that affect the moveset
      "ReplaceMoveThisBattleWithTargetLastMoveUsed",       # Mimic
      "ReplaceMoveWithTargetLastMoveUsed",                 # Sketch
      "TransformUserIntoTarget",                           # Transform
	  "UserCopiesMovesWithoutTransforming",			   	   # Recollection
      # Counter moves
      "CounterPhysicalDamage",                             # Counter
      "CounterSpecialDamage",                              # Mirror Coat
      "CounterDamagePlusHalf",                             # Metal Burst        # Not listed on Bulbapedia
      # Helping Hand, Feint (always blacklisted together, don't know why)
      "PowerUpAllyMove",                                   # Helping Hand
      "RemoveProtections",                                 # Feint
      # Protection moves
      "ProtectUser",                                       # Detect, Protect
      "ProtectUserSideFromPriorityMoves",                  # Quick Guard        # Not listed on Bulbapedia
      "ProtectUserSideFromMultiTargetDamagingMoves",       # Wide Guard         # Not listed on Bulbapedia
      "UserEnduresFaintingThisTurn",                       # Endure
      "ProtectUserSideFromDamagingMovesIfUserFirstTurn",   # Mat Block
      "ProtectUserSideFromStatusMoves",                    # Crafty Shield      # Not listed on Bulbapedia
      "ProtectUserFromDamagingMovesKingsShield",           # King's Shield
      "ProtectUserFromDamagingMovesObstruct",              # Obstruct           # Not listed on Bulbapedia
      "ProtectUserFromTargetingMovesSpikyShield",          # Spiky Shield
      "ProtectUserBanefulBunker",                          # Baneful Bunker
      # Moves that call other moves
      "UseLastMoveUsedByTarget",                           # Mirror Move
      "UseLastMoveUsed",                                   # Copycat (this move)
      "UseMoveTargetIsAboutToUse",                         # Me First
      "UseMoveDependingOnEnvironment",                     # Nature Power       # Not listed on Bulbapedia
      "UseRandomUserMoveIfAsleep",                         # Sleep Talk
      "UseRandomMoveFromUserParty",                        # Assist
      "UseRandomMove",                                     # Metronome
      # Move-redirecting and stealing moves
      "BounceBackProblemCausingStatusMoves",               # Magic Coat         # Not listed on Bulbapedia
      "StealAndUseBeneficialStatusMove",                   # Snatch
      "RedirectAllMovesToUser",                            # Follow Me, Rage Powder
      "RedirectAllMovesToTarget",                          # Spotlight
      # Set up effects that trigger upon KO
      "ReduceAttackerMovePPTo0IfUserFaints",               # Grudge             # Not listed on Bulbapedia
      "AttackerFaintsIfUserFaints",                        # Destiny Bond
      # Held item-moving moves
      "UserTakesTargetItem",                               # Covet, Thief
      "UserTargetSwapItems",                               # Switcheroo, Trick
      "TargetTakesUserItem",                               # Bestow
      # Moves that start focussing at the start of the round
      "FailsIfUserDamagedThisTurn",                        # Focus Punch
      "UsedAfterUserTakesPhysicalDamage",                  # Shell Trap
      "BurnAttackerBeforeUserActs",                        # Beak Blast
      # Event moves that do nothing
      "DoesNothingFailsIfNoAlly",                          # Hold Hands
      "DoesNothingCongratulations"                         # Celebrate
    ]
    if Settings::MECHANICS_GENERATION >= 6
      @moveBlacklist += [
        # Target-switching moves
        "SwitchOutTargetStatusMove",                       # Roar, Whirlwind
        "SwitchOutTargetDamagingMove"                      # Circle Throw, Dragon Tail
      ]
    end
  end
end

#===============================================================================
# Uses a random move that exists. (Metronome)
#
# Addition: Added Recollection to Metronome's blacklist
#===============================================================================
class Battle::Move::UseRandomMove < Battle::Move
  def initialize(battle, move)
    super
    @moveBlacklist = [
      "FlinchTargetFailsIfUserNotAsleep",                  # Snore
      "TargetActsNext",                                    # After You
      "TargetActsLast",                                    # Quash
      "TargetUsesItsLastUsedMoveAgain",                    # Instruct
      # Struggle, Belch
      "Struggle",                                          # Struggle
      "FailsIfUserNotConsumedBerry",                       # Belch
      # Moves that affect the moveset
      "ReplaceMoveThisBattleWithTargetLastMoveUsed",       # Mimic
      "ReplaceMoveWithTargetLastMoveUsed",                 # Sketch
      "TransformUserIntoTarget",                           # Transform
	  "UserCopiesMovesWithoutTransforming",			   	   # Recollection
      # Counter moves
      "CounterPhysicalDamage",                             # Counter
      "CounterSpecialDamage",                              # Mirror Coat
      "CounterDamagePlusHalf",                             # Metal Burst        # Not listed on Bulbapedia
      # Helping Hand, Feint (always blacklisted together, don't know why)
      "PowerUpAllyMove",                                   # Helping Hand
      "RemoveProtections",                                 # Feint
      # Protection moves
      "ProtectUser",                                       # Detect, Protect
      "ProtectUserSideFromPriorityMoves",                  # Quick Guard
      "ProtectUserSideFromMultiTargetDamagingMoves",       # Wide Guard
      "UserEnduresFaintingThisTurn",                       # Endure
      "ProtectUserSideFromDamagingMovesIfUserFirstTurn",   # Mat Block
      "ProtectUserSideFromStatusMoves",                    # Crafty Shield
      "ProtectUserFromDamagingMovesKingsShield",           # King's Shield
      "ProtectUserFromDamagingMovesObstruct",              # Obstruct
      "ProtectUserFromTargetingMovesSpikyShield",          # Spiky Shield
      "ProtectUserBanefulBunker",                          # Baneful Bunker
      # Moves that call other moves
      "UseLastMoveUsedByTarget",                           # Mirror Move
      "UseLastMoveUsed",                                   # Copycat
      "UseMoveTargetIsAboutToUse",                         # Me First
      "UseMoveDependingOnEnvironment",                     # Nature Power
      "UseRandomUserMoveIfAsleep",                         # Sleep Talk
      "UseRandomMoveFromUserParty",                        # Assist
      "UseRandomMove",                                     # Metronome
      # Move-redirecting and stealing moves
      "BounceBackProblemCausingStatusMoves",               # Magic Coat         # Not listed on Bulbapedia
      "StealAndUseBeneficialStatusMove",                   # Snatch
      "RedirectAllMovesToUser",                            # Follow Me, Rage Powder
      "RedirectAllMovesToTarget",                          # Spotlight
      # Set up effects that trigger upon KO
      "ReduceAttackerMovePPTo0IfUserFaints",               # Grudge             # Not listed on Bulbapedia
      "AttackerFaintsIfUserFaints",                        # Destiny Bond
      # Held item-moving moves
      "UserTakesTargetItem",                               # Covet, Thief
      "UserTargetSwapItems",                               # Switcheroo, Trick
      "TargetTakesUserItem",                               # Bestow
      # Moves that start focussing at the start of the round
      "FailsIfUserDamagedThisTurn",                        # Focus Punch
      "UsedAfterUserTakesPhysicalDamage",                  # Shell Trap
      "BurnAttackerBeforeUserActs",                        # Beak Blast
      # Event moves that do nothing
      "DoesNothingFailsIfNoAlly",                          # Hold Hands
      "DoesNothingCongratulations"                         # Celebrate
    ]
  end
end

#===============================================================================
# Uses a random move known by any non-user Pokémon in the user's party. (Assist)
#
# Addition: Added Recollection to Assist's blacklist
#===============================================================================
class Battle::Move::UseRandomMoveFromUserParty < Battle::Move
  def initialize(battle, move)
    super
    @moveBlacklist = [
      # Struggle, Belch
      "Struggle",                                          # Struggle
      "FailsIfUserNotConsumedBerry",                       # Belch
      # Moves that affect the moveset
      "ReplaceMoveThisBattleWithTargetLastMoveUsed",       # Mimic
      "ReplaceMoveWithTargetLastMoveUsed",                 # Sketch
      "TransformUserIntoTarget",                           # Transform
	  "UserCopiesMovesWithoutTransforming",			   	   # Recollection
      # Counter moves
      "CounterPhysicalDamage",                             # Counter
      "CounterSpecialDamage",                              # Mirror Coat
      "CounterDamagePlusHalf",                             # Metal Burst        # Not listed on Bulbapedia
      # Helping Hand, Feint (always blacklisted together, don't know why)
      "PowerUpAllyMove",                                   # Helping Hand
      "RemoveProtections",                                 # Feint
      # Protection moves
      "ProtectUser",                                       # Detect, Protect
      "ProtectUserSideFromPriorityMoves",                  # Quick Guard        # Not listed on Bulbapedia
      "ProtectUserSideFromMultiTargetDamagingMoves",       # Wide Guard         # Not listed on Bulbapedia
      "UserEnduresFaintingThisTurn",                       # Endure
      "ProtectUserSideFromDamagingMovesIfUserFirstTurn",   # Mat Block
      "ProtectUserSideFromStatusMoves",                    # Crafty Shield      # Not listed on Bulbapedia
      "ProtectUserFromDamagingMovesKingsShield",           # King's Shield
      "ProtectUserFromDamagingMovesObstruct",              # Obstruct           # Not listed on Bulbapedia
      "ProtectUserFromTargetingMovesSpikyShield",          # Spiky Shield
      "ProtectUserBanefulBunker",                          # Baneful Bunker
      # Moves that call other moves
      "UseLastMoveUsedByTarget",                           # Mirror Move
      "UseLastMoveUsed",                                   # Copycat
      "UseMoveTargetIsAboutToUse",                         # Me First
#      "UseMoveDependingOnEnvironment",                    # Nature Power       # See below
      "UseRandomUserMoveIfAsleep",                         # Sleep Talk
      "UseRandomMoveFromUserParty",                        # Assist
      "UseRandomMove",                                     # Metronome
      # Move-redirecting and stealing moves
      "BounceBackProblemCausingStatusMoves",               # Magic Coat         # Not listed on Bulbapedia
      "StealAndUseBeneficialStatusMove",                   # Snatch
      "RedirectAllMovesToUser",                            # Follow Me, Rage Powder
      "RedirectAllMovesToTarget",                          # Spotlight
      # Set up effects that trigger upon KO
      "ReduceAttackerMovePPTo0IfUserFaints",               # Grudge             # Not listed on Bulbapedia
      "AttackerFaintsIfUserFaints",                        # Destiny Bond
      # Target-switching moves
#      "SwitchOutTargetStatusMove",                        # Roar, Whirlwind    # See below
      "SwitchOutTargetDamagingMove",                       # Circle Throw, Dragon Tail
      # Held item-moving moves
      "UserTakesTargetItem",                               # Covet, Thief
      "UserTargetSwapItems",                               # Switcheroo, Trick
      "TargetTakesUserItem",                               # Bestow
      # Moves that start focussing at the start of the round
      "FailsIfUserDamagedThisTurn",                        # Focus Punch
      "UsedAfterUserTakesPhysicalDamage",                  # Shell Trap
      "BurnAttackerBeforeUserActs",                        # Beak Blast
      # Event moves that do nothing
      "DoesNothingFailsIfNoAlly",                          # Hold Hands
      "DoesNothingCongratulations"                         # Celebrate
    ]
    if Settings::MECHANICS_GENERATION >= 6
      @moveBlacklist += [
        # Moves that call other moves
        "UseMoveDependingOnEnvironment",                   # Nature Power
        # Two-turn attacks
        "TwoTurnAttack",                                   # Razor Wind                # Not listed on Bulbapedia
        "TwoTurnAttackOneTurnInSun",                       # Solar Beam, Solar Blade   # Not listed on Bulbapedia
        "TwoTurnAttackParalyzeTarget",                     # Freeze Shock              # Not listed on Bulbapedia
        "TwoTurnAttackBurnTarget",                         # Ice Burn                  # Not listed on Bulbapedia
        "TwoTurnAttackFlinchTarget",                       # Sky Attack                # Not listed on Bulbapedia
        "TwoTurnAttackChargeRaiseUserDefense1",            # Skull Bash                # Not listed on Bulbapedia
        "TwoTurnAttackInvulnerableInSky",                  # Fly
        "TwoTurnAttackInvulnerableUnderground",            # Dig
        "TwoTurnAttackInvulnerableUnderwater",             # Dive
        "TwoTurnAttackInvulnerableInSkyParalyzeTarget",    # Bounce
        "TwoTurnAttackInvulnerableRemoveProtections",      # Shadow Force/Phantom Force
        "TwoTurnAttackInvulnerableInSkyTargetCannotAct",   # Sky Drop
        "AllBattlersLoseHalfHPUserSkipsNextTurn",          # Shadow Half
        "TwoTurnAttackRaiseUserSpAtkSpDefSpd2",            # Geomancy                  # Not listed on Bulbapedia
        # Target-switching moves
        "SwitchOutTargetStatusMove"                        # Roar, Whirlwind
      ]
    end
  end
end


#===============================================================================
# This move turns into the last move used by the target, until user switches
# out. (Mimic)
#
# Addition: Added in a check for Recollection
#===============================================================================
class Battle::Move::ReplaceMoveThisBattleWithTargetLastMoveUsed < Battle::Move
  def ignoresSubstitute?(user); return true; end

  def initialize(battle, move)
    super
    @moveBlacklist = [
      "UseRandomMove",                                 # Metronome
      # Struggle
      "Struggle",                                      # Struggle
      # Moves that affect the moveset
      "ReplaceMoveThisBattleWithTargetLastMoveUsed",   # Mimic
      "ReplaceMoveWithTargetLastMoveUsed",             # Sketch
      "TransformUserIntoTarget",                       # Transform
	  "UserCopiesMovesWithoutTransforming"			   # Recollection
    ]
  end
end

