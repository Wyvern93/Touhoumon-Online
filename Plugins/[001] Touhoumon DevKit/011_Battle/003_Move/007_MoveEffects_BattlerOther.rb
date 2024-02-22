#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Tweaks to existing move effects to account for Touhoumon mechanics
#==============================================================================#

#===============================================================================
# Target's ability becomes Simple. (Simple Beam)
#
# Addition: Added in a check for Fretful
#===============================================================================
class Battle::Move::SetTargetAbilityToSimple < Battle::Move
  def pbFailsAgainstTarget?(user, target, show_message)
    if target.unstoppableAbility? || [:TRUANT, :SIMPLE, :FRETFUL].include?(target.ability_id)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end
end

#===============================================================================
# Target's ability becomes Insomnia. (Worry Seed)
#
# Addition: Added in a check for Fretful
#===============================================================================
class Battle::Move::SetTargetAbilityToInsomnia < Battle::Move
  def pbFailsAgainstTarget?(user, target, show_message)
    if target.unstoppableAbility? || [:TRUANT, :INSOMNIA, :FRETFUL].include?(target.ability_id)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end
end

#===============================================================================
# User copies target's ability. (Role Play)
#
# Addition: Added in a check for Play Ghost
#===============================================================================
class Battle::Move::SetUserAbilityToTargetAbility < Battle::Move
  def pbFailsAgainstTarget?(user, target, show_message)
    if !target.ability || user.ability == target.ability
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    if target.ungainableAbility? ||
       [:POWEROFALCHEMY, :RECEIVER, :TRACE, :WONDERGUARD, :PLAYGHOST].include?(target.ability_id)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end
end

#===============================================================================
# Target copies user's ability. (Entrainment)
#
# Addition: Added in a check for Fretful
#===============================================================================
class Battle::Move::SetTargetAbilityToUserAbility < Battle::Move
  def pbMoveFailed?(user, targets)
    if !user.ability
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if user.ungainableAbility? ||
       [:POWEROFALCHEMY, :RECEIVER, :TRACE, :FRETFUL].include?(user.ability_id)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# User and target swap abilities. (Skill Swap)
#
# Addition: Added in a check for Play Ghost
#===============================================================================
class Battle::Move::UserTargetSwapAbilities < Battle::Move
  def ignoresSubstitute?(user); return true; end

  def pbMoveFailed?(user, targets)
    if !user.ability
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if user.unstoppableAbility?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if user.ungainableAbility? || user.ability == [:WONDERGUARD, :PLAYGHOST].include?(user.ability_id)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if !target.ability ||
       (user.ability == target.ability && Settings::MECHANICS_GENERATION <= 5)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    if target.unstoppableAbility?
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    if target.ungainableAbility? || target.ability == [:WONDERGUARD, :PLAYGHOST].include?(user.ability_id)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end
end