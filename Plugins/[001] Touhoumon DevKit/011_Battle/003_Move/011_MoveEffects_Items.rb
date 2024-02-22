#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Tweaks to existing move effects to account for Touhoumon mechanics
#==============================================================================#

#===============================================================================
# Target drops its item. It regains the item at the end of the battle. (Knock Off)
# If target has a losable item, damage is multiplied by 1.5.
#
# Addition: Made it so those w/ Collector as an ability can't lose items
#===============================================================================
class Battle::Move::RemoveTargetItem < Battle::Move
  def pbEffectAfterAllHits(user, target)
    return if user.wild?   # Wild Pokémon can't knock off
    return if user.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item || target.unlosableItem?(target.item)
    return if (target.hasActiveAbility?(:STICKYHOLD) ||
			   target.hasActiveAbility?(:COLLECTOR)) && !@battle.moldBreaker
    itemName = target.itemName
    target.pbRemoveItem(false)
    @battle.pbDisplay(_INTL("{1} dropped its {2}!", target.pbThis, itemName))
  end
end

#===============================================================================
# User steals the target's item, if the user has none itself. (Covet, Thief)
# Items stolen from wild Pokémon are kept after the battle.
#
# Addition: Made it so those w/ Collector as an ability can't lose items
#===============================================================================
class Battle::Move::UserTakesTargetItem < Battle::Move
  def pbEffectAfterAllHits(user, target)
    return if user.wild?   # Wild Pokémon can't thieve
    return if user.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item || user.item
    return if target.unlosableItem?(target.item)
    return if user.unlosableItem?(target.item)
    return if (target.hasActiveAbility?(:STICKYHOLD) ||
			   target.hasActiveAbility?(:COLLECTOR)) && !@battle.moldBreaker
    itemName = target.itemName
    user.item = target.item
    # Permanently steal the item from wild Pokémon
    if target.wild? && !user.initialItem && target.item == target.initialItem
      user.setInitialItem(target.item)
      target.pbRemoveItem
    else
      target.pbRemoveItem(false)
    end
    @battle.pbDisplay(_INTL("{1} stole {2}'s {3}!", user.pbThis, target.pbThis(true), itemName))
    user.pbHeldItemTriggerCheck
  end
end

#===============================================================================
# User and target swap items. They remain swapped after wild battles.
# (Switcheroo, Trick)
#
# Addition: Made it so those w/ Collector as an ability can't lose items
#===============================================================================
class Battle::Move::UserTargetSwapItems < Battle::Move
  def pbFailsAgainstTarget?(user, target, show_message)
    if !user.item && !target.item
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    if target.unlosableItem?(target.item) ||
       target.unlosableItem?(user.item) ||
       user.unlosableItem?(user.item) ||
       user.unlosableItem?(target.item)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    if (target.hasActiveAbility?(:STICKYHOLD) ||
		target.hasActiveAbility?(:COLLECTOR)) && !@battle.moldBreaker
      if show_message
        @battle.pbShowAbilitySplash(target)
        if Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("But it failed to affect {1}!", target.pbThis(true)))
        else
          @battle.pbDisplay(_INTL("But it failed to affect {1} because of its {2}!",
                                  target.pbThis(true), target.abilityName))
        end
        @battle.pbHideAbilitySplash(target)
      end
      return true
    end
    return false
  end
end



#===============================================================================
# For 5 rounds, all held items cannot be used in any way and have no effect.
# Held items can still change hands, but can't be thrown. (Magic Room)
#
# Change: Removed explicit references to Pokemon as an individual species
#===============================================================================
class Battle::Move::StartNegateHeldItems < Battle::Move
  def pbEffectGeneral(user)
    if @battle.field.effects[PBEffects::MagicRoom] > 0
      @battle.field.effects[PBEffects::MagicRoom] = 0
      @battle.pbDisplay(_INTL("The area returned to normal!"))
    else
      @battle.field.effects[PBEffects::MagicRoom] = 5
      @battle.pbDisplay(_INTL("It created a bizarre area in which held items lose their effects!"))
    end
  end
end
#===============================================================================
# User consumes target's berry and gains its effect. (Bug Bite, Pluck)
#
# Addition: Made it so those w/ Collector as an ability can't lose items
#===============================================================================
class Battle::Move::UserConsumeTargetBerry < Battle::Move
  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || target.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item || !target.item.is_berry? || target.unlosableItem?(target.item)
    return if (target.hasActiveAbility?(:STICKYHOLD) ||
			   target.hasActiveAbility?(:COLLECTOR)) && !@battle.moldBreaker
    item = target.item
    itemName = target.itemName
    user.setBelched
    target.pbRemoveItem
    @battle.pbDisplay(_INTL("{1} stole and ate its target's {2}!", user.pbThis, itemName))
    user.pbHeldItemTriggerCheck(item.id, false)
    user.pbSymbiosis
  end
end

#===============================================================================
# User flings its item at the target. Power/effect depend on the item. (Fling)
#
# Addition: Baked Potato can cause burns
#           Ice Ball can cause freeze
#           Advent blocks secondary effects from Fling
#===============================================================================
class Battle::Move::ThrowUserItemAtTarget < Battle::Move
  def pbEffectAgainstTarget(user, target)
    return if target.damageState.substitute
    return if (target.hasActiveAbility?(:SHIELDDUST) ||
	           target.hasActiveAbility?(:ADVENT)) && !@battle.moldBreaker
    case user.item_id
    when :POISONBARB
      target.pbPoison(user) if target.pbCanPoison?(user, false, self)
    when :TOXICORB
      target.pbPoison(user, nil, true) if target.pbCanPoison?(user, false, self)
    when :FLAMEORB, :BAKEDPOTATO
      target.pbBurn(user) if target.pbCanBurn?(user, false, self)
    when :LIGHTBALL
      target.pbParalyze(user) if target.pbCanParalyze?(user, false, self)
	when :ICEBALL
      target.pbFreeze(user) if target.pbCanFreeze?(user, false, self)
    when :KINGSROCK, :RAZORFANG
      target.pbFlinch(user)
    else
      target.pbHeldItemTriggerCheck(user.item_id, true)
    end
    # NOTE: The official games only let the target use Belch if the berry flung
    #       at it has some kind of effect (i.e. it isn't an effectless berry). I
    #       think this isn't in the spirit of "consuming a berry", so I've said
    #       that Belch is usable after having any kind of berry flung at you.
    target.setBelched if user.item.is_berry?
  end
end

#===============================================================================
# Target's berry/Gem is destroyed. (Incinerate)
#
# Addition: Collector blocs Incinerate Effect
#===============================================================================
class Battle::Move::DestroyTargetBerryOrGem < Battle::Move
  def pbEffectWhenDealingDamage(user, target)
    return if target.damageState.substitute || target.damageState.berryWeakened
    return if !target.item || (!target.item.is_berry? &&
              !(Settings::MECHANICS_GENERATION >= 6 && target.item.is_gem?))
    return if target.unlosableItem?(target.item)
    return if (target.hasActiveAbility?(:STICKYHOLD)
               target.hasActiveAbility?(:COLLECTOR)) && !@battle.moldBreaker
    item_name = target.itemName
    target.pbRemoveItem
    @battle.pbDisplay(_INTL("{1}'s {2} was incinerated!", target.pbThis, item_name))
  end
end

#===============================================================================
# Negates the effect and usability of the target's held item for the rest of the
# battle (even if it is switched out). Fails if the target doesn't have a held
# item, the item is unlosable, the target has Sticky Hold, or the target is
# behind a substitute. (Corrosive Gas)
#
# Addition: Collector blocs Incinerate Effect
#===============================================================================
class Battle::Move::CorrodeTargetItem < Battle::Move
  def pbFailsAgainstTarget?(user, target, show_message)
    if !target.item || target.unlosableItem?(target.item) ||
       target.effects[PBEffects::Substitute] > 0
      @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis)) if show_message
      return true
    end
    if (target.hasActiveAbility?(:STICKYHOLD)
               target.hasActiveAbility?(:COLLECTOR)) && !@battle.moldBreaker
      if show_message
        @battle.pbShowAbilitySplash(target)
        if Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis))
        else
          @battle.pbDisplay(_INTL("{1} is unaffected because of its {2}!",
                                  target.pbThis(true), target.abilityName))
        end
        @battle.pbHideAbilitySplash(target)
      end
      return true
    end
    if @battle.corrosiveGas[target.index % 2][target.pokemonIndex]
      @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis)) if show_message
      return true
    end
    return false
  end
end