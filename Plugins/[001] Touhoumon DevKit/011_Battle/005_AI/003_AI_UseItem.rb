
class Battle::AI
#==============================================================================#
# Changes in this section include the following:
#	* Added various itemns to arrays where relevant
#==============================================================================#
  HP_HEAL_ITEMS[:POTATO] = 20
  HP_HEAL_ITEMS[:BAKEDPOTATO] = 1 # Actual amount is determined below (pkmn.totalhp / 3) # 80,

  ALL_STATUS_CURE_ITEMS.push(:BAKEDPOTATO)
  ALL_STATUS_CURE_ITEMS.push(:GRILLEDLAMPREY)

#==============================================================================#
# Changes in this section include the following:
#	* Added Baked Potato to the checks alongside Sitrus Berry
#==============================================================================#
  def get_usability_of_item_on_pkmn(item, party_index, side)
    pkmn = @battle.pbParty(side)[party_index]
    battler = @battle.pbFindBattler(party_index, side)
    ret = {}
    return ret if !@battle.pbCanUseItemOnPokemon?(item, pkmn, battler, @battle.scene, false)
    return ret if !ItemHandlers.triggerCanUseInBattle(item, pkmn, battler, nil,
                                                      false, self, @battle.scene, false)
    want_to_cure_status = (pkmn.status != :NONE)
    if battler
      if want_to_cure_status
        want_to_cure_status = @battlers[battler.index].wants_status_problem?(pkmn.status)
        want_to_cure_status = false if pkmn.status == :SLEEP && pkmn.statusCount <= 2
      end
      want_to_cure_status ||= (battler.effects[PBEffects::Confusion] > 1)
    end
    if HP_HEAL_ITEMS.include?(item)
      if pkmn.hp < pkmn.totalhp
        heal_amount = HP_HEAL_ITEMS[item]
        heal_amount = pkmn.totalhp / 4 if item == :SITURUSBERRY
		heal_amount = pkmn.totalhp / 4 if item == :BAKEDPOTATO
        ret[:hp_heal] ||= []
        ret[:hp_heal].push([item, party_index, 5, heal_amount])
      end
    elsif FULL_RESTORE_ITEMS.include?(item)
      prefer_full_restore = (pkmn.hp <= pkmn.totalhp * 2 / 3 && want_to_cure_status)
      if pkmn.hp < pkmn.totalhp
        ret[:hp_heal] ||= []
        ret[:hp_heal].push([item, party_index, (prefer_full_restore) ? 3 : 7, 999])
      end
      if want_to_cure_status
        ret[:status_cure] ||= []
        ret[:status_cure].push([item, party_index, (prefer_full_restore) ? 3 : 9])
      end
    elsif ONE_STATUS_CURE_ITEMS.include?(item)
      if want_to_cure_status
        ret[:status_cure] ||= []
        ret[:status_cure].push([item, party_index, 5])
      end
    elsif ALL_STATUS_CURE_ITEMS.include?(item)
      if want_to_cure_status
        ret[:status_cure] ||= []
        ret[:status_cure].push([item, party_index, 7])
      end
    elsif ONE_STAT_RAISE_ITEMS.include?(item)
      stat_data = ONE_STAT_RAISE_ITEMS[item]
      if battler && stat_raise_worthwhile?(@battlers[battler.index], stat_data[0])
        ret[:stat_raise] ||= []
        ret[:stat_raise].push([item, party_index, battler.stages[stat_data[0]], stat_data[1]])
      end
    elsif ALL_STATS_RAISE_ITEMS.include?(item)
      if battler
        ret[:all_stats_raise] ||= []
        ret[:all_stats_raise].push([item, party_index])
      end
    elsif REVIVE_ITEMS.include?(item)
      ret[:revive] ||= []
      ret[:revive].push([item, party_index, REVIVE_ITEMS[item]])
    end
    return ret
  end
end