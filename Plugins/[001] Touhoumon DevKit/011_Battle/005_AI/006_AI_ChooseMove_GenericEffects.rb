
class Battle::AI
#==============================================================================#
# Changes in this section include the following:
#	* Added Unconscious and Hisouten to Weather Checks
#	* Added Hydro and Pyro to Sun and Rain checks
#	* Added Beast to Sandstorm checks
#	* Added Touhoumon Weather Ball in relevant areas
#==============================================================================#
  def get_score_for_weather(weather, move_user, starting = false)
    return 0 if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
                @battle.pbCheckGlobalAbility(:CLOUDNINE) ||
				@battle.pbCheckGlobalAbility(:HISOUTEN) ||
				@battle.pbCheckGlobalAbility(:UNCONSCIOUS)
    ret = 0
    if starting
      weather_extender = {
        :Sun       => :HEATROCK,
        :Rain      => :DAMPROCK,
        :Sandstorm => :SMOOTHROCK,
        :Hail      => :ICYROCK
      }[weather]
      ret += 4 if weather_extender && move_user.has_active_item?(weather_extender)
    end
    each_battler do |b, i|
      # Check each battler for weather-specific effects
      case weather
      when :Sun
        # Check for Fire/Water moves
        if b.has_damaging_move_of_type?(:FIRE) || b.has_damaging_move_of_type?(:FIRE18)
          ret += (b.opposes?(move_user)) ? -10 : 10
        end
        if b.has_damaging_move_of_type?(:WATER) || b.has_damaging_move_of_type?(:WATER18)
          ret += (b.opposes?(move_user)) ? 10 : -10
        end
        # Check for moves that freeze
        if b.has_move_with_function?("FreezeTarget", "FreezeFlinchTarget") ||
           (b.has_move_with_function?("EffectDependsOnEnvironment") &&
           [:Snow, :Ice].include?(@battle.environment))
          ret += (b.opposes?(move_user)) ? 5 : -5
        end
      when :Rain
        # Check for Fire/Water moves
        if b.has_damaging_move_of_type?(:WATER) || b.has_damaging_move_of_type?(:WATER18)
          ret += (b.opposes?(move_user)) ? -10 : 10
        end
        if b.has_damaging_move_of_type?(:FIRE) || b.has_damaging_move_of_type?(:FIRE18)
          ret += (b.opposes?(move_user)) ? 10 : -10
        end
      when :Sandstorm
        # Check for battlers affected by sandstorm's effects
        if b.battler.takesSandstormDamage?   # End of round damage
          ret += (b.opposes?(move_user)) ? 10 : -10
        end
        if b.has_type?(:ROCK)   # +SpDef for Rock types
          ret += (b.opposes?(move_user)) ? -10 : 10
        end
		if b.has_type?(:BEAST18)   # +SpDef for Beast types
          ret += (b.opposes?(move_user)) ? -10 : 10
        end
      when :Hail
        # Check for battlers affected by hail's effects
        if b.battler.takesHailDamage?   # End of round damage
          ret += (b.opposes?(move_user)) ? 10 : -10
        end
      when :ShadowSky
        # Check for battlers affected by Shadow Sky's effects
        if b.has_damaging_move_of_type?(:SHADOW)
          ret += (b.opposes?(move_user)) ? 10 : -10
        end
        if b.battler.takesShadowSkyDamage?   # End of round damage
          ret += (b.opposes?(move_user)) ? 10 : -10
        end
      end
      # Check each battler's abilities/other moves affected by the new weather
      if @trainer.medium_skill? && !b.has_active_item?(:UTILITYUMBRELLA)
        beneficial_abilities = {
          :Sun       => [:CHLOROPHYLL, :FLOWERGIFT, :FORECAST, :HARVEST, :LEAFGUARD, :SOLARPOWER],
          :Rain      => [:DRYSKIN, :FORECAST, :HYDRATION, :RAINDISH, :SWIFTSWIM],
          :Sandstorm => [:SANDFORCE, :SANDRUSH, :SANDVEIL],
          :Hail      => [:FORECAST, :ICEBODY, :SLUSHRUSH, :SNOWCLOAK]
        }[weather]
        if beneficial_abilities && beneficial_abilities.length > 0 &&
           b.has_active_ability?(beneficial_abilities)
          ret += (b.opposes?(move_user)) ? -5 : 5
        end
        if weather == :Hail && b.ability == :ICEFACE
          ret += (b.opposes?(move_user)) ? -5 : 5
        end
        negative_abilities = {
          :Sun => [:DRYSKIN]
        }[weather]
        if negative_abilities && negative_abilities.length > 0 &&
           b.has_active_ability?(negative_abilities)
          ret += (b.opposes?(move_user)) ? 5 : -5
        end
        beneficial_moves = {
          :Sun       => ["HealUserDependingOnWeather",
                         "RaiseUserAtkSpAtk1Or2InSun",
                         "TwoTurnAttackOneTurnInSun",
						 "TypeAndPowerDependOnWeather",
                         "TypeAndPowerDependOnWeatherThmn"],
          :Rain      => ["ConfuseTargetAlwaysHitsInRainHitsTargetInSky",
                         "ParalyzeTargetAlwaysHitsInRainHitsTargetInSky",
                         "TypeAndPowerDependOnWeather",
                         "TypeAndPowerDependOnWeatherThmn"],
          :Sandstorm => ["HealUserDependingOnSandstorm",
                         "TypeAndPowerDependOnWeather",
                         "TypeAndPowerDependOnWeatherThmn"],
          :Hail      => ["FreezeTargetAlwaysHitsInHail",
                         "StartWeakenDamageAgainstUserSideIfHail",
                         "TypeAndPowerDependOnWeather",
                         "TypeAndPowerDependOnWeatherThmn"],
          :ShadowSky => ["TypeAndPowerDependOnWeather",
                         "TypeAndPowerDependOnWeatherThmn"],
        }[weather]
        if beneficial_moves && beneficial_moves.length > 0 &&
           b.has_move_with_function?(*beneficial_moves)
          ret += (b.opposes?(move_user)) ? -5 : 5
        end
        negative_moves = {
          :Sun       => ["ConfuseTargetAlwaysHitsInRainHitsTargetInSky",
                         "ParalyzeTargetAlwaysHitsInRainHitsTargetInSky"],
          :Rain      => ["HealUserDependingOnWeather",
                         "TwoTurnAttackOneTurnInSun"],
          :Sandstorm => ["HealUserDependingOnWeather",
                         "TwoTurnAttackOneTurnInSun"],
          :Hail      => ["HealUserDependingOnWeather",
                         "TwoTurnAttackOneTurnInSun"]
        }[weather]
        if negative_moves && negative_moves.length > 0 &&
           b.has_move_with_function?(*negative_moves)
          ret += (b.opposes?(move_user)) ? 5 : -5
        end
      end
    end
    return ret
  end
  
#==============================================================================#
# Changes in this section include the following:
#	* Added Nature to Grassy Terrain checks
#	* Added Wind to Electric Terrain checks
#	* Added Faith to Misty Terrain checks
#	* Added Reason to Psychic Terrain checks
#==============================================================================#
  def get_score_for_terrain(terrain, move_user, starting = false)
    ret = 0
    ret += 4 if starting && terrain != :None && move_user.has_active_item?(:TERRAINEXTENDER)
    # Inherent effects of terrain
    each_battler do |b, i|
      next if !b.battler.affectedByTerrain?
      case terrain
      when :Electric
        # Immunity to sleep
        if b.status == :NONE
          ret += (b.opposes?(move_user)) ? -8 : 8
        end
        if b.effects[PBEffects::Yawn] > 0
          ret += (b.opposes?(move_user)) ? -10 : 10
        end
        # Check for Electric moves
        if b.has_damaging_move_of_type?(:ELECTRIC)
          ret += (b.opposes?(move_user)) ? -10 : 10
        end
		if b.has_damaging_move_of_type?(:WIND18)
          ret += (b.opposes?(move_user)) ? -10 : 10
        end
      when :Grassy
        # End of round healing
        ret += (b.opposes?(move_user)) ? -8 : 8
        # Check for Grass moves
        if b.has_damaging_move_of_type?(:GRASS)
          ret += (b.opposes?(move_user)) ? -10 : 10
        end
        if b.has_damaging_move_of_type?(:NATURE18)
          ret += (b.opposes?(move_user)) ? -10 : 10
        end
      when :Misty
        # Immunity to status problems/confusion
        if b.status == :NONE || b.effects[PBEffects::Confusion] == 0
          ret += (b.opposes?(move_user)) ? -8 : 8
        end
        # Check for Dragon moves
        if b.has_damaging_move_of_type?(:DRAGON)
          ret += (b.opposes?(move_user)) ? 10 : -10
        end
		if b.has_damaging_move_of_type?(:FAITH18)
          ret += (b.opposes?(move_user)) ? 10 : -10
        end
      when :Psychic
        # Check for priority moves
        if b.check_for_move { |m| m.priority > 0 && m.pbTarget(b.battler)&.can_target_one_foe? }
          ret += (b.opposes?(move_user)) ? 10 : -10
        end
        # Check for Psychic moves
        if b.has_damaging_move_of_type?(:PSYCHIC)
          ret += (b.opposes?(move_user)) ? -10 : 10
        end
		if b.has_damaging_move_of_type?(:REASON18)
          ret += (b.opposes?(move_user)) ? -10 : 10
        end
      end
    end
    # Held items relating to terrain
    seed = {
      :Electric => :ELECTRICSEED,
      :Grassy   => :GRASSYSEED,
      :Misty    => :MISTYSEED,
      :Psychic  => :PSYCHICSEED
    }[terrain]
    each_battler do |b, i|
      if seed && b.has_active_item?(seed)
        ret += (b.opposes?(move_user)) ? -8 : 8
      end
    end
    # Check for abilities/moves affected by the terrain
    if @trainer.medium_skill?
      abils = {
        :Electric => :SURGESURFER,
        :Grassy   => :GRASSPELT
      }[terrain]
      good_moves = {
        :Electric => ["DoublePowerInElectricTerrain"],
        :Grassy   => ["HealTargetDependingOnGrassyTerrain",
                      "HigherPriorityInGrassyTerrain"],
        :Misty    => ["UserFaintsPowersUpInMistyTerrainExplosive"],
        :Psychic  => ["HitsAllFoesAndPowersUpInPsychicTerrain"]
      }[terrain]
      bad_moves = {
        :Grassy => ["DoublePowerIfTargetUnderground",
                    "LowerTargetSpeed1WeakerInGrassyTerrain",
                    "RandomPowerDoublePowerIfTargetUnderground"]
      }[terrain]
      each_battler do |b, i|
        next if !b.battler.affectedByTerrain?
        # Abilities
        if b.has_active_ability?(:MIMICRY)
          ret += (b.opposes?(move_user)) ? -5 : 5
        end
        if abils && b.has_active_ability?(abils)
          ret += (b.opposes?(move_user)) ? -8 : 8
        end
        # Moves
        if b.has_move_with_function?("EffectDependsOnEnvironment",
                                     "SetUserTypesBasedOnEnvironment",
                                     "TypeAndPowerDependOnTerrain",
                                     "UseMoveDependingOnEnvironment")
          ret += (b.opposes?(move_user)) ? -5 : 5
        end
        if good_moves && b.has_move_with_function?(*good_moves)
          ret += (b.opposes?(move_user)) ? -5 : 5
        end
        if bad_moves && b.has_move_with_function?(*bad_moves)
          ret += (b.opposes?(move_user)) ? 5 : -5
        end
      end
    end
    return ret
  end
end