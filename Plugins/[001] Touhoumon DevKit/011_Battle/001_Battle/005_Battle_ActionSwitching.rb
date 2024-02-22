#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Removing explicit references to Pokemon as an individual species
#==============================================================================#
class Battle
  def pbCanSwitchIn?(idxBattler, idxParty, partyScene = nil)
    return true if idxParty < 0
    party = pbParty(idxBattler)
    return false if idxParty >= party.length
    return false if !party[idxParty]
    if party[idxParty].egg?
      partyScene&.pbDisplay(_INTL("An Egg can't battle!"))
      return false
    end
    if !pbIsOwner?(idxBattler, idxParty)
      if partyScene
        owner = pbGetOwnerFromPartyIndex(idxBattler, idxParty)
        partyScene.pbDisplay(_INTL("You can't switch {1}'s active party member with one of yours!",
                                   owner.name))
      end
      return false
    end
    if party[idxParty].fainted?
      partyScene&.pbDisplay(_INTL("{1} has no energy left to battle!", party[idxParty].name))
      return false
    end
    if pbFindBattler(idxParty, idxBattler)
      partyScene&.pbDisplay(_INTL("{1} is already in battle!", party[idxParty].name))
      return false
    end
    return true
  end

#==============================================================================#
# Changes in this section include the following:
#	* Made it so Touhoumon Ghost Types can switch out regardless of conditions
#==============================================================================#
  def pbCanSwitchOut?(idxBattler, partyScene = nil)
    battler = @battlers[idxBattler]
    return true if battler.fainted?
    # Ability/item effects that allow switching no matter what
    if battler.abilityActive? && Battle::AbilityEffects.triggerCertainSwitching(battler.ability, battler, self)
      return true
    end
    if battler.itemActive? && Battle::ItemEffects.triggerCertainSwitching(battler.item, battler, self)
      return true
    end
    # Other certain switching effects
    return true if Settings::MORE_TYPE_EFFECTS && (battler.pbHasType?(:GHOST) || 
												   battler.pbHasType?(:GHOST18))
    # Other certain trapping effects
    if battler.trappedInBattle?
      partyScene&.pbDisplay(_INTL("{1} can't be switched out!", battler.pbThis))
      return false
    end
    # Trapping abilities/items
    allOtherSideBattlers(idxBattler).each do |b|
      next if !b.abilityActive?
      if Battle::AbilityEffects.triggerTrappingByTarget(b.ability, battler, b, self)
        partyScene&.pbDisplay(_INTL("{1}'s {2} prevents switching!", b.pbThis, b.abilityName))
        return false
      end
    end
    allOtherSideBattlers(idxBattler).each do |b|
      next if !b.itemActive?
      if Battle::ItemEffects.triggerTrappingByTarget(b.item, battler, b, self)
        partyScene&.pbDisplay(_INTL("{1}'s {2} prevents switching!", b.pbThis, b.itemName))
        return false
      end
    end
    return true
  end
  
  def pbCanSwitch?(idxBattler, idxParty = -1, partyScene = nil)
    # Check whether party Pokémon can switch in
    return false if !pbCanSwitchIn?(idxBattler, idxParty, partyScene)
    # Make sure another battler isn't already choosing to switch to the party
    # Pokémon
    allSameSideBattlers(idxBattler).each do |b|
      next if choices[b.index][0] != :SwitchOut || choices[b.index][1] != idxParty
      partyScene&.pbDisplay(_INTL("{1} has already been selected.",
                                  pbParty(idxBattler)[idxParty].name))
      return false
    end
    # Check whether battler can switch out
    return pbCanSwitchOut?(idxBattler, partyScene)
  end
   
#==============================================================================#
# Changes in this section include the following:
#	* Removing explicit references to Pokemon as an individual species
#==============================================================================#  
  def pbEORSwitch(favorDraws = false)
    return if @decision > 0 && !favorDraws
    return if @decision == 5 && favorDraws
    pbJudge
    return if @decision > 0
    # Check through each fainted battler to see if that spot can be filled.
    switched = []
    loop do
      switched.clear
      @battlers.each do |b|
        next if !b || !b.fainted?
        idxBattler = b.index
        next if !pbCanChooseNonActive?(idxBattler)
        if !pbOwnedByPlayer?(idxBattler)   # Opponent/ally is switching in
          next if b.wild?   # Wild Pokémon can't switch
          idxPartyNew = pbSwitchInBetween(idxBattler)
          opponent = pbGetOwnerFromBattlerIndex(idxBattler)
          # NOTE: The player is only offered the chance to switch their own
          #       Pokémon when an opponent replaces a fainted Pokémon in single
          #       battles. In double battles, etc. there is no such offer.
          if @internalBattle && @switchStyle && trainerBattle? && pbSideSize(0) == 1 &&
             opposes?(idxBattler) && !@battlers[0].fainted? && !switched.include?(0) &&
             pbCanChooseNonActive?(0) && @battlers[0].effects[PBEffects::Outrage] == 0
            idxPartyForName = idxPartyNew
            enemyParty = pbParty(idxBattler)
            if enemyParty[idxPartyNew].ability == :ILLUSION && !pbCheckGlobalAbility(:NEUTRALIZINGGAS)
              new_index = pbLastInTeam(idxBattler)
              idxPartyForName = new_index if new_index >= 0 && new_index != idxPartyNew
            end
            if pbDisplayConfirm(_INTL("{1} is about to send in {2}. Will you switch?",
                                      opponent.full_name, enemyParty[idxPartyForName].name))
              idxPlayerPartyNew = pbSwitchInBetween(0, false, true)
              if idxPlayerPartyNew >= 0
                pbMessageOnRecall(@battlers[0])
                pbRecallAndReplace(0, idxPlayerPartyNew)
                switched.push(0)
              end
            end
          end
          pbRecallAndReplace(idxBattler, idxPartyNew)
          switched.push(idxBattler)
        elsif trainerBattle?   # Player switches in in a trainer battle
          idxPlayerPartyNew = pbGetReplacementPokemonIndex(idxBattler)   # Owner chooses
          pbRecallAndReplace(idxBattler, idxPlayerPartyNew)
          switched.push(idxBattler)
        else   # Player's Pokémon has fainted in a wild battle
          switch = false
          if pbDisplayConfirm(_INTL("Continue battling?"))
            switch = true
          else
            switch = (pbRun(idxBattler, true) <= 0)
          end
          if switch
            idxPlayerPartyNew = pbGetReplacementPokemonIndex(idxBattler)   # Owner chooses
            pbRecallAndReplace(idxBattler, idxPlayerPartyNew)
            switched.push(idxBattler)
          end
        end
      end
      break if switched.length == 0
      pbOnBattlerEnteringBattle(switched)
    end
  end
  
#==============================================================================#
# Changes in this section include the following:
#	* Added in a check for the Donation Box to the money doubling formula
#	* Made it so the Miasma type is immune to Poison Spikes
#	* Made it so the Earth type has the same immunity as Rock types to Stealth
#	  Rock (Not Implemented Yet)
#==============================================================================#  	
  def pbRecordBattlerAsParticipated(battler)
    # Record money-doubling effect of Amulet Coin/Luck Incense
    if !battler.opposes? && [:AMULETCOIN, :LUCKINCENSE, :DONATIONBOX].include?(battler.item_id)
      @field.effects[PBEffects::AmuletCoin] = true
    end
    # Update battlers' participants (who will gain Exp/EVs when a battler faints)
    allBattlers.each { |b| b.pbUpdateParticipants }
  end

#==============================================================================#
# Changes in this section include the following:
#	* Removing explicit references to Pokemon as an individual species
#==============================================================================#  
  def pbMessagesOnBattlerEnteringBattle(battler)
    # Introduce Shadow Pokémon
    if battler.shadowPokemon?
      pbCommonAnimation("Shadow", battler)
      pbDisplay(_INTL("Oh!\nThey're cloaked in a shadowy aura!")) if battler.opposes?
    end
  end

#==============================================================================#
# Changes in this section include the following:
#	* Made it so the Miasma type is immune to Poison Spikes
#==============================================================================#  	
  def pbEntryHazards(battler)
    battler_side = battler.pbOwnSide
    # Toxic Spikes
    if battler_side.effects[PBEffects::ToxicSpikes] > 0 && !battler.fainted? && !battler.airborne?
      if (battler.pbHasType?(:POISON) || battler.pbHasType?(:MIASMA18))
        battler_side.effects[PBEffects::ToxicSpikes] = 0
        pbDisplay(_INTL("{1} absorbed the poison spikes!", battler.pbThis))
      elsif battler.pbCanPoison?(nil, false) && !battler.hasActiveItem?(:HEAVYDUTYBOOTS)
        if battler_side.effects[PBEffects::ToxicSpikes] == 2
          battler.pbPoison(nil, _INTL("{1} was badly poisoned by the poison spikes!", battler.pbThis), true)
        else
          battler.pbPoison(nil, _INTL("{1} was poisoned by the poison spikes!", battler.pbThis))
        end
      end
    end
  end
end