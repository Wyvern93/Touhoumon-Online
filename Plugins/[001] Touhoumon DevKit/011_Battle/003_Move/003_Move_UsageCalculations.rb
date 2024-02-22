#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Addition of various type-based interactions for Touhoumon types
#		* Scrappy w/ Touhoumon Ghost
#		* Strong Winds w/ Touhoumon Flying
#		* Grounded Flying/Touhoumon Flying w/ Ground/Touhoumon Earth
#		* Iron Ball interactions with Touhoumon Flying
#==============================================================================#
class Battle::Move
  def pbCalcTypeModSingle(moveType, defType, user, target)
    ret = Effectiveness.calculate(moveType, defType)
    if Effectiveness.ineffective_type?(moveType, defType)
      # Ring Target
      if target.hasActiveItem?(:RINGTARGET)
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
      # Foresight
      if (user.hasActiveAbility?(:SCRAPPY) || target.effects[PBEffects::Foresight]) &&
         (defType == :GHOST || defType == :GHOST18)
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
      # Miracle Eye
      if target.effects[PBEffects::MiracleEye] && defType == :DARK
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
    elsif Effectiveness.super_effective_type?(moveType, defType)
      # Delta Stream's weather
      if target.effectiveWeather == :StrongWinds && (defType == :FLYING || defType == :FLYING18)
        ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
      end
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    if !target.airborne? && (defType == :FLYING || defType == :FLYING18) && 
    						(moveType == :GROUND || moveType == :EARTH18)
      ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
    end
    return ret
  end

  def pbCalcTypeMod(moveType, user, target)
    ret = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
    return ret if !moveType
    return ret if (moveType == :GROUND || moveType == :EARTH18) &&
                                              (target.pbHasType?(:FLYING) || target.pbHasType?(:FLYING18)) &&
                                              target.hasActiveItem?(:IRONBALL)

    # Get effectivenesses
    if moveType == :SHADOW
      if target.shadowPokemon?
        ret = Effectiveness::NOT_VERY_EFFECTIVE_MULTIPLIER
      else
        ret = Effectiveness::SUPER_EFFECTIVE_MULTIPLIER
      end
    else
      target.pbTypes(true).each do |type|
        ret *= pbCalcTypeModSingle(moveType, type, user, target)
      end
      ret *= 2 if target.effects[PBEffects::TarShot] && moveType == :FIRE
    end
    return ret
  end
  
#==============================================================================#
# Changes in this section include the following:
#	* Made it so Charge effect works with Touhoumon's Wind type
#	* Made it so the Mud Sport affects the Wind Type
#	* Made it so the Water Sport affects Touhoumon's Fire Type
#	* Added interactions to Electric Terrain for the Wind Type
#	* Added interactions to Grass Terrain for the Nature Type
#	* Added interactions to Psychic Terrain for the Reason Type
#	* Added interactions to Misty Terrain for the Faith Type
#	* Added interactions to Sunny Weather for Touhoumon's Fire Type
#	* Added interactions to Sunny Weather for Touhoumon's Water Type
#	* Added interactions to Rainy Weather for Touhoumon's Fire Type
#	* Added interactions to Rainy Weather for Touhoumon's Water Type
#	* Added interaction for Beast Types in Sandstorms
#==============================================================================#
  def pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
    # Global abilities
    if (@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
       (@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY)
      if @battle.pbCheckGlobalAbility(:AURABREAK)
        multipliers[:power_multiplier] *= 3 / 4.0
      else
        multipliers[:power_multiplier] *= 4 / 3.0
      end
    end
    # Ability effects that alter damage
    if user.abilityActive?
      Battle::AbilityEffects.triggerDamageCalcFromUser(
        user.ability, user, target, self, multipliers, baseDmg, type
      )
    end
    if !@battle.moldBreaker
      # NOTE: It's odd that the user's Mold Breaker prevents its partner's
      #       beneficial abilities (i.e. Flower Gift boosting Atk), but that's
      #       how it works.
      user.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromAlly(
          b.ability, user, target, self, multipliers, baseDmg, type
        )
      end
      if target.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromTarget(
          target.ability, user, target, self, multipliers, baseDmg, type
        )
      end
    end
    if target.abilityActive?
      Battle::AbilityEffects.triggerDamageCalcFromTargetNonIgnorable(
        target.ability, user, target, self, multipliers, baseDmg, type
      )
    end
    if !@battle.moldBreaker
      target.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromTargetAlly(
          b.ability, user, target, self, multipliers, baseDmg, type
        )
      end
    end
    # Item effects that alter damage
    if user.itemActive?
      Battle::ItemEffects.triggerDamageCalcFromUser(
        user.item, user, target, self, multipliers, baseDmg, type
      )
    end
    if target.itemActive?
      Battle::ItemEffects.triggerDamageCalcFromTarget(
        target.item, user, target, self, multipliers, baseDmg, type
      )
    end
    # Parental Bond's second attack
    if user.effects[PBEffects::ParentalBond] == 1
      multipliers[:power_multiplier] /= (Settings::MECHANICS_GENERATION >= 7) ? 4 : 2
    end
    # Other
    if user.effects[PBEffects::MeFirst]
      multipliers[:power_multiplier] *= 1.5
    end
    if user.effects[PBEffects::HelpingHand] && !self.is_a?(Battle::Move::Confusion)
      multipliers[:power_multiplier] *= 1.5
    end
    if user.effects[PBEffects::Charge] > 0 && (type == :ELECTRIC ||
											   type == :WIND18)
      multipliers[:power_multiplier] *= 2
    end
    # Mud Sport
    if (type == :ELECTRIC || type == :WIND18)
      if @battle.allBattlers.any? { |b| b.effects[PBEffects::MudSport] }
        multipliers[:power_multiplier] /= 3
      end
      if @battle.field.effects[PBEffects::MudSportField] > 0
        multipliers[:power_multiplier] /= 3
      end
    end
    # Water Sport
    if (type == :FIRE || type == :FIRE18)
      if @battle.allBattlers.any? { |b| b.effects[PBEffects::WaterSport] }
        multipliers[:power_multiplier] /= 3
      end
      if @battle.field.effects[PBEffects::WaterSportField] > 0
        multipliers[:power_multiplier] /= 3
      end
    end
    # Terrain moves
    terrain_multiplier = (Settings::MECHANICS_GENERATION >= 8) ? 1.3 : 1.5
    case @battle.field.terrain
    when :Electric
      multipliers[:power_multiplier] *= terrain_multiplier if (type == :ELECTRIC ||
      																 type == :WIND18) && user.affectedByTerrain?
    when :Grassy
      multipliers[:power_multiplier] *= terrain_multiplier if (type == :GRASS ||
      																 type == :NATURE18) && user.affectedByTerrain?
    when :Psychic
      multipliers[:power_multiplier] *= terrain_multiplier if (type == :PSYCHIC ||
      																 type == :REASON18) && user.affectedByTerrain?
    when :Misty
      multipliers[:power_multiplier] /= 2 if (type == :DRAGON ||
      												type == :FAITH18) && target.affectedByTerrain?
    end
    # Badge multipliers
    if @battle.internalBattle
      if user.pbOwnedByPlayer?
        if physicalMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_ATTACK
          multipliers[:attack_multiplier] *= 1.1
        elsif specialMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPATK
          multipliers[:attack_multiplier] *= 1.1
        end
      end
      if target.pbOwnedByPlayer?
        if physicalMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_DEFENSE
          multipliers[:defense_multiplier] *= 1.1
        elsif specialMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPDEF
          multipliers[:defense_multiplier] *= 1.1
        end
      end
    end
    # Multi-targeting attacks
    multipliers[:final_damage_multiplier] *= 0.75 if numTargets > 1
    # Weather
    case user.effectiveWeather
    when :Sun, :HarshSun
      case type
      when :FIRE
        multipliers[:final_damage_multiplier] *= 1.5
      when :FIRE18
        multipliers[:final_damage_multiplier] *= 1.5
      when :WATER
        multipliers[:final_damage_multiplier] /= 2
      when :WATER18
        multipliers[:final_damage_multiplier] /= 2
      end
    when :Rain, :HeavyRain
      case type
      when :FIRE
        multipliers[:final_damage_multiplier] /= 2
      when :FIRE18
        multipliers[:final_damage_multiplier] /= 2
      when :WATER
        multipliers[:final_damage_multiplier] *= 1.5
      when :WATER18
        multipliers[:final_damage_multiplier] *= 1.5
      end
    when :Sandstorm
      if target.pbHasType?(:ROCK) && specialMove? && @function_code != "UseTargetDefenseInsteadOfTargetSpDef"
        multipliers[:defense_multiplier] *= 1.5
      end
    when :ShadowSky
      multipliers[:final_damage_multiplier] *= 1.5 if type == :SHADOW
    end
    # Critical hits
    if target.damageState.critical
      if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
        multipliers[:final_damage_multiplier] *= 1.5
      else
        multipliers[:final_damage_multiplier] *= 2
      end
    end
    # Random variance
    if !self.is_a?(Battle::Move::Confusion)
      random = 85 + @battle.pbRandom(16)
      multipliers[:final_damage_multiplier] *= random / 100.0
    end
    # STAB
    if type && user.pbHasType?(type)
      if user.hasActiveAbility?(:ADAPTABILITY)
        multipliers[:final_damage_multiplier] *= 2
      else
        multipliers[:final_damage_multiplier] *= 1.5
      end
    end
    # Type effectiveness
    multipliers[:final_damage_multiplier] *= target.damageState.typeMod
    # Burn
    if user.status == :BURN && physicalMove? && damageReducedByBurn? &&
       !user.hasActiveAbility?(:GUTS)
      multipliers[:final_damage_multiplier] /= 2
    end
    # Aurora Veil, Reflect, Light Screen
    if !ignoresReflect? && !target.damageState.critical &&
       !user.hasActiveAbility?(:INFILTRATOR)
      if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && physicalMove?
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && specialMove?
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      end
    end
    # Minimize
    if target.effects[PBEffects::Minimize] && tramplesMinimize?
      multipliers[:final_damage_multiplier] *= 2
    end
    # Move-specific base damage modifiers
    multipliers[:power_multiplier] = pbBaseDamageMultiplier(multipliers[:power_multiplier], user, target)
    # Move-specific final damage modifiers
    multipliers[:final_damage_multiplier] = pbModifyDamage(multipliers[:final_damage_multiplier], user, target)
  end
  
#==============================================================================#
# Changes in this section include the following:
#	* Addition of Advent to pbAdditionalEffectChance and pbFlinchChance
#==============================================================================#
  def pbAdditionalEffectChance(user, target, effectChance = 0)
    return 0 if (target.hasActiveAbility?(:SHIELDDUST) ||
    			 target.hasActiveAbility?(:ADVENT)) && !@battle.moldBreaker
    ret = (effectChance > 0) ? effectChance : @addlEffect
    return ret if ret > 100
    if (Settings::MECHANICS_GENERATION >= 6 || @function_code != "EffectDependsOnEnvironment") &&
       (user.hasActiveAbility?(:SERENEGRACE) || user.pbOwnSide.effects[PBEffects::Rainbow] > 0)
      ret *= 2
    end
    ret = 100 if $DEBUG && Input.press?(Input::CTRL)
    return ret
  end

  # NOTE: Flinching caused by a move's effect is applied in that move's code,
  #       not here.
  def pbFlinchChance(user, target)
    return 0 if flinchingMove?
    return 0 if (target.hasActiveAbility?(:SHIELDDUST) ||
    			 target.hasActiveAbility?(:ADVENT)) && !@battle.moldBreaker
    ret = 0
    if user.hasActiveAbility?(:STENCH, true) ||
       user.hasActiveItem?([:KINGSROCK, :RAZORFANG], true)
      ret = 10
    end
    ret *= 2 if user.hasActiveAbility?(:SERENEGRACE) ||
                user.pbOwnSide.effects[PBEffects::Rainbow] > 0
    return ret
  end
end