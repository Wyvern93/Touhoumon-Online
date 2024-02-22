#==============================================================================#
# Changes in this section include the following:
#	* Added a check for switching a Miasma type in onto Toxic Spikes
#==============================================================================#
Battle::AI::Handlers::ShouldSwitch.add(:cure_status_problem_by_switching_out,
  proc { |battler, reserves, ai, battle|
    next false if !battler.ability_active?
    # Don't try to cure a status problem/heal a bit of HP if entry hazards will
    # KO the battler if it switches back in
    entry_hazard_damage = ai.calculate_entry_hazard_damage(battler.pokemon, battler.side)
    next false if entry_hazard_damage >= battler.hp
    # Check specific abilities
    single_status_cure = {
      :IMMUNITY    => :POISON,
      :INSOMNIA    => :SLEEP,
      :LIMBER      => :PARALYSIS,
      :MAGMAARMOR  => :FROZEN,
      :VITALSPIRIT => :SLEEP,
      :WATERBUBBLE => :BURN,
      :WATERVEIL   => :BURN
    }[battler.ability_id]
    if battler.ability == :NATURALCURE || (single_status_cure && single_status_cure == battler.status)
      # Cures status problem
      next false if battler.wants_status_problem?(battler.status)
      next false if battler.status == :SLEEP && battler.statusCount == 1   # Will wake up this round anyway
      next false if entry_hazard_damage >= battler.totalhp / 4
      # Don't bother curing a poisoning if Toxic Spikes will just re-poison the
      # battler when it switches back in
      if battler.status == :POISON && reserves.none? { |pkmn| pkmn.hasType?(:POISON) }
        next false if battle.field.effects[PBEffects::ToxicSpikes] == 2
        next false if battle.field.effects[PBEffects::ToxicSpikes] == 1 && battler.statusCount == 0
	  elsif battler.status == :POISON && reserves.none? { |pkmn| pkmn.hasType?(:MIASMA18) }
        next false if battle.field.effects[PBEffects::ToxicSpikes] == 2
        next false if battle.field.effects[PBEffects::ToxicSpikes] == 1 && battler.statusCount == 0
      end
      # Not worth curing status problems that still allow actions if at high HP
      next false if battler.hp >= battler.totalhp / 2 && ![:SLEEP, :FROZEN].include?(battler.status)
      if ai.pbAIRandom(100) < 70
        PBDebug.log_ai("#{battler.name} wants to switch to cure its status problem with #{battler.ability.name}")
        next true
      end
    elsif battler.ability == :REGENERATOR
      # Not worth healing if battler would lose more HP from switching back in later
      next false if entry_hazard_damage >= battler.totalhp / 3
      # Not worth healing HP if already at high HP
      next false if battler.hp >= battler.totalhp / 2
      # Don't bother if a foe is at low HP and could be knocked out instead
      if battler.check_for_move { |m| m.damagingMove? }
        weak_foe = false
        ai.each_foe_battler(battler.side) do |b, i|
          weak_foe = true if b.hp < b.totalhp / 3
          break if weak_foe
        end
        next false if weak_foe
      end
      if ai.pbAIRandom(100) < 70
        PBDebug.log_ai("#{battler.name} wants to switch to heal with #{battler.ability.name}")
        next true
      end
    end
    next false
  }
)

#==============================================================================#
# Changes in this section include the following:
#	* Added Baked Potato to sleep check alongside Chesto/Lum Berry
#	* Added Nether checks to species that can't be trapped
#==============================================================================#
Battle::AI::Handlers::ShouldSwitch.add(:yawning,
  proc { |battler, reserves, ai, battle|
    # Yawning and can fall asleep because of it
    next false if battler.effects[PBEffects::Yawn] == 0 || !battler.battler.pbCanSleepYawn?
    # Doesn't want to be asleep (includes checking for moves usable while asleep)
    next false if battler.wants_status_problem?(:SLEEP)
    # Can't cure itself of sleep
    if battler.ability_active?
      next false if [:INSOMNIA, :NATURALCURE, :REGENERATOR, :SHEDSKIN].include?(battler.ability_id)
      next false if battler.ability_id == :HYDRATION && [:Rain, :HeavyRain].include?(battler.battler.effectiveWeather)
    end
    next false if battler.has_active_item?([:CHESTOBERRY, :LUMBERRY, :BAKEDPOTATO]) && battler.battler.canConsumeBerry?
    # Ally can't cure sleep
    ally_can_heal = false
    ai.each_ally(battler.index) do |b, i|
      ally_can_heal = b.has_active_ability?(:HEALER)
      break if ally_can_heal
    end
    next false if ally_can_heal
    # Doesn't benefit from being asleep/isn't less affected by sleep
    next false if battler.has_active_ability?([:EARLYBIRD, :MARVELSCALE])
    # Not trapping another battler in battle
    if ai.trainer.high_skill?
      next false if ai.battlers.any? do |b|
        b.effects[PBEffects::JawLock] == battler.index ||
        b.effects[PBEffects::MeanLook] == battler.index ||
        b.effects[PBEffects::Octolock] == battler.index ||
        b.effects[PBEffects::TrappingUser] == battler.index
      end
      trapping = false
      ai.each_foe_battler(battler.side) do |b, i|
        next if b.ability_active? && Battle::AbilityEffects.triggerCertainSwitching(b.ability, b.battler, battle)
        next if b.item_active? && Battle::ItemEffects.triggerCertainSwitching(b.item, b.battler, battle)
        next if Settings::MORE_TYPE_EFFECTS && b.has_type?(:GHOST) || b.has_type?(:GHOST18)
        next if b.battler.trappedInBattle?   # Relevant trapping effects are checked above
        if battler.ability_active?
          trapping = Battle::AbilityEffects.triggerTrappingByTarget(battler.ability, b.battler, battler.battler, battle)
          break if trapping
        end
        if battler.item_active?
          trapping = Battle::ItemEffects.triggerTrappingByTarget(battler.item, b.battler, battler.battler, battle)
          break if trapping
        end
      end
      next false if trapping
    end
    # Doesn't have sufficiently raised stats that would be lost by switching
    next false if battler.stages.any? { |key, val| val >= 2 }
    PBDebug.log_ai("#{battler.name} wants to switch because it is yawning and can't do anything while asleep")
    next true
  }
)

#==============================================================================#
# Changes in this section include the following:
#	* Added Spring Charm to sleep checks
#	* Added Nether checks to species that can't be trapped
#==============================================================================#
Battle::AI::Handlers::ShouldSwitch.add(:asleep,
  proc { |battler, reserves, ai, battle|
    # Asleep and won't wake up this round or next round
    next false if battler.status != :SLEEP || battler.statusCount <= 2
    # Doesn't want to be asleep (includes checking for moves usable while asleep)
    next false if battler.wants_status_problem?(:SLEEP)
    # Doesn't benefit from being asleep
    next false if battler.has_active_ability?(:MARVELSCALE)
	next false if battler.has_active_ability?(:SPRINGCHARM)
    # Doesn't know Rest (if it does, sleep is expected, so don't apply this check)
    next false if battler.check_for_move { |m| m.function_code == "HealUserFullyAndFallAsleep" }
    # Not trapping another battler in battle
    if ai.trainer.high_skill?
      next false if ai.battlers.any? do |b|
        b.effects[PBEffects::JawLock] == battler.index ||
        b.effects[PBEffects::MeanLook] == battler.index ||
        b.effects[PBEffects::Octolock] == battler.index ||
        b.effects[PBEffects::TrappingUser] == battler.index
      end
      trapping = false
      ai.each_foe_battler(battler.side) do |b, i|
        next if b.ability_active? && Battle::AbilityEffects.triggerCertainSwitching(b.ability, b.battler, battle)
        next if b.item_active? && Battle::ItemEffects.triggerCertainSwitching(b.item, b.battler, battle)
        next if Settings::MORE_TYPE_EFFECTS && b.has_type?(:GHOST) || b.has_type?(:GHOST18)
        next if b.battler.trappedInBattle?   # Relevant trapping effects are checked above
        if battler.ability_active?
          trapping = Battle::AbilityEffects.triggerTrappingByTarget(battler.ability, b.battler, battler.battler, battle)
          break if trapping
        end
        if battler.item_active?
          trapping = Battle::ItemEffects.triggerTrappingByTarget(battler.item, b.battler, battler.battler, battle)
          break if trapping
        end
      end
      next false if trapping
    end
    # Doesn't have sufficiently raised stats that would be lost by switching
    next false if battler.stages.any? { |key, val| val >= 2 }
    # 50% chance to not bother
    next false if ai.pbAIRandom(100) < 50
    PBDebug.log_ai("#{battler.name} wants to switch because it is asleep and can't do anything")
    next true
  }
)