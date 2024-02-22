
class Battle::AI::AIBattler
#==============================================================================#
# Changes in this section include the following:
#	* Added Hisouten and Unconscious to Weather Immunity Checks
#==============================================================================#
  def rough_end_of_round_damage
    ret = 0
    # Weather
    weather = battler.effectiveWeather
	if @ai.battle.field.weatherDuration == 1
      weather = @ai.battle.field.defaultWeather
      weather = :None if @ai.battle.allBattlers.any? { |b| b.hasActiveAbility?([:CLOUDNINE, :AIRLOCK, :UNCONSCIOUS, :HISOUTEN]) }
      weather = :None if [:Sun, :Rain, :HarshSun, :HeavyRain].include?(weather) && has_active_item?(:UTILITYUMBRELLA)
    end
    case weather
    when :Sandstorm
      ret += [self.totalhp / 16, 1].max if battler.takesSandstormDamage?
    when :Hail
      ret += [self.totalhp / 16, 1].max if battler.takesHailDamage?
    when :ShadowSky
      ret += [self.totalhp / 16, 1].max if battler.takesShadowSkyDamage?
    end
    case ability_id
    when :DRYSKIN
      ret += [self.totalhp / 8, 1].max if [:Sun, :HarshSun].include?(weather) && battler.takesIndirectDamage?
      ret -= [self.totalhp / 8, 1].max if [:Rain, :HeavyRain].include?(weather) && battler.canHeal?
    when :ICEBODY
      ret -= [self.totalhp / 16, 1].max if weather == :Hail && battler.canHeal?
    when :RAINDISH
      ret -= [self.totalhp / 16, 1].max if [:Rain, :HeavyRain].include?(weather) && battler.canHeal?
    when :SOLARPOWER
      ret += [self.totalhp / 8, 1].max if [:Sun, :HarshSun].include?(weather) && battler.takesIndirectDamage?
    end
    # Future Sight/Doom Desire
    # NOTE: Not worth estimating the damage from this.
    # Wish
    if @ai.battle.positions[@index].effects[PBEffects::Wish] == 1 && battler.canHeal?
      ret -= @ai.battle.positions[@index].effects[PBEffects::WishAmount]
    end
    # Sea of Fire
#==============================================================================#
# Changes in this section include the following:
#	* Added Pyro immunity to Sea of Fire
#==============================================================================#	
    if @ai.battle.sides[@side].effects[PBEffects::SeaOfFire] > 1 &&
       battler.takesIndirectDamage? && !(has_type?(:FIRE) ||
										 has_type?(:FIRE18))
      ret += [self.totalhp / 8, 1].max
    end
    # Grassy Terrain (healing)
    if @ai.battle.field.terrain == :Grassy && battler.affectedByTerrain? && battler.canHeal?
      ret -= [self.totalhp / 16, 1].max
    end
    # Leftovers/Black Sludge
    if has_active_item?(:BLACKSLUDGE)
      if has_type?(:POISON) || has_type?(:MIASMA18)
        ret -= [self.totalhp / 16, 1].max if battler.canHeal?
      else
        ret += [self.totalhp / 8, 1].max if battler.takesIndirectDamage?
      end
    elsif has_active_item?(:LEFTOVERS)
      ret -= [self.totalhp / 16, 1].max if battler.canHeal?
    end
    # Aqua Ring
    if self.effects[PBEffects::AquaRing] && battler.canHeal?
      amt = self.totalhp / 16
      amt = (amt * 1.3).floor if has_active_item?(:BIGROOT)
      ret -= [amt, 1].max
    end
    # Ingrain
    if self.effects[PBEffects::Ingrain] && battler.canHeal?
      amt = self.totalhp / 16
      amt = (amt * 1.3).floor if has_active_item?(:BIGROOT)
      ret -= [amt, 1].max
    end
    # Leech Seed
    if self.effects[PBEffects::LeechSeed] >= 0
      if battler.takesIndirectDamage?
        ret += [self.totalhp / 8, 1].max if battler.takesIndirectDamage?
      end
    else
      @ai.each_battler do |b, i|
        next if i == @index || b.effects[PBEffects::LeechSeed] != @index
        amt = [[b.totalhp / 8, b.hp].min, 1].max
        amt = (amt * 1.3).floor if has_active_item?(:BIGROOT)
        ret -= [amt, 1].max
      end
    end
    # Hyper Mode (Shadow Pokémon)
    if battler.inHyperMode?
      ret += [self.totalhp / 24, 1].max
    end
    # Poison/burn/Nightmare
    if self.status == :POISON
      if has_active_ability?(:POISONHEAL)
        ret -= [self.totalhp / 8, 1].max if battler.canHeal?
      elsif battler.takesIndirectDamage?
        mult = 2
        mult = [self.effects[PBEffects::Toxic] + 1, 16].min if self.statusCount > 0   # Toxic
        ret += [mult * self.totalhp / 16, 1].max
      end
    elsif self.status == :BURN
      if battler.takesIndirectDamage?
        amt = (Settings::MECHANICS_GENERATION >= 7) ? self.totalhp / 16 : self.totalhp / 8
        amt = (amt / 2.0).round if has_active_ability?(:HEATPROOF)
        ret += [amt, 1].max
      end
    elsif battler.asleep? && self.statusCount > 1 && self.effects[PBEffects::Nightmare]
      ret += [self.totalhp / 4, 1].max if battler.takesIndirectDamage?
    end
    # Curse
    if self.effects[PBEffects::Curse]
      ret += [self.totalhp / 4, 1].max if battler.takesIndirectDamage?
    end
    # Trapping damage
    if self.effects[PBEffects::Trapping] > 1 && battler.takesIndirectDamage?
      amt = (Settings::MECHANICS_GENERATION >= 6) ? self.totalhp / 8 : self.totalhp / 16
      if @ai.battlers[self.effects[PBEffects::TrappingUser]].has_active_item?(:BINDINGBAND)
        amt = (Settings::MECHANICS_GENERATION >= 6) ? self.totalhp / 6 : self.totalhp / 8
      end
      ret += [amt, 1].max
    end
    # Perish Song
    return 999_999 if self.effects[PBEffects::PerishSong] == 1
    # Bad Dreams
    if battler.asleep? && self.statusCount > 1 && battler.takesIndirectDamage?
      @ai.each_battler do |b, i|
        next if i == @index || !b.battler.near?(battler) || !b.has_active_ability?(:BADDREAMS)
        ret += [self.totalhp / 8, 1].max
      end
    end
    # Sticky Barb
    if has_active_item?(:STICKYBARB) && battler.takesIndirectDamage?
      ret += [self.totalhp / 8, 1].max
    end
    return ret
  end

#==============================================================================#
# Changes in this section include the following:
#	* Added Earth and Aero check to certain effectiveness
#	* Added Hydro checks to moves like Freeze Dry
#	* Added Pyro checks to moves like Tar Shot
#==============================================================================#
  def effectiveness_of_type_against_battler(type, user = nil, move = nil)
	ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
    return ret if !type
    #return ret if type == :GROUND && (has_type?(:FLYING) || has_type?(:FLYING18)) && has_active_item?(:IRONBALL) # Old Code. Backup.
	 return ret if [:GROUND, :EARTH18].include?(type) && (has_type?(:FLYING) || has_type?(:FLYING18) && has_active_item?(:IRONBALL))
    # Get effectivenesses
    if type == :SHADOW
      if battler.shadowPokemon?
        ret = Effectiveness::NOT_VERY_EFFECTIVE_MULTIPLIER
      else
        ret = Effectiveness::SUPER_EFFECTIVE_MULTIPLIER
      end
    else
      battler.pbTypes(true).each do |defend_type|
        mult = effectiveness_of_type_against_single_battler_type(type, defend_type, user)
        if move
          case move.function_code
          when "HitsTargetInSkyGroundsTarget"
            #mult = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER if type == :GROUND && defend_type == :FLYING # Old Code. backup.
			mult = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER if [:GROUND, :EARTH18].include?(type) && [:FLYING, :FLYING18].include?(defend_type)
          when "FreezeTargetSuperEffectiveAgainstWater"
            #mult = Effectiveness::SUPER_EFFECTIVE_MULTIPLIER if defend_type == :WATER # Old Code. Backup.
			mult = Effectiveness::SUPER_EFFECTIVE_MULTIPLIER if [:WATER, :WATER18].include?(defend_type)
          end
        end
        ret *= mult
      end
      ret *= 2 if self.effects[PBEffects::TarShot] && type == :FIRE 
	  #ret *= 2 if self.effects[PBEffects::TarShot] && [:FIRE, :FIRE18].include?(type) # Not sure if I should do this.
    end
    return ret
  end
  
#==============================================================================#
# Changes in this section include the following:
#	* Added Fretful checks alongside Truant
#==============================================================================#
  def can_attack?
    return false if self.effects[PBEffects::HyperBeam] > 0
    return false if status == :SLEEP && statusCount > 1
    return false if status == :FROZEN   # Only 20% chance of unthawing; assune it won't
    return false if self.effects[PBEffects::Truant] && has_active_ability?(:TRUANT)
	return false if self.effects[PBEffects::Truant] && has_active_ability?(:FRETFUL)
    return false if self.effects[PBEffects::Flinch]
    # NOTE: Confusion/infatuation/paralysis have higher chances of allowing the
    #       attack, so the battler is treated as able to attack in those cases.
    return true
  end
  
#==============================================================================#
# Changes in this section include the following:
#	* Added Nether to types that can't be trapped.
#==============================================================================#
  def can_become_trapped?
    return false if fainted?
    # Ability/item effects that allow switching no matter what
    if ability_active? && Battle::AbilityEffects.triggerCertainSwitching(ability, battler, @ai.battle)
      return false
    end
    if item_active? && Battle::ItemEffects.triggerCertainSwitching(item, battler, @ai.battle)
      return false
    end
    # Other certain switching effects
    return false if Settings::MORE_TYPE_EFFECTS && has_type?(:GHOST)
	return false if Settings::MORE_TYPE_EFFECTS && has_type?(:GHOST18)
    # Other certain trapping effects
    return false if battler.trappedInBattle?
    # Trapping abilities/items
    @ai.each_foe_battler(side) do |b, i|
      if b.ability_active? &&
         Battle::AbilityEffects.triggerTrappingByTarget(b.ability, battler, b.battler, @ai.battle)
        return false
      end
      if b.item_active? &&
         Battle::ItemEffects.triggerTrappingByTarget(b.item, battler, b.battler, @ai.battle)
        return false
      end
    end
    return true
  end  
  
#==============================================================================#
# Changes in this section include the following:
#	* Added various items to to the score change on consumption method
#		+ Potato
#		+ Baked Potato
#==============================================================================#
  def get_score_change_for_consuming_item(item, try_preserving_item = false)
    ret = 0
    case item
    when :ORANBERRY, :BERRYJUICE, :ENIGMABERRY, :SITRUSBERRY, :POTATO, :BAKEDPOTATO
      # Healing
      ret += (hp > totalhp * 0.75) ? -6 : 6
      ret = ret * 3 / 2 if GameData::Item.get(item).is_berry? && has_active_ability?(:RIPEN)
    when :AGUAVBERRY, :FIGYBERRY, :IAPAPABERRY, :MAGOBERRY, :WIKIBERRY
      # Healing with confusion
      fraction_to_heal = 8   # Gens 6 and lower
      if Settings::MECHANICS_GENERATION == 7
        fraction_to_heal = 2
      elsif Settings::MECHANICS_GENERATION >= 8
        fraction_to_heal = 3
      end
      ret += (hp > totalhp * (1 - (1.0 / fraction_to_heal))) ? -6 : 6
      ret = ret * 3 / 2 if GameData::Item.get(item).is_berry? && has_active_ability?(:RIPEN)
      if @ai.trainer.high_skill?
        flavor_stat = {
          :AGUAVBERRY  => :SPECIAL_DEFENSE,
          :FIGYBERRY   => :ATTACK,
          :IAPAPABERRY => :DEFENSE,
          :MAGOBERRY   => :SPEED,
          :WIKIBERRY   => :SPECIAL_ATTACK
        }[item]
        if @battler.nature.stat_changes.any? { |val| val[0] == flavor_stat && val[1] < 0 }
          ret -= 3 if @battler.pbCanConfuseSelf?(false)
        end
      end
    when :ASPEARBERRY, :CHERIBERRY, :CHESTOBERRY, :PECHABERRY, :RAWSTBERRY
      # Status cure
      cured_status = {
        :ASPEAR      => :FROZEN,
        :CHERIBERRY  => :PARALYSIS,
        :CHESTOBERRY => :SLEEP,
        :PECHABERRY  => :POISON,
        :RAWSTBERRY  => :BURN
      }[item]
      ret += (cured_status && status == cured_status) ? 6 : -6
    when :PERSIMBERRY
      # Confusion cure
      ret += (self.effects[PBEffects::Confusion] > 1) ? 6 : -6
    when :LUMBERRY, :BAKEDPOTATO
      # Any status/confusion cure
      ret += (status != :NONE || self.effects[PBEffects::Confusion] > 1) ? 6 : -6
    when :MENTALHERB
      # Cure mental effects
      if self.effects[PBEffects::Attract] >= 0 ||
         self.effects[PBEffects::Taunt] > 1 ||
         self.effects[PBEffects::Encore] > 1 ||
         self.effects[PBEffects::Torment] ||
         self.effects[PBEffects::Disable] > 1 ||
         self.effects[PBEffects::HealBlock] > 1
        ret += 6
      else
        ret -= 6
      end
    when :APICOTBERRY, :GANLONBERRY, :LIECHIBERRY, :PETAYABERRY, :SALACBERRY,
         :KEEBERRY, :MARANGABERRY
      # Stat raise
      stat = {
        :APICOTBERRY  => :SPECIAL_DEFENSE,
        :GANLONBERRY  => :DEFENSE,
        :LIECHIBERRY  => :ATTACK,
        :PETAYABERRY  => :SPECIAL_ATTACK,
        :SALACBERRY   => :SPEED,
        :KEEBERRY     => :DEFENSE,
        :MARANGABERRY => :SPECIAL_DEFENSE
      }[item]
      ret += (stat && @ai.stat_raise_worthwhile?(self, stat)) ? 8 : -8
      ret = ret * 3 / 2 if GameData::Item.get(item).is_berry? && has_active_ability?(:RIPEN)
    when :STARFBERRY
      # Random stat raise
      ret += 8
      ret = ret * 3 / 2 if GameData::Item.get(item).is_berry? && has_active_ability?(:RIPEN)
    when :WHITEHERB
      # Resets lowered stats
      ret += (battler.hasLoweredStatStages?) ? 8 : -8
    when :MICLEBERRY
      # Raises accuracy of next move
      ret += (@ai.stat_raise_worthwhile?(self, :ACCURACY, true)) ? 6 : -6
    when :LANSATBERRY
      # Focus energy
      ret += (self.effects[PBEffects::FocusEnergy] < 2) ? 6 : -6
    when :LEPPABERRY
      # Restore PP
      ret += 6
      ret = ret * 3 / 2 if GameData::Item.get(item).is_berry? && has_active_ability?(:RIPEN)
    end
    ret = 0 if ret < 0 && !try_preserving_item
    return ret
  end
  
#==============================================================================#
# Changes in this section include the following:
#	* Added Umbral to Miracle Eye check
#	* Added Nether to Scrappy check
#	* Added Aero to Strong Winds check
#	* Added checks for changed effectiveness for Earth and Aero
#==============================================================================#
  def effectiveness_of_type_against_single_battler_type(type, defend_type, user = nil)
    ret = Effectiveness.calculate(type, defend_type)
    if Effectiveness.ineffective_type?(type, defend_type)
      # Ring Target
      if has_active_item?(:RINGTARGET)
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
      # Foresight
      if (user&.has_active_ability?(:SCRAPPY) || self.effects[PBEffects::Foresight]) &&
         #defend_type == :GHOST
		 [:GHOST, :GHOST18].include?(defend_type)
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
      # Miracle Eye
      if self.effects[PBEffects::MiracleEye] && [:DARK, :DARK18].include?(defend_type) #defend_type == :DARK
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
    elsif Effectiveness.super_effective_type?(type, defend_type)
      # Delta Stream's weather
      if battler.effectiveWeather == :StrongWinds && [:FLYING, :FLYING18].include?(defend_type) #defend_type == :FLYING
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    #if !battler.airborne? && defend_type == :FLYING && type == :GROUND
	if !battler.airborne? && [:FLYING, :FLYING18].include?(defend_type) && type == [:GROUND, :EARTH18].include?(type)
      ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
    end
    return ret
  end
end